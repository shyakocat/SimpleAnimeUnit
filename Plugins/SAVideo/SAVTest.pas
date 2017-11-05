Uses SimpleAnimeUnit2,SAVideoUnit,SysUtils;
Var
 a:VideoGraph;
 FPS,TIM:TextGraph;
 Id,key:Longint;
 SA:SimpleAnime;
 LG:AnimeLog;
 BoolTf:Boolean=False;
 tf:Real;
 tP,x,y,z:Longint;


Procedure CmdInput;
Var Tmp:Real;
Begin
 Repeat
  ReadLn(tmp);
  BoolTf:=True; tf:=tmp;
 Until False
End;


Procedure MouseControl(Env:pElement;Below:pGraph;Const E:SAMouseEvent;inner:ShortInt);

 function getTime(Const _t:Real):Ansistring;
 var tmp1,tmp2:Ansistring; t:Longint;
 Begin
  t:=Round(_t);
  Str(t Div 60,tmp1); While Length(tmp1)<2 Do tmp1:='0'+tmp1;
  Str(t mod 60,tmp2); While Length(tmp2)<2 Do tmp2:='0'+tmp2;
  Exit(tmp1+':'+tmp2)
 End;

Begin
 If MACMouseDown Then
 Begin
  TIM.Create(getTime(a.TimeEnd*(E.Y/Below^.Width)));
  TIM.FontSize:=50;
  TIM.Bold:=True;
  TIM.Update
 End
 Else TIM.Create;
 If E.Release Then
  a.Skip(a.TimeEnd*(E.Y/Below^.Width))
End;

Procedure KeyControl(Env:pElement;Below:pGraph;Const E:SAKeyEvent);
Begin
 If (E.Key=32)And(E.Release) Then
  If a.BoolPause Then a.Resume
  Else a.Pause
End;


Begin
 a.Create;
// a.Load('Test.mp4');
// a.Load('Test2.flv');
 a.Load('Test3.mkv');
// a.Load('Test5.wmv');
// a.Load('Test6.webm');
// a.Resize();
// a.Width:=760;
// a.Height:=360
// a.Free;
// a.Load('E:\FFOutput\Trouble(Lyrics).mp4');
// a.Load('E:\FFOutput\Horizon(full).mp4');
 A.Resize(1280,720);
 A.Resize(640,360);
 Init('SAVTest',a.Width,a.Height);
// a.Volume(1);
 Id:=Main.AddObj(A);
 LG.Create;
 LG.KeyEvent:=@KeyControl;
 LG.MouseEvent:=@MouseControl;
 Main.AttachLogic(Id,LG);
 SA.Create;
 SA.SetScale(-0.45,tpb_Sin);
 SA.SetTime(7000);
 SA.SetType(atp_loop);
// Main.AttachAnime(Id,SA);
// a.BoolPlayMusic:=False;
// a.BoolPlayVideo:=False;
// BeginThread(@CmdInput);
 FPS.Create;
 TIM.Create;
 Repeat
{  If BoolTf Then
  Begin
   If Tf=-2 Then Halt;
   If Tf=-1 Then If a.BoolPause Then a.Resume Else a.Pause
            Else a.Skip(Tf);
   BoolTf:=False
  End;}
  Lock;
  ScreenClear;
//  a.Decode;
//  DrawTo(a.vExchange,Screen,0,0);
  Main.Communication;
  Main.DisplayDirect;
//  Main.Display;
  FPS.Free;
  FPS.Create('FPS='+IntToStr(NowFPS));
  FPS.FontColor:=Color_LBlue;
  FPS.WriteTo(Screen,1,1);
  TIM.WriteTo(Screen,Round((Screen.Height-TIM.Height)*0.5),Round((Screen.Width-TIM.Width)*0.5));
  UnLock;
//  inc(tp);
//  WriteLn(tp)
 Until Not ConsoleUsing;
End.