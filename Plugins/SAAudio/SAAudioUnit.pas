{$MODE OBJFPC}{$H+}
unit SAAudioUnit;
interface
uses
 Bass,
 BassWMA,
 BassFLAC,
 BassApe,
 BassMidi,
 Bass_Fx,
 Windows,
 SysUtils,
 CommonTypeUnit;


Var
 SAAudioTime:Int64;
Type
 SAAFFT=Array[0..512]Of Single;
Var
 TempChan:Specialize List<LongWord>;
 TempPath:Specialize List<PChar>;
 SAAChanInfo:BASS_CHANNELINFO;
// SAAFFTData:Array[0..128]Of Single;
// SAAFFTPeacks,SAAFFTNeks:Array[0..128]Of Integer;


Function SAALoadMusic(Const Path:Ansistring):LongWord;
Function SAALoadMusic(Buf:Pointer;BufLen:Longint):LongWord;
Function SAARemoveMusic(Chan:LongWord):Boolean;

Function SAAGetMusicLen(Chan:LongWord):Real;
Function SAAGetMusicPos(Chan:LongWord):Real;
Procedure SAAGetMusicFFT(Chan:LongWord;Var A:SAAFFT);
Function SAAGetMusicVol(Chan:LongWord):Single;
Function SAAGetMusicFrq(Chan:LongWord):Single;
Function SAAGetMusicPan(Chan:LongWord):Single;
Function SAAGetMusicTpo(Chan:LongWord):Single;
Function SAAGetMusicTpc(Chan:LongWord):Single;


Procedure SAASetMusicPos(Chan:LongWord;_pos:Single);
Procedure SAASetMusicVol(Chan:LongWord;_vol:Single);
Procedure SAASetMusicFrq(Chan:LongWord;_frq:Single);
Procedure SAASetMusicPan(Chan:LongWord;_pan:Single);
Procedure SAASetMusicTpo(Chan:LongWord;_tpo:Single);
Procedure SAASetMusicTpc(Chan:LongWord;_tpc:Single);

Function SAAPlayMusic(Chan:LongWord):Boolean;
Function SAAStopMusic(Chan:LongWord):Boolean;
Function SAAPauseMusic(Chan:LongWord):Boolean;
Function SAAContinueMusic(Chan:LongWord):Boolean;

Function SAAGetCPU:Single;

Function DeltaTimeA:Int64;

implementation

Function DeltaTimeA:Int64;
Begin
 Exit(GetTickCount64-SAAudioTime)
End;

Function SAALoadMusic(Const Path:Ansistring):LongWord;
Var
 FName:PChar;
 Chan:LongWord;
Begin
 FName:=Pchar(Path);
 Chan:=BASS_STREAMCREATEFILE(False,FName,0,0,BASS_STREAM_DECODE Or BASS_SAMPLE_LOOP Or BASS_STREAM_PRESCAN);
 Chan:=BASS_FX_TempoCreate(Chan,BASS_FX_FREESOURCE Or BASS_SAMPLE_LOOP);
 If Chan=0 Then Chan:=BASS_WMA_STREAMCREATEFILE(False,FName,0,0,BASS_SAMPLE_LOOP);
 If Chan=0 Then Chan:=BASS_APE_STREAMCREATEFILE(False,FName,0,0,BASS_SAMPLE_LOOP);
 If Chan=0 Then Chan:=BASS_FLAC_STREAMCREATEFILE(False,FName,0,0,BASS_SAMPLE_LOOP);
 If Chan=0 Then Chan:=BASS_MUSICLOAD(False,Pchar(Path),0,0,BASS_MUSIC_RAMP or BASS_SAMPLE_LOOP or BASS_STREAM_PRESCAN {$IFDEF UNICODE} Or BASS_UNICODE {$ENDIF},1);
 If Chan=0 Then Chan:=BASS_MIDI_STREAMCREATEFILE(False,FName,0,0,BASS_SAMPLE_LOOP,1);
 If Chan<>0 Then Begin TempChan.PushBack(Chan); TempPath.PushBack(FName) ENd;
 Exit(Chan)
End;

Function SAALoadMusic(Buf:Pointer;BufLen:Longint):LongWord;
Var
 Chan:LongWord;
Begin
 Chan:=BASS_STREAMCREATEFILE(True,Buf,0,BufLen,BASS_STREAM_DECODE Or BASS_SAMPLE_LOOP Or BASS_STREAM_PRESCAN);
 Chan:=BASS_FX_TempoCreate(Chan,BASS_FX_FREESOURCE Or BASS_SAMPLE_LOOP);
 If Chan=0 Then Chan:=BASS_WMA_STREAMCREATEFILE(True,Buf,0,BufLen,BASS_SAMPLE_LOOP);
 If Chan=0 Then Chan:=BASS_APE_STREAMCREATEFILE(True,Buf,0,BufLen,BASS_SAMPLE_LOOP);
 If Chan=0 Then Chan:=BASS_FLAC_STREAMCREATEFILE(True,Buf,0,BufLen,BASS_SAMPLE_LOOP);
 If Chan=0 Then Chan:=BASS_MUSICLOAD(True,Buf,0,BufLen,BASS_MUSIC_RAMP or BASS_SAMPLE_LOOP or BASS_STREAM_PRESCAN {$IFDEF UNICODE} Or BASS_UNICODE {$ENDIF},1);
 If Chan=0 Then Chan:=BASS_MIDI_STREAMCREATEFILE(True,Buf,0,BufLen,BASS_SAMPLE_LOOP,1);
 If Chan<>0 Then Begin TempChan.PushBack(Chan); TempPath.PushBack(nil) ENd;
 Exit(Chan)
End;

Function SAARemoveMusic(Chan:LongWord):Boolean;
Begin
 Bass_MusicFree(Chan);
 Bass_StreamFree(Chan);
 Exit(True)
End;

Function SAAGetCPU:Single;
Begin
 Exit(BASS_GetCPU)
End;

Function SAAGetMusicLen(Chan:LongWord):Real;
Begin
 Exit(BASS_ChannelBytes2Seconds(Chan,BASS_ChannelGetLength(Chan,BASS_POS_BYTE)))
End;

Function SAAGetMusicPos(Chan:LongWord):Real;
Begin
 Exit(BASS_ChannelBytes2Seconds(Chan,BASS_ChannelGetPosition(Chan,BASS_POS_BYTE)))
End;

Procedure SAAGetMusicFFT(Chan:LongWord;Var A:SAAFFT);
Begin
 If BASS_ChannelIsActive(Chan)=BASS_ACTIVE_PLAYING Then
 Begin
  BASS_ChannelGetData(Chan,@A,BASS_DATA_FFT1024);
 End;
End;

Function SAAGetMusicVol(Chan:LongWord):Single;
Begin
 BASS_ChannelGetAttribute(Chan,BASS_ATTRIB_VOL,Result);
End;

Procedure SAASetMusicVol(Chan:LongWord;_vol:Single);
Begin
 BASS_ChannelSetAttribute(Chan,BASS_ATTRIB_VOL,_vol);
End;

Function SAAGetMusicFrq(Chan:LongWord):Single;
Begin
 BASS_ChannelGetAttribute(Chan,BASS_ATTRIB_FREQ,Result);
End;

Procedure SAASetMusicFrq(Chan:LongWord;_frq:Single);
Begin
 BASS_ChannelSetAttribute(Chan,BASS_ATTRIB_FREQ,_frq);
End;

Function SAAGetMusicPan(Chan:LongWord):Single;
Begin
 BASS_ChannelGetAttribute(Chan,BASS_ATTRIB_PAN,Result)
End;

Procedure SAASetMusicPan(Chan:LongWord;_pan:Single);
Begin
 BASS_ChannelSetAttribute(Chan,BASS_ATTRIB_PAN,_pan);
End;

Procedure SAASetMusicPos(Chan:LongWord;_pos:Single);
Begin
 BASS_ChannelSetPosition(Chan,Trunc(BASS_ChannelGetLength(Chan,BASS_POS_BYTE)*_pos),BASS_POS_BYTE);
End;

Function SAAGetMusicTpo(Chan:LongWord):Single;
Begin
 BASS_ChannelGetAttribute(Chan,BASS_ATTRIB_TEMPO,Result)
End;

Procedure SAASetMusicTpo(Chan:LongWord;_tpo:Single);
Begin
 BASS_ChannelSetAttribute(Chan,BASS_ATTRIB_TEMPO,_tpo);
End;

Function SAAGetMusicTpc(Chan:LongWord):Single;
Begin
 BASS_ChannelGetAttribute(Chan,BASS_ATTRIB_TEMPO_PITCH,Result)
End;

Procedure SAASetMusicTpc(Chan:LongWord;_tpc:Single);
Begin
 BASS_ChannelSetAttribute(Chan,BASS_ATTRIB_TEMPO_PITCH,_tpc);
End;

Function SAAPlayMusic(Chan:LongWord):Boolean;
Var
 Tmp:Longint;
 FName:PChar;
 SF:BASS_MIDI_FONT;
Begin
 Tmp:=TempChan.Get[Chan]; If Tmp=0 Then Exit(False);
 FName:=TempPath[Tmp];
 SF.Font:=BASS_MIDI_FONTINIT(FName,0);
 SF.Preset:=-1;
 SF.Bank:=0;
 BASS_MIDI_STREAMSETFONTS(Chan,PBASS_MIDI_FONT(@sf),1);
 BASS_ChannelSetAttribute(Chan,BASS_ATTRIB_VOL,0.25);
 Result:=BASS_ChannelPlay(Chan,True);
 BASS_ChannelGetInfo(Chan,SAAChanInfo);
End;

Function SAAStopMusic(Chan:LongWord):Boolean;
Begin
 Exit(BASS_ChannelStop(Chan))
End;

Function SAAPauseMusic(Chan:LongWord):Boolean;
Begin
 Exit(BASS_ChannelPause(Chan))
End;

Function SAAContinueMusic(Chan:LongWord):Boolean;
Begin
 Exit(BASS_ChannelPlay(Chan,False))
End;

Begin
 If HiWord(BASS_GetVersion)<>BASSVERSION Then //Bass Version Error
 ;//  Halt(2001);
 If Not BASS_Init(-1,44100,0,0,nil) Then
 ;//  Halt(2002);
 SAAudioTime:=GetTickCount64;
end.
