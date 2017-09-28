//本代码是隶属于SA2库及SAKit库的测试代码的ScreenShot.pas
Uses SimpleAnimeUnit2,SAKitUnit,Windows,SysUtils;
Const
 ScaleFactor=0.6;      //缩放因子
Var
 a:Graph;
 b:BitmapGraph;        //与WinAPI的Bitmap对应
Begin
 b.ScreenShot(GetDesktopWindow);     //GetDesktopWindow获取桌面句柄
                                     //ScreenShot是BitmapGraph的一种构析函数，可以复制句柄的像素内存
 Init('SAK',Round(b.Width*ScaleFactor),Round(b.Height*ScaleFactor));
 Repeat
  Lock;
  a:=b.toGraph;                          //toGraph将BitmapGraph转为Graph
  Opt_Scale(a,ScaleFactor,ScaleFactor);  //缩放到适应窗口
  DrawTo(a,Screen,0,0);
  a.Free;
  b.ScreenShot(GetDesktopWindow);
  UnLock;
 Until Not ConsoleUsing
End.