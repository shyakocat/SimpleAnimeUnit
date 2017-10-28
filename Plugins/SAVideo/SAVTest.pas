Uses SimpleAnimeUnit2,SAVideoUnit,SysUtils;
Var
 a:VideoGraph;
 FPS:TextGraph;
 Id,key:Longint;
 SA:SimpleAnime;
Begin
 Init('SAVTest',1280,720);
 a.Create;
// a.Load('Test.mp4');
// a.Resize();
// a.Width:=760;
// a.Height:=360
// a.Free;
// a.Load('E:\FFOutput\Trouble(Lyrics).mp4');
 a.Load('E:\FFOutput\Horizon(full).mp4');
 A.Resize(1280,720);
 Id:=Main.AddObj(A);
 SA.Create;
 SA.SetAlpha(-1,tpb_Sin);
 SA.SetTime(1000);
 SA.SetType(atp_loop);
// Main.AttachAnime(Id,SA);
 Repeat
  Lock;
  ScreenClear;
  Main.DisplayDirect;
//  Main.Display;
  FPS.Create(IntToStr(NowFPS));
  FPS.FontColor:=Color_LBlue;
  FPS.WriteTo(Screen,1,1);
  If TestKey(key) Then
   If Key=27 Then A.Skip(50);
  UnLock;
 Until Not ConsoleUsing
End.