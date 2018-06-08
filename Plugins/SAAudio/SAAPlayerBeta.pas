{$MODE OBJFPC}{$H+}
{$APPTYPE GUI}
uses SimpleAnimeUnit2,CommonTypeUnit,SAAudioUnit,Math;

Var
 MusicPath,
 PicturePath,
 LyricsPath:Ansistring;
 Id:LongWord;
 StdWidth,StdHeight,LimSize:Longint;

Procedure User;
Var
 MusicL:SList;
Begin
 StdWidth:=400;
 StdHeight:=400;
 LimSize:=200;
 Init('SAAPlayerBeta',StdWidth,StdHeight);
 MusicL.Clear;
 MusicL.PushBack('所有文件'#0'*.wav;*.mp3;*.ogg;*.wma;*.ape;*.aac;*.mp3;*.m4a;*.flac'#0);
 MusicL.PushBack('WAV文件 (*.wav)'#0'*.wav'#0);
 MusicL.PushBack('MP3文件 (*.mp3)'#0'*.mp3'#0);
 MusicL.PushBack('OGG文件 (*.ogg)'#0'*.ogg'#0);
 MusicL.PushBack('WMA文件 (*.ape)'#0'*.wma'#0);
 MusicL.PushBack('APE文件 (*.ape)'#0'*.ape'#0);
 MusicL.PushBack('AAC文件 (*.aac)'#0'*.aac'#0);
 MusicL.PushBack('MP2文件 (*.mp2)'#0'*.mp2'#0);
 MusicL.PushBack('M4A文件 (*.m4a)'#0'*.m4a'#0);
 MusicL.PushBack('FLAC文件 (*.flac)'#0'*.flac'#0);
 MusicPath:=SelectFile(MusicL,sf_Open);
 MusicL.Clear;
End;

Procedure Main;
Var
 MLen:Single;
 i,j:Longint;
 FileSpider:SList;
 Tit:TextGraph;
 Pic:Graph;
 Wav:Graph;
 War:TextGraph;
 LastWar:Int64;
 FFTData:SAAFFT;
 U:Array[0..512]Of Integer;
 vol:Single=0.25;
 tmp:Ansistring;
 EM:SAMouseEvent;
 EK:SAKeyEvent;

 Function TimeString(T:Single):Ansistring;
 Var Tmp:Ansistring; _T:Longint;
 Begin
  _T:=Round(T);
  Str(_T div 60,Result);
  While Length(Result)<2 Do Result:='0'+Result;
  Str(_T mod 60,Tmp);
  While Length(Tmp)<2 Do Tmp:='0'+Tmp;
  Exit(Result+':'+Tmp);
 End;

Begin
 Id:=SAALoadMusic(MusicPath);
 If Id=0 Then Exit;
 For i:=Length(MusicPath)Downto 1 Do If MusicPath[i]='.' Then Break;
 If (i>0)And(MusicPath[i]='.') Then
 Begin
  FileSpider:=GetFile(Copy(MusicPath,1,i)+'*');
  For j:=1 to FileSpider.Size Do
   Case Copy(FileSpider[j],Length(FileSpider[j])-2,3) Of
    'lrc':LyricsPath:=FileSpider[j];
    'jpg','bmp','png':PicturePath:=FileSpider[j]
  End;
  For j:=i-1 Downto 1 DO
   If MusicPath[j]in ['\','/'] Then Break;
  If (J>0)And(MusicPath[j]in ['/','\']) Then SetTitle(Copy(MusicPath,J+1,i-j-1))
 End;
 Tit.Create('正在播放的是：'+MusicPath);
 Tit.SetSize(15);
 Tit.FontColor:=RGBA(159,122,182,255);
 If PicturePath<>'' Then
 Begin
  Pic.Create;
  Pic.Load(PicturePath);
  Pic:=Pic.Adapt(StdHeight,StdWidth);
 End
 Else
 Begin
  Pic.Create(StdHeight,StdWidth);
  Pic.Fill(1,1,Pic.Height,Pic.Width,Color_Black);
 End;
 Wav.Create(StdHeight,StdWidth);
 Wav.Fill(1,1,Wav.Height,Wav.Width,Color_White);
 War.Create;
 MLen:=SAAGetMusicLen(Id);
 SAAPlayMusic(Id);
 While TestMouse(EM) Do;
 While TestKey(EK) Do;
 Repeat
  While TestMouse(EM) Do
  Begin
   tmp:=TimeString(MLen*(EM.X/StdWidth))+'/'+TimeString(MLen);
   If MACMouseDown Then
   Begin
    War.Create(Tmp+' ');
    War.SetSize(60);
    War.Bold:=True;
    War.FontColor:=Color_Cyan;
    LastWar:=DeltaTime
   End;
   If EM.Release Then
   Begin
    If EM.Y<StdHeight*0.3 Then
    Begin
     SAASetMusicPOS(Id,EM.X/StdWidth)
    End
   End
  End;
  While TestKey(EK) Do
  Begin
   If EK.Release Then
    If EK.Key=38 Then
     Begin
      vol:=Min(Vol+0.1,1);
      SAASetMusicVol(Id,vol);
      Str(Trunc(vol*100),Tmp);
      War.Create(Tmp+'% ');
      War.SetSize(60);
      War.Bold:=True; //Bug For Width-Count While Bold Is Applying   Add Space For Temperory Solve
      War.FontColor:=Color_Cyan;
      LastWar:=DeltaTime
     End
    Else If EK.Key=40 Then
     Begin
      vol:=Max(Vol-0.1,0);
      SAASetMusicVol(Id,vol);
      Str(Trunc(vol*100),Tmp);
      War.Create(Tmp+'% ');
      War.SetSize(60);
      War.Bold:=True;
      War.FontColor:=Color_Cyan;
      LastWar:=DeltaTime
     End
  End;
  Lock;
  SAAGetMusicFFT(Id,FFTData);
  For i:=0 to LimSize-1 Do
  Begin
   j:=Min(StdHeight,Trunc(Abs(FFTData[i])*StdHeight));
   If J>=U[i] Then U[i]:=J Else U[i]:=U[i]-3;
   With Wav Do Fill(Height-U[i],Trunc(i/LimSize*Width),Height,Trunc((i+1)/LimSize*Width)-1,Color_LGreen)
  End;
  Opt_Alpha(Wav,0.6);
  DrawTo(Pic,Screen,0,0);
  BlendTo(Wav,Screen,0,0);
  Tit.WriteTo(Screen,5,Round(DeltaTime mod 20000/20000*(Tit.Width+StdWidth)-Tit.Width));
  Screen.Fill(1,1,3,Trunc(SAAGetMusicPos(Id)/SAAGetMusicLen(Id)*StdWidth),Color_LBlue);
  If War.Text<>'' Then War.WriteTo(Screen,Round((Screen.Height-War.Height)*0.4),Round((Screen.Width-War.Width)*0.55));
  If DeltaTime-LastWar>3000 Then War.Create;
  UnLock;
 Until Not ConsoleUsing;
 SAAStopMusic(Id);
 SAARemoveMusic(Id)
End;

Begin
 User;
 Main
End.
