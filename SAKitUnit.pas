unit SAkitUnit;
interface
uses SimpleAnimeUnit2,Windows,SysUtils;


Type

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

Type

 pSAButtonBox=^SAButtonBox;
 pSACheckBox=^SACheckBox;

 SAButtonBox=Object(Element)
  Plain:MultiGraph;
  Caption:TextGraph;
  CustomHandle:AnimeLog;
  Constructor Create;
  Constructor Create1(_H,_W:Longint;Const _C:Color);
  Constructor Create2(_up,_over,_down:pBaseGraph);
  Procedure SetSelect(_SAEtp:ShortInt);
  Procedure SetPic(_SAEtp:ShortInt;Ind:pBaseGraph);
  Procedure SetText(Const T:TextGraph);
  Procedure SetText(Tx:Ansistring);
  Procedure CountUpdate(_SAEtp:ShortInt);
  Function Reproduce:pElement;Virtual;
 End;

 SACheckBox=Object(Element)
  Check:Boolean;
  Constructor Create;
  Constructor Create1;
  Constructor Create2;
  Constructor Create3(_up,_down:pBaseGraph);
  Function Reproduce:pElement;Virtual;
 End;


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
 Plain.Create;
 Role.Create;
 Acts.Create;
 Talk.Create;
 CustomHandle.Create;
End;

 Procedure SAButtonBoxMouseDeal1(Env:pElement;Below:pGraph;Const E:SAMouseEvent;inner:ShortInt);
 Var
  cEnv:pSAButtonBox;
 Begin
  cEnv:=pSAButtonBox(Env);
  If Inner And 1=0 Then
   Begin
    cEnv^.SetSelect(SAMouseUp);
    cEnv^.Role.Alpha:=0.85
   End
  Else
  If (E.Button=1)And(MACMouseDown) Then
   Begin
    cEnv^.SetSelect(SAMouseDown);
    cEnv^.Role.Alpha:=1;
    If E.Press Then
    If cEnv^.CustomHandle.Enable Then
     cEnv^.CustomHandle.MouseEvent(Env,Below,E,Inner)
   End
  Else
   Begin
    cEnv^.SetSelect(SAMouseOver);
    cEnv^.Role.Alpha:=0.9
   End;
 End;

Constructor SAButtonBox.Create1(_H,_W:Longint;Const _C:Color);
Var
 Core:pMultiGraph;
 TmpG:pPureGraph;
Begin
 New(TmpG,Create(_H,_W,_C));
 Plain.Create;
 Plain.AddPic(TmpG);
 Plain.AddPic(TmpG);
 Plain.AddPic(TmpG);
 Plain.SetSelect(SAMouseUp);
 Role.Create(Plain);
 Role.Alpha:=0.85;
 Acts.Create;
 Talk.Create;
 Caption.Create;
 CustomHandle.Create;
 Talk.MouseEvent:=@SAButtonBoxMouseDeal1
End;

 Procedure SAButtonBoxMouseDeal2(Env:pElement;Below:pGraph;Const E:SAMouseEvent;inner:ShortInt);
 Var
  cEnv:pSAButtonBox;
 Begin
  cEnv:=pSAButtonBox(Env);
  If Inner And 1=0 Then
   Begin
    cEnv^.SetSelect(SAMouseUp);
   End
  Else
  If (E.Button=1)And(MACMouseDown) Then
   Begin
    cEnv^.SetSelect(SAMouseDown);
    If E.Press Then
    If cEnv^.CustomHandle.Enable Then
     cEnv^.CustomHandle.MouseEvent(Env,Below,E,Inner)
   End
  Else
   Begin
    cEnv^.SetSelect(SAMouseOver);
   End;
 End;

Constructor SAButtonBox.Create2(_up,_over,_down:pBaseGraph);
Begin
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
 Talk.MouseEvent:=@SAButtonBoxMouseDeal2
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
Begin
 Caption:=T.Cut;
 CountUpdate(1);
 CountUpdate(2);
 CountUpdate(3)
End;

Procedure SAButtonBox.SetText(Tx:Ansistring);
Begin
 Caption.Create(Tx);
 CountUpdate(1);
 CountUpdate(2);
 CountUpdate(3)
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

Constructor SACheckBox.Create1;
Var
 Tmp:MultiGraph;
 tBG:BitmapGraph;
 tG:Graph;
 tTG:TextGraph;
Begin
 Check:=False;
 Tmp.Create;
 tBG.Create(12,12);
 tBG.DrawRect(1,1,12,12,RGB(254,254,254),RGB(216,212,204),1);
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

Constructor SACheckBox.Create2;
Var
 Tmp:MultiGraph;
 tBG:BitmapGraph;
 tG:Graph;
Begin
 Check:=False;
 Tmp.Create;
 tBG.Create(12,12);
 tBG.DrawEllipse(1,1,12,12,RGB(254,254,254),RGB(216,212,204),1);
 tBG.DrawEllipse(3,3,10,10,RGB(254,254,254),RGB(216,212,204),1);
 tG:=tBG.ToGraph;
 Tmp.AddPic(@tG);
 tG.Free;
 tBG.DrawEllipse(3,3,10,10,RGB(128,255,0),RGB(216,212,204),1);
 tG:=tBG.ToGraph;
 Tmp.AddPic(@tG);
 Tmp.SetSelect(1);
 tG.Free;
 Role.Create(Tmp);
 Tmp.Free;
 Acts.Create;
 Talk.Create;
 Talk.MouseEvent:=@SACheckBoxMouseDeal1
End;

Constructor SACheckBox.Create3(_up,_down:pBaseGraph);
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