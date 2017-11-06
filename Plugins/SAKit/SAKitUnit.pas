unit SAkitUnit;
interface
uses CommonTypeUnit,SimpleAnimeUnit2,Windows,SysUtils;


Type

 IntList=Specialize List<Longint>;

 pPureGraph=^PureGraph;
 pGradualGraph=^GradualGraph;
 pMultiGraph=^MultiGraph;
 pBitmapGraph=^BitmapGraph;


 PureGraph=Object(BaseGraph)
  Color:Color;
  Constructor Create;
  Constructor Create(_H,_W:Longint;Const _C:Color);
  Destructor Free;Virtual;
  Function Reproduce:pBaseGraph;Virtual;
  Function Recovery(Env:pElement;Below:pGraph):pGraph;Virtual;
 End;

 GradualGraph=Object(BaseGraph)
  BeginColor,EndColor:Color;
  Angle:Single;
  GType:ShortInt;
  Constructor Create;
  Constructor Create(_H,_W:Longint);
  Procedure SetParam(Const S,T:Color;A:Single;_tp:ShortInt);
  Destructor Free;Virtual;
  Function Reproduce:pBaseGraph;Virtual;
  Function Recovery(Env:pElement;Below:pGraph):pGraph;Virtual;
 End;

 MultiGraph=Object(BaseGraph)
  Select:Longint;
  Alternative:Specialize List<pBaseGraph>;
  Constructor Create;
  Destructor Free;Virtual;
  Function Size:Longint;
  Function SetSelect(X:Longint):Longint;
  Procedure AddPic(Const al:pBaseGraph);
  Function Cut:MultiGraph;
  Function Reproduce:pBaseGraph;Virtual;
  Function Recovery(Env:pElement;Below:pGraph):pGraph;Virtual;
 End;

 BitmapGraph=Object(BaseGraph)
  Dc:HDC;
  Hbmp:HBITMAP;
  Bmi:TBitmapInfo;
  _Stride,_Offset:Longint;
  Constructor Create;
  Constructor Create(_W,_H:Longint);
  Constructor Create(Const A:Graph);
  Constructor ScreenShot(window:HWND);
  Destructor Free;Virtual;
  Function Cut:BitmapGraph;
  Function toGraph:Graph;

  Function SetPixel(_x,_y:Longint;_c:COLORREF):COLORREF; //unusual
  Function GetPixel(_x,_y:Longint):COLORREF;             //unusual
  Procedure Fill(x0,y0,x1,y1,_c:Longint);
  Procedure DrawLine(x0,y0,x1,y1,_style,_width,_c:Longint);
  Procedure DrawCircle(x,y,r,_ci,_co,_so:Longint);
  Procedure DrawEllipse(x0,y0,x1,y1,_ci,_co,_so:Longint);
  Procedure DrawRect(x0,y0,x1,y1,_ci,_co,_so:Longint);
  Procedure DrawRect(x0,y0,x1,y1,_style,_ci,_co,_so:Longint);
  Procedure DrawRoundRect(x0,y0,x1,y1,bx,by,_ci,_co,_so:Longint);
  Procedure DrawBmp(x0,y0,x1,y1:Longint;_f:LPCTSTR);
  Procedure DrawArc(x0,y0,x1,y1,Xstart,Ystart,Xend,Yend,_ci,_co,_so:Longint);
  Procedure DrawChord(x0,y0,x1,y1,Xstart,Ystart,Xend,Yend,_ci,_co,_so:Longint);
  Procedure DrawPie(x0,y0,x1,y1,Xstart,Ystart,Xend,Yend,_ci,_co,_so:Longint);
  Procedure DrawPolygon(p:pPoint;n,_width,_ci,_co,_so:Longint);
  Procedure DrawBezier(p:pPoint;n,_width,_c:Longint);
  Procedure DrawText(x,y:Longint;s:lpCTSTR;c:Longint);
  Procedure DrawText(x,y:Longint;Const T:TextGraph);

  Function Reproduce:pBaseGraph;Virtual;
  Function Recovery(Env:pElement;Below:pGraph):pGraph;Virtual;
 End;

Const
 SAMouseUp=1;
 SAMouseOver=2;
 SAMouseDown=3;
//SAMouseFocus=;
//SAMouseDisable=;

Type

 pSAButtonBox=^SAButtonBox;
 pSACheckBox=^SACheckBox;

 SAButtonStatus=Record Gray,Down,Focus,High,Normal:Boolean End;

 SAButtonBox=Object(Element)
  Enable:Boolean;
  Caption:TextGraph;
  CustomHandle:AnimeLog;
  Std:SAButtonStatus;
  Plain:MultiGraph;
  Constructor Create;
  Constructor Create(_up,_over,_down:pBaseGraph);
  Constructor CreateType1(_H,_W:Longint;Const _C:Color);
  Constructor CreateType2(_H,_W:Longint);
  Procedure SetSelect(_SAEtp:ShortInt);
  Procedure SetPic(_SAEtp:ShortInt;Ind:pBaseGraph);
  Procedure SetText(Const T:TextGraph);
  Procedure SetText(Tx:Ansistring);
  Procedure SetClick(_MP:MouseProc);
  Procedure CountUpdate(_SAEtp:ShortInt);
  Function Reproduce:pElement;Virtual;
 End;

 SACheckBox=Object(Element)
  Check:Boolean;
  Constructor Create;
  Constructor Create(_up,_down:pBaseGraph);
  Constructor CreateType1;
  Constructor CreateType2;
  Function Reproduce:pElement;Virtual;
 End;


Var
 SAButtonStatusInit:SAButtonStatus=(Gray:False;    //Gray=Disable
                                    Down:False;    //Down=Click
                                    Focus:False;
                                    High:False;    //High=Activation(Over)
                                    Normal:True);


implementation

Constructor PureGraph.Create;
Begin Create(10,10,Color_Alpha) End;

Constructor PureGraph.Create(_H,_W:Longint;Const _C:Color);
Begin Height:=_H; Width:=_W; Color:=_C End;

Destructor PureGraph.Free;
Begin End;

Function PureGraph.Reproduce:pBaseGraph;
Var Tmp:pPureGraph;
Begin
 New(Tmp,Create(Height,Width,Color));
 Exit(Tmp)
End;

Function PureGraph.Recovery(Env:pElement;Below:pGraph):pGraph;
Var Tmp:pGraph;
Begin
 New(Tmp,Create(Height,Width));
 Tmp^.Fill(1,1,Height,Width,Color);
 Exit(Tmp)
End;

Constructor GradualGraph.Create;
Begin
 Create(10,10)
End;

Constructor GradualGraph.Create(_H,_W:Longint);
Begin
 Height:=_H;
 Width:=_W;
 BeginColor:=Color_Alpha;
 EndColor:=Color_Alpha;
 GType:=0;
End;

Procedure GradualGraph.SetParam(Const S,T:Color;A:Single;_tp:ShortInt);
Begin
 BeginColor:=S;
 EndColor:=T;
 Angle:=A;
 GType:=_tp
End;

Destructor GradualGraph.Free;
Begin End;

Function GradualGraph.Reproduce:pBaseGraph;
Var Tmp:pGradualGraph;
Begin
 New(Tmp,Create(Height,Width));
 Tmp^.BeginColor:=BeginColor;
 Tmp^.EndColor:=EndColor;
 Tmp^.Angle:=Angle;
 Tmp^.GType:=GType;
 Exit(Tmp)
End;

Function GradualGraph.Recovery(Env:pElement;Below:pGraph):pGraph;
Var
 Tmp:pGraph;
 _Sin,_Cos,MxDis,Dis,Pro:Single;
 i,j:Longint;
Begin
 If Not((0<=Angle)And(Angle<=90)) Then Exit(Nil);
 New(Tmp,Create(Height,Width));
 _Sin:=Sin(Angle*pi/180);
 _Cos:=Cos(Angle*pi/180);
 MxDis:=Sqrt(Sqr(Width*_Cos)+Sqr(Height*_Sin));
 For i:=1 to Tmp^.Height Do
 For j:=1 to Tmp^.Width Do
 Begin
  Dis:=Sqrt(Sqr(j*_Cos)+Sqr(i*_Sin));
  Pro:=tp_Count(Dis/MxDis,GType);
  Tmp^[i,j]:=RGBA(Round(BeginColor.R*(1-Pro)+EndColor.R*Pro),
                  Round(BeginColor.G*(1-Pro)+EndColor.G*Pro),
                  Round(BeginColor.B*(1-Pro)+EndColor.B*Pro),
                  Round(BeginColor.A*(1-Pro)+EndColor.A*Pro))
 End;
 Exit(Tmp)
End;

Constructor MultiGraph.Create;
Begin
 Width:=0;
 Height:=0;
 Select:=0;
 Alternative.Clear
End;

Destructor MultiGraph.Free;
Begin
 Select:=0;
 Alternative.Clear
End;

Procedure MultiGraph.AddPic(Const al:pBaseGraph);
Begin
 Alternative.Pushback(al^.Reproduce)
End;

Function MultiGraph.Size:Longint;
Begin
 Exit(Alternative.Size)
End;

Function MultiGraph.Cut:MultiGraph;
Var i:Longint;
Begin
 Cut.Create;
 For i:=1 to Size Do
  Cut.Alternative.Pushback(Alternative[i]^.Reproduce)
End;

Function MultiGraph.Reproduce:pBaseGraph;
Var
 i:Longint;
 Tmp:pMultiGraph;
Begin
 New(Tmp,Create);
 For i:=1 to Size Do
  Tmp^.Alternative.Pushback(Alternative[i]^.Reproduce);
 Tmp^.SetSelect(Select);
 Exit(Tmp)
End;

Function MultiGraph.Recovery(Env:pElement;Below:pGraph):pGraph;
Begin
 If Select=0 Then Exit(Nil);
 Exit(Alternative[Select]^.Recovery(Env,Below))
End;

Function MultiGraph.SetSelect(X:Longint):Longint;
Begin
 If X<=0 Then Begin Select:=0; Width:=0; Height:=0; Exit(0) End;
 If X>Size Then X:=Size;
 Select:=X;
 Width:=Alternative[X]^.Width;
 Height:=Alternative[X]^.Height;
 Exit(X)
End;

Constructor BitmapGraph.Create;
Begin
 Width:=0;
 Height:=0;
 Dc:=0;
 Hbmp:=0;
 FillChar(Bmi,Sizeof(Bmi),0)
End;

Constructor BitmapGraph.Create(_W,_H:Longint);
Begin
 Width:=_W;
 Height:=_H;
 _Stride:=(Width*3-1or 3)+1;
 _Offset:=_Stride-Width*3;
 Dc:=CreateCompatibleDC(0);
 HBmp:=CreateBitmap(Width,Height,1,32,nil);
 With Bmi.bmiHeader Do
 Begin
  biSize:=Sizeof(TBitmapInfoHeader);
  biWidth:=Width;
  biHeight:=Height;
  biPlanes:=1;
  biBitCount:=24;
  biCompression:=BI_RGB
 End;
 SelectObject(Dc,hbmp)
End;

Constructor BitmapGraph.Create(Const A:Graph);
var
 Buffer:Pointer;
 p:pRGBTriple;
 i,j:Longint;
Begin
 Width:=A.Width;
 Height:=A.Height;
 _Stride:=(Width*3-1or 3)+1;
 _Offset:=_Stride-Width*3;
 GetMem(Buffer,Height*_Stride);
 p:=Buffer;
 For i:=Height Downto 1 Do Begin
 For j:=1 to Width Do with A[i,j] Do Begin
  p^.rgbtRed:=r;
  p^.rgbtGreen:=g;
  p^.rgbtBlue:=b;
 Inc(P) End;
 P:=Pointer(LongWord(P)+_Offset) End;
 Dc:=CreateCompatibleDC(0);
 Hbmp:=CreateBitmap(Width,Height,1,32,nil);
 With Bmi.bmiHeader Do
 Begin
  biSize:=Sizeof(TBitmapInfoHeader);
  biWidth:=Width;
  biHeight:=Height;
  biPlanes:=1;
  biBitCount:=24;
  biCompression:=BI_RGB
 End;
 SetDIBits(dc,hbmp,0,Height,Buffer,Bmi,DIB_RGB_COLORS);
 SelectObject(Dc,hbmp);
 FreeMem(Buffer)
End;

Constructor BitmapGraph.ScreenShot(window:HWND);
Var
 _Dc:HDC;
 RE:RECT;
Begin
 _Dc:=GetWindowDC(Window);
 DC:=CreateCompatibleDC(0);
 GetWindowRect(Window,@RE);
 Width:=RE.Right;
 Height:=RE.Bottom;
 _Stride:=(Width*3-1or 3)+1;
 _Offset:=_Stride-Width*3;
 With Bmi.bmiHeader Do
 Begin
  biSize:=Sizeof(TBitmapInfoHeader);
  biWidth:=Width;
  biHeight:=Height;
  biPlanes:=1;
  biBitCount:=24;
  biCompression:=BI_RGB
 End;
 hbmp:=CreateCompatibleBitmap(_Dc,Width,Height);
 SelectObject(dc,hbmp);
 StretchBlt(dc,0,0,Width,Height,_dc,0,0,width,height,SRCCOPY);
End;

Destructor BitmapGraph.Free;
Begin
 DeleteObject(hbmp);
 DeleteDC(dc);
 FillChar(Bmi,Sizeof(Bmi),0)
End;

Function BitmapGraph.toGraph:Graph;
Var
 Buffer:Pointer;
 Tmp:pGraph;
 i,j:Longint;
 p:pRGBTriple;
Begin
 New(Tmp,Create(Height,Width));
 GetMem(Buffer,Height*_Stride);
 GetDIBits(Dc,HBmp,0,Height,Buffer,Bmi,DIB_RGB_COLORS);
 p:=Buffer;
 For i:=Height Downto 1 Do Begin
 For j:=1 to Width Do Begin Tmp^.SetP(i,j,RGBA(p^.rgbtRed,p^.rgbtGreen,p^.rgbtBlue,255));
 Inc(P) End;
 P:=Pointer(LongWord(p)+_Offset) End;
 FreeMem(Buffer);
 Exit(Tmp^)
End;

Function BitmapGraph.Cut:BitmapGraph;
Var
 Tmp:pBitmapGraph;
Begin
 New(Tmp,Create);
 Tmp^.Width:=Width;
 Tmp^.Height:=Height;
 Tmp^._Stride:=_Stride;
 Tmp^._Offset:=_Offset;
 Tmp^.Dc:=CreateCompatibleDC(0);
 Tmp^.Hbmp:=CreateBitmap(Width,Height,1,32,nil);
 Tmp^.Bmi:=Bmi;
 SelectObject(Tmp^.Dc,Tmp^.HBmp);
 BitBlt(Tmp^.Dc,0,0,Width,Height,Dc,0,0,SRCCOPY);
 Exit(Tmp^)
End;

Function BitmapGraph.Reproduce:pBaseGraph;
Var
 Tmp:pBitmapGraph;
Begin
 New(Tmp,Create);
 Tmp^:=Cut;
 Exit(Tmp)
End;

Function BitmapGraph.Recovery(Env:pElement;Below:pGraph):pGraph;
Var Tmp:pGraph;
Begin
 New(Tmp,Create);
 Tmp^:=toGraph;
 Exit(Tmp)
ENd;

Function BitmapGraph.SetPixel(_x,_y:Longint;_c:COLORREF):COLORREF;
Begin
 Exit(Windows.SetPixel(Dc,_X,_Y,_C))
End;

Function BitmapGraph.GetPixel(_x,_y:Longint):COLORREF;
Begin
 Exit(Windows.GetPixel(Dc,_X,_Y))
End;

Procedure BitmapGraph.Fill(x0,y0,x1,y1,_c:Longint);
Var
 hBrush:LongWord;
 Rt:Rect;
Begin
 hBrush:=CreateSolidBrush(_C);
 With Rt Do Begin Left:=x0; Top:=y0; Right:=x1; Bottom:=y1 End;
 FillRect(Dc,Rt,hBrush);
 DeleteObject(hBrush)
End;

Procedure BitmapGraph.DrawLine(x0,y0,x1,y1,_style,_width,_c:Longint);
Var
 hPen,hOldPen:LongWord;
Begin
 hPen:=CreatePen(_style,_width,_c);
 hOldPen:=SelectObject(Dc,hPen);
 MoveToEx(Dc,x0,y0,nil);
 LineTo(Dc,x1,y1);
 SelectObject(Dc,hOldPen);
 DeleteObject(hPen)
End;

Procedure BitmapGraph.DrawCircle(x,y,r,_ci,_co,_so:Longint);
Begin
 DrawEllipse(x-r,y-r,x+r,y+r,_ci,_co,_so)
End;

Procedure BitmapGraph.DrawEllipse(x0,y0,x1,y1,_ci,_co,_so:Longint);
Var
 hBrush,hPen,hOldBrush,hOldPen:LongWord;
Begin
 hBrush:=CreateSolidBrush(_Ci);
 hOldBrush:=SelectObject(Dc,hBrush);
 hPen:=CreatePen(PS_SOLID,_so,_Co);
 hOldPen:=SelectObject(Dc,hPen);
 Ellipse(Dc,x0,y0,x1,y1);
 SelectObject(Dc,hOldPen);
 DeleteObject(hPen);
 SelectObject(Dc,hOldBrush);
 DeleteObject(hBrush)
End;

Procedure BitmapGraph.DrawRect(x0,y0,x1,y1,_ci,_co,_so:Longint);
Var
 hBrush,hPen,hOldBrush,hOldPen:LongWord;
Begin
 hBrush:=CreateSolidBrush(_ci);
 hOldBrush:=SelectObject(Dc,hBrush);
 hPen:=CreatePen(PS_SOLID,_so,_Co);
 hOldPen:=SelectObject(Dc,hPen);
 Rectangle(Dc,x0,y0,x1,y1);
 SelectObject(Dc,hOldBrush);
 DeleteObject(hBrush);
 SelectObject(Dc,hOldPen);
 DeleteObject(hPen)
End;

Procedure BitmapGraph.DrawRect(x0,y0,x1,y1,_style,_ci,_co,_so:Longint);
Var
 hBrush,hPen,hOldBrush,hOldPen:LongWord;
Begin
 hBrush:=CreateHatchBrush(_style,_ci);
 hOldBrush:=SelectObject(Dc,hBrush);
 hPen:=CreatePen(PS_SOLID,_so,_Co);
 hOldPen:=SelectObject(Dc,hPen);
 Rectangle(Dc,x0,y0,x1,y1);
 SelectObject(Dc,hOldBrush);
 DeleteObject(hBrush);
 SelectObject(Dc,hOldPen);
 DeleteObject(hPen)
End;

 Procedure BitmapGraph.DrawRoundRect(x0,y0,x1,y1,bx,by,_ci,_co,_so:Longint);
Var
 hBrush,hPen,hOldBrush,hOldPen,Rgn:LongWord;
Begin
 hBrush:=CreateSolidBrush(_ci);
 hOldBrush:=SelectObject(Dc,hBrush);
 hPen:=CreatePen(PS_SOLID,_so,_Co);
 hOldPen:=SelectObject(Dc,hPen);
 Rgn:=CreateRoundRectRgn(x0,y0,x1,y1,bx,by);
 FillRgn(Dc,Rgn,hBrush);
 FrameRgn(Dc,Rgn,hPen,_so,_so);
 SelectObject(Dc,hOldBrush);
 DeleteObject(hBrush);
 SelectObject(Dc,hOldPen);
 DeleteObject(hPen);
 DeleteObject(Rgn)
End;

Procedure BitmapGraph.DrawBmp(x0,y0,x1,y1:Longint;_f:LPCTSTR);
Var
 hBmpPic:HBITMAP;
 hBrush,hOldBrush:LongWord;
Begin
 hBmpPic:=LoadImage(0,_f,IMAGE_BITMAP,0,0,LR_LOADFROMFILE Or LR_CREATEDIBSECTION);
 hBrush:=CreatePatternBrush(hBmpPic);
 hOldBrush:=SelectObject(Dc,hBrush);
 Rectangle(Dc,x0,y0,x1,y1);
 SelectObject(Dc,hOldBrush);
 DeleteObject(hBrush);
 DeleteObject(hBmpPic)
End;

Procedure BitmapGraph.DrawArc(x0,y0,x1,y1,Xstart,Ystart,Xend,Yend,_ci,_co,_so:Longint);
Var
 hBrush,hPen,hOldBrush,hOldPen:LongWord;
Begin
 hBrush:=CreateSolidBrush(_ci);
 hOldBrush:=SelectObject(Dc,hBrush);
 hPen:=CreatePen(PS_SOLID,_so,_Co);
 hOldPen:=SelectObject(Dc,hPen);
 Arc(Dc,x0,y0,x1,y1,Xstart,Ystart,Xend,Yend);
 SelectObject(Dc,hOldBrush);
 DeleteObject(hBrush);
 SelectObject(Dc,hOldPen);
 DeleteObject(hPen)
End;

Procedure BitmapGraph.DrawChord(x0,y0,x1,y1,Xstart,Ystart,Xend,Yend,_ci,_co,_so:Longint);
Var
 hBrush,hPen,hOldBrush,hOldPen:LongWord;
Begin
 hBrush:=CreateSolidBrush(_ci);
 hOldBrush:=SelectObject(Dc,hBrush);
 hPen:=CreatePen(PS_SOLID,_so,_Co);
 hOldPen:=SelectObject(Dc,hPen);
 Chord(Dc,x0,y0,x1,y1,Xstart,Ystart,Xend,Yend);
 SelectObject(Dc,hOldBrush);
 DeleteObject(hBrush);
 SelectObject(Dc,hOldPen);
 DeleteObject(hPen)
End;

Procedure BitmapGraph.DrawPie(x0,y0,x1,y1,Xstart,Ystart,Xend,Yend,_ci,_co,_so:Longint);
Var
 hBrush,hPen,hOldBrush,hOldPen:LongWord;
Begin
 hBrush:=CreateSolidBrush(_ci);
 hOldBrush:=SelectObject(Dc,hBrush);
 hPen:=CreatePen(PS_SOLID,_so,_Co);
 hOldPen:=SelectObject(Dc,hPen);
 Pie(Dc,x0,y0,x1,y1,Xstart,Ystart,Xend,Yend);
 SelectObject(Dc,hOldBrush);
 DeleteObject(hBrush);
 SelectObject(Dc,hOldPen);
 DeleteObject(hPen)
End;

Procedure BitmapGraph.DrawPolygon(p:pPoint;n,_width,_ci,_co,_so:Longint);
Var
 hBrush,hPen,hOldBrush,hOldPen:LongWord;
Begin
 hBrush:=CreateSolidBrush(_ci);
 hOldBrush:=SelectObject(Dc,hBrush);
 hPen:=CreatePen(PS_SOLID,_so,_Co);
 hOldPen:=SelectObject(Dc,hPen);
 Polygon(Dc,p,n);
 SelectObject(Dc,hOldBrush);
 DeleteObject(hBrush);
 SelectObject(Dc,hOldPen);
 DeleteObject(hPen)
End;
Procedure BitmapGraph.DrawBezier(p:pPOINT;n,_width,_c:Longint);
Var
 hPen,hOldPen:LongWord;
Begin
 hPen:=CreatePen(PS_SOLID,_width,_c);
 hOldPen:=SelectObject(Dc,hPen);
 PolyBezier(Dc,p,n);
 SelectObject(Dc,hOldPen);
 DeleteObject(hPen)
End;

Procedure BitmapGraph.DrawText(x,y:Longint;s:lpCTSTR;c:Longint);
Begin
 TextOut(Dc,x,y,s,c)
End;

Procedure BitmapGraph.DrawText(x,y:Longint;Const T:TextGraph);
Var
 hFont,hOldFont:LongWord;
Begin
 With T Do
 hFont:=CreateFont(FontSize,0,Round(FontAngle*10),Round(FontAngle*10),
                   Ord(Bold)*FW_BOLD+Ord(Not Bold)*FW_NORMAL,Ord(Italic),Ord(UnderLine),Ord(StrikeOut),CHARSET,
                    OUT_DEFAULT_PRECIS,
                   CLIP_DEFAULT_PRECIS,
                   DEFAULT_QUALITY,
                   DEFAULT_PITCH or FF_DONTCARE,
                   PChar(FontType));
 hOldFont:=SelectObject(Dc,hFont);
 TextOut(Dc,x,y,pChar(T.Text),Length(T.Text));
 SelectObject(Dc,hOldFont);
 DeleteObject(hFont)
End;

Constructor SAButtonBox.Create;
Begin
 Enable:=True;
 Plain.Create;
 Role.Create;
 Acts.Create;
 Talk.Create;
 CustomHandle.Create;
 Std:=SAButtonStatusInit;
End;

 Procedure SAButtonBoxGeneral(Env:pElement;Below:pGraph;Const E:SAMouseEvent;Inner:ShortInt);
 Begin
  With pSAButtonBox(Env)^ Do
  With Std Do
  Begin
   Gray:=Enable;
   If (Inner And 1=1)And(E.Press) Then Begin Down:=True; Focus:=True End;
   If E.Release Then Begin Down:=False; If Inner And 1=0 Then Focus:=False End;
   High:=Inner And 1=1;
   //Normal Is Redundant
  End
 End;

 Procedure SAButtonBoxMouseDeal1(Env:pElement;Below:pGraph;Const E:SAMouseEvent;inner:ShortInt);
 Begin
  SAButtonBoxGeneral(Env,Below,E,Inner);
  With pSAButtonBox(Env)^ Do
  With Std Do
  Begin
   Role.Visible:=Gray;
   If Down Then
   Begin
    SetSelect(SAMouseDown);
    Role.Alpha:=1;
    if (E.Press)And(CustomHandle.Enable) Then
     If CustomHandle.MouseEvent<>Nil Then
      CustomHandle.MouseEvent(Env,Below,E,Inner)
   End Else
   If High Then
   Begin
    SetSelect(SAMouseOver);
    Role.Alpha:=0.8
   End Else
   Begin
    SetSelect(SAMouseUp);
    Role.Alpha:=0.6
   End
  End
 End;

Constructor SAButtonBox.CreateType1(_H,_W:Longint;Const _C:Color);
Var
 Core:pMultiGraph;
 TmpG:pPureGraph;
Begin
 Enable:=True;
 New(TmpG,Create(_H,_W,_C));
 Plain.Create;
 Plain.AddPic(TmpG);
 Plain.AddPic(TmpG);
 Plain.AddPic(TmpG);
 Plain.SetSelect(SAMouseUp);
 Role.Create(Plain);
 Role.Alpha:=0.6;
 Acts.Create;
 Talk.Create;
 Caption.Create;
 CustomHandle.Create;
 Std:=SAButtonStatusInit;
 Talk.MouseEvent:=@SAButtonBoxMouseDeal1
End;

 Procedure SAButtonBoxMouseDeal2(Env:pElement;Below:pGraph;Const E:SAMouseEvent;inner:ShortInt);
 Begin
  SAButtonBoxGeneral(Env,Below,E,Inner);
  With pSAButtonBox(Env)^ Do
  WIth Std Do
  Begin
   If Down Then
   Begin
    SetSelect(SAMouseDown);
    If (E.Press)And(CustomHandle.Enable) Then
     If CustomHandle.MouseEvent<>Nil Then
      CustomHandle.MouseEvent(Env,Below,E,Inner)
   End Else
   If High Then
   Begin
    SetSelect(SAMouseOver)
   End Else
   Begin
    SetSelect(SAMouseUp)
   End
  End;
 End;

Constructor SAButtonBox.Create(_up,_over,_down:pBaseGraph);
Begin
 Enable:=True;
 Plain.Create;
 Plain.AddPic(_up);
 Plain.AddPic(_over);
 Plain.AddPic(_down);
 Plain.SetSelect(SAMouseUp);
 Role.Create(Plain);
 Acts.Create;
 Talk.Create;
 Caption.Create;
 CustomHandle.Create;
 Std:=SAButtonStatusInit;
 Talk.MouseEvent:=@SAButtonBoxMouseDeal2
End;

 Procedure SAButtonBoxMouseDeal3(Env:pElement;Below:pGraph;Const E:SAMouseEvent;inner:ShortInt);
 Begin
  SAButtonBoxGeneral(Env,Below,E,Inner);
  With pSAButtonBox(Env)^ Do
  With Std Do
  Begin
   If Not Gray Then SetSelect(5) Else
   If     Down Then SetSelect(3) Else
   If     High Then SetSelect(2) Else
   If    Focus Then SetSelect(4) Else
                    SetSelect(1);
   If (Inner And 1=1)And(E.Press) Then
    If CustomHandle.MouseEvent<>Nil Then
     CustomHandle.MouseEvent(Env,Below,E,Inner)
  End
 End;


//Picture Sourece : http://bbs.cskin.net/thread-63-1-1.html
Constructor SAButtonBox.CreateType2(_H,_W:Longint);
Var
 _Ratio:Longint;
 QBtn_Gray,
 QBtn_Down,
 QBtn_Focus,
 QBtn_High,
 QBtn_Normal:Graph;
 Rgn:hRGN;
 Pen:hPen;
 Temp:BitmapGraph;
 QBtn_Cut:IntList;

 Procedure QBtn_Slicing(Var A:BitmapGraph;Const C:IntList);
 Var n,i:Longint;
 Begin
  n:=C.Size;
  For i:=1 to n Do
   A.DrawRect(0,Round(_H*(i-1)/n),_W,Round(_H*i/n),C[i],C[i],0);
 End;

 Procedure QBtn_OutLine(Var A:BitmapGraph;c1,c2:Longint);
 Begin
  Rgn:=CreateRoundRectRgn(0,0,_W+1,_H,_ratio,_ratio);
  Pen:=CreatePen(PS_SOLID,1,c1);
  FrameRgn(A.Dc,Rgn,Pen,1,1);
  DeleteObject(Rgn);
  DeleteObject(Pen);
  Rgn:=CreateRoundRectRgn(1,1,_W,_H-1,_ratio,_ratio);
  Pen:=CreatePen(PS_SOLID,1,c2);
  FrameRgn(A.Dc,Rgn,Pen,1,1);
  DeleteObject(Rgn);
  DeleteObject(Pen);
 End;

 Procedure QBtn_Clean(Var A:Graph;Const B:BitmapGraph);
 Begin
  A:=B.ToGraph;
  A.ChangeNear(1,1,Color_Alpha);
  A.ChangeNear(1,_W,Color_Alpha);
  A.ChangeNear(_H,1,Color_Alpha);
  A.ChangeNear(_H,_W,Color_Alpha)
 End;

Begin

 _ratio:=Max(5,Round(Max(_W,_H)*0.1));
 //Gray
  Temp.Create(_W,_H);
  QBtn_Cut.Clear;
  QBtn_Cut.PushBack(RGB(222,222,222));
  QBtn_Cut.PushBack(RGB(214,214,214));
  QBtn_Cut.PushBack(RGB(206,206,206));
  QBtn_Cut.PushBack(RGB(198,198,198));
  QBtn_Slicing(Temp,QBtn_Cut);
  QBtn_OutLine(Temp,RGB(123,123,123),RGB(247,247,247));
  QBtn_Clean(QBtn_Gray,Temp);
  Temp.Free;

 //Down
  Temp.Create(_W,_H);
  QBtn_Cut.Clear;
  QBtn_Cut.PushBack(RGB(214,222,222));
  QBtn_Cut.PushBack(RGB(222,222,222));
  QBtn_Cut.PushBack(RGB(222,231,231));
  QBtn_Cut.PushBack(RGB(231,231,239));
  QBtn_Cut.PushBack(RGB(231,239,239));
  QBtn_Cut.PushBack(RGB(239,239,239));
  QBtn_Slicing(Temp,QBtn_Cut);
  QBtn_OutLine(Temp,RGB(165,165,165),RGB(255,255,255));
  QBtn_Clean(QBtn_Down,Temp);
  Temp.Free;

  //Focus
  Temp.Create(_W,_H);
  QBtn_Cut.Clear;
  QBtn_Cut.PushBack(RGB(255,255,255));
  QBtn_Cut.PushBack(RGB(247,255,255));
  QBtn_Cut.PushBack(RGB(247,247,255));
  QBtn_Cut.PushBack(RGB(239,247,247));
  QBtn_Cut.PushBack(RGB(231,239,239));
  QBtn_Cut.PushBack(RGB(222,239,239));
  QBtn_Slicing(Temp,QBtn_Cut);
  QBtn_OutLine(Temp,RGB(74,132,173),RGB(115,214,255));
  QBtn_Clean(QBtn_Focus,Temp);
  Temp.Free;

 //High
  Temp.Create(_W,_H);
  QBtn_Cut.Clear;
  QBtn_Cut.PushBack(RGB(206,231,247));
  QBtn_Cut.PushBack(RGB(198,231,247));
  QBtn_Cut.PushBack(RGB(189,231,247));
  QBtn_Cut.PushBack(RGB(181,222,239));
  QBtn_Cut.PushBack(RGB(173,222,239));
  QBtn_Cut.PushBack(RGB(165,214,239));
  QBtn_Cut.PushBack(RGB(156,214,239));
  QBtn_Slicing(Temp,QBtn_Cut);
  QBtn_OutLine(Temp,RGB(66,140,189),RGB(231,247,255));
  QBtn_Clean(QBtn_High,Temp);
  Temp.Free;

 //Normal
  Temp.Create(_W,_H);
  QBtn_Cut.Clear;
  QBtn_Cut.PushBack(RGB(255,255,255));
  QBtn_Cut.PushBack(RGB(247,255,255));
  QBtn_Cut.PushBack(RGB(247,247,255));
  QBtn_Cut.PushBack(RGB(247,247,247));
  QBtn_Cut.PushBack(RGB(239,247,247));
  QBtn_Cut.PushBack(RGB(239,239,247));
  QBtn_Cut.PushBack(RGB(239,239,239));
  QBtn_Cut.PushBack(RGB(231,239,239));
  QBtn_Cut.PushBack(RGB(231,231,239));
  QBtn_Cut.PushBack(RGB(231,231,231));
  QBtn_Slicing(Temp,QBtn_Cut);
  QBtn_OutLine(Temp,RGB(181,181,181),RGB(255,255,255));
  QBtn_Clean(QBtn_Normal,Temp);
  Temp.Free;

 Plain.Create;
 Plain.AddPic(@QBtn_Normal);
 Plain.AddPic(@QBtn_High);
 Plain.AddPic(@QBtn_Down);
 Plain.AddPic(@QBtn_Focus);
 Plain.AddPic(@QBtn_Gray);
 QBtn_Normal.Free;
 QBtn_High.Free;
 QBtn_Down.Free;
 QBtn_Focus.Free;
 QBtn_Gray.Free;

 Role.Create(Plain);
 Acts.Create;
 Talk.Create;

 Talk.MouseEvent:=@SAButtonBoxMouseDeal3;

 SetSelect(1);

 CustomHandle.Create;
 Enable:=True;

 Std:=SAButtonStatusInit

End;


Procedure SAButtonBox.SetClick(_MP:MouseProc);
Begin
 CustomHandle.MouseEvent:=_MP
End;

Procedure SAButtonBox.SetSelect(_SAEtp:ShortInt);
Begin
 pMultiGraph(Role.Source)^.SetSelect(_SAEtp)
End;

Procedure SAButtonBox.SetPic(_SAEtp:ShortInt;Ind:pBaseGraph);
Begin
 If Not(_SAEtp in[1..3]) Then Exit;
 Plain.Alternative.Items[_SAEtp]^.Free;
 Plain.Alternative.Items[_SAEtp]:=Ind^.Reproduce;
 CountUpdate(_SAEtp)
End;

Procedure SAButtonBox.SetText(Const T:TextGraph);
Var i:Longint;
Begin
 Caption:=T.Cut;
 For i:=1 to Plain.Size Do CountUpdate(i)
End;

Procedure SAButtonBox.SetText(Tx:Ansistring);
var i:Longint;
Begin
 Caption.Create(Tx);
 For i:=1 to Plain.Size Do CountUpdate(i)
End;

Procedure SAButtonBox.CountUpdate(_SAEtp:ShortInt);
Var
 obj:pMultiGraph;
 tmp:pGraph;
Begin
 obj:=pMultiGraph(Role.Source);
 obj^.Alternative.Items[_SAEtp]^.Free;
 tmp:=Plain.Alternative.Items[_SAEtp]^.Recovery(Nil,Nil);
 Caption.WriteTo(tmp^,(Height-Caption.Height)Div 2,(Width-Caption.Width)Div 2);
 obj^.Alternative.Items[_SAEtp]:=Tmp;
End;

Function SAButtonBox.Reproduce:pElement;
Var Tmp:pSAButtonBox;
Begin
 New(Tmp,Create);
 Tmp^.Plain:=Plain.Cut;
 Tmp^.Role:=Role.Cut;
 Tmp^.Acts:=Acts;
 Tmp^.Talk:=Talk;
 Tmp^.CustomHandle:=CustomHandle;
 Exit(Tmp)
End;

Constructor SACheckBox.Create;
Begin
 Check:=False
End;

 Procedure SACheckBoxMouseDeal1(Env:pElement;Below:pGraph;Const E:SAMouseEvent;inner:ShortInt);
 Var
  cEnv:pSACheckBox;
 Begin
  cEnv:=pSACheckBox(Env);
  If (inner And 1=1)And(E.Button=1)And(E.Press) Then
   cEnv^.Check:=Not cEnv^.Check;
  pMultiGraph(Env^.Role.Source)^.SetSelect(1+Ord(cEnv^.Check));
 End;

Constructor SACheckBox.CreateType1;
Var
 Tmp:MultiGraph;
 tBG:BitmapGraph;
 tG:Graph;
 tTG:TextGraph;
Begin
 Check:=False;
 Tmp.Create;
 tBG.Create(12,12);
 tBG.DrawRect(0,0,12,12,RGB(254,254,254),RGB(216,212,204),1);
 tG:=tBG.ToGraph;
 Tmp.AddPic(@tG);
 tBG.Free;
 tTG.Create('��');
 tTG.SetSize(12);
 tTG.Bold:=True;
 tTG.FontColor:=Color_LGreen;
 tTG.WriteTo(tG,0,1);
 Tmp.AddPic(@tG);
 Tmp.SetSelect(1);
 tG.Free;
 tTG.Free;
 Role.Create(Tmp);
 Tmp.Free;
 Acts.Create;
 Talk.Create;
 Talk.MouseEvent:=@SACheckBoxMouseDeal1
End;

Constructor SACheckBox.CreateType2;
Var
 Tmp:MultiGraph;
 tBG:BitmapGraph;
 tG:Graph;
Begin
 Check:=False;
 Tmp.Create;
 tBG.Create(12,12);
 tBG.DrawEllipse(0,0,12,12,RGB(254,254,254),RGB(216,212,204),1);
 tBG.DrawEllipse(3,3,10,10,RGB(254,254,254),RGB(216,212,204),1);
 tG:=tBG.ToGraph;
 tG.Change(Color_Black,Color_Alpha);
 Tmp.AddPic(@tG);
 tG.Free;
 tBG.DrawEllipse(3,3,10,10,RGB(128,255,0),RGB(216,212,204),1);
 tG:=tBG.ToGraph;
 tG.Change(Color_Black,Color_Alpha);
 Tmp.AddPic(@tG);
 Tmp.SetSelect(1);
 tG.Free;
 Role.Create(Tmp);
 Tmp.Free;
 Acts.Create;
 Talk.Create;
 Talk.MouseEvent:=@SACheckBoxMouseDeal1
End;

Constructor SACheckBox.Create(_up,_down:pBaseGraph);
Var
 Tmp:MultiGraph;
Begin
 Check:=False;
 Tmp.Create;
 Tmp.AddPic(_up);
 Tmp.AddPic(_down);
 Tmp.SetSelect(1);
 ROle.Create(Tmp);
 Tmp.Free;
 Acts.Create;
 Talk.Create;
 Talk.MouseEvent:=@SACheckBoxMouseDeal1
End;

Function SACheckBox.Reproduce:pElement;
Var Tmp:pSACheckBox;
Begin
 New(Tmp,Create);
 Tmp^.Role:=Role.Cut;
 Tmp^.Acts:=Acts;
 Tmp^.Talk:=Talk;
 Tmp^.Check:=Check;
 Exit(Tmp)
End;


end.
