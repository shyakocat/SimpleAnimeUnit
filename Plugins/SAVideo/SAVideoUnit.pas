{$MODE OBJFPC}{$H+}
//{$DEFINE printtime}
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

 AudioFrame=Record Frame:pWaveHDR; Time:Real End;

 pVideoGraph=^VideoGraph;
 VideoGraph=Object(BaseGraph)
  afmt,vfmt:pAVFormatContext;
  VInd,AInd,SInd:Specialize List<Longint>;
  vRate,aRate,sRate,
  vBase,aBase,sBase:TAVRational;
  vCodecP,aCodecP,sCodecP:pAVCodecContext;
  vCodec ,aCodec ,sCodec:pAVCodec;
  vFrame,vFrameRGB,aFrame:pAVFrame; sFrame:PAVSubtitle;
  vTime,aTime,sTime:Real;
  vFrameFinish,aFrameFinish,sFrameFinish:Longint;
  vSwsCtx:pSwsContext;
  aSwrCtx:pSwrContext; aSize,aRet:LongWord;
  vBufLen:Longint;
  vBuf:pByte;
  hOut:hWAVEOUT;
  fmt:TWAVEFormatEx;
  audioforkid:DWord;
  TimeBias,TimeEnd,TimeNow,TimeFreeze,TimeLastV,TimeLastA:Real;
  BoolPlayVideo,BoolPlayMusic,BoolSkip,BoolPause,BoolRestA:Boolean;
  packet:TAVPacket;


  vExchange:Graph;
  aExchange:pWaveHDR;
  aStream:Specialize Queue<AudioFrame>;

  Constructor Create;
  Destructor Free;Virtual;

  Procedure AudioFree;

  Procedure Load(Const Path:Ansistring);
  Procedure Resize(_W,_H:Longint);
  Procedure VideoSwitch(_on:Boolean);
  Procedure MusicSwitch(_on:Boolean);
  Procedure Decode;
  Procedure Skip(Const TimeFall:Real);
  Procedure Pause;
  Procedure Resume;
  Procedure Volume(Const _av:Real);


  Function Reproduce:pBaseGraph;Virtual;
  Function Recovery(Env:pElement;Below:pGraph):pGraph;Virtual;
 End;

var
 debugstr:Ansistring;

implementation


 Function PlayAudioThread(pVideoObj:pVideoGraph):DWord;StdCall;
 Begin
  With pVideoObj^ Do Begin
   BoolPlayMusic:=True;
   While BoolPlayMusic Do
   Begin
    While (BoolPlayMusic)And(Not aStream.MoveR)Or(BoolPause)Or(BoolRestA) Do
    Begin
     If BoolRestA Then
     Begin
      WaveOutReset(hOut);
      If BoolPause Then WaveOutPause(hOut)
                   Else WaveOutRestart(hOut);
      BoolRestA:=False;
     End;
     Sleep(1)
    End;
    While (BoolPlayMusic)And(Not BoolRestA)And(aStream.Now<>Nil)And(aStream.Now^.Data.Time<=(DeltaTime-TimeBias)/1000-5e-2) Do aStream.MoveR;
    While (BoolPlayMusic)And(Not BoolRestA)And(aStream.Now<>Nil)And((DeltaTime-TimeBias)/1000<aStream.Now^.Data.Time) Do Sleep(1);
    If (BoolPlayMusic)And(Not BoolRestA)And(aStream.Now<>Nil) Then
    Begin
     With aStream.Now^.Data Do
     Begin
      If (Frame^.dwFlags And WHDR_PREPARED)>0 Then
       WaveOutUnPrepareHeader(hOut,Frame,SizeOf(WaveHdr));
      WaveOutPrepareHeader(hOut,Frame,SizeOf(WaveHdr));
      WaveOutWrite(hOut,Frame,SizeOf(WaveHdr));
     End;
    End
   End;
   AudioFree
  End;
 End;

 Procedure PlayAudioRelease(hOut:HWAVEOUT;msg,dwInstance,dwParam1,dwParam2:DWORD);stdcall;
 Begin
  If msg=WOM_DONE Then
  With pVideoGraph(dwInstance)^ Do
  Begin
   While aStream.Head<>aStream.Now Do aStream.HeadPop
  End
 End;

 Constructor VideoGraph.Create;
 Begin
  Width:=0;
  Height:=0;
  vExchange.Create;
  aExchange:=Nil;
  aStream.Create;
  TimeLastV:=-1;
  TimeLastA:=-1;
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
   WaveOutReset(hOut);
   WaveOutClose(hOut);
   av_Free(aFrame);
   avcodec_close(aCodecP);
   AInd.Clear
  End;
  If SInd.Size>0 Then
  Begin
   FreeMem(sFrame)
  End;
  BoolPlayVideo:=False;
  BoolPlayMusic:=False;
  AudioFree;
  avformat_close_input(@afmt);
  avformat_close_input(@vfmt);
 End;

 Procedure VideoGraph.AudioFree;
 Begin
  BoolRestA:=True;
  While aStream.Size<>0 Do Begin FreeMemory(aStream.Head^.Data.Frame); aStream.HeadPop End;
 End;

 Function VideoGraph.Reproduce:pBaseGraph;
 Begin
  Exit(@Self)
 End;


 Procedure VideoGraph.Decode;
 Var
  CatchMusic,CatchVideo:Boolean;
  tmpA:AudioFrame;
 Begin
  TimeNow:=(DeltaTime-TimeBias)/1000;
  If (TimeNow<0)Or(TimeNow>TimeEnd) Then Begin If vExchange.Width<>0 Then vExchange.Create; aExchange:=Nil End;
  If BoolPause And Not BoolSkip Then Exit;
  If BoolPlayVideo Then Begin
  If (TimeLastV>=TimeNow)And(Not BoolSkip) Then Exit;
  If (BoolSkip)Or
     (BoolPlayVideo)And(TimeNow-TimeLastV>=4)Or
     (BoolPlayMusic)And(TimeNow-TimeLastA>=4) Then Begin BoolSkip:=True;
   If VInd.Size>0 Then
   Begin av_seek_frame(vfmt,VInd[1],Trunc(TimeNow/av_q2d(vBase)),AVSEEK_FLAG_BACKWARD);
         av_seek_frame(afmt,VInd[1],Trunc(TimeNow/av_q2d(vBase)),AVSEEK_FLAG_BACKWARD) End Else
   Begin av_seek_frame(vfmt,AInd[1],Trunc(TimeNow/av_q2d(aBase)),AVSEEK_FLAG_BACKWARD);
         av_seek_frame(vfmt,AInd[1],Trunc(TimeNow/av_q2d(aBase)),AVSEEK_FLAG_BACKWARD) End;
   AudioFree End;
  End;
  CatchMusic:=(Not BoolPlayMusic)Or(TimeLastA>=TimeNow)And(Not BoolSkip)Or(BoolSkip)And(BoolPause);
  CatchVideo:=(Not BoolPlayVideo)Or(TimeLastV>=TimeNow)And(Not BoolSkip);
  {$IFDEF printtime} WriteLn('TimeNow=',TimeNow:0:2); {$ENDIF}
  While (Not CatchMusic)Or(Not CatchVideo) Do
  Begin
   If Not CatchVideo Then
   If av_read_frame(vfmt,@packet)>=0 Then
   Begin
    If packet.stream_index=AInd.top Then
    Begin
    End Else
    If packet.stream_index=VInd.top Then
    Begin
     If BoolPlayVideo Then
     Begin
      vTime:=packet.dts*av_q2d(vBase);
      {$IFDEF printtime} WriteLn('vTime=',vTime:0:2); {$ENDIF}
      avcodec_decode_Video2(vCodecP,vFrame,@vframefinish,@packet);
      If vFrameFinish>0 Then
      If vTime>=TimeNow Then
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
       vExchange.Width:=Width;
       vExchange.Height:=Height;
       vExchange.Canvas:=PCOLOR(vFrameRGB^.Data[0]);
       TimeLastV:=vTime;
       CatchVideo:=CatchVideo Or(vTime>=TimeNow);
      End
     End
    End Else
    If packet.stream_index=SInd.top Then
    Begin
    End;
   End
   Else Break;
   av_free_packet(@packet);
   If Not CatchMusic Then
   If av_read_frame(afmt,@packet)>=0 Then
   Begin
    If packet.stream_index=AInd.top Then
    Begin
     If BoolPlayMusic Then
     Begin
      aTime:=packet.dts*av_q2d(aBase);
      {$IFDEF printtime} WriteLn('aTime=',aTime:0:2); {$ENDIF}
      If (aStream.Size=0)Or(aTime>aStream.Tail^.Data.Time) Then
      Begin
       avcodec_decode_audio4(aCodecP,aFrame,@aframefinish,@packet);
       If aFrameFinish>0 Then
       Begin
        aSwrCtx:=swr_alloc_set_opts(nil,av_get_default_channel_layout(fmt.nChannels),AV_SAMPLE_FMT_S16,fmt.nSamplesPerSec,
                                        av_get_default_channel_layout(aFrame^.Channels),TAVSampleFormat(aFrame^.format),aFrame^.sample_rate,0,nil);
        swr_init(aSwrCtx);
        aSize:=aFrame^.nb_samples*av_get_bytes_per_sample(AV_SAMPLE_FMT_S16)*2;
        aExchange:=AllocMem(SizeOf(WAVEHDR)+aSize);
        aExchange^.dwBufferLength:=aSize;
        aExchange^.lpData:=PCHAR(aExchange)+SizeOf(WAVEHDR);
        aRet:=swr_convert(aSwrCtx,@aExchange^.lpData,aSize,aFrame^.Data,aFrame^.nb_samples);
        aSize:=aRet*av_get_bytes_per_sample(AV_SAMPLE_FMT_S16)*2;
        aExchange^.dwBufferLength:=aSize;
        swr_free(@aSwrCtx);
        tmpA.Frame:=aExchange;
        tmpA.Time:=aTime;
        aStream.TailAdd(tmpA);
        TimeLastA:=aTime;
        CatchMusic:=CatchMusic Or(aTime>=TimeNow);
       End
      End
     End
    End Else
    If packet.stream_index=VInd.top Then
    Begin
    End Else
    If packet.stream_index=SInd.top Then
    Begin
    End;
   End
   Else Break;
   av_free_packet(@packet);
  End;
  BoolSkip:=False;
 End;

 Procedure VideoGraph.Volume(Const _av:Real);
 Var tmp:LongWord;
 Begin
  tmp:=Round(Min(Max(0,_av),1)*$ffff);
  tmp:=tmp<<16Or tmp;
  WaveOutSetVolume(hOut,tmp)
 End;

 Procedure VideoGraph.Pause;
 Begin
  BoolPause:=True;
  BoolRestA:=True;
  TimeFreeze:=DeltaTime-TimeBias
 End;

 Procedure VideoGraph.Resume;
 Begin
  BoolPause:=False;
  BoolRestA:=True;
  TimeBias:=DeltaTime-TimeFreeze
 End;

 Procedure VideoGraph.Skip(Const TimeFall:Real);
 Begin
  BoolSkip:=True;
  BoolRestA:=True;
  TimeBias:=DeltaTime-TimeFall*1000;
  TimeFreeze:=TimeFall*1000;
 End;


 Function VideoGraph.Recovery(Env:pElement;Below:pGraph):pGraph;
 Begin
  Decode;
  If vExchange.Width=0 Then Begin
   New(Result,Create(Height,Width));
   Result^.Fill(1,1,Height,Width,Color_Black);
   Exit
  End;
  New(Result);
  Result^:=vExchange.Cut;
 End;



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

 Procedure VideoGraph.VideoSwitch(_on:Boolean);
 Begin
  BoolPlayVideo:=_on
 End;

 Procedure VideoGraph.MusicSwitch(_on:Boolean);
 Begin
  If _on Then
   Begin
    If Not BoolPlayMusic Then
    Begin
     BoolRestA:=True;
     AudioFree;
     BoolPlayMusic:=True;
    End
   End
  Else
   Begin
    BoolRestA:=True;
    BoolPlayMusic:=False;
    AudioFree;
   End
 End;

 Procedure VideoGraph.Load(Const Path:Ansistring);
 Var
  i:Longint;
  tmptext:TextGraph;
 Begin
  //1.Open Video File
  vfmt:=avformat_alloc_Context;
  If avformat_open_input(@vfmt,Pchar(Path),nil,nil)<>0 Then Exit;
  If avformat_find_stream_info(vfmt,nil)<0 Then Exit;
  afmt:=avformat_alloc_Context;
  If avformat_open_input(@afmt,Pchar(Path),nil,nil)<>0 Then Exit;
  If avformat_find_stream_info(afmt,nil)<0 Then Exit;
  TimeEnd:=vfmt^.duration/AV_TIME_BASE;
  //2.Find Streams
  VInd.Clear;
  AInd.Clear;
  SInd.Clear;
  For i:=0 to vfmt^.nb_Streams-1 Do
  Begin
   Case vfmt^.Streams[i]^.codec^.codec_type Of
    AVMEDIA_TYPE_VIDEO   :VInd.PushBack(i);
    AVMEDIA_TYPE_AUDIO   :AInd.PushBack(i);
    AVMEDIA_TYPE_SUBTITLE:SInd.PushBack(i)
   End
  End;
  //3.Get Context About Decoder & Encoder
  If VInd.Size>0 Then
  Begin
   vRate:=vfmt^.streams[VInd[1]]^.r_frame_rate;
   vBase:=vfmt^.streams[VInd[1]]^.time_base;
   vCodecP:=vfmt^.streams[VInd[1]]^.codec;
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
   aRate:=vfmt^.streams[AInd[1]]^.r_frame_rate;
   aBase:=vfmt^.streams[AInd[1]]^.time_base;
   aCodecP:=vfmt^.streams[AInd[1]]^.codec;
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
   CreateThread(Nil,0,@PlayAudioThread,@Self,0,audioforkid);
   WaveOutOpen(@hOut,WAVE_MAPPER,@fmt,DWORD(@PlayAudioRelease),DWORD(@Self),CALLBACK_FUNCTION);
   Volume(0.25);
  End;
  If SInd.Size>0 Then
  Begin
   sRate:=vfmt^.streams[SInd[1]]^.r_frame_rate;
   sBase:=vfmt^.streams[SInd[1]]^.time_base;
   sCodecP:=vfmt^.streams[SInd[1]]^.codec;
   sCodec:=avcodec_find_decoder(sCodecP^.codec_id);
   avcodec_open2(sCodecP,sCodeC,Nil);
   sFrame:=ALLOCMEM(SizeOf(sFrame));
  End;
  BoolPlayVideo:=True;
  BoolPlayMusic:=True;
  BoolSkip:=False;
  BoolPause:=False;
  TimeBias:=DeltaTime;
  TimeNow:=0;
 End;

end.
