//��������������SA2�⼰SAKit��Ĳ��Դ����ScreenShot.pas
Uses SimpleAnimeUnit2,SAKitUnit,Windows,SysUtils;
Const
 ScaleFactor=0.6;      //��������
Var
 a:Graph;
 b:BitmapGraph;        //��WinAPI��Bitmap��Ӧ
Begin
 b.ScreenShot(GetDesktopWindow);     //GetDesktopWindow��ȡ������
                                     //ScreenShot��BitmapGraph��һ�ֹ������������Ը��ƾ���������ڴ�
 Init('SAK',Round(b.Width*ScaleFactor),Round(b.Height*ScaleFactor));
 Repeat
  Lock;
  a:=b.toGraph;                          //toGraph��BitmapGraphתΪGraph
  Opt_Scale(a,ScaleFactor,ScaleFactor);  //���ŵ���Ӧ����
  DrawTo(a,Screen,0,0);
  a.Free;
  b.ScreenShot(GetDesktopWindow);
  UnLock;
 Until Not ConsoleUsing
End.