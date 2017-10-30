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
{
 pAudioFrame=^AudioFrame;
 pVideoFrame=^VideoFrame;
 pSubtitleFrame=^SubtitleFrame;
 AudioFrame=Record Frame:pWaveHDR; Time:Real; Next:Pointer; Size:LongWord End;
 VideoFrame=Record Frame:pGraph; Time:Real; Next:Pointer End;
 SubtitleFrame=Record Frame:pavsubtitle; Time:Real; Next,Prev:Pointer End;
}

 pVideoGraph=^VideoGraph;
 VideoGraph=Object(BaseGraph)
  avfmt:pAVFormatContext;
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
  hAOut:hWAVEOUT;
  fmt:TWAVEFormatEx;
  TimeBegin,TimeEnd,TimeLast,TimeLastM:Real;
  BoolPlayVideo,BoolPlayMusic,BoolSkip,BoolRestA:Boolean;
  packet:TAVPacket;


  vExchange:Graph;
  aExchange:pWaveHDR;
  aStream:Specialize Queue<pWaveHDR>;

  Constructor Create;
  Destructor Free;
  Procedure Load(Const Path:Ansistring);
  Procedure Resize(_W,_H:Longint);
  Procedure Decode(Const TimeFall:Real);
  Procedure Skip(Const TimeFall:Real);
  Procedure Pause(_vt:Boolean);
  Procedure Volume(Const _av:Real);


  Function Reproduce:pBaseGraph;Virtual;
  Function Recovery(Env:pElement;Below:pGraph):pGraph;Virtual;
 End;

implementation


 Function PlayAudioThread(pVideoObj:pVideoGraph):DWord;StdCall;
 Begin
  With pVideoObj^ Do Begin
   BoolPlayMusic:=True;
   While BoolPlayMusic Do
   Begin
    While (BoolPlayMusic)And(aStream.Size<>0) Do
    Begin
     If BoolRestA Then
     Begin
      WaveOutReset(hAOut);
      If BoolPlayVideo Then WaveOutPause(hAOut)
                       Else WaveOutRestart(hAOut);
      BoolRestA:=False;
     End;
     Sleep(1)
    End;
    If BoolPlayMusic Then
    Begin
     If aStream.Head<>Nil Then
     With aStream.Head^ Do
     Begin
      If Data^.dwFlags and WHDR_PREPARED>0 Then
       WaveOutUnPrepareHeader(hAOut,Data,SizeOf(WaveHdr));
      WaveOutPrepareHeader(hAOut,Data,SizeOf(WaveHdr));
      WaveOutWrite(hAOut,Data,SizeOf(WaveHdr));
      FreeMemory(Data)
     End;
     aStream.HeadPop
    End
   End
  End
 End;

 Constructor VideoGraph.Create;
 Begin
  Width:=0;
  Height:=0;
  vExchange.Create;
  aExchange:=Nil;
  aStream.Create;
  TimeLast:=-1;
  TimeLastM:=-1;
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
 Var
  CatchMusic,CatchVideo:Boolean;
 Begin
  If Not BoolPlayVideo Then Exit;
  If (TimeFall<0)Or(TimeFall>TimeEnd) Then Begin vExchange.Free; FreeMemory(aExchange); Exit End;
  If (TimeLast>=TimeFall)And(Not BoolSkip) Then Exit;
  If (TimeLast>TimeFall)Or(TimeFall>TimeLast+1) Then Begin
   If VInd.Size>0 Then av_seek_frame(avfmt,VInd[1],Trunc(TimeFall/av_q2d(vBase)),AVSEEK_FLAG_BACKWARD)
                  Else av_seek_frame(avfmt,AInd[1],Trunc(TimeFall/av_q2d(aBase)),AVSEEK_FLAG_BACKWARD);
   While aStream.Size>0 Do Begin FreeMemory(aStream.Head^.Data); aStream.HeadPop End
  End;
  CatchMusic:=(Not BoolPlayMusic)Or(TimeLastM>=TimeFall);
  CatchVideo:=False;
  Repeat
   If av_read_frame(avfmt,@packet)>=0 Then
   Begin
    If packet.stream_index=AInd.top Then
    Begin
     If BoolPlayMusic Then
     Begin
      aTime:=packet.dts*av_q2d(aBase);
      avcodec_decode_audio4(aCodecP,aFrame,@aframefinish,@packet);
      If aFrameFinish>0 Then
      If (aTime>=TimeFall)And(BoolSkip)Or(Not BoolSkip) Then
      Begin
       aSwrCtx:=swr_alloc_set_opts(nil,av_get_default_channel_layout(fmt.nChannels),AV_SAMPLE_FMT_S16,fmt.nSamplesPerSec,
                                       av_get_default_channel_layout(aFrame^.Channels),TAVSampleFormat(aFrame^.format),aFrame^.sample_rate,0,nil);
       swr_init(aSwrCtx);
       aSize:=aFrame^.nb_samples*av_get_bytes_per_sample(AV_SAMPLE_FMT_S16)*2;
       While BoolRestA Do Sleep(1);
       aExchange:=AllocMem(SizeOf(WAVEHDR)+aSize);
       aExchange^.dwBufferLength:=aSize;
       aExchange^.lpData:=PCHAR(aExchange)+SizeOf(WAVEHDR);
       aRet:=swr_convert(aSwrCtx,@aExchange^.lpData,aSize,aFrame^.Data,aFrame^.nb_samples);
       aSize:=aRet*av_get_bytes_per_sample(AV_SAMPLE_FMT_S16)*2;
       aExchange^.dwBufferLength:=aSize;
       swr_free(@aSwrCtx);
       aStream.TailAdd(aExchange);
       TimeLastM:=aTime;
       CatchMusic:=aTime>=TimeFall;
      End
     End
    End Else
    If packet.stream_index=VInd.top Then
    Begin
     vTime:=packet.dts*av_q2d(vBase);
     avcodec_decode_Video2(vCodecP,vFrame,@vframefinish,@packet);
     If vFrameFinish>0 Then
     If vTime>=TimeFall Then
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
      TimeLast:=vTime;
      CatchVideo:=True;
     End
    End Else
    If packet.stream_index=SInd.top Then
    Begin
    End;
   End
   Else Break;
   av_free_packet(@packet);
   If CatchMusic And CatchVideo Then Begin BoolSkip:=False; Exit End
  Until False
 End;

 Procedure VideoGraph.Volume(Const _av:Real);
 Var tmp:LongWord;
 Begin
  tmp:=Round(Min(Max(0,_av),1)*$ffff);
  tmp:=tmp<<16Or tmp;
  WaveOutSetVolume(hAOut,tmp)
 End;

 Procedure VideoGraph.Pause(_vt:Boolean);
 Begin
  BoolPlayVideo:=_vt
 End;

 Procedure VideoGraph.Skip(Const TimeFall:Real);
 Begin
  BoolSkip:=True;
  BoolRestA:=True;
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
   If vExchange.Width=0 Then Begin
    New(Result,Create(Height,Width));
    Result^.Fill(1,1,Height,Width,Color_Black);
    Exit
   End;
   New(Result);
   Result^:=vExchange.Cut
  End
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

 Procedure VideoGraph.Load(Const Path:Ansistring);
 Var
  i:Longint;
  playaudioid:DWord;
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
   vRate:=avfmt^.streams[VInd[1]]^.r_frame_rate;
   vBase:=avfmt^.streams[VInd[1]]^.time_base;
   vCodecP:=avfmt^.streams[VInd[1]]^.codec;
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
   aRate:=avfmt^.streams[AInd[1]]^.r_frame_rate;
   aBase:=avfmt^.streams[AInd[1]]^.time_base;
   aCodecP:=avfmt^.streams[AInd[1]]^.codec;
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
   CreateThread(Nil,0,@PlayAudioThread,@Self,0,playaudioid);
   WaveOutOpen(@hAOut,WAVE_MAPPER,@fmt,0,0,CALLBACK_FUNCTION);
   Volume(0.25);
  End;
  If SInd.Size>0 Then
  Begin
   sRate:=avfmt^.streams[SInd[1]]^.r_frame_rate;
   sBase:=avfmt^.streams[SInd[1]]^.time_base;
   sCodecP:=avfmt^.streams[SInd[1]]^.codec;
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
