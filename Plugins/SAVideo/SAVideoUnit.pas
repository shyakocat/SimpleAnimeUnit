{$IFDEF NORMAL}
  {$H-,I+,OBJECTCHECKS-,Q-,R-,S-}
{$ENDIF NORMAL}
{$IFDEF DEBUG}
  {$H-,I+,OBJECTCHECKS-,Q+,R+,S-}
{$ENDIF DEBUG}
{$IFDEF RELEASE}
  {$H-,I-,OBJECTCHECKS-,Q-,R-,S-}
{$ENDIF RELEASE}
{$MODE OBJFPC}{$H+}
unit SAVideoUnit;
interface
uses SimpleAnimeUnit2,
 CommonTypeUnit,
 libavcodec,
 libavformat,
 libavutil,
 libavutil_frame,
 libavutil_mem,
 libavutil_pixfmt,
 libavutil_rational,
 libavutil_samplefmt,
 libavutil_channel_layout,
 libswscale,
 libswresample,
 SysUtils,
 MMSystem,
 Windows,
 math;

Type
 ByteArr=Array Of Byte;
 RealArr=Array Of Real;

Type
 pAudioFrame=^AudioFrame;
 pVideoFrame=^VideoFrame;
 pSubtitleFrame=^SubtitleFrame;
 AudioFrame=Record Frame:pWaveHDR; Time:Real; Next:Pointer; Size:LongWord End;
 VideoFrame=Record Frame:pGraph; Time:Real; Next:Pointer End;
 SubtitleFrame=Record Frame:pavsubtitle; Time:Real; Next,Prev:Pointer End;


 VideoGraph=Object(BaseGraph)
  avfmt:pAVFormatContext;
  VInd,AInd,SInd:Specialize List<Longint>;
  vRate,aRate,sRate,
  vBase,aBase,sBase:TAVRational;
  vCodecP,aCodecP,sCodecP:pAVCodecContext;
  vCodec ,aCodec ,sCodec:pAVCodec;
  vFrame,vFrameRGB,aFrame:pAVFrame;
  sFrame:PAVSubtitle;
  vTime,aTime,sTime:Real;
  vFrameFinish,aFrameFinish,sFrameFinish:Longint;
  vSwsCtx:pSwsContext;
  vBufLen:Longint;
  vBuf:pByte;
  pVS,pVN,pVT:pVideoFrame;
  pAS,pAN,pAT:pAudioFrame;
  pSS,pSN,pST:pSubtitleFrame;
  hAOut:hWAVEOUT;
  fmt:TWAVEFormatEx;
  TimeBegin,TimeEnd,TimePREV,TimeSUCC:Real;
  BoolPlayVideo,BoolPlayMusic,BoolSkip:Boolean;
  packet:TAVPacket;


  Exchange,Cache:Graph;

  Constructor Create;
  Destructor Free;
  Procedure Load(Const Path:Ansistring);
  Procedure Resize(_W,_H:Longint);
  Procedure Decode(Const TimeFall:Real);
  Procedure Skip(Const TimeFall:Real);


{
  Function NewVideo(_w,_h:Longint):pVideoFrame;
  Function CrtVideo(_w,_h:Longint):pVideoFrame;
  Procedure DelVideo(pV:pVideoFrame);
  Procedure DelVideoAll;
  Procedure FreeVideo(pV:pVideoFrame);
  Procedure FreeVideoAll;
  Function NewAudio(_s:LongWord):pAudioFrame;
  Function CrtAudio(_s:LongWord):pAudioFrame;
  Procedure DelAudio(pA:pAudioFrame);
  Procedure DelAudioAll;
  Procedure FreeAudio(pA:pAudioFrame);
  Procedure FreeAudioAll;
  Function NewSubtitle(pSb:pAVSUBTITLE):pSubtitleFrame;
  Procedure FreeSubtitle(pS:pSubtitleFrame);
  Procedure FreeSubtitleAll;
  Function LenToSec(Len:LongWord):Real;
  Function SecToLen(Sec:Real):LongWord;
  Procedure PauseAudio(p:Boolean);
  Function GetAudioTimS:LongWord;
  Function GetAudioPosS:LongWord;
  Function GetAudioTim:Real;
  Function GetAudioPos:Real;
  Function GetVideoLen:Real;
  Function GetVideoPos:Real;
  Function GetAudioVolS:Word;
  Function GetAudioVol:Real;
  Procedure SetVideoPos(_p:Real);
  Procedure SetAudioVolS(_v:Word);
  Procedure SetAudioVol(_v:Real);
  Procedure PlayAudioProc(h:HWAVEOUT;msg,inst,wp,lp:LongWord);StdCall;
  Procedure PlayAudioThread;StdCall;
  Procedure OutAudio;
  Procedure GetAudioData(Var Wave:byteArr;_P,_S:LongWord);
  Procedure DrawSubtitleAV(avsb:pAVSubtitle);
  Procedure DrawSubtitle;
  Procedure DrawVideoAV(pV:pVideoFrame);
  Procedure DrawVideo;
}

  Function Reproduce:pBaseGraph;Virtual;
  Function Recovery(Env:pElement;Below:pGraph):pGraph;Virtual;
 End;

implementation



 Constructor VideoGraph.Create;
 Begin
  Width:=0;
  Height:=0;
  Exchange.Create;
  Cache.Create;
  TimePREV:=-1;
  TimeSUCC:=-1;
  av_register_all;
 End;

 Destructor VideoGraph.Free;
 Begin
  If VInd.Size>0 Then
  Begin
   av_Free(vBuf);
   av_Free(vFrame);
   av_Free(vFrameRGB);
   avcodec_close(vCodecP);
   VInd.Clear;
  End;
  If AInd.Size>0 Then
  Begin
   WaveOutReset(hAOut);
   WaveOutClose(hAOut);
   av_Free(aFrame);
   avcodec_close(aCodecP);
   AInd.Clear
  End;
  If SInd.Size>0 Then
  Begin
   FreeMem(sFrame)
  End;
  avformat_close_input(@avfmt);
 End;

 Function VideoGraph.Reproduce:pBaseGraph;
 Begin
  Exit(@Self)
 End;

 Procedure VideoGraph.Decode(Const TimeFall:Real);
 Begin
  If (TimeFall<0)Or(TimeFall>TimeEnd) Then Begin Exchange.Free; Exit End;
  If (TimePREV<=TimeFall)And(TimeFall<=TimeSUCC) Then Exit;
  If (TimeFall<TimePREV)Or(TimeSUCC+1<TimeFall) Then Begin
   av_seek_frame(avfmt,VInd.Size-1,Trunc(TimeFall/av_q2d(vBase)),AVSEEK_FLAG_BACKWARD);
   TimePREV:=-1; Exchange.Free;
   TimeSUCC:=-1;
  End;
  Repeat
   If av_read_frame(avfmt,@packet)>=0 Then
   Begin
    If packet.stream_index=AInd.top Then
    Begin

    End Else
    If packet.stream_index=VInd.top Then
    Begin
     vTime:=packet.dts*av_q2d(vBase);
     avcodec_decode_Video2(vCodecP,vFrame,@vframefinish,@packet);
     If vFrameFinish>0 Then
     Begin
      vSwsCtx:=sws_getcontext(vFrame^.Width,
                              vFrame^.Height,
                              vCodecP^.pix_fmt,
                              Width,Height,
                              AV_PIX_FMT_BGRA,
                              SWS_FAST_BILINEAR,
                              nil,nil,nil);
      sws_scale(vSwsCtx,
                vFrame^.Data,
                vFrame^.linesize,
                0,vFrame^.Height,
                vFrameRGB^.data,
                vFrameRGB^.linesize);
      sws_FreeContext(vSwsCtx);
      If TimeSUCC=-1 Then
       If vTime>TimeFall Then Exit
       Else Begin TimeSUCC:=vTime; Cache.Width:=Width; Cache.Height:=Height; Cache.Canvas:=PCOLOR(vFrameRGB^.Data[0]) End
      Else
       Begin
        TimePREV:=TimeSUCC; TimeSUCC:=vTime;
        If (TimePREV<>-1)And(TimeSUCC>TimeFall) Then Begin
         FreeMemory(Exchange.Canvas); Exchange:=Cache.Cut; Exit End;
        Cache.Canvas:=PCOLOR(vFrameRGB^.Data[0])
       End
     End
    End Else
    If packet.stream_index=SInd.top Then
    Begin
    End;
   End
   Else Break;
   av_free_packet(@packet)
  Until False
 End;

 Procedure VideoGraph.Skip(Const TimeFall:Real);
 Begin
  BoolSkip:=True;
  TimeBegin:=Trunc(DeltaTime-TimeFall*1000);
 End;

 Function VideoGraph.Recovery(Env:pElement;Below:pGraph):pGraph;
 Var
  TimeNow:Real;
 Begin
  If BoolPlayVideo Then
  Begin
   TimeNow:=(DeltaTime-TimeBegin)/1000;
   Decode(TimeNow);
   If Exchange.Width=0 Then Begin
    New(Result,Create(Height,Width));
    Result^.Fill(1,1,Height,Width,Color_Black);
    Exit
   End;
   New(Result);
   Result^:=Exchange.Cut
  End
 End;

{
 Function VideoGraph.CrtVideo(_w,_h:Longint):pVideoFrame;
 Begin
  New(Result);
  With Result^ Do
  Begin
   New(Frame,Create(_h,_w));
   Time:=0;
   Next:=Nil
  End
 End;

 Function VideoGraph.NewVideo(_w,_h:Longint):pVideoFrame;
 Begin
  If (PVS^.Next<>Nil)And(PVS^.Frame^.Width=_w)And(PVS^.Frame^.Height=_h) Then
  Begin
   Result:=pVS;
   pVS:=pVS^.Next;
   Result^.Time:=0;
   Result^.Next:=Nil
  End
  Else Exit(CrtVideo(_w,_h))
 End;

 Procedure VideoGraph.DelVideo(pV:pVideoFrame);
 Begin
  pV^.Time:=0;
  pV^.Next:=pVS;
  pVS:=pV
 End;

 Procedure VideoGraph.DelVideoAll;
 Begin
  While pVN^.Next<>Nil Do
  Begin
   pVT:=pVN;
   pVN:=pVN^.Next;
   DelVideo(pVT)
  End
 End;

 Procedure VideoGraph.FreeVideo(pV:pVideoFrame);
 Begin
  pV^.Frame^.Free;
  FreeMem(pV)
 End;

 Procedure VideoGraph.FreeVideoAll;
 Begin
  DelVideoAll;
  While pVS^.Next<>Nil Do
  Begin
   pVT:=pVS;
   pVS:=pVS^.Next;
   FreeVideo(pVT)
  End
 End;


 Function VideoGraph.CrtAudio(_s:LongWord):pAudioFrame;
 Begin
  New(Result);
  With Result^ Do
  Begin
   Frame:=ALLOCMEM(_s+SizeOf(WAVEHDR));
   Frame^.dwBufferLength:=_S;
   Frame^.lpData:=PChar(Frame)+SizeOf(WAVEHDR);
   Time:=0;
   Next:=Nil;
   Size:=_S
  End
 End;

 Function VideoGraph.NewAudio(_s:LongWord):pAudioFrame;
 Begin
  If (pAS^.Next<>Nil)And(pAS^.Size>=_S) Then
  Begin
   Result:=pAS;
   pAS:=pAS^.Next;
   Result^.Time:=0;
   Result^.Next:=Nil
  End
  Else Exit(CrtAudio(_s))
 End;

 Procedure VideoGraph.DelAudio(pA:pAudioFrame);
 Begin
  pA^.Time:=0;
  pA^.Next:=pVS;
  pAS:=pA
 End;

 Procedure VideoGraph.DelAudioAll;
 Begin
  While pAN^.Next<>Nil Do
  Begin
   pAT:=pAN;
   pAN:=pAN^.Next;
   DelAudio(pAT)
  End
 End;

 Procedure VideoGraph.FreeAudio(pA:pAudioFrame);
 Begin
  FreeMem(pA^.Frame);
  FreeMem(pA)
 End;

 Procedure VideoGraph.FreeAudioAll;
 Begin
  DelAudioAll;
  While pAS^.Next<>Nil Do
  Begin
   pAT:=pAS;
   pAS:=pAS^.Next;
   FreeAudio(pAT)
  End
 End;

 Function VideoGraph.NewSubtitle(pSb:pAVSubTitle):pSubtitleFrame;
 Begin
  Result:=ALLOCMEM(SizeOf(SubtitleFrame));
  Result^.Frame:=ALLOCMEM(SizeOf(TAVSUBTITLE));
  Move(pSb^,Result^.Frame^,SizeOf(TAVSUBTITLE))
 End;

 Procedure VideoGraph.FreeSubtitle(pS:pSubtitleFrame);
 Begin
  FreeMem(pS^.Frame);
  FreeMem(pS)
 End;

 Procedure VideoGraph.FreeSubtitleAll;
 Begin
  While pSS<>Nil Do
  Begin
   pST:=pSS^.Next;
   FreeSubtitle(PSS);
   pSS:=pST
  End
 End;

 Function VideoGraph.LenToSec(Len:LongWord):Real;
 Begin
  Result:=Len/Fmt.nSamplesPerSec
 End;

 Function VideoGraph.SecToLen(Sec:Real):LongWord;
 Begin
  Result:=Trunc(Sec*fmt.nSamplesPerSec)
 End;


 Procedure VideoGraph.PauseAudio(p:Boolean);
 Begin
  If P Then WaveOutPause(hAOut)
       Else WaveOutRestart(hAOut)
 End;

 Function VideoGraph.GetAudioTimS:LongWord;
 Var Tim:MMTime;
 Begin
  WaveOutGetPosition(hAOut,@Tim,SizeOf(Tim));
  Result:=Tim.Ms
 End;

 Function VideoGraph.GetAudioPosS:LongWord;
 Begin
  Result:=GetAudioTimS Div fmt.nBlockAlign
 End;

 Function VideoGraph.GetAudioTim:Real;
 Begin
  Exit(LenToSec(GetAudioTimS))
 End;

 Function VideoGraph.GetAudioPos:Real;
 Begin
  Exit(LenToSec(GetAudioPosS))
 End;

 Function VideoGraph.GetVideoLen:Real;
 Begin
  Exit(TimeEnd)
 End;

 Function VideoGraph.GetVideoPos:Real;
 Begin
  If (AInd.Size>0)And(pAT<>pAN) Then
  Begin
   Result:=GetAudioPos;
   TimeBegin:=DeltaTime-Result
  End
  Else If VInd.Size>0 Then
   Result:=DeltaTime-TimeBegin
  Else
   Result:=0;
  Result:=Result+TimeSkip;
  if Result<0 Then Result:=0;
  If Result>GetVideoLen Then Result:=GetVideoLen
 End;

 Function VideoGraph.GetAudioVolS:Word;
 Var tVol:LongWord;
 Begin
  WaveOutGetVolume(hAOut,@tVol);
  Result:=(HI(tVol)+LO(tVol))Div 2
 End;

 Function VideoGraph.GetAudioVol:Real;
 Begin
  Exit(GetAudioVolS/$ffff)
 End;

 Procedure VideoGraph.SetVideoPos(_p:Real);
 Begin
  TimeSkip:=_p;
  If VInd.Size>0 Then
  Begin
   DelVideoAll;
   av_seek_frame(avfmt,VInd.Size-1,Trunc(TimeSkip/av_q2d(vBase)),AVSEEK_FLAG_BACKWARD)
  End
  Else If AInd.Size>0 Then
   av_seek_frame(avfmt,AInd.Size-1,Trunc(TimeSkip/av_q2d(aBase)),AVSEEK_FLAG_BACKWARD);
  BoolSkip:=True;
  BoolReset:=True;
  BoolFrame:=False;
 End;

 Procedure VideoGraph.SetAudioVolS(_v:Word);
 Var tVol:LongWord;
 Begin
  tVol:=_v<<16or _v;
  WaveOutSetVolume(hAOut,tVol)
 End;

 Procedure VideoGraph.SetAudioVol(_v:Real);
 Begin
  SetAudioVol(Min(Max(0,_v),1)*$ffff)
 End;

 Procedure VideoGraph.OutAudio;
 Var Remain:Longint;
 Begin
  If BoolPlay Then
  While pAN^.Next=Nil Do
  Begin
   If BoolReset Then
   Begin
    WaveOutReset(hAOut);
    PauseAudio(BoolPause);
    BoolReset:=False
   End;
   Sleep(1);
   pAN:=pAN^.Next;
   With pAN^ Do
   With Frame^ Do
   Begin
    If (dwFlags And WHDR_PREPARED)>0 Then
     WaveOutUnprepareHeader(hAOut,Frame,SizeOf(WAVEHDR));
    WaveOutPrepareHeader(hAOut,Frame,SizeOf(WAVEHDR));
    WaveOutWrite(hAOut,Frame,SizeOf(WAVEHDR))
   End
  End;
 End;

 Procedure VideoGraph.GetAudioData(Var Wave:byteArr;_P,_S:LongWord);
 Var
  srcp,desp,nowp:Longint;
  posf,sizf:LongWord;

  Procedure MoveAudioData(pA:pAudioFrame);
  Begin
   While pA^.Next<>Nil Do
   Begin
    posf:=SecToLen(pA^.Time)*4;
    sizf:=pA^.Size;
    srcp:=Max(_P-posf,0);
    desp:=Max(posf-_P,0);
    nowp:=Max(Sizf-srcp-max(posf+sizf-_P-_S,0),0);
    If nowp>0 Then Move((pA^.frame^.lpData+srcp)^,Wave[desp],nowp);
    pA:=pA^.Next
   End
  End;

 Begin
  _P:=_P*4;
  _S:=_S*4;
  SetLength(Wave,_S*4);
  MoveAudioData(pAT);
  MoveAudioData(pAS)
 End;

 Procedure VideoGraph.DrawSubtitleAV(avsb:pAVSubtitle);
 Var
  i,j,k:Longint;
  ShowStr,ShowStrLn:Ansistring;
  TextDrawer:TextGraph;
 Begin
  With avsb^ Do
  Begin
   For i:=0 to num_rec0ts-1 Do
   With avsb^.rects[i]^ Do
   Begin
    case ttype Of
     SUBTITLE_TEXT:showstr:=Text;
     SUBTITLE_ASS:Begin
       k:=0;
       For j:=0 to Length(Ass)-1 Do
       Begin
        If Ass[j]=',' Then Inc(k);
        If k=9 Then Break
       End;
       showstr:=Copy(Ass,j+2,Length(Ass)-j-1)
      End
    End;
    ShowStr:=UTF8ToAnsi(ShowStr);
    k:=2;
    For j:=1 to Length(ShowStr) Do
     Inc(K,Ord(ShowStr[j]='\'));
    Repeat
     j:=Pos('\',ShowStr);
     If J>0 Then
      Begin
       ShowStrLn:=Copy(ShowStr,1,J-1);
       Delete(ShowStr,1,J+1)
      End
     Else
      Begin
       ShowStrLn:=ShowStr;
       ShowStr:=''
      End;
     TextDrawer.Create(ShowStrLn);
     TextDrawer.SetSize(Max(10,Exchange.Height Div 20));
     TextDrawer.FontColor:=Color_White;
     TextDrawer.WriteTo(Exchange,Exchange.Height-TextDrawer.Height,(Exchange.Width-TextDrawer.Width)Div 2);
     TextDrawer.Free;
    Until J=0;
   End
  End
 End;

 Procedure VideoGraph.DrawSubtitle;
 Var
  TimeCur:Real;
  pS:pSubtitleFrame;
  avsb:PAVSubtitle;
 Begin
  TimeCur:=GetVideoPos;
  pS:=pSS;
  While pS^.Next<>Nil Do pS:=pS^.Next;
  While pS^.Prev<>Nil Do
  Begin
   avsb:=pS^.Frame;
   If avsb<>Nil Then
    If (avsb^.start_display_time/1000+pS^.Time<=TimeCur)And
       (avsb^.end_display_time/1000+pS^.Time>=TimeCur) Then
     Begin
      DrawSubtitleAV(avsb);
      Break
     End
  End
 End;

 Procedure VideoGraph.DrawVideoAV(pV:pVideoFrame);
 Begin
  Exchange.Free;
  If pV=Nil Then Begin Exchange.Create; Exit End;
  Exchange:=pV^.Frame^.Cut;
  If (Exchange.Width>0)And(Exchange.Height>0) Then
   Opt_Scale(Exchange,Height/Exchange.Height,Width/Exchange.Width)
 End;

 Procedure VideoGraph.DrawVideo;
 Begin
  If BoolPlay Then

 End;

 Procedure VideoGraph.PlayAudioProc(h:HWAVEOUT;msg,inst,wp,lp:LongWord);StdCall;
 Var C:pAudioFrame;
 Begin
  if msg=WOM_DONE Then
  If pAT<>Nil Then
  Begin
   C:=pAT;
   pAT:=pAT^.Next;
   DelAudio(C)
  End
 End;

 Procedure VideoGraph.PlayAudioThread;StdCall;
 Begin
  BoolPlay:=True;
  While BoolPlay Do OutAudio
 End;
}

 Procedure VideoGraph.Resize(_W,_H:Longint);
 Begin
//  Width:=_W>>4<<4;
//  Height:=_H>>4<<4;
  Width:=_W;
  Height:=_H;
  If VInd.Size>0 Then
  Begin
   av_Free(vBuf);
   vBufLen:=avpicture_get_size(AV_PIX_FMT_BGRA,Width,Height);
   vBuf:=av_malloc(vBufLen);
   avpicture_fill(pAVPicture(vFrameRGB),vBuf,AV_PIX_FMT_BGRA,Width,Height)
  End
 End;

 Procedure VideoGraph.Load(Const Path:Ansistring);
 Var
  i:Longint;
  _tid:DWord;
  tmptext:TextGraph;
 Begin
  //1.Open Video File
  avfmt:=avformat_alloc_Context;
  If avformat_open_input(@avfmt,Pchar(Path),nil,nil)<>0 Then Exit;
  If avformat_find_stream_info(avfmt,nil)<0 Then Exit;
  TimeEnd:=avfmt^.duration/AV_TIME_BASE;
  //2.Find Streams
  VInd.Clear;
  AInd.Clear;
  SInd.Clear;
  For i:=0 to avfmt^.nb_Streams-1 Do
  Begin
   Case avfmt^.Streams[i]^.codec^.codec_type Of
    AVMEDIA_TYPE_VIDEO   :VInd.PushBack(i);
    AVMEDIA_TYPE_AUDIO   :AInd.PushBack(i);
    AVMEDIA_TYPE_SUBTITLE:SInd.PushBack(i)
   End
  End;
  //3.Get Context About Decoder & Encoder
  If VInd.Size>0 Then
  Begin
   vRate:=avfmt^.streams[VInd.Size-1]^.r_frame_rate;
   vBase:=avfmt^.streams[VInd.Size-1]^.time_base;
   vCodecP:=avfmt^.streams[VInd.Size-1]^.codec;
   vCodec:=avcodec_find_decoder(vCodecP^.codec_id);
   avcodec_open2(vCodecP,vCodeC,Nil);
   vFrame:=avcodec_alloc_frame;
   vFrameRGB:=avcodec_alloc_frame;
   Width:=vCodecP^.Width;
   Height:=vCodecP^.Height;
   vBufLen:=avpicture_get_size(AV_PIX_FMT_BGRA,Width,Height);
   vBuf:=av_malloc(vBufLen);
   avpicture_fill(pAVPicture(vFrameRGB),vBuf,AV_PIX_FMT_BGRA,Width,Height);
  End;
  If AInd.Size>0 Then
  Begin
   aRate:=avfmt^.streams[AInd.Size-1]^.r_frame_rate;
   aBase:=avfmt^.streams[AInd.Size-1]^.time_base;
   aCodecP:=avfmt^.streams[AInd.Size-1]^.codec;
   aCodec:=avcodec_find_decoder(aCodecP^.codec_id);
   avcodec_open2(aCodecP,aCodeC,Nil);
   aFrame:=avcodec_alloc_frame;
   with fmt Do
   Begin
    nChannels:=2;
    wBitsPerSample:=16;
    nSamplesPerSec:=aCodecP^.Sample_rate;
    wFormatTag:=WAVE_FORMAT_PCM;
    nBlockAlign:=wBitsPerSample*nChannels>>3;
    nAvgBytesPerSec:=nBlockAlign*nSamplesPerSec;
    cbSize:=0
   End;
//   CreateThread(Nil,0,Pointer(DWORD(@PlayAudioThread)),Nil,0,_tid);
//   WaveOutOpen(@hAOut,WAVE_MAPPER,@fmt,DWord(@PlayAudioProc),0,CALLBACK_FUNCTION);
//   SetAudioVol(0.25);
  End;
  If SInd.Size>0 Then
  Begin
   sRate:=avfmt^.streams[SInd.Size-1]^.r_frame_rate;
   sBase:=avfmt^.streams[SInd.Size-1]^.time_base;
   sCodecP:=avfmt^.streams[SInd.Size-1]^.codec;
   sCodec:=avcodec_find_decoder(sCodecP^.codec_id);
   avcodec_open2(sCodecP,sCodeC,Nil);
   sFrame:=ALLOCMEM(SizeOf(sFrame));
  End;
  BoolPlayVideo:=True;
  BoolPlayMusic:=True;
  BoolSkip:=False;
  TimeBegin:=DeltaTime;
 End;

end.