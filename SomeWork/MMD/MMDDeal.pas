{$MODE OBJFPC}{$H+}
unit MMDDeal;
interface

uses SimpleAnimeUnit2,MatrixUnit,PMDDeal,VMDDeal,ptc,gl,glu,math;
Type
 NULLGraph=Object(BaseGraph)
  Function Reproduce:pBaseGraph;Virtual;
  Function Recovery(Env:pElement;Below:pGraph):pGraph;Virtual;
 End;
var
 LightPos:array[0..3]of GLfloat=(3,0,-3,0);
 LightCol:array[0..3]of GLfloat=(1,1,1,1);
 Ambient :array[0..3]of GLfloat=(1,1,1,1);

 Eye:Vector3=(0,10,-38);
 Ctr:Vector3=(0,10,0);
 UpW:Vector3=(0,1,0);


 ScaleConst:Single=20;
 TransConstX:Single=20;
 TransConstY:Single=20;
 RotateConstY:Single=90;
 RotateConstX:Single=90;

 MMDCameraPic:NULLGraph;
 MMDCameraLog:AnimeLog;
 MMDCamera:Stage;

Procedure OpenGLInit(const title:String;Width,Height:Longint);
Procedure MMDDraw(Var A:PMDFormat);

implementation

Function NULLGraph.Reproduce:pBaseGraph;
Var Tmp:^NULLGraph;
Begin
 New(Tmp,Create);
 Exit(Tmp)
End;

Function NULLGraph.Recovery(Env:pElement;Below:pGraph):pGraph;
Begin
 Exit(Nil)
End;


Procedure OpenGLInit(const title:String;Width,Height:Longint);
Begin
 Console:=TPTCConsoleFactory.CreateNew;
 Console.Option('windowed output');
 Console.OpenGL_Enabled:=True;
 Console.OpenGL_Attributes.DoubleBuffer:=True;
 Format:=TPTCFormatFactory.CreateNew(32,$ff0000,$ff00,$ff);
 Console.Open(title,Width,Height,Format);
End;

Procedure MMDDraw(Var A:PMDFormat);
Begin
 glClearColor(1,1,1,1);
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
 glPushMatrix;
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 gluPerspective(45,Console.Width/Console.Height,0.1,1000);
 glViewPort(0,0,Console.Width,Console.Height);
 gluLookAt(Eye[1],Eye[2],Eye[3],Ctr[1],Ctr[2],Ctr[3],UpW[1],UpW[2],UpW[3]);
 glLightfv(GL_LIGHT0,GL_AMBIENT,ambient);
 glLightfv(GL_LIGHT0,GL_POSITION,LightPos);
 glLightfv(GL_LIGHT0,GL_DIFFUSE,LightCol);
 glEnable(GL_LIGHTING);
 glEnable(GL_LIGHT0);
 glEnable(GL_TEXTURE_2D);
 glEnable(GL_DEPTH_TEST);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;
 a.Draw;
 glFlush;
 glPopMatrix;
 glFlush;
 Console.OpenGL_SwapBuffers
End;

Var
 TmpX,TmpY:Longint;
 TmpEye,TmpCtr,TmpUpW:Vector3;
 Status:Longint=0;

Procedure MMDCameraBasic(Env:pElement;Below:pGraph;Const E:SAMouseEvent;inner:ShortInt);
Var
 Tmp1,Tmp2:Vector3;
 TmpL,TmpA,TmpB:Single;
 TmpM:Matrix3;
Begin
 if E.press then Begin
  TmpX:=E.x;
  TmpY:=E.y;
  TmpEye:=Eye;
  TmpCtr:=Ctr;
  TmpUPW:=UpW;
  Case E.Button Of
   1:Status:=1; //Left    =  Scale
   2:Status:=2; //Right   =  Rotate
   4:Status:=3; //Middle  =  Translate
   Else Status:=0
  End
 End Else
 if E.Release then Status:=0 Else
 Case Status Of
  1:Begin
     Tmp1:=Normalize(TmpCtr-TmpEye);
     Eye:=TmpEye+Tmp1*(ScaleConst*(E.Y-TmpY)/Console.Width);
    End;
  2:Begin
     Tmp1:=TmpCtr-TmpEye;
     TmpL:=Mold(Tmp1);
     TmpA:=ArcTan2(Tmp1[3],Tmp1[1])*180/pi;
     TmpB:=ArcTan2(Tmp1[2],Sqrt(Sqr(Tmp1[1])+Sqr(Tmp1[3])))*180/pi;
     TmpA:=TmpA+RotateConstY*(E.Y-TmpY)/Console.Width;
     TmpB:=TmpB-RotateConstX*(E.X-TmpX)/Console.Height;
     TmpM:=RotateY(TmpA)*RotateZ(-TmpB);
     Tmp2:=TmpM*Vec3(-TmpL,0,0);
     Eye:=TmpCtr+Tmp2;
     UpW:=TmpM*Vec3(0,1,0);
    End;
  3:Begin
     Tmp1:=Normalize(UpW);
     Tmp2:=Normalize(Cross_Product(UpW,TmpCtr-TmpEye));
     Tmp1:=Tmp1*(TransConstX*(E.X-TmpX)/Console.Height)+
           Tmp2*(TransConstY*(E.Y-TmpY)/Console.Width);
     Ctr:=TmpCtr+Tmp1;
     Eye:=TmpEye+Tmp1;
    End
 End
End;

Begin
 MMDCameraPic.Create;
 MMDCameraLog.Create;
 MMDCameraLog.MouseEvent:=@MMDCameraBasic;
 MMDCamera.AttachLogic(MMDCamera.AddObj(MMDCameraPic),MMDCameraLog);

End.
