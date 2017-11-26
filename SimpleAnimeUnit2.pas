{$M 100000000,0,100000000}
{$MODE OBJFPC}{$H+}
{$MODESWITCH ADVANCEDRECORDS}
//{$OPTIMIZATION ON,REGVAR,FASTMATH,LOOPUNROLL,CSE,DFA}
//{$R-,S-,Q-,I-,D-}
unit SimpleAnimeUnit2;

interface
uses math,Windows,Commdlg,SysUtils,Classes,ptc,gl,glu,FPImage,MMSystem,
     FPReadJPEG,FPReadPNG,FPReadBMP,FPReadTGA,FPREADGIF,
     FPWriteJPEG,FPWritePNG,FPWriteBMP,FPWriteTGA,
     CommonTypeUnit;

const
 GL_BGRA_EXT=$80e1;



var
 Console:IPTCConsole;
 Format:IPTCFormat;
 Surface:IPTCSurface;
 Event:IPTCEvent;

 ConsoleHWND:HWND;

 FreshLimit:Longint=0;
 LastFresh:Int64;
 UpdateFPS:Int64;
 FPSCount,LastFPS:Longint;


 ScrWidth,ScrHeight:Longint;





Type
 EList=Specialize List<IPTCEvent>;




//Custom Type
type
 shyGifReader=class;



const
 oo=$3f3f3f3f;

const
 tp_NULL=0;
 tp_Line=1;
 tp_Sqr=2;
 tp_Sqrt=3;
 tp_Pow=4;
 tp_Sin=5;
 tp_ArcSin=6;
 tp_ArcTan=7;

 tp_Luna=21;
 tp_Luna2=22;


 tpb_Line=51;
 tpb_Sqr=52;
 tpb_Sqr2=53;
 tpb_Sin=54;

const
 atp_normal=0;
 atp_loop=1;

const
 blend_alpha=1;
 blend_lighten=2;
 blend_darken=3;
 blend_multiply=4;
 blend_filter=5;
 blend_deep=6;
 blend_shallow=7;
 blend_over=8;
 blend_hard=9;
 blend_soft=10;
 blend_vivid=11;

type
 Color=record b,g,r,a:byte end;
 pColor=^Color;

 FColor=record
  case integer of
   0:(c:Color);
   1:(x:Longint);
   2:(s:array[0..3]of char)
 end;


 function RGBA(_r,_g,_b,_a:byte):Color;
 operator =(const a,b:Color)c:Boolean;


 function Color_ALW(const a,b:Color):Longint;
 function Color_Blend(const a,b:Color;BlendTp:Shortint):Color;


 function tp_Count(const x:real;_tp:shortint):real;

const
 Color_Alpha  :Color=(b:0;g:0;r:0;a:0);
 Color_Black  :Color=(b:0;g:0;r:0;a:255);
 Color_Red    :Color=(b:0;g:0;r:255;a:255);
 Color_Green  :Color=(b:0;g:255;r:0;a:255);
 Color_Blue   :Color=(b:255;g:0;r:0;a:255);
 Color_White  :Color=(b:255;g:255;r:255;a:255);
 Color_Gray   :Color=(b:128;g:128;r:128;a:255);
 Color_Yellow :Color=(b:0;g:255;r:255;a:255);
 Color_Cyan   :Color=(b:255;g:255;r:0;a:255);
 Color_Purple :Color=(b:255;g:0;r:255;a:255);
 Color_LYellow:Color=(b:128;g:255;r:255;a:255);
 Color_LGreen :Color=(b:128;g:255;r:0;a:255);
 Color_LRed   :Color=(b:44;g:44;r:250;a:255);
 Color_LBlue  :Color=(b:255;g:128;r:0;a:255);
 Color_LPurple:Color=(b:255;g:128;r:128;a:255);
 Color_Pink   :Color=(b:192;g:128;r:255;a:255);
 Color_LGray  :Color=(b:192;g:192;r:192;a:255);
 Color_Forest :Color=(b:0;g:128;r:0;a:255);
 Color_Tea    :Color=(b:0;g:128;r:128;a:255);
 Color_CRed   :Color=(b:128;g:0;r:255;a:255);
 Color_CGreen :Color=(b:128;g:255;r:128;a:255);
 Color_CBlue  :Color=(b:255;g:255;r:128;a:255);


const
 cp_non=0;
 cp_jpg=1;
 cp_png=2;

 cp_RLC=3;

const
 rev_Horizontal=1;
 rev_Vertical=2;





type

 pBaseGraph=^BaseGraph;
 pBaseAnime=^BaseAnime;
 pGraph=^Graph;
 pTextGraph=^TextGraph;
 pGroupGraph=^GroupGraph;
 pSimpleAnime=^SimpleAnime;
 pTimeLineAnime=^TimeLineAnime;
 pAnimeObj=^AnimeObj;
 pAnimeTag=^AnimeTag;
 pAnimeLog=^AnimeLog;
 pElement=^Element;
 pSAMACEvent=^SAMACEvent;

 BaseGraph=Object
  Width,Height:Longint;
  Constructor Create;
  Destructor Free;Virtual;Abstract;
  Function Reproduce:pBaseGraph;Virtual;Abstract;
  Function Recovery(Env:pSAMACEvent;Obj:pElement;Below:pGraph):pGraph;Virtual;Abstract;
 end;

 Graph=packed object(BaseGraph)
  Canvas:pColor;
  Constructor Create;
  Constructor Create(_h,_w:longint);
  Constructor Create(const g:TFPMemoryImage);
  Constructor CreateText(const s:ansistring;fontsize:longint;const c:Color);
  destructor Free;Virtual;
  function toFPImage:TFPMemoryImage;
  procedure LoadTGA(const path:ansistring);
  procedure LoadBMP(const path:ansistring);
  procedure LoadPNG(const path:ansistring);
  procedure LoadJPG(const path:ansistring);
  procedure LoadGIF(const path:ansistring);
  procedure LoadSAG(const path:ansistring);
  procedure Load(const path:ansistring);
  procedure LoadTGA(data:TMemoryStream);
  procedure LoadBMP(data:TMemoryStream);
  procedure LoadPNG(data:TMemoryStream);
  procedure LoadJPG(data:TMemoryStream);
  procedure LoadGIF(data:TMemoryStream);
  procedure LoadSAG(data:TMemoryStream);
  procedure Load(data:TMemoryStream);
  procedure SaveTGA(const path:ansistring);
  procedure SaveBMP(const path:ansistring);
  procedure SavePNG(const path:ansistring);
  procedure SaveJPG(const path:ansistring);
  function Bits:longint;
  function getp(x,y:longint):Color;
  procedure setp(x,y:longint;const c:Color);
  procedure fill(x1,y1,x2,y2:longint;const c:Color);
  procedure filla(x1,y1,x2,y2:longint;const c:Color);
  procedure resize(newH,newW:Longint);
  procedure reverse(_rv:Longint);
  function cut(x1,y1,x2,y2:longint):Graph;
  function cut:Graph;
  Function Adapt(limitH,limitW:Longint):Graph;
  Function Scale(limitH,limitW:Longint):Graph;
  Function Scale2(LimitH,LimitW:Longint):Graph;
  function LinearMapped(x1,y1,x2,y2,x3,y3,x4,y4:real):Graph;
  function ColorBlend(const G:Graph;x,y:longint;blendtp:shortint):Graph;
  procedure AddText(const s:ansistring;fontsize:longint;const c:Color;_x,_y:longint);
  procedure Change(const csrc,cdst:Color);
  procedure Change(const csrc,cdst:Color;Aw:Longint);
  procedure ChangeNear(x,y:Longint;const cdst:Color);
  procedure ChangeNear(x,y:Longint;const cdst:Color;Aw:Longint);
  function inGraph(x,y:Longint):Boolean;
  property Items[i,j:Longint]:Color read getp write setp;default;
  Function Reproduce:pBaseGraph;Virtual;
  Function Recovery(Env:pSAMACEvent;Obj:pElement;Below:pGraph):pGraph;Virtual;
 end;

 CompressGraph=packed object(BaseGraph)
  CompressType:Shortint;
  CompressStream:TStream;
  Constructor Create;
  Constructor Compress(Const A:Graph;_cp:Longint);
  Destructor Free;Virtual;
  function DeCompress:Graph;
  function cut:CompressGraph;
  Function Reproduce:pBaseGraph;Virtual;
  Function Recovery(Env:pSAMACEvent;Obj:pElement;Below:pGraph):pGraph;Virtual;
 end;

 GroupGraph=packed object(BaseGraph)
  Pic:Specialize List<pGraph>;
  Res:Specialize List<Int64>;
  Constructor Create;
  Destructor Free;Virtual;
  procedure LoadGif(const path:ansistring);
  procedure LoadSAG(const path:ansistring);
  procedure AddPic(const a:Graph);
  procedure AddPic(const a:Graph;const b:Int64);
  procedure Split(const a:Graph;n,m,sz:Longint);
  procedure Operate(const c:Color);
  procedure Operate;
  function Size:Longint;
  function TotTime:Int64;
  procedure SetSpTime(const _t:Int64);
  Function GetFrame(const Time:Int64):Graph;
  function cut:GroupGraph;
  Function Reproduce:pBaseGraph;Virtual;
  Function Recovery(Env:pSAMACEvent;Obj:pElement;Below:pGraph):pGraph;Virtual;
 end;

 shyGifReader=class(TFPReaderGif)
  public
   function ReadFromStream(Stream:TStream):GroupGraph;
   function ReadFromFile(const FileName:Ansistring):GroupGraph;
   constructor Create;override;
   destructor Destroy;override;
 end;

 TextGraph=Packed Object(BaseGraph)
  Text,FontType:Ansistring;
  FontSize:Longint;
  FontAngle:Single;
  FontColor,FontBackColor:Color;
  Bold,Italic,UnderLine,StrikeOut:Boolean;
  CharSet:DWord; //EASTEUROPE_CHARSET  GB2312_CHARSET   SHIFTJIS_CHARSET   RUSSIAN_CHARSET
  Constructor Create;
  Constructor Create(Const Str:Ansistring);
  Destructor Free;Virtual;
  Procedure WriteTo(var A:Graph;_x,_y:Longint);
  Procedure SetText(Const Str:Ansistring);
  Procedure SetSize(_s:Longint);
  Procedure SetType(Const tp:Ansistring);
  Procedure Update;
  Function Cut:TextGraph;
  Function Reproduce:pBaseGraph;Virtual;
  Function Recovery(Env:pSAMACEvent;Obj:pElement;Below:pGraph):pGraph;Virtual;
 End;

 BaseAnime=Object
  AnimeType:ShortInt;
  StdTime,TotTime:Int64;
  Constructor Create;
  Destructor Free;Virtual;Abstract;
  procedure SetType(_atp:shortint);Virtual;
  Procedure SetTime(Const _t:Int64);Virtual;
  procedure Start;Virtual;
  procedure Start(const _t:Int64);Virtual;
  Function AnimeEnd:Boolean;Virtual;Abstract;
  Function Apply(obj:pAnimeObj):Shortint;Virtual;Abstract;
  Function Reproduce:pBaseAnime;Virtual;Abstract;
 End;

 AnimeTag=Packed Object
  Enable:Boolean;
  Source:pBaseAnime;
  Constructor Create;
  Constructor Create(Const a:BaseAnime);
  Destructor Free;Virtual;
  Procedure On;Virtual;
  Procedure Off;Virtual;
  Function StdTime:int64;
  Function TotTime:Int64;
  Function AnimeType:ShortInt;
  Function Cut:AnimeTag;
  Function AnimeEnd:Boolean;
  Function Apply(obj:pAnimeObj):ShortInt;
 End;

 SimpleAnime=packed object(BaseAnime)
  Reserve:Longint;

  an_BiasX,an_BiasY,
  an_ClipX1,an_ClipY1,an_ClipX2,an_ClipY2,
  an_Rotate,an_Alpha,an_ScaleX,an_ScaleY:single;

  tp_BiasX,tp_BiasY,
  tp_ClipX1,tp_ClipY1,tp_ClipX2,tp_ClipY2,
  tp_Rotate,tp_Alpha,tp_ScaleX,tp_ScaleY:shortint;

  Constructor Create;
  Destructor Free;Virtual;
  procedure SetXY(_x,_y:single;_tp:shortint);
  procedure SetClip(_x1,_y1,_x2,_y2:single;_tp:shortint);
  procedure SetRotate(_r:single;_tp:shortint);
  procedure SetAlpha(_a:single;_tp:shortint);
  procedure SetScale(_s:single;_tp:shortint);
  procedure SetXY(_x,_y:single);
  procedure SetClip(_x1,_y1,_x2,_y2:single);
  procedure SetRotate(_r:single);
  procedure SetAlpha(_a:single);
  procedure SetScale(_s:single);
  Function AnimeEnd:Boolean;Virtual;
  Function Apply(obj:pAnimeObj):Shortint;Virtual;
  Function Reproduce:pBaseAnime;Virtual;
 end;

 AnimeObj=packed object
  Visible:boolean;
  Reverse:Longint;
  BiasX,BiasY,ClipX1,ClipY1,ClipX2,ClipY2:Single;
  Rotate,Alpha,ScaleX,ScaleY:single;
  Source:pBaseGraph;
  Constructor Create;
  Constructor Create(const a:BaseGraph);
  Constructor CreateLink(Const a:BaseGraph);
  Destructor Free;
  Function Width:Longint;
  Function Height:Longint;
  procedure SetXY(_x,_y:longint);
  procedure SetClip(_x1,_y1,_x2,_y2:longint);
  procedure SetRotate(_r:single);
  procedure SetAlpha(_a:single);
  procedure SetScale(_s:single);
  procedure SetReverse(_rv:Longint);
  procedure SetSource(const src:BaseGraph);
  procedure SetParam(_x,_y:longint;_r,_a,_s:single);
  procedure SetParam(_x,_y,_x1,_y1,_x2,_y2:longint;_r,_a,_s:single);
  function Inner(x,y:longint):boolean;
  Function Cut:AnimeObj;
 end;

 TLAnimeObj=Packed Record
  BiasX,BiasY,ClipX1,ClipY1,ClipX2,ClipY2,Rotate,Alpha,ScaleX,ScaleY:single;
  tp_BiasX,tp_BiasY,tp_ClipX1,tp_ClipY1,tp_ClipX2,tp_ClipY2,tp_Rotate,tp_Alpha,tp_ScaleX,tp_ScaleY:ShortInt;
  Time:Int64;
  Class Operator <(Const a,b:TLAnimeObj)c:Boolean;
  Class Operator >(Const a,b:TLAnimeObj)c:Boolean;
  Class Operator =(Const a,b:TLAnimeObj)c:Boolean;
  Class Operator <=(Const a,b:TLAnimeObj)c:Boolean;
  Class Operator >=(Const a,b:TLAnimeObj)c:Boolean;
  Procedure Create;
  Procedure SetTime(Const _t:Int64);
  Procedure SetBiasX(Const _v:Single;_tp:ShortInt);
  Procedure SetBiasY(Const _v:Single;_tp:ShortInt);
  Procedure SetClipX1(Const _v:Single;_tp:ShortInt);
  Procedure SetClipY1(Const _v:Single;_tp:ShortInt);
  Procedure SetClipX2(Const _v:Single;_tp:ShortInt);
  Procedure SetClipY2(Const _v:Single;_tp:ShortInt);
  Procedure SetRotate(Const _v:Single;_tp:ShortInt);
  Procedure SetAlpha (Const _v:Single;_tp:ShortInt);
  Procedure SetScaleX(Const _v:Single;_tp:ShortInt);
  Procedure SetScaleY(Const _v:Single;_tp:ShortInt);
 End;

 TimeLineAnime=Packed Object(BaseAnime)
  TimeLine:Specialize Treap<TLAnimeObj>;
  Constructor Create;
  Destructor Free;Virtual;
  Procedure SetFrame(Const _tl:TLAnimeObj);
  Procedure SetFrame(Const _t:Int64;Const _tl:AnimeObj);
  Function AnimeEnd:Boolean;Virtual;
  Function Apply(obj:pAnimeObj):Shortint;Virtual;
  Function Reproduce:pBaseAnime;Virtual;
 End;

 SAMouseEvent=Packed Record x,y,button:Longint; press,release:Boolean End;
 SAKeyEvent=Packed Record key:Longint; press,release,alt,shift,ctrl:Boolean End;
 SAMACEvent=Packed Record
  MouseAccept,KeyAccept,MouseDown:Boolean;
  MouseX,MouseY,MouseClickX,MouseClickY:Longint;
  MouseClickT:Int64;
 End;

 MouseProc=procedure(Env:pSAMACEvent;Obj:pElement;Below:pGraph;Const E:SAMouseEvent;inner:ShortInt);
   KeyProc=procedure(Env:pSAMACEvent;Obj:pElement;Below:pGraph;Const E:SAKeyEvent);
   NonProc=procedure(Env:pSAMACEvent;Obj:pElement;Below:pGraph);

 AnimeLog=packed object
  Enable:Boolean;
  LastInner:shortint;
  MouseEvent:MouseProc;
  KeyEvent:KeyProc;
  NonEvent:NonProc;
  Constructor Create;
  procedure DealMouse(Env:pSAMACEvent;Obj:pElement;Below:pGraph;Const E:SAMouseEvent);
  procedure DealKey(Env:pSAMACEvent;Obj:pElement;Below:pGraph;Const E:SAKeyEvent);
  procedure DealNon(Env:pSAMACEvent;Obj:pElement;Below:pGraph);
 end;


 Element=Object
  Role:AnimeObj;
  Acts:AnimeTag;
  Talk:AnimeLog;
  Constructor Create;
  Constructor Create(const A:AnimeObj);
  Constructor Create(const A:AnimeObj;const B:AnimeTag;const C:AnimeLog);
  Function Width:Longint;
  Function Height:Longint;
  Function Reproduce:pElement;Virtual;
  Destructor Free;Virtual;
 end;

 Stage=object
  Member:Specialize List<pElement>;
  StageMAC:SAMACEvent;
  StageBiasX,StageBiasY:Single;
  constructor Create;
  destructor Free;
  Destructor FreeData;
  function Size:longint;
  function AddObj(const _role:Element):Longint;
  function AddObj(const _role:AnimeObj):longint;
  function AddObj(const _role:BaseGraph):Longint;
  function LinkObj(const _role:Element):Longint;
//function LinkObj(const _role:AnimeObj):longint;
  function LinkObj(const _role:BaseGraph):Longint;
  function AnimeEnd(id:longint):boolean;
  function AnimeAllEnd:boolean;
  function IsInner(id,x,y:longint):boolean;
  function Get(id:longint):pAnimeObj;
  procedure ReplaceObj(id:longint;const _role:AnimeObj);
  procedure DeleteObj(id:longint);
  Procedure AttachAnime(Id:Longint;Const _act:BaseAnime);
  procedure AttachAnime(id:longint;const _act:AnimeTag);
  procedure AttachLogic(id:longint;const _log:AnimeLog);
  Procedure AnimeBegin(id:Longint);
  Procedure AnimeAllBegin;
  procedure StopAnime(id:longint);
  procedure DisplayObj(id:longint;Var Below:Graph);
  procedure DisplayBlendObj(id:longint;tp:shortint;Var Below:Graph);
  procedure Display(Var Below:Graph);
  procedure DisplayBlend(tp:shortint;Var Below:Graph);
  procedure DisplayObj(id:longint);
  procedure DisplayBlendObj(id:longint;tp:shortint);
  procedure Display;
  procedure DisplayBlend(tp:shortint);
  Procedure DisplayDirectObj(id:Longint;Var Below:Graph);
  Procedure DisplayDirect(Var Below:Graph);
  Procedure DisplayDirect;
  procedure Communication;
  Procedure Communication(Const L:EList);
  procedure Communication(Below:pGraph);
  procedure Communication(Below:pGraph;Const L:EList);
 end;




var
 Screen:Graph;

 function NULLGraph:Graph;
 function NULLAnimeObj:AnimeObj;
 function NULLAnimeTag:AnimeTag;
 function NULLAnimeLog:AnimeLog;

 function NowFPS:Longint;
 procedure Lock;
 procedure UnLock;
 procedure OpenGLScreenShot(var Scr:Graph);
 procedure ScreenClear;
 procedure ScreenClear(const c:Color);

 procedure DrawTo(const pen:Graph;var goal:Graph;x,y:longint);
 procedure BlendTo(const pen:Graph;var goal:Graph;x,y:longint);

 procedure PureBlendColor(var a:Color;const b:Color);

 procedure Opt_Mask(var g:Graph;_x1,_y1,_x2,_y2:Single);
 procedure Opt_Scale(var g:Graph;x,y:single);
 procedure Opt_Alpha(var g:Graph;a:single);
 procedure Opt_Rotate(var g:Graph;r:single);



var
 ProgramStart:int64;
 MusicId:longint;

const
 sf_Open=True;
 sf_Save=False;







var
 Main:Stage;

 MAC:SAMACEvent;

function DeltaTime:Int64;

Function RootDirectory:Ansistring;

function GetFile(const regex:ansistring):SList;

Function SelectFile(Open:Boolean):Ansistring;
Function SelectFile(const Entry:SList;Open:Boolean):Ansistring;
Function SelectFile(const Entry:SList;Ext:Pchar;Open:Boolean):Ansistring;

Procedure ExeFile(Const S:Ansistring);
Procedure OpenFile(Const S:Ansistring);

function BeginThread(p:TProcedure):Dword;
procedure EndThread(tid:Dword);

function OpenMusic(const path:ansistring):longint;
procedure PlayMusicRepeat(mid:longint);
procedure PlayMusic(mid:longint);
procedure PlayMusicAt(mid,nowSchedule:Longint);
procedure PauseMusic(mid:longint);
procedure ResumeMusic(mid:longint);
procedure StopMusic(mid:longint);

Function ConsoleUsing:Boolean;

Function GetMouse(var x,y,button:longint):Boolean;
Function GetKey(var key:longint):Boolean;
Function GetMouse(Var E:SAMouseEvent):Boolean;
Function GetKey(Var E:SAKeyEvent):Boolean;
Function GetKeyPress:Boolean;
Function TestMouse(var x,y,button:longint):Boolean;
Function TestKey(var key:longint):Boolean;
Function TestMouse(Var E:SAMouseEvent):Boolean;
Function TestKey(Var E:SAKeyEvent):Boolean;
Function TestKeyPress:Boolean;
Function GetClose:Boolean;
Function GetClose(Const LimT:Int64):Boolean;

Function GetEvent:EList;

procedure ImageToSAGFormat(const g:Graph;const path:AnsiString);
procedure ImagesToSAGFormat(const gs:GroupGraph;const path:AnsiString);

procedure Init(const title:string;Width,Height:longint);
procedure Endit;
Procedure SetTitle(Const title:String);
Procedure SetPosition(X,Y:Longint);

implementation

procedure sw(var a,b:real);
var c:real; begin c:=a; a:=b; b:=c end;

procedure sw(var a,b:Longint);
var c:Longint; begin c:=a; a:=b; b:=c end;

procedure sw(var a,b:Color);
var c:Color; begin c:=a; a:=b; b:=c end;

operator =(const a,b:Color)c:Boolean;
begin exit((a.r=b.r)and(a.g=b.g)and(a.b=b.b)and(a.a=b.a)) end;



Operator =(Const a,b:Graph)c:Boolean;
Begin Exit((a.Width=b.Width)And(a.Height=b.Height)And(a.Canvas=b.Canvas)) End;

//CustomObject-shyGifReader-Begin

 function shyGifReader.ReadFromStream(Stream:TStream):GroupGraph;
 var
  Introducer:byte;
  ColorTableSize :Integer;
  ContProgress: Boolean;

  Img:TFPMemoryImage;
  a,atmp:Graph;
  DelayS:Int64=0;
 begin
  result.Create;
  a.Create;
  atmp.Create;
  FPalette:=nil;
  FScanLine:=nil;
  try
    ContProgress:=true;
    Progress(psStarting, 0, False, Rect(0,0,0,0), '', ContProgress);
    if not ContProgress then exit;

    FPalette := TFPPalette.Create(0);

    Stream.Position:=0;
    // header
    Stream.Read(FHeader,SizeOf(FHeader));
    Progress(psRunning, trunc(100.0 * (Stream.position / Stream.size)), False, Rect(0,0,0,0), '', ContProgress);
    if not ContProgress then exit;

    // Endian Fix Mantis 8541. Gif is always little endian
    {$IFDEF ENDIAN_BIG}
      with FHeader do
        begin
          ScreenWidth := LEtoN(ScreenWidth);
          ScreenHeight := LEtoN(ScreenHeight);
        end;
    {$ENDIF}
    // global palette
    if (FHeader.Packedbit and $80) <> 0 then
    begin
      ColorTableSize := FHeader.Packedbit and 7 + 1;
      ReadPalette(stream, 1 shl ColorTableSize);
    end;

    a.Create(FHeader.ScreenHeight,FHeader.ScreenWidth);
    a.Fill(1,1,a.Height,a.Width,Color_Black);

    Repeat

     // skip extensions
     Repeat
       Introducer:=SkipBlock(Stream);
     until (Introducer = $2C) or (Introducer = $3B);

     // descriptor
     Stream.Read(FDescriptor, SizeOf(FDescriptor));
     {$IFDEF ENDIAN_BIG}
       with FDescriptor do
         begin
           Left := LEtoN(Left);
           Top := LEtoN(Top);
           Width := LEtoN(Width);
           Height := LEtoN(Height);
         end;
     {$ENDIF}

     // local palette
     if (FDescriptor.Packedbit and $80) <> 0 then
     begin
       ColorTableSize := FDescriptor.Packedbit and 7 + 1;
       ReadPalette(stream, 1 shl ColorTableSize);
     end;

     // parse header
     if not AnalyzeHeader then exit;

     // create image
     Img:=TFPMemoryImage.Create(0,0);
     if Assigned(OnCreateImage) then
       OnCreateImage(Self,Img);
     Img.SetSize(FWidth,FHeight);

     // read pixels
     if not ReadScanLine(Stream) then exit;
     if not WriteScanLine(Img) then exit;

     atmp.Create(Img);
     BlendTo(atmp,a,FDescriptor.Top,FDescriptor.Left);

     inc(DelayS,GraphicsCtrlExt.DelayTime);
     Result.AddPic(a,DelayS*10);

     ReAllocMem(FScanLine,0);
     Img.Free;

    Until Stream.Position>=Stream.Size-1;

  finally
   FreeAndNil(FPalette)
  end;
  a.Free;
  atmp.Free;
  Progress(FPimage.psEnding, 100, false, Rect(0,0,FWidth,FHeight), '', ContProgress);
 end;

 Function shyGifReader.ReadFromFile(const FileName:Ansistring):GroupGraph;
 var
  fs:TStream;
 begin
  result.Create;
  if not FileExists(FileName) then exit;
  fs:=TFileStream.Create(FIleName,fmOpenRead);
  result:=ReadFromStream(Fs);
  FreeAndNil(Fs)
 end;

 constructor shyGifReader.Create;
 begin inherited Create end;

 destructor shyGifReader.Destroy;
 begin inherited Destroy end;

//CustomObject-shyGifReader-End


function DeltaTime:Int64;
begin
 exit(GetTickCount64-ProgramStart)
end;


function RGBA(_r,_g,_b,_a:byte):Color;
begin
 with RGBA do
 begin
  r:=_r;
  g:=_g;
  b:=_b;
  a:=_a
 end
end;

function Color_ALW(const a,b:Color):Longint;
var u,v,w:Longint;
begin
 u:=a.R-b.R;
 v:=a.G-b.G;
 w:=a.B-b.B;
 if u<v then sw(u,v);
 if u<w then sw(u,w);
 if v<w then sw(v,w);
 if w>=0 then exit(u);
 if u<=0 then exit(-w);
 exit(u-w)
end;


function GetFile(const regex:ansistring):SList;
var
 i:TSearchRec;
begin
 GetFile.Clear;
 if FindFirst(regex,faAnyFile,i)=0 then
 repeat
  GetFile.pushback(i.Name)
 until FindNext(i)<>0;
 FindClose(i)
end;

function BeginThread(p:TProcedure):Dword;
var tid:dword;
begin
 CreateThread(nil,0,p,nil,0,tid);
end;

procedure EndThread(tid:Dword);
begin
 TerminateThread(tid,0);
 CloseHandle(tid)
end;

Function SelectFile(Open:Boolean):Ansistring;
Var Temp:SList;
Begin
 Temp.Clear;
 Temp.Pushback('All files (*.*)'#0'*.*'#0);
 Result:=SelectFile(Temp,#0,Open);
 Temp.Clear;
End;

Function SelectFile(const Entry:SList;Open:Boolean):Ansistring;
Begin
 Exit(SelectFile(Entry,#0,Open))
End;

Function SelectFile(const Entry:SList;Ext:Pchar;Open:Boolean):Ansistring;
Var
 NameRec:OpenFileName;
 Filter:Ansistring='';
 FName:Array[0..255]of Char;
 i:Longint;
Begin
 FillChar(NameRec,Sizeof(NameRec),0);
 FName[0]:=#0;
 For i:=1 to Entry.Size Do
 Filter:=Filter+Entry.Items[i];
 Filter:=Filter+#0;
 With NameRec Do
 Begin
  LStructSize:=SizeOf(NameRec);
  HWndOwner:=ConsoleHwnd;
  LpStrFilter:=PChar(Filter);
  LpStrFile:=@FName;
  NMaxFile:=255;
  Flags:=OFN_Explorer Or OFN_HideReadOnly;
  If Open Then Flags:=Flags Or OFN_FileMustExist;
  LpStrDefExt:=Ext
 End;
 If Open Then GetOpenFileName(@NameRec)
         Else GetSaveFileName(@NameRec);
 Result:=Ansistring(FName)
End;

Procedure ExeFile(Const S:Ansistring);
Begin
 WinExec(Pchar(S),SW_SHOW)
End;

Function RootDirectory:Ansistring;
Var
 Tmp:Array[0..500]of char;
Begin
 GetCurrentDirectory(500,Tmp);
 Exit(Ansistring(Tmp))
End;

Procedure OpenFile(Const S:Ansistring);
Var
 Path:Ansistring;
 PathFlag:Boolean=True;
 i:Longint;
Begin
 Path:=S;
 For i:=Length(Path)Downto 1 Do
 if (Path[i]='/')Or(Path[i]='\') Then
 Begin
  Delete(Path,i,Length(Path));
  PathFlag:=False;
  Break
 End;
 If PathFlag Then Path:=RootDirectory;
 ShellExecute(0,'open',Pchar(S),nil,Pchar(Path),SW_SHOW)
End;

function OpenMusic(const path:ansistring):longint;
var MStr:ansistring;
begin
 inc(MusicId);
 str(MusicId,MStr);
 mciSendString(pchar('open '+path+' alias '+MStr),nil,0,0);
 exit(MusicId)
end;

procedure PlayMusicRepeat(mid:longint);
var MStr:ansistring;
begin
 Str(mid,MStr);
 mciSendString(pchar('play '+Mstr+' repeat'),nil,0,0);
end;

procedure PlayMusic(mid:longint);
var MStr:ansistring;
begin
 Str(mid,MStr);
 mciSendString(pchar('play '+MStr),nil,0,0)
end;

procedure PlayMusicAt(mid,nowSchedule:Longint);
var MStr,VStr:ansistring;
begin
 Str(mid,MStr);
 Str(nowSchedule,VStr);
 mciSendString(pchar('play '+MStr+' from '+VStr),nil,0,0)
end;

procedure PauseMusic(mid:longint);
var MStr:ansistring;
begin
 Str(mid,MStr);
 mciSendString(pchar('pause '+MStr),nil,0,0)
end;

procedure ResumeMusic(mid:longint);
var MStr:ansistring;
begin
 Str(mid,MStr);
 mciSendString(pchar('resume '+MStr),nil,0,0)
end;

procedure StopMusic(mid:longint);
var MStr:ansistring;
begin
 Str(mid,MStr);
 mciSendString(pchar('stop '+MStr),nil,0,0)
end;

 Function GetMouseCode(B:TPTCMouseButton):Longint;
 Begin
  if B=PTCMouseButton1 then Exit(1);  //Left Mouse
  if B=PTCMouseButton2 then Exit(2);  //Right Mouse
  if B=PTCMouseButton3 then Exit(4);  //Middle Mouse
  if B=PTCMouseButton4 then Exit(8);  //Scroll Up
  if B=PTCMouseButton5 then Exit(16); //Scroll Down
  Exit(0)
 End;

 Function GetMouseCode(Const S:TPTCMouseButtonState):Longint;
 Var I:TPTCMouseButton;
 Begin
  Result:=0;
  For i in S Do Result:=Result Or GetMouseCode(i)
 End;


Function ConsoleUsing:Boolean;
Begin
 If (Not Assigned(Console))Or(Console=Nil) Then Exit(False);
 if Console.PeekEvent(False,[PTCCloseEvent])is IPTCCloseEvent then
 Begin EndIt; Exit(False) End;
 Exit(True)
End;

Function NULLSAMACEvent:SAMACEvent;
Begin
 With Result Do Begin
  MouseAccept:=False;
  KeyAccept:=False;
  MouseDown:=False;
  MouseX:=-1;
  MouseY:=-1;
  MouseClickX:=-1;
  MouseClickY:=-1;
  MouseClickT:=-1;
 End
End;


Function GetMouse(Var MAC:SAMACEvent;Var x,y,button:Longint):Boolean;
Var
 TmpB:IPTCMouseButtonEvent;
 tmpM:IPTCMouseEvent;
Begin
 With MAC Do Begin
 X:=0; Y:=0; Button:=0;
 If Not ConsoleUsing Then Exit(False);
 Console.NextEvent(Event,True,[PTCMouseEvent,PTCCloseEvent]);
 If Supports(Event,IPTCCloseEvent) Then Begin Endit; Exit(False) End;
 If Supports(Event,IPTCMouseEvent) Then
 Begin
  If Supports(Event,IPTCMouseButtonEvent) Then
  Begin
   tmpB:=Event as IPTCMouseButtonEvent;
   x:=tmpB.Y;
   y:=tmpB.X;
   button:=GetMouseCode(tmpB.button);
   If tmpB.Press Then Begin MouseDown:=True; MouseClickX:=x; MouseClickY:=y; MouseClickT:=DeltaTime End;
   If tmpB.Release Then Begin MouseDown:=False; MouseClickX:=-1; MouseClickY:=-1; MouseClickT:=-1 End;
   MouseX:=x;
   MouseY:=y
  End
  Else
  Begin
   tmpM:=Event as IPTCMouseEvent;
   x:=tmpM.Y;
   y:=tmpM.X;
   button:=GetMouseCode(tmpM.ButtonState);
   MouseX:=x;
   MouseY:=y;
  End
 End;
 Exit(True)
 End
End;

Function GetMouse(Var x,y,button:Longint):Boolean;
Begin Exit(GetMouse(MAC,x,y,button)) End;

Function TestMouse(Var MAC:SAMACEvent;Var x,y,button:Longint):Boolean;
Var
 TmpB:IPTCMouseButtonEvent;
 tmpM:IPTCMouseEvent;
Begin
 WIth MAC Do Begin
 X:=0; Y:=0; Button:=0;
 If Not ConsoleUsing Then Exit(False);
 Console.NextEvent(Event,False,[PTCMouseEvent,PTCCloseEvent]);
 If Supports(Event,IPTCCloseEvent) Then Begin Endit; Exit(False) End;
 If Supports(Event,IPTCMouseEvent) Then
 Begin
  If Supports(Event,IPTCMouseButtonEvent) Then
  Begin
   tmpB:=Event as IPTCMouseButtonEvent;
   x:=tmpB.Y;
   y:=tmpB.X;
   button:=GetMouseCode(tmpB.button);
   If tmpB.Press Then Begin MouseDown:=True; MouseClickX:=x; MouseClickY:=y; MouseClickT:=DeltaTime End;
   If tmpB.Release Then Begin MouseDown:=False; MouseClickX:=-1; MouseClickY:=-1; MouseClickT:=-1  End;
   MouseX:=x;
   MouseY:=y;
  End
  Else
  Begin
   tmpM:=Event as IPTCMouseEvent;
   x:=tmpM.Y;
   y:=tmpM.X;
   button:=GetMouseCode(tmpM.ButtonState);
   MouseX:=x;
   MouseY:=y;
  End;
  Exit(True)
 End;
 Exit(False)
 End
End;

Function TestMouse(Var x,y,button:Longint):Boolean;
Begin Exit(TestMouse(MAC,x,y,button)) ENd;

Function GetMouse(Var MAC:SAMACEvent;Var E:SAMouseEvent):Boolean;
Var
 TmpB:IPTCMouseButtonEvent;
 tmpM:IPTCMouseEvent;
Begin
 With MAC Do Begin
 FillChar(E,Sizeof(E),0);
 If Not ConsoleUsing Then Exit(False);
 Console.NextEvent(Event,True,[PTCMouseEvent,PTCCloseEvent]);
 If Supports(Event,IPTCCloseEvent) Then Begin Endit; Exit(False) End;
 If Supports(Event,IPTCMouseEvent) Then
 Begin
  If Supports(Event,IPTCMouseButtonEvent) Then
  Begin
   tmpB:=Event as IPTCMouseButtonEvent;
   E.x:=tmpB.Y;
   E.y:=tmpB.X;
   E.button:=GetMouseCode(tmpB.button);
   E.press:=tmpB.press;
   E.release:=tmpB.release;
   If tmpB.Press Then Begin MouseDown:=True; MouseClickX:=E.x; MouseClickY:=E.y; MouseClickT:=DeltaTime End;
   If tmpB.Release Then Begin MouseDown:=False; MouseClickX:=-1; MouseClickY:=-1; MouseClickT:=-1  End;
   MouseX:=E.x;
   MouseY:=E.y;
  End
  Else
  Begin
   tmpM:=Event as IPTCMouseEvent;
   E.x:=tmpM.Y;
   E.y:=tmpM.X;
   E.button:=GetMouseCode(tmpM.ButtonState);
   E.press:=False;
   E.release:=False;
   MouseX:=E.x;
   MouseY:=E.y;
  End
 End;
 Exit(True)
 End
End;

Function GetMouse(Var E:SAMouseEvent):Boolean;
Begin Exit(GetMouse(MAC,E)) End;


Function TestMouse(Var MAC:SAMACEvent;Var E:SAMouseEvent):Boolean;
Var
 TmpB:IPTCMouseButtonEvent;
 tmpM:IPTCMouseEvent;
Begin
 With MAC Do Begin
 FillChar(E,Sizeof(E),0);
 If Not ConsoleUsing Then Exit(False);
 Console.NextEvent(Event,False,[PTCMouseEvent,PTCCloseEvent]);
 If Supports(Event,IPTCCloseEvent) Then Begin Endit; Exit(False) End;
 If Supports(Event,IPTCMouseEvent) Then
 Begin
  If Supports(Event,IPTCMouseButtonEvent) Then
  Begin
   tmpB:=Event as IPTCMouseButtonEvent;
   E.x:=tmpB.Y;
   E.y:=tmpB.X;
   E.button:=GetMouseCode(tmpB.button);
   E.press:=tmpB.press;
   E.release:=tmpB.release;
   If tmpB.Press Then Begin MouseDown:=True; MouseClickX:=E.x; MouseClickY:=E.y; MouseClickT:=DeltaTime End;
   If tmpB.Release Then Begin MouseDown:=False; MouseClickX:=-1; MouseClickY:=-1; MouseClickT:=-1  End;
   MouseX:=E.x;
   MouseY:=E.y;
  End
  Else
  Begin
   tmpM:=Event as IPTCMouseEvent;
   E.x:=tmpM.Y;
   E.y:=tmpM.X;
   E.button:=GetMouseCode(tmpM.ButtonState);
   E.press:=False;
   E.release:=False;
   MouseX:=E.x;
   MouseY:=E.y;
  End;
  Exit(True)
 End;
 Exit(False)
 End
End;

Function TestMouse(Var E:SAMouseEvent):Boolean;
Begin Exit(TestMouse(MAC,E)) End;



Function GetKey(Var MAC:SAMACEvent;Var Key:Longint):Boolean;
var
 tmpK:IPTCKeyEvent;
Begin
 With MAC DO Begin
 Key:=0;
 If Not ConsoleUsing Then Exit(False);
 Console.NextEvent(Event,True,[PTCKeyEvent,PTCCloseEvent]);
 If Supports(Event,IPTCCloseEvent) Then Begin Endit; Exit(False) End;
 if Supports(Event,IPTCKeyEvent) Then
 Begin
  tmpK:=Event as IPTCKeyEvent;
  key:=tmpK.Code;
 End;
 Exit(True)
 End
End;

Function GetKey(Var key:Longint):Boolean;
Begin Exit(GetKey(MAC,Key)) End;

Function TestKey(Var MAC:SAMACEvent;Var Key:Longint):Boolean;
var
 tmpK:IPTCKeyEvent;
Begin
 With MAC DO Begin
 Key:=0;
 If Not ConsoleUsing Then Exit(False);
 Console.NextEvent(Event,False,[PTCKeyEvent,PTCCloseEvent]);
 If Supports(Event,IPTCCloseEvent) Then Begin Endit; Exit(False) End;
 if Supports(Event,IPTCKeyEvent) Then
 Begin
  tmpK:=Event as IPTCKeyEvent;
  key:=tmpK.Code;
  Exit(True)
 End;
 Exit(False)
 End
End;

Function TestKey(Var Key:Longint):Boolean;
Begin Exit(TestKey(MAC,Key)) ENd;

Function GetKey(Var MAC:SAMACEvent;var E:SAKeyEvent):Boolean;
Var
 TmpK:IPTCKeyEvent;
Begin
 With MAC DO Begin
 FillChar(E,Sizeof(E),0);
 If Not ConsoleUsing Then Exit(False);
 Console.NextEvent(Event,True,[PTCKeyEvent,PTCCloseEvent]);
 If Supports(Event,IPTCCloseEvent) Then Begin Endit; Exit(False) End;
 if Supports(Event,IPTCKeyEvent) Then
 Begin
  tmpK:=Event as IPTCKeyEvent;
  E.key:=tmpK.Code;
  E.press:=tmpK.Press;
  E.release:=tmpK.Release;
  E.shift:=TmpK.Shift;
  E.alt:=TmpK.Alt;
  E.ctrl:=TmpK.Control;
 End;
 Exit(True)
 End
End;

Function GetKey(Var E:SAKeyEvent):Boolean;
Begin Exit(GetKey(MAC,E)) ENd;

Function TestKey(Var MAC:SAMACEvent;var E:SAKeyEvent):Boolean;
Var
 TmpK:IPTCKeyEvent;
Begin
 With MAC Do Begin
 FillChar(E,Sizeof(E),0);
 If Not ConsoleUsing Then Exit(False);
 Console.NextEvent(Event,False,[PTCKeyEvent,PTCCloseEvent]);
 If Supports(Event,IPTCCloseEvent) Then Begin Endit; Exit(False) End;
 if Supports(Event,IPTCKeyEvent) Then
 Begin
  tmpK:=Event as IPTCKeyEvent;
  E.key:=tmpK.Code;
  E.press:=tmpK.Press;
  E.release:=tmpK.Release;
  E.shift:=TmpK.Shift;
  E.alt:=TmpK.Alt;
  E.ctrl:=TmpK.Control;
  Exit(True)
 End;
 Exit(False)
 End
End;

Function TestKey(Var E:SAKeyEvent):Boolean;
Begin Exit(TestKey(MAC,E)) End;


Function GetKeyPress:Boolean;
Begin
 If Not ConsoleUsing Then Exit(False);
 Console.NextEvent(Event,True,[PTCKeyEvent,PTCCloseEvent]);
 If Supports(Event,IPTCCloseEvent) Then Begin Endit; Exit(False) End;
 Exit(Supports(Event,IPTCKeyEvent))
End;

Function TestKeyPress:Boolean;
Begin
 If Not ConsoleUsing Then Exit(False);
 Console.NextEvent(Event,False,[PTCKeyEvent,PTCCloseEvent]);
 If Supports(Event,IPTCCloseEvent) Then Begin Endit; Exit(False) End;
 Exit(Supports(Event,IPTCKeyEvent))
End;

Function GetClose:Boolean;
Begin
 If Not ConsoleUsing Then Exit(False);
 Console.NextEvent(Event,True,[PTCCloseEvent]);
 If Supports(Event,IPTCCloseEvent) Then Begin EndIt; Exit(True) End;
 Exit(False)
End;

Function GetClose(Const LimT:Int64):Boolean;
Var StdTim:Int64;
Begin
 StdTim:=DeltaTime;
 While (ConsoleUsing)And(DeltaTime-StdTim<=LimT) Do Sleep(1)
End;


Function GetEvent:EList;
Begin
 Result.Clear;
 If Not ConsoleUsing Then Exit;
 while Console.NextEvent(Event,False,PTCAnyEvent) do
 Begin
  If Supports(Event,IPTCCloseEvent) Then Begin EndIt; Result.Clear; Exit End;
  Result.Pushback(Event)
 End
End;


procedure Init(const title:string;Width,Height:longint);
begin
 Console:=TPTCConsoleFactory.CreateNew;
  Format:=TPTCFormatFactory.CreateNew(32,$FF0000,$FF00,$FF);
 Console.Option('windowed output');
 Console.Option('intercept window close');
 Console.Open(title,Width,Height,Format);
 Surface:=TPTCSurfaceFactory.CreateNew(Width,Height,Format);
 ConsoleHWND:=FindWindow(nil,PChar(Title))
end;

procedure Endit;
begin
 if Assigned(Console) then Console.Close;
 Console:=Nil
end;

Procedure SetTitle(Const title:String);
Begin
 SetWindowText(ConsoleHWND,PChar(Title))
End;

Procedure SetPosition(X,Y:Longint);
Begin
 MoveWindow(ConsoleHWND,X,Y,Console.Width,Console.Height,True)
End;

//Object-BaseGraph-Begin

Constructor BaseGraph.Create;
begin
 Width:=0;
 Height:=0
end;

//Object-BaseGraph-End


//Object-Graph-Begin

Constructor Graph.Create;
begin
 Canvas:=nil;
 Width:=0;
 Height:=0;
end;

constructor Graph.Create(_h,_w:longint);
begin
 Free;
 Width:=_W;
 Height:=_H;
 GetMem(Canvas,bits);
end;

constructor Graph.Create(const g:TFPMemoryImage);
var i,j:longint;
begin
 Create(g.Height,g.Width);
 for i:=0 to Height-1 do
 for j:=0 to Width-1 do
 with g[j,i] do
 with Canvas[i*Width+j] do
 begin
  r:=Red>>8;
  g:=Green>>8;
  b:=Blue>>8;
  a:=Alpha>>8
 end
end;

constructor Graph.CreateText(const s:ansistring;fontsize:longint;const c:Color);
Var
 Tmp:TextGraph;
 BackC:Color;
begin
 Tmp.Create(s);
 Tmp.SetSize(fontsize);
 Tmp.FontColor:=c;
 Create(Tmp.Height,Tmp.Width);
 If c<>Color_Black Then BackC:=Color_Black
                   Else BackC:=Color_White;
 Fill(1,1,Height,Width,BackC);
 Tmp.WriteTo(Self,1,1);
 Change(BackC,Color_Alpha)
end;

procedure Graph.AddText(const s:ansistring;fontsize:longint;const c:Color;_x,_y:longint);
Var
 Tmp:TextGraph;
begin
 Tmp.Create(s);
 Tmp.SetSize(fontsize);
 Tmp.FontColor:=c;
 Tmp.WriteTo(Self,_x,_y)
end;

procedure Graph.Load(const path:ansistring);
Var
 HeaderGet:File;
 Buf:Array[0..15]Of Char;
begin
 if not FileExists(path) then exit;
 AssignFile(HeaderGet,Path);
 Reset(HeaderGet,1);
 BlockRead(HeaderGet,Buf,16);
 Close(HeaderGet);
 If Copy(Buf,1,2)='BM'                      Then LoadBMP(Path) Else
 If Copy(Buf,1,8)=#137#80#78#71#13#10#26#10 Then LoadPNG(Path) Else
 If Copy(Buf,1,2)=#255#216                  Then LoadJPG(Path) Else
 If Copy(Buf,1,3)='GIF'                     Then LoadGIF(Path) Else
 If LowerCase(Copy(Buf,1,10))='`imagedata'  Then LoadSAG(Path) Else
 If (Buf[1]in[#0,#1])And(Buf[2]in[#2,#10])  Then LoadTGA(Path)
end;

procedure Graph.LoadTGA(const path:ansistring);
var
 Img:TFPMemoryImage;
 Reader:TFPCustomImageReader;
begin
 Img:=TFPMemoryImage.Create(0,0);
 Reader:=TFPReaderTarga.Create;
 Img.LoadFromFile(path,Reader);
 Create(Img);
 Img.Free;
 Reader.Free
end;

procedure Graph.LoadBMP(const path:ansistring);
var
 Img:TFPMemoryImage;
 Reader:TFPCustomImageReader;
begin
 Img:=TFPMemoryImage.Create(0,0);
 Reader:=TFPReaderBMP.Create;
 Img.LoadFromFile(path,Reader);
 Create(Img);
 Img.Free;
 Reader.Free
end;

procedure Graph.LoadPNG(const path:ansistring);
var
 Img:TFPMemoryImage;
 Reader:TFPCustomImageReader;
begin
 Img:=TFPMemoryImage.Create(0,0);
 Reader:=TFPReaderPNG.Create;
 Img.LoadFromFile(path,Reader);
 Create(Img);
 Img.Free;
 Reader.Free
end;

procedure Graph.LoadJPG(const path:ansistring);
var
 Img:TFPMemoryImage;
 Reader:TFPCustomImageReader;
begin
 Img:=TFPMemoryImage.Create(0,0);
 Reader:=TFPReaderJPEG.Create;
 Img.LoadFromFile(path,Reader);
 Create(Img);
 Img.Free;
 Reader.Free
end;

procedure Graph.LoadGIF(const path:ansistring);
var
 Img:TFPMemoryImage;
 Reader:TFPCustomImageReader;
begin
 Img:=TFPMemoryImage.Create(0,0);
 Reader:=TFPReaderGIF.Create;
 Img.LoadFromFile(path,Reader);
 Create(Img);
 Img.Free;
 Reader.Free
end;

procedure Graph.LoadSAG(const path:Ansistring);
var
 F:Text;
 s:AnsiString;
 tmp:FColor;
 i,j:Longint;
 procedure gets;begin with tmp do read(f,s[0],s[1],s[2],s[3]) end;
begin
 Create;
 Assign(F,path); Reset(F);
 Readln(F,s);
 if s<>'`imagedata' then begin Close(F); exit end;
 gets; j:=tmp.x;
 gets; i:=tmp.x;
 Create(i,j);
 for i:=1 to Height do
 for j:=1 to Width do begin gets; SetP(i,j,tmp.c) end;
 close(F)
end;

procedure Graph.Load(data:TMemoryStream);
Var
 HeaderGet:File;
 Buf:Array[0..15]Of Char;
begin
 data.Position:=0;
 data.Read(Buf,16);
 If Copy(Buf,1,2)='BM'                      Then LoadBMP(data) Else
 If Copy(Buf,1,8)=#137#80#78#71#13#10#26#10 Then LoadPNG(data) Else
 If Copy(Buf,1,2)=#255#216                  Then LoadJPG(data) Else
 If Copy(Buf,1,3)='GIF'                     Then LoadGIF(data) Else
 If LowerCase(Copy(Buf,1,10))='`imagedata'  Then LoadSAG(data) Else
 If (Buf[1]in[#0,#1])And(Buf[2]in[#2,#10])  Then LoadTGA(data)
end;

procedure Graph.LoadTGA(data:TMemoryStream);
var
 Img:TFPMemoryImage;
 Reader:TFPCustomImageReader;
begin
 Img:=TFPMemoryImage.Create(0,0);
 Reader:=TFPReaderTarga.Create;
 data.Position:=0;
 Img.LoadFromStream(data,Reader);
 Create(Img);
 Img.Free;
 Reader.Free
end;

procedure Graph.LoadBMP(data:TMemoryStream);
var
 Img:TFPMemoryImage;
 Reader:TFPCustomImageReader;
begin
 Img:=TFPMemoryImage.Create(0,0);
 Reader:=TFPReaderBMP.Create;
 data.Position:=0;
 Img.LoadFromStream(data,Reader);
 Create(Img);
 Img.Free;
 Reader.Free
end;

procedure Graph.LoadPNG(data:TMemoryStream);
var
 Img:TFPMemoryImage;
 Reader:TFPCustomImageReader;
begin
 Img:=TFPMemoryImage.Create(0,0);
 Reader:=TFPReaderPNG.Create;
 data.Position:=0;
 Img.LoadFromStream(data,Reader);
 Create(Img);
 Img.Free;
 Reader.Free
end;

procedure Graph.LoadJPG(data:TMemoryStream);
var
 Img:TFPMemoryImage;
 Reader:TFPCustomImageReader;
begin
 Img:=TFPMemoryImage.Create(0,0);
 Reader:=TFPReaderJPEG.Create;
 data.Position:=0;
 Img.LoadFromStream(data,Reader);
 Create(Img);
 Img.Free;
 Reader.Free
end;

procedure Graph.LoadGIF(data:TMemoryStream);
var
 Img:TFPMemoryImage;
 Reader:TFPCustomImageReader;
begin
 Img:=TFPMemoryImage.Create(0,0);
 Reader:=TFPReaderGIF.Create;
 data.Position:=0;
 Img.LoadFromStream(data,Reader);
 Create(Img);
 Img.Free;
 Reader.Free
end;

procedure Graph.LoadSAG(data:TMemoryStream);
var
 buf:Array[0..11]Of Char;
 tmp:FColor;
 i,j:Longint;
begin
 Create;
 data.Position:=0;
 data.Read(Buf,12);
 If buf<>'`imagedata'#13#10 Then Exit;
 data.Read(tmp,4); j:=tmp.x;
 data.Read(tmp,4); i:=tmp.x;
 Create(i,j);
 for i:=1 to Height do
 for j:=1 to Width do begin data.Read(tmp,4); SetP(i,j,tmp.c) end;
end;

function Graph.toFPImage:TFPMemoryImage;
var i,j:Longint; c:TFPColor;
begin
 result:=TFPMemoryImage.Create(Width,Height);
 with c do
 for i:=0 to Height-1 do
 for j:=0 to Width-1 do
 with Canvas[i*Width+j] do
 begin
  Red:=r<<8;
  Green:=g<<8;
  Blue:=b<<8;
  Alpha:=a<<8;
  result[j,i]:=c
 end
end;

procedure Graph.SaveBMP(const path:ansistring);
var
 Img:TFPMemoryImage;
 writer:TFPCustomImageWriter;
begin
 Img:=toFPImage;
 writer:=TFPWriterBMP.Create;
 Img.SaveToFile(path,writer);
 img.Free;
 writer.Free
end;

procedure Graph.SaveTGA(const path:ansistring);
var
 Img:TFPMemoryImage;
 writer:TFPCustomImageWriter;
begin
 Img:=toFPImage;
 writer:=TFPWriterTARGA.Create;
 Img.SaveToFile(path,writer);
 img.Free;
 writer.Free
end;

procedure Graph.SavePNG(const path:ansistring);
var
 Img:TFPMemoryImage;
 writer:TFPCustomImageWriter;
begin
 Img:=toFPImage;
 writer:=TFPWriterPNG.Create;
 Img.SaveToFile(path,writer);
 img.Free;
 writer.Free
end;

procedure Graph.SaveJPG(const path:ansistring);
var
 Img:TFPMemoryImage;
 writer:TFPCustomImageWriter;
begin
 Img:=toFPImage;
 writer:=TFPWriterJPEG.Create;
 Img.SaveToFile(path,writer);
 img.Free;
 writer.Free
end;

destructor Graph.Free;
begin
 if Assigned(Canvas) then
  FreeMem(Canvas);
 Create
end;

function Graph.bits:longint;
begin
 exit(Width*Height*4)
end;

function Graph.getp(x,y:longint):Color;
begin
 exit(Canvas[(x-1)*Width+(y-1)])
end;

procedure Graph.setp(x,y:longint;const c:Color);
begin
 Canvas[(x-1)*Width+(y-1)]:=c
end;

procedure Graph.fill(x1,y1,x2,y2:longint;const c:Color);
var i,j:longint; p:pColor;
begin
 x1:=Max(1,x1); x2:=Min(Height,x2);
 y1:=Max(1,y1); y2:=Min(Width,y2);
 for i:=x1-1 to x2-1 do Begin p:=Canvas+i*Width+y1-1;
 for j:=y1-1 to y2-1 Do Begin p^:=c; inc(p) End End
end;

Procedure Graph.filla(x1,y1,x2,y2:Longint;const c:Color);
Var i,j:Longint; p:pColor;
Begin
 If c.a=0 Then Exit;
 x1:=Max(1,x1); x2:=Min(Height,x2);
 y1:=Max(1,y1); y2:=Min(Width,y2);
 For i:=x1-1 to x2-1 Do Begin p:=Canvas+i*Width+y1-1;
 For j:=y1-1 to y2-1 Do Begin PureBlendColor(p^,c); Inc(p) End End
End;

procedure Graph.Resize(newH,newW:Longint);
Var tmp:pGraph;
begin
 If (Height<=0)Or(Width<=0)Or(newH<=0)Or(newW<=0) Then Begin Create; Exit End;
 New(tmp);
 tmp^:=Scale(newH,newW);
 Free;
 Self:=tmp^
end;

procedure Graph.Reverse(_rv:Longint);
var i,j:Longint;
begin
 if _rv and rev_Horizontal<>0 then
 begin
  for i:=0 to Height-1 do
  for j:=0 to Width>>1-1 do sw(Canvas[i*Width+j],Canvas[i*Width+Width-1-j])
 end;
 if _rv and rev_Vertical<>0 then
 begin
  for j:=0 to Width-1 do
  for i:=0 to Height>>1-1 do sw(Canvas[i*Width+j],Canvas[(Height-1-i)*Width+j])
 end
end;

function Graph.cut(x1,y1,x2,y2:longint):Graph;
var
 i,j:longint;
begin
 cut.Create;
 cut.Create(x2-x1+1,y2-y1+1);
 for i:=x1 to x2 do
 for j:=y1 to y2 do
 if inGraph(i,j) then cut.setp(i-x1+1,j-y1+1,GetP(i,j))
                 else cut.setp(i-x1+1,j-y1+1,Color_Alpha)
end;

function Graph.cut:Graph;
begin
 cut.Create;
 cut.Width:=Width;
 cut.Height:=Height;
 cut.Canvas:=GetMem(bits);
 Move(Canvas^,Cut.Canvas^,bits)
end;

Function Graph.Adapt(limitH,limitW:Longint):Graph;
Var ScaleFactor:Single;
Begin
 ScaleFactor:=Math.Max(LimitH/Height,LimitW/Width);
 Adapt:=Scale(Round(Height*ScaleFactor),Round(Width*ScaleFactor));
End;

Function Graph.Scale(limitH,limitW:Longint):Graph;
Var i,j:Longint; sx,sy:Real; p,q:pColor;
Begin
 If (Height<=0)Or(Width<=0)Or(LimitH<=0)Or(LimitW<=0) Then Begin Result.Create; Exit End;
 Result.Create(LimitH,LimitW);
 sx:=(Height-1)/LimitH;
 sy:=(Width-1)/LimitW;
 p:=Result.Canvas;
 For i:=0 to LimitH-1 Do Begin q:=Canvas+Round(i*Sx)*Width;
 For j:=0 to LimitW-1 Do Begin
  p^:=(q+Round(j*sy))^; Inc(p) End End
End;

Function Graph.Scale2(limitH,limitW:Longint):Graph;
Var i,j,k:Longint; sx,sy,tx,ty:Real; p,u,v:pColor;

 Function CountDisWeight(Const rx,ry:Real;Const c1,c2,c3,c4:Color):Color;
 Var d1,d2,d3,d4,di:Real;
 Begin
  d1:=Sqrt(Sqr(  rx)+Sqr(  ry));
  d2:=Sqrt(Sqr(1-rx)+Sqr(  ry));
  d3:=Sqrt(Sqr(  rx)+Sqr(1-ry));
  d4:=Sqrt(Sqr(1-rx)+Sqr(1-ry));
  di:=1/(d1+d2+d3+d4);
  d1:=d1*di; d2:=d2*di; d3:=d3*di; d4:=d4*di;
  Exit(RGBA(Round(c1.r*d1+c2.r*d2+c3.r*d3+c4.r*d4),
            Round(c1.g*d1+c2.g*d2+c3.g*d3+c4.g*d4),
            Round(c1.b*d1+c2.b*d2+c3.b*d3+c4.b*d4),
            Round(c1.a*d1+c2.a*d2+c3.a*d3+c4.a*d4)))
 End;

Begin
 If (Height<=0)Or(Width<=0)Or(LimitH<=0)Or(LimitW<=0) Then Begin Result.Create; Exit End;
 Result.Create(LimitH,LimitW);
 sx:=(Height-1)/LimitH;
 sy:=(Width-1)/LimitW;
 p:=Result.Canvas;
 For i:=0 to LimitH-1 Do Begin tx:=i*Sx; u:=Canvas+Trunc(tx)*Width; v:=u+Width; tx:=tx-Int(Tx);
 For j:=0 to LimitW-1 Do Begin ty:=j*Sy; k:=Trunc(ty);
  p^:=CountDisWeight(tx,ty-k,(u+k)^,(u+k+1)^,(v+k)^,(v+k+1)^); Inc(p) End End
End;

Function Graph.Reproduce:pBaseGraph;
var Tmp:pGraph;
begin
 New(Tmp);
 Tmp^:=Cut;
 Exit(Tmp)
end;

function Graph.LinearMapped(x1,y1,x2,y2,x3,y3,x4,y4:real):Graph;
var
 sz:longint=0;
 a:array[1..9,1..9]of real;
 i,j,u,v:longint;
 OutG:Graph;

 procedure SetU(U,X,Y:real);
 begin
  inc(sz);
  a[sz,1]:=x;
  a[sz,2]:=y;
  a[sz,3]:=1;
  a[sz,4]:=0;
  a[sz,5]:=0;
  a[sz,6]:=0;
  a[sz,7]:=-u*x;
  a[sz,8]:=-u*y;
  a[sz,9]:=u
 end;

 procedure SetV(V,X,Y:real);
 begin
  inc(sz);
  a[sz,1]:=0;
  a[sz,2]:=0;
  a[sz,3]:=0;
  a[sz,4]:=x;
  a[sz,5]:=y;
  a[sz,6]:=1;
  a[sz,7]:=-v*x;
  a[sz,8]:=-v*y;
  a[sz,9]:=v
 end;

 procedure Gauss;
 var
  i,j,k:longint;
  t:real;
 begin
  for i:=1 to 8 do
  begin
   for j:=i to 8 do if abs(a[j,i])>1e-7 then break;
   if j<>i then for k:=1 to 9 do sw(a[i,k],a[j,k]);
   t:=a[i,i];
   for k:=1 to 9 do a[i,k]:=a[i,k]/t;
   for j:=1 to 8 do if j<>i then begin t:=a[j,i];
   for k:=1 to 9 do a[j,k]:=a[j,k]-a[i,k]*t end
  end
 end;

 function CountU(X,Y:real):real;
 begin
  if abs(a[7,9]*X+a[8,9]*Y+1)<1e-7 then exit(-1);
  exit((a[1,9]*X+a[2,9]*Y+a[3,9])/(a[7,9]*X+a[8,9]*Y+1))
 end;

 function CountV(X,Y:real):real;
 begin
  if abs(a[7,9]*X+a[8,9]*Y+1)<1e-7 then exit(-1);
  exit((a[4,9]*X+a[5,9]*Y+a[6,9])/(a[7,9]*X+a[8,9]*Y+1))
 end;

begin
 SetU(1,x1,y1); SetV(1,x1,y1);
 SetU(1,x2,y2); SetV(Width,x2,y2);
 SetU(Height,x3,y3); SetV(1,x3,y3);
 SetU(Height,x4,y4); SetV(Width,x4,y4);
 Gauss;
 OutG.Create;
 OutG.Create(Height,Width);
 OutG.Fill(1,1,Height,Width,Color_Alpha);
 for i:=1 to Height do
 for j:=1 to Width do
 begin
  u:=Round(CountU(i,j));
  v:=Round(CountV(i,j));
  if (1<=u)and(u<=Height)and(1<=v)and(v<=Width) then OutG.SetP(i,j,GetP(u,v))
 end;
 exit(OutG)
end;

function Color_Blend(const a,b:Color;BlendTp:Shortint):Color;
var
 C1,C2,C3:Color;
 a1,a2,na:Single;
begin
 C1:=a;
 C2:=b;
 Case BlendTp of
  blend_alpha:
   Begin
    a1:=C1.A/255;
    a2:=C2.A/255;
    na:=a1+a2-a1*a2;
    if abs(na)<1e-7 then Exit(RGBA(255,255,255,0));
    Exit(RGBA(Round((C1.R*a1*(1-a2)+C2.R*a2)/na),
              Round((C1.G*a1*(1-a2)+C2.G*a2)/na),
              Round((C1.B*a1*(1-a2)+C2.B*a2)/na),Round(na*255)))
   End;
  blend_lighten:
   Exit(RGBA(max(C1.R,C2.R),max(C1.G,C2.G),max(C1.B,C2.B),C2.A));
  blend_darken:
   Exit(RGBA(min(C1.R,C2.R),min(C1.G,C2.G),min(C1.B,C2.B),C2.A));
  blend_multiply:
   Exit(RGBA(Round(longint(C1.R)*C2.R/255),
             Round(longint(C1.G)*C2.G/255),
             Round(longint(C1.B)*C2.B/255),C2.A));
  blend_filter:   //Screen?
   Exit(RGBA(Round(255-longint(255-C1.R)*(255-C2.R)/255),
             Round(255-longint(255-C1.G)*(255-C2.G)/255),
             Round(255-longint(255-C1.B)*(255-C2.B)/255),C2.A));
  blend_deep:     //Burn??
   Begin
    if C2.R=0 then C3.R:=0 else C3.R:=Max(0,Round(C1.R-longint(255-C1.R)*(255-C2.R)/C2.R));
    if C2.G=0 then C3.G:=0 else C3.G:=Max(0,Round(C1.G-longint(255-C1.G)*(255-C2.G)/C2.G));
    if C2.B=0 then C3.B:=0 else C3.B:=Max(0,Round(C1.B-longint(255-C1.B)*(255-C2.B)/C2.B));
    C3.A:=C2.A;
    Exit(C3)
   End;
  blend_shallow:  //Dodge??
   Begin
    if C2.R=255 then C3.R:=255 else C3.R:=Min(255,Round(C1.R+longint(C1.R)*C2.R/(255-C2.R)));
    if C2.G=255 then C3.G:=255 else C3.G:=Min(255,Round(C1.G+longint(C1.G)*C2.G/(255-C2.G)));
    if C2.B=255 then C3.B:=255 else C3.B:=Min(255,Round(C1.B+longint(C1.B)*C2.B/(255-C2.B)));
    C3.A:=C2.A;
    Exit(C3)
   End;
  blend_over:     //overlay??
   Begin
    if C1.R<=128 then C3.R:=Round(Longint(C1.R)*C2.R/255)
                 else C3.R:=Round(255-Longint(C1.R)*C2.R/255);
    if C1.G<=128 then C3.G:=Round(Longint(C1.G)*C2.G/255)
                 else C3.G:=Round(255-Longint(C1.G)*C2.G/255);
    if C1.B<=128 then C3.B:=Round(Longint(C1.B)*C2.B/255)
                 else C3.B:=Round(255-Longint(C1.B)*C2.B/255);
    C3.A:=C2.A;
    Exit(C3)
   End;
  blend_hard:
   begin
    if C2.R<=128 then C3.R:=Round(Longint(C1.R)*C2.R/128)
                 else C3.R:=Round(255-Longint(255-C1.R)*(255-C2.R)/128);
    if C2.G<=128 then C3.G:=Round(Longint(C1.G)*C2.G/128)
                 else C3.G:=Round(255-Longint(255-C1.G)*(255-C2.G)/128);
    if C2.B<=128 then C3.B:=Round(Longint(C1.B)*C2.B/128)
                 else C3.B:=Round(255-Longint(255-C1.B)*(255-C2.B)/128);
    C3.A:=C2.A;
    Exit(C3)
   End;
  blend_soft:
   Begin
    if C2.R<=128 then C3.R:=Round(Longint(C1.R)*C2.R/128+Sqr(C1.R/255)*(255-Longint(C2.R)*2))
                 else C3.R:=Round(Longint(C1.R)*(255-C2.R)/128+Sqr(C1.R/255)*(Longint(C2.R)*2-255));
    if C2.G<=128 then C3.G:=Round(Longint(C1.G)*C2.G/128+Sqr(C1.G/255)*(255-Longint(C2.G)*2))
                 else C3.G:=Round(Longint(C1.G)*(255-C2.G)/128+Sqr(C1.G/255)*(Longint(C2.G)*2-255));
    if C2.B<=128 then C3.B:=Round(Longint(C1.B)*C2.B/128+Sqr(C1.B/255)*(255-Longint(C2.B)*2))
                 else C3.B:=Round(Longint(C1.B)*(255-C2.B)/128+Sqr(C1.B/255)*(Longint(C2.B)*2-255));
    C3.A:=C2.A;
    Exit(C3)
   End;
  blend_vivid:
   Begin
    if C2.R<=128 then if C2.R=  0 then C3.R:=  0 else C3.R:=Max(  0,Round(C1.R-Longint(255-C1.R)*(255-Longint(C2.R)*2)/(Longint(C2.R)*2)))
                 else if C2.R=255 then C3.R:=255 else C3.R:=Min(255,Round(C1.R+Longint(C1.R)*(Longint(C2.R)*2-255)/(2*Longint(255-C2.R))));
    if C2.G<=128 then if C2.G=  0 then C3.G:=  0 else C3.G:=Max(  0,Round(C1.G-Longint(255-C1.G)*(255-Longint(C2.G)*2)/(Longint(C2.G)*2)))
                 else if C2.G=255 then C3.G:=255 else C3.G:=Min(255,Round(C1.G+Longint(C1.G)*(Longint(C2.G)*2-255)/(2*Longint(255-C2.G))));
    if C2.B<=128 then if C2.B=  0 then C3.B:=  0 else C3.B:=Max(  0,Round(C1.B-Longint(255-C1.B)*(255-Longint(C2.B)*2)/(Longint(C2.B)*2)))
                 else if C2.B=255 then C3.B:=255 else C3.B:=Min(255,Round(C1.B+Longint(C1.B)*(Longint(C2.B)*2-255)/(2*Longint(255-C2.B))));
    C3.A:=C2.A;
    Exit(C3)
  End
 End
end;

function Graph.ColorBlend(const G:Graph;x,y:longint;blendtp:shortint):Graph;
var
 i,j:longint;
 OutG:Graph;
begin
 OutG:=Cut;
 for i:=max(1,x) to min(Height,x-1+G.height) do
 for j:=max(1,y) to min( Width,y-1+G.Width) do
  OutG.SetP(i,j,Color_Blend(GetP(i,j),G.GetP(i-x+1,j-y+1),blendtp));
 exit(OutG)
end;

procedure Graph.Change(const csrc,cdst:Color);
var i,j:longint;
begin
 for i:=1 to Height do
 for j:=1 to Width do if getp(i,j)=csrc then setp(i,j,cdst)
end;

procedure Graph.Change(const csrc,cdst:Color;Aw:Longint);
var i,j:Longint;
begin
 for i:=1 to Height do
 for j:=1 to Width do if Color_ALW(GetP(i,j),csrc)<=Aw then SetP(i,j,cdst)
end;

procedure Graph.ChangeNear(x,y:Longint;const cdst:Color);
var csrc:Color;

 procedure SearchNear(x,y:Longint);
 begin
  if not inGraph(x,y) then Exit;
  if GetP(x,y)<>csrc then Exit;
  SetP(x,y,cdst);
  SearchNear(x-1,y);
  SearchNear(x+1,y);
  SearchNear(x,y-1);
  SearchNear(x,y+1)
 end;

begin
 if not inGraph(x,y) then exit;
 csrc:=GetP(x,y);
 if csrc=cdst then Exit;
 SearchNear(x,y)
end;

procedure Graph.ChangeNear(x,y:Longint;const cdst:Color;Aw:Longint);
var csrc:Color;

 procedure SearchNear(x,y:Longint);
 begin
  if not inGraph(x,y) then Exit;
  if Color_ALW(GetP(x,y),csrc)>Aw then Exit;
  SetP(x,y,cdst);
  SearchNear(x-1,y);
  SearchNear(x+1,y);
  SearchNear(x,y-1);
  SearchNear(x,y+1)
 end;

begin
 if not inGraph(x,y) then exit;
 csrc:=GetP(x,y);
 if csrc=cdst then Exit;
 SearchNear(x,y)
end;

function Graph.inGraph(x,y:Longint):Boolean;
begin
 exit((0<x)and(x<=Height)and(0<y)and(y<=Width))
end;

Function Graph.Recovery(Env:pSAMACEvent;Obj:pElement;Below:pGraph):pGraph;
Var Tmp:pGraph;
begin
 New(Tmp);
 Tmp^:=Cut;
 Exit(Tmp)
end;


//Object-Graph-End

//Object-CompressGraph-Begin

Constructor CompressGraph.Create;
begin
 Width:=0;
 Height:=0;
 CompressType:=cp_non;
 CompressStream:=Nil;
end;

Destructor CompressGraph.Free;
begin
 Width:=0;
 Height:=0;
 CompressType:=cp_non;
 FreeAndNil(CompressStream)
end;

Function CompressGraph.Cut:CompressGraph;
begin
 cut.Create;
 cut.Width:=Width;
 cut.Height:=Height;
 cut.CompressType:=CompressType;
 cut.CompressStream:=TMemoryStream.Create;
 CompressStream.Position:=0;
 cut.CompressStream.CopyFrom(CompressStream,0);
 cut.CompressStream.Position:=0;
 CompressStream.Position:=0
end;

Function CompressGraph.Reproduce:pBaseGraph;
var Tmp:^CompressGraph;
begin
 New(Tmp);
 Tmp^:=Cut;
 Exit(Tmp)
end;

Constructor CompressGraph.Compress(Const A:Graph;_cp:Longint);
 procedure Compress_RLC;
 var
  tmp:FColor;
  arr:pint;
  n,i,j,L,R,shyFlag,shyLast,shyCount,shyPointer:Longint;

  procedure puts(x:Longint);begin arr[shyPointer]:=x; inc(shyPointer) end;

 begin
  n:=A.Width*A.Height;
  GetMem(arr,n*4);
  for i:=0 to n-1 do begin tmp.c:=A.Canvas[i]; arr[i]:=tmp.x end;
  L:=0;
  R:=N;
  while L<R do
  begin
   if arr[l]=l then inc(l) else
   if (arr[l]>=R)or(arr[l]<L)or(arr[arr[l]]=arr[l]) then begin dec(R); arr[l]:=arr[R] end
   else sw(arr[l],arr[arr[l]])
  end;
  shyFlag:=l;
  shyLast:=0;
  shyCount:=0;
  shyPointer:=0;
  puts(shyFlag);
  for i:=0 to n do begin
   if i<>n then
   begin
    tmp.c:=A.Canvas[i];
    if tmp.x=shyLast then begin inc(shyCount); continue end
   end;
   if shyCount>3 then
    begin
     puts(shyFlag);
     puts(shyLast);
     puts(shyCount)
    end
   else
    begin
     for j:=1 to shyCount do puts(shyLast)
    end;
   shyLast:=tmp.x;
   shyCount:=1
  end;
  FreeAndNil(CompressStream);
  CompressStream:=TMemoryStream.Create;
  CompressStream.Write(arr^,shyPointer*4);
  CompressStream.Position:=0;
  FreeMem(arr)
 end;

 procedure Compress_JPG;
 var
  Img:TFPMemoryImage;
  writer:TFPCustomImageWriter;
 begin
  FreeAndNil(CompressStream);
  CompressStream:=TMemoryStream.Create;
  Img:=A.toFPImage;
  writer:=TFPWriterJPEG.Create;
  Img.SaveToStream(CompressStream,writer);
  Img.Free;
  writer.Free
 end;

 procedure Compress_PNG;
 var
  Img:TFPMemoryImage;
  writer:TFPCustomImageWriter;
 begin
  FreeAndNil(CompressStream);
  CompressStream:=TMemoryStream.Create;
  Img:=A.toFPImage;
  writer:=TFPWriterPNG.Create;
  Img.SaveToStream(CompressStream,writer);
  Img.Free;
  writer.Free
 end;

begin
 Create;
 CompressType:=_cp;
 case _cp of
  cp_jpg:Compress_JPG;
  cp_png:Compress_PNG;
  cp_RLC:Compress_RLC;
  else CompressType:=0
 end
end;

function CompressGraph.DeCompress:Graph;
var
 a:Graph;

 procedure DeCompress_RLC;
 var
  tmp:FColor;
  arr:pint;
  n,i,now,shyFlag,shyPointer,shyLast,shyCount:Longint;

  function gets:Longint;begin CompressStream.Read(tmp,4); gets:=tmp.x end;
  procedure puts(x:Longint);begin arr[shyPointer]:=x; inc(shyPointer) end;

 begin
  CompressStream.Position:=0;
  n:=Width*Height;
  GetMem(arr,n*4);
  shyPointer:=0;
  shyFlag:=gets;
  while shyPointer<n do
  begin
   now:=gets;
   if now=shyFlag then
    begin
     shyLast:=gets;
     shyCount:=gets;
     for i:=1 to shyCount do puts(shyLast)
    end
   else
    puts(now)
  end;
  a.Canvas:=pColor(arr)
 end;

 procedure DeCompress_JPG;
 var
  Img:TFPMemoryImage;
  reader:TFPCustomImageReader;
 begin
  Img:=TFPMemoryImage.Create(0,0);
  reader:=TFPReaderJPEG.Create;
  CompressStream.Position:=0;
  Img.LoadFromStream(CompressStream,Reader);
  a.Create(Img);
  Img.Free;
  reader.Free
 end;

 procedure DeCompress_PNG;
 var
  Img:TFPMemoryImage;
  reader:TFPCustomImageReader;
 begin
  Img:=TFPMemoryImage.Create(0,0);
  reader:=TFPReaderPNG.Create;
  CompressStream.Position:=0;
  Img.LoadFromStream(CompressStream,Reader);
  a.Create(Img);
  Img.Free;
  reader.Free
 end;

begin
 a.Create;
 a.Width:=Width;
 a.Height:=Height;
 case CompressType of
  cp_non:;
  cp_jpg:DeCompress_JPG;
  cp_png:DeCompress_PNG;
  cp_RLC:DeCompress_RLC;
 end;
 exit(a)
end;

Function CompressGraph.Recovery(Env:pSAMACEvent;Obj:pElement;Below:pGraph):pGraph;
var Tmp:pGraph;
begin
 New(Tmp);
 Tmp^:=DeCompress;
 Exit(Tmp)
end;

//Object-CompressGraph-End

//Object-GraphGroup-Begin

Constructor GroupGraph.Create;
begin
 Width:=0;
 Height:=0;
 Pic.Clear;
 Res.Clear;
end;

function GroupGraph.Size:Longint;
begin
 exit(Pic.Size)
end;

function GroupGraph.TotTime:Int64;
begin
 if Size<1 then exit(0);
 exit(Res.Items[Size])
end;

procedure GroupGraph.SetSpTime(const _t:int64);
var i:Longint;
begin
 for i:=1 to Size do Res.Items[i]:=_t*i
end;

procedure GroupGraph.AddPic(const a:Graph;const b:Int64);
Var Tmp:pGraph;
begin
 New(Tmp); Tmp^:=a.Cut;
 Pic.pushback(Tmp);
 Res.pushback(b);
 if Pic.Size=1 then
 Begin
  Width:=a.Width;
  Height:=a.Height
 End
end;

procedure GroupGraph.AddPic(const a:Graph);
begin
 AddPic(a,0)
end;

procedure GroupGraph.LoadGIF(const path:ansistring);
var
 Reader:shyGifReader;
begin
 Reader:=shyGifReader.Create;
 self:=Reader.ReadFromFile(path);
 Reader.Destroy
end;

procedure GroupGraph.LoadSAG(const path:Ansistring);
var
 F:Text;
 s:AnsiString;
 tmp:FColor;
 c:char;
 i,j:Longint;
 g:Graph;
 procedure gets;begin with tmp do read(f,s[0],s[1],s[2],s[3]) end;
begin
 Create;
 Assign(F,path); Reset(F);
 Readln(F,s);
 if s<>'`imagedata' then begin Close(F); exit end;
 g.Create;
 c:='s';
 while c='s' do
 begin
  c:='x';
  gets; j:=tmp.x;
  gets; i:=tmp.x;
  g.Create(i,j);
  for i:=1 to g.Height do
  for j:=1 to g.Width do begin gets; g.SetP(i,j,tmp.c) end;
  AddPic(g);
  read(F,c)
 end;
 Close(F);
 g.Free
end;

procedure GroupGraph.Split(const a:Graph;n,m,sz:Longint);
var
 i,j,tH,tW:Longint;
 Tmp:pGraph;
begin
 New(Tmp);
 th:=a.Height div n;
 tw:=a.Width  div m;
 for i:=0 to n-1 do
 for j:=0 to m-1 do
 begin
  Tmp^:=a.cut(th*i+1,tw*j+1,th*(i+1),tw*(j+1));
  Pic.Pushback(Tmp);
  Res.Pushback(0);
  if Size=sz then exit
 end
end;

procedure GroupGraph.Operate(const c:Color);
var i:Longint;
begin
 with Pic do
  for i:=1 to Size do Items[i]^.Change(c,Color_Alpha)
end;

procedure GroupGraph.Operate;
begin
 if Size>0 then Operate(Pic.Items[1]^.Canvas[0])
end;

Destructor GroupGraph.Free;
var i:Longint;
begin
 Width:=0;
 Height:=0;
 for i:=1 to Pic.Size do Pic.Items[i]^.Free;
 Pic.Clear;
 Res.Clear;
end;

Function GroupGraph.GetFrame(const Time:Int64):Graph;
var
 Fall:Int64;
 L,R,M:Longint;
begin
 Result.Create;
 if (Size=0)or(TotTime=0) then Exit;
 Fall:=Time mod TotTime;
 L:=1;
 R:=Size;
 with Res do
 while L<R do
 begin
  m:=(L+R)>>1;
  if Items[M]>=Fall then R:=M
                    else L:=M+1
 end;
 exit(Pic[L]^.Cut)
end;

Function GroupGraph.Cut:GroupGraph;
var i:Longint;
begin
 Cut.Create;
 For i:=1 to Pic.Size do Cut.AddPic(Pic[i]^,Res[i]);
end;

Function GroupGraph.Reproduce:pBaseGraph;
var Tmp:^GroupGraph;
begin
 New(Tmp);
 Tmp^:=Cut;
 Exit(Tmp)
end;

Function GroupGraph.Recovery(Env:pSAMACEvent;Obj:pElement;Below:pGraph):pGraph;
var Tmp:pGraph;
Begin
 New(Tmp);
 Tmp^:=GetFrame(DeltaTime-Obj^.acts.StdTime);
 Exit(Tmp)
End;

//Object-GroupGraph-End

//Object-TextGraph-Begin

Constructor TextGraph.Create;
Begin
 Text:='';
 FontType:='幼圆';
 FontSize:=20;
 FontColor:=Color_Black;
 FontBackColor:=Color_Alpha;
 FontAngle:=0;
 Bold:=False;
 Italic:=False;
 UnderLine:=False;
 StrikeOut:=False;
 CharSet:=GB2312_CHARSET;
 Height:=0;
 Width:=0;
End;

Procedure TextGraph.Update;
Var
 dc:HDC;
 tmp:LPSize;
 hFt:HFont;
Begin
 dc:=CreateCompatibleDC(0);
 hFt:=CreateFont(FontSize,0,Round(FontAngle*10),Round(FontAngle*10),
                 Ord(Bold)*FW_BOLD+Ord(Not Bold)*FW_NORMAL,Ord(Italic),Ord(UnderLine),Ord(StrikeOut),CHARSET,
                  OUT_DEFAULT_PRECIS,
                 CLIP_DEFAULT_PRECIS,
                 DEFAULT_QUALITY,
                 DEFAULT_PITCH or FF_DONTCARE,
                 PChar(FontType));
 SelectObject(dc,hFt);
 New(Tmp);
 GetTextExtentPoint32(dc,Pchar(Text),Length(Text),tmp);
 Width:=Tmp^.CX;
 Height:=Tmp^.CY;
 Dispose(Tmp);
 DeleteObject(hFt);
 DeleteDC(dc)
End;

Constructor TextGraph.Create(Const Str:Ansistring);
Begin
 Text:=Str;
 FontType:='幼圆';
 FontSize:=20;
 FontColor:=Color_Black;
 FontBackColor:=Color_Alpha;
 FontAngle:=0;
 Bold:=False;
 Italic:=False;
 UnderLine:=False;
 StrikeOut:=False;
 CharSet:=GB2312_CHARSET;
 Update
End;

Function TextGraph.Cut:TextGraph;
Begin
 Cut.Create;
 Cut.Text:=Text;
 Cut.FontType:=FontType;
 Cut.FontSize:=FontSize;
 Cut.FontColor:=FontColor;
 Cut.FontAngle:=FontAngle;
 Cut.FontBackColor:=FontBackColor;
 Cut.Bold:=Bold;
 Cut.Italic:=Italic;
 Cut.UnderLine:=UnderLine;
 Cut.StrikeOut:=StrikeOut;
 Cut.CharSet:=CharSet;
 Cut.Height:=Height;
 Cut.Width:=Width;
ENd;

Procedure TextGraph.SetText(Const Str:AnsiString);
Begin
 Text:=Str;
 Update
End;

Procedure TextGraph.SetSize(_s:Longint);
Begin
 FontSize:=_s;
 Update
End;

Procedure TextGraph.SetType(Const tp:Ansistring);
Begin
 FontType:=tp;
 Update
End;

Destructor TextGraph.Free;
Begin End;

Procedure TextGraph.WriteTo(Var A:Graph;_x,_y:Longint);
Var
 Clip:Graph;
 ClipX1,ClipY1,ClipX2,ClipY2:Longint;
 w,h,_stride,_offset,x,y:longint;
 hHeight,hWidth,_cx,_cy,_nx,_ny,_sin,_cos,_hx,_hy,_vx,_vy,_tx,_ty:Single;
 TextC,BoldValue:DWord;
 colp:pColor;
 buf:pointer;
 dc:HDC;
 hbmp:HBITMAP;
 bmi:TBitmapInfo;
 hFt:HFont;
 p:PRGBTriple;
Begin
 hHeight:=Height*0.5;
 hWidth:=Width*0.5;
 _cx:=_X+hHeight;
 _cy:=_Y+hWidth;
 _sin:=sin(FontAngle/180*pi);
 _cos:=cos(FontAngle/180*pi);
 _nx:=-hHeight*_cos+hWidth*_sin+_cx;
 _ny:=-hHeight*_sin-hWidth*_cos+_cy;
 _hx:=hHeight*Abs(_Cos)+hWidth*Abs(_Sin);
 _hy:=hHeight*Abs(_Sin)+hWidth*Abs(_Cos);
 ClipX1:=Round(_CX-_hx);
 ClipY1:=Round(_CY-_hy);
 ClipX2:=Round(_CX+_hx);
 ClipY2:=Round(_CY+_hy);
 If (ClipX1>A.Height)Or(ClipY1>A.Width) Then Exit;
 Clip:=A.Cut(ClipX1,ClipY1,ClipX2,ClipY2);
 If FontBackColor.a<>0 Then
 If FontAngle=0 Then Clip.FillA(1,1,Clip.Height,Clip.Width,FOntBackColor) Else
 Begin
  ColP:=Clip.Canvas;
  For x:=0 to Clip.Height-1 Do
  For y:=0 to Clip.Width-1 Do Begin
   _vx:=x-_hx; _vy:=y-_hy;
   _tx:=_vy*_sin+_vx*_cos; _ty:=_vy*_cos-_vx*_sin;
   If Not((Abs(_tx)>hHeight)Or(Abs(_ty)>hWidth)) Then PureBlendColor(Colp^,FontBackColor);
   Inc(colp)
  End
 End;
 H:=Clip.Height;
 W:=Clip.Width;
 _stride:=(w*3-1or 3)+1;
 _offset:=_stride-w*3;
 GetMem(buf,h*_Stride);
 p:=buf;
 for x:=h-1 downto 0 do begin
 for y:=0 to w-1 do with Clip.Canvas[x*W+y] do begin
  p^.rgbtRed:=r;
  p^.rgbtGreen:=g;
  p^.rgbtBlue:=b;
  inc(p) end;
  p:=pointer(LongWord(p)+_offset) end;
 dc:=CreateCompatibleDC(0);
 hbmp:=CreateBitmap(w,h,1,32,nil);
 SelectObject(dc,hbmp);
 with bmi.bmiHeader do
 begin
  biSize:=Sizeof(TBitmapInfoHeader);
  biWidth:=w;
  biHeight:=h;
  biPlanes:=1;
  biBitCount:=24;
  biCompression:=BI_RGB
 end;
 SetDIBits(dc,hbmp,0,h,buf,bmi,DIB_RGB_COLORS);
 With FontColor Do textc:=RGB(r,g,b);
 SetTextColor(dc,textc);
 SetBkMode(dc,TRANSPARENT);
 IF Bold Then BoldValue:=FW_BOLD ELSE BOLDVALUE:=FW_NORMAL;
 hFt:=CreateFont(FontSize,0,Round(FontAngle*10),Round(FontAngle*10),BOLDVALUE,Ord(Italic),Ord(UnderLine),Ord(StrikeOut),CHARSET,
                  OUT_DEFAULT_PRECIS,
                 CLIP_DEFAULT_PRECIS,
                 DEFAULT_QUALITY,
                 DEFAULT_PITCH or FF_DONTCARE,
                 PChar(FontType));
 SelectObject(dc,hFt);
 TextOut(dc,Round(_ny-ClipY1),Round(_nx-ClipX1),pChar(Text),Length(Text));
 DeleteObject(hFt);
 GetDIBits(dc,hbmp,0,h,buf,bmi,DIB_RGB_COLORS);
 p:=Buf;
 for x:=h downto 1 do begin
 for y:=1 to w do begin
  Clip.setp(x,y,RGBA(p^.rgbtRed,p^.rgbtGreen,p^.rgbtBlue,Clip.getp(x,y).A));
  inc(p) end;
  p:=pointer(LongWord(p)+_offset) end;
 FreeMem(buf);
 DeleteObject(hbmp);
 DeleteDC(dc);
 DrawTo(Clip,A,ClipX1-1,ClipY1-1);
 Clip.Free
End;

Function TextGraph.Reproduce:pBaseGraph;
Var Tmp:^TextGraph;
Begin
 New(Tmp);
 Tmp^:=Self;
 Exit(Tmp)
End;

Function TextGraph.Recovery(Env:pSAMACEvent;Obj:pElement;Below:pGraph):pGraph;
Var
 Tmp:Graph;
 Acs:AnimeObj;
 oSize:Longint;
 oRotate:Single;
 oText:Ansistring;
 I,X,Y,ClipX1,ClipY1,ClipX2,ClipY2:Longint;
 hHeight,hWidth,_Sin,_Cos,_hX,_hY:Single;
Begin
 Acs:=Obj^.Role;
 If Obj^.Acts.Enable Then Obj^.Acts.Apply(@Acs);
 oSize:=FontSize;
 oRotate:=FontAngle;
 oText:=Text;
 SetSize(Round(FontSize*Acs.ScaleX));
 FontAngle:=oRotate+Acs.Rotate;
 X:=Round((Length(Text)-1)*Acs.ClipX1)+1;
 Y:=Round((Length(Text)-1)*Acs.ClipX2)+1;
 For I:=1 to X-1 Do Text[I]:=' ';
 For I:=Y+1 to Length(Text) Do Text[I]:=' ';
 hHeight:=Height*0.5;
 hWidth:=Width*0.5;
 X:=Round(Acs.BiasX+hHeight);
 Y:=Round(Acs.BiasY+hWidth);
 _sin:=sin(FontAngle/180*pi);
 _cos:=cos(FontAngle/180*pi);
 _hx:=hHeight*Abs(_Cos)+hWidth*Abs(_Sin);
 _hy:=hHeight*Abs(_Sin)+hWidth*Abs(_Cos);
 ClipX1:=Round(X-_hx);
 ClipY1:=Round(Y-_hy);
 ClipX2:=Round(X+_hx);
 ClipY2:=Round(Y+_hy);
 Tmp:=Below^.Cut(ClipX1,ClipY1,ClipX2,ClipY2);
 WriteTo(Tmp,Round(Acs.BiasX)-ClipX1+1,Round(Acs.BiasY)-ClipY1+1);
 if Abs(1-Acs.Alpha)>1e-5 then Opt_Alpha(Tmp,Acs.Alpha);
 BlendTo(Tmp,Below^,ClipX1-1,ClipY1-1);
 Tmp.Free;
 SetSize(oSize);
 FontAngle:=oRotate;
 Text:=oText;
 Exit(Nil)
End;

//Object-TextGraph-End


//Object-AnimeObj-Begin

Constructor AnimeObj.Create;
begin
 Visible:=True;
 BiasX:=0;
 BiasY:=0;
 ClipX1:=0;
 ClipY1:=0;
 ClipX2:=0;
 ClipY2:=0;
 Reverse:=0;
 Rotate:=0;
 Alpha:=1;
 ScaleX:=1;
 ScaleY:=1;
 Source:=nil;
end;

Constructor AnimeObj.Create(const a:BaseGraph);
begin
 Visible:=True;
 BiasX:=0;
 BiasY:=0;
 ClipX1:=0;
 ClipY1:=0;
 ClipX2:=1;
 ClipY2:=1;
 Rotate:=0;
 Alpha:=1;
 ScaleX:=1;
 ScaleY:=1;
 Source:=a.ReProduce;
end;

Constructor AnimeObj.CreateLink(const a:BaseGraph);
begin
 Visible:=True;
 BiasX:=0;
 BiasY:=0;
 ClipX1:=0;
 ClipY1:=0;
 ClipX2:=1;
 ClipY2:=1;
 Rotate:=0;
 Alpha:=1;
 ScaleX:=1;
 ScaleY:=1;
 Source:=@a;
end;

Function AnimeObj.Width:Longint;
Begin Exit(Source^.Width) End;

Function AnimeObj.Height:Longint;
Begin Exit(Source^.Height) End;

procedure AnimeObj.SetXY(_x,_y:longint);
begin
 BiasX:=_x;
 BiasY:=_y
end;

procedure AnimeObj.SetClip(_x1,_y1,_x2,_y2:longint);
begin
 ClipX1:=_x1;
 ClipY1:=_y1;
 ClipX2:=_x2;
 ClipY2:=_y2
end;

procedure AnimeObj.SetRotate(_r:single);
begin
 Rotate:=_r
end;

procedure AnimeObj.SetAlpha(_a:single);
begin
 Alpha:=_a
end;

procedure AnimeObj.SetReverse(_rv:Longint);
begin
 Reverse:=_rv
end;

procedure AnimeObj.SetSource(const src:BaseGraph);
begin
 Source:=@src
end;

procedure AnimeObj.SetScale(_s:single);
begin
 ScaleX:=_s;
 ScaleY:=_s
end;

procedure AnimeObj.SetParam(_x,_y:longint;_r,_a,_s:single);
begin
 SetXY(_x,_y);
 SetRotate(_r);
 SetAlpha(_a);
 SetScale(_s)
end;

procedure AnimeObj.SetParam(_x,_y,_x1,_y1,_x2,_y2:longint;_r,_a,_s:single);
begin
 SetClip(_x1,_y1,_x2,_y2);
 SetParam(_x,_y,_r,_a,_s)
end;


function AnimeObj.Inner(x,y:longint):boolean;
var
 fx,fy,_w,_h,_px,_py,_x,_y,_sin,_cos,_ru,_rv:real;

  procedure Rot(const x,y:real);
  begin _ru:=x*_cos+y*_sin; _rv:=-x*_sin+y*_cos end;

begin
 fx:=x;
 fy:=y;
 _w:=Source^.Width*ScaleY;
 _h:=Source^.Height*ScaleX;
 if abs(Rotate)>1e-5 then
 begin
  _px:=BiasX+_h*0.5;
  _py:=BiasY+_w*0.5;
  _x:=fx-_px;
  _y:=fy-_py;
  _sin:=sin(Rotate*pi/180);
  _cos:=cos(Rotate*pi/180);
  Rot(_x,_y);
  fx:=_ru+_px;
  fy:=_rv+_py
 end;

 exit((BiasX<=fx)and(fx<=BiasX+_h)and
      (BiasY<=fy)and(fy<=BiasY+_w))
end;

Function AnimeObj.Cut:AnimeObj;
begin
 Cut.Create;
 Move(Self,Cut,SizeOf(AnimeObj)-4);
 If Source=Nil Then Cut.Source:=Nil
               Else Cut.Source:=Source^.ReProduce
end;

Destructor AnimeObj.Free;
Begin
 Source^.Free
End;

//Object-AnimeObj-End

//Object-BaseAnime-Begin

Constructor BaseAnime.Create;
Begin
 AnimeType:=atp_normal;
 StdTime:=DeltaTime;
 TotTime:=1000;
End;

procedure BaseAnime.SetType(_atp:shortint);
begin
 AnimeType:=_Atp
end;

procedure BaseAnime.SetTime(const _t:int64);
begin
 TotTime:=_t
end;

procedure BaseAnime.Start;
begin
 StdTime:=DeltaTime
end;

procedure BaseAnime.Start(const _t:INt64);
begin
 StdTime:=_t
end;

//Object-BaseAnime-End

//Object-AnimeTag-Begin

Constructor AnimeTag.Create;
Begin
 Enable:=False;
 Source:=Nil
End;

Constructor AnimeTag.Create(Const a:BaseAnime);
Begin
 Enable:=True;
 Source:=a.Reproduce
End;

Destructor AnimeTag.Free;
Begin
 Source^.Free
End;

procedure AnimeTag.On;
begin
 Enable:=True
end;

procedure AnimeTag.Off;
begin
 Enable:=False
end;

Function AnimeTag.StdTime:Int64;
Begin
 If Source=Nil Then Exit(0);
 Exit(Source^.StdTime)
End;

Function AnimeTag.TotTime:Int64;
Begin
 If Source=Nil Then Exit(0);
 Exit(Source^.TotTime)
End;

Function AnimeTag.AnimeType:ShortInt;
Begin
 If Source=Nil Then Exit(0);
 Exit(Source^.AnimeType)
End;

Function AnimeTag.Apply(obj:pAnimeObj):SHortInt;
Begin
 If Source=Nil Then Exit(0);
 Exit(Source^.Apply(obj))
End;

Function AnimeTag.Cut:AnimeTag;
Begin
 Cut.Create;
 Cut.Enable:=Enable;
 If Source=Nil Then Cut.Source:=Nil
               Else Cut.Source:=Source^.Reproduce;
End;

Function AnimeTag.AnimeEnd:Boolean;
Begin
 Exit(Source^.AnimeEnd)
End;

//Object-AnimeTag-End

//Object-SimpleAnime-Begin

Constructor SimpleAnime.Create;
begin
 inherited Create;

 an_BiasX:=0;
 an_BiasY:=0;
 an_ClipX1:=0;
 an_ClipY1:=0;
 an_ClipX2:=0;
 an_ClipY2:=0;
 an_Rotate:=0;
 an_Alpha :=0;
 an_ScaleX:=0;
 an_ScaleY:=0;

 tp_BiasX :=0;
 tp_BiasY :=0;
 tp_ClipX1:=0;
 tp_ClipY1:=0;
 tp_ClipX2:=0;
 tp_ClipY2:=0;
 tp_Rotate:=0;
 tp_Alpha :=0;
 tp_ScaleX:=0;
 tp_ScaleY:=0;

end;

Destructor SimpleAnime.Free;
Begin
End;


procedure SimpleAnime.SetXY(_x,_y:single;_tp:shortint);
begin
 an_BiasX:=_x;
 an_BiasY:=_y;
 tp_BiasX:=_tp;
 tp_BiasY:=_tp
end;

procedure SimpleAnime.SetClip(_x1,_y1,_x2,_y2:single;_tp:shortint);
begin
 an_ClipX1:=_x1;
 an_ClipY1:=_y1;
 an_ClipX2:=_x2;
 an_ClipY2:=_y2;
 tp_ClipX1:=_tp;
 tp_ClipY1:=_tp;
 tp_ClipX2:=_tp;
 tp_ClipY2:=_tp
end;

procedure SimpleAnime.SetRotate(_r:single;_tp:shortint);
begin
 an_Rotate:=_r;
 tp_Rotate:=_tp
end;

procedure SimpleAnime.SetAlpha(_a:single;_tp:shortint);
begin
 an_Alpha:=_a;
 tp_Alpha:=_tp
end;

procedure SimpleAnime.SetScale(_s:single;_tp:shortint);
begin
 an_ScaleX:=_s;
 an_ScaleY:=_s;
 tp_ScaleX:=_tp;
 tp_ScaleY:=_tp
end;

procedure SimpleAnime.SetXY(_x,_y:single);
begin
 SetXY(_x,_y,tp_Line)
end;

procedure SimpleAnime.SetClip(_x1,_y1,_x2,_y2:single);
begin
 SetClip(_x1,_y1,_x2,_y2,tp_Line)
end;

procedure SimpleAnime.SetRotate(_r:single);
begin
 SetRotate(_r,tp_Line)
end;

procedure SimpleAnime.SetAlpha(_a:single);
begin
 SetAlpha(_a,tp_Line)
end;

procedure SimpleAnime.SetScale(_s:single);
begin
 SetScale(_s,tp_Line)
end;


 function tp_Count(const x:real;_tp:shortint):real;
 begin
  case _tp of
   tp_NULL:exit(0);
   tp_Line:exit(x);
   tp_Sqr :exit(x*x);
   tp_Sqrt:exit(sqrt(x));
   tp_Pow :exit(2**x-1);
   tp_Sin :exit(sin(x*pi*0.5));
   tp_ArcSin:Exit(ArcSin(x*2-1)/pi+0.5);
   tp_ArcTan:Exit(ArcTan(x*2-1)/(pi*0.5)+0.5);

   tp_Luna :If x<0.5 Then Exit(0.5-Sqrt(0.25-x*x)) Else Exit(0.5+Sqrt(0.25-Sqr(1-x)));
   tp_Luna2:If x<0.5 Then Exit(Sqrt(0.25-Sqr(x-0.5))) Else Exit(1-Sqrt(0.25-Sqr(x-0.5)));


   tpb_Line:if x<0.5 then exit(2*x) else exit(2-2*x);
   tpb_Sqr :if x<0.5 then exit(4*x*x) else exit(4*sqr(1-x));
   tpb_Sqr2:exit(1-4*sqr(x-0.5));
   tpb_Sin :exit(sin(x*pi))
  end
 end;


Function SimpleAnime.AnimeEnd:Boolean;
Begin
 Case AnimeType Of
  atp_normal:Exit(DeltaTime-StdTime>=TotTime);
  atp_loop  :Exit(False)
 End;
 Exit(True)
End;

Function SimpleAnime.Apply(obj:pAnimeObj):ShortInt;
Var Tim:Real;
begin
 If obj<>Nil Then
 with obj^ do
 begin
  Tim:=(DeltaTime-StdTime)/TotTime;
  If Tim>=1 Then
  Case AnimeType Of
   atp_normal:Tim:=1;
   atp_loop  :Tim:=Tim-Trunc(Tim)
  End;
  BiasX:=BiasX+an_BiasX*tp_Count(Tim,tp_BiasX);
  BiasY:=BiasY+an_BiasY*tp_Count(Tim,tp_BiasY);
  ClipX1:=ClipX1+an_ClipX1*tp_Count(Tim,tp_ClipX1);
  ClipY1:=ClipY1+an_ClipY1*tp_Count(Tim,tp_ClipY1);
  ClipX2:=ClipX2+an_ClipX2*tp_Count(Tim,tp_ClipX2);
  ClipY2:=ClipY2+an_ClipY2*tp_Count(Tim,tp_ClipY2);
  Rotate:=Rotate+an_Rotate*tp_Count(Tim,tp_Rotate);
  Alpha :=Alpha+an_Alpha *tp_Count(Tim,tp_Alpha );
  ScaleX:=ScaleX+an_ScaleX*tp_Count(Tim,tp_ScaleX);
  ScaleY:=ScaleY+an_ScaleY*tp_Count(Tim,tp_ScaleY)
 end;
 Exit(11) //11=SimpleAnime
end;

Function SImpleAnime.Reproduce:pBaseAnime;
Var Tmp:pSimpleAnime;
Begin
 New(Tmp);
 Tmp^:=Self;
 Exit(Tmp)
End;

//Object-SimpleAnime-End

 Class Operator TLAnimeObj.<(Const a,b:TLAnimeObj)c:Boolean;Begin Exit(a.Time<b.Time) End;
 Class Operator TLAnimeObj.>(Const a,b:TLAnimeObj)c:Boolean;Begin Exit(a.Time>b.Time) End;
 Class Operator TLAnimeObj.=(Const a,b:TLAnimeObj)c:Boolean;Begin Exit(a.Time=b.Time) End;
 Class Operator TLAnimeObj.<=(Const a,b:TLAnimeObj)c:Boolean;Begin Exit(a.Time<=b.Time) End;
 Class Operator TLAnimeObj.>=(Const a,b:TLAnimeObj)c:Boolean;Begin Exit(a.Time>=b.Time) End;

 Procedure TLAnimeObj.Create;
 Begin
  Time:=0;
  BiasX:=0;  tp_BiasX:=tp_Line;
  BiasY:=0;  tp_BiasY:=tp_Line;
  ClipX1:=0; tp_ClipX1:=tp_Line;
  ClipY1:=0; tp_ClipY1:=tp_Line;
  ClipX2:=1; tp_ClipX2:=tp_Line;
  ClipY2:=1; tp_ClipY2:=tp_Line;
  Rotate:=0; tp_Rotate:=tp_Line;
  Alpha :=1; tp_Alpha :=tp_Line;
  ScaleX:=1; tp_ScaleX:=tp_Line;
  ScaleY:=1; tp_ScaleY:=tp_Line;
 End;

 Procedure TLAnimeObj.SetTime(Const _t:Int64);Begin Time:=_t End;
 Procedure TLAnimeObj.SetBiasX(Const _v:Single;_tp:ShortInt);Begin BiasX:=_v; tp_BiasX:=_tp End;
 Procedure TLAnimeObj.SetBiasY(Const _v:Single;_tp:ShortInt);Begin BiasY:=_v; tp_BiasY:=_tp End;
 Procedure TLAnimeObj.SetClipX1(Const _v:Single;_tp:ShortInt);Begin ClipX1:=_v; tp_ClipX1:=_tp End;
 Procedure TLAnimeObj.SetClipY1(Const _v:Single;_tp:ShortInt);Begin ClipY1:=_v; tp_ClipY1:=_tp End;
 Procedure TLAnimeObj.SetClipX2(Const _v:Single;_tp:ShortInt);Begin ClipX2:=_v; tp_ClipX2:=_tp End;
 Procedure TLAnimeObj.SetClipY2(Const _v:Single;_tp:ShortInt);Begin ClipY2:=_v; tp_ClipY2:=_tp End;
 Procedure TLAnimeObj.SetRotate(Const _v:Single;_tp:ShortInt);Begin Rotate:=_v; tp_Rotate:=_tp End;
 Procedure TLAnimeObj.SetAlpha (Const _v:Single;_tp:ShortInt);Begin Alpha :=_v; tp_Alpha :=_tp End;
 Procedure TLAnimeObj.SetScaleX(Const _v:Single;_tp:ShortInt);Begin ScaleX:=_v; tp_ScaleX:=_tp End;
 Procedure TLAnimeObj.SetScaleY(Const _v:Single;_tp:ShortInt);Begin ScaleY:=_v; tp_ScaleY:=_tp End;

//Object-TimeLineAnime-Begin

Constructor TimeLineAnime.Create;
Begin
 TimeLine.Clear;
 AnimeType:=atp_normal;
 StdTime:=DeltaTime;
 TotTime:=1000;
End;

Destructor TimeLineAnime.Free;
Begin
 TimeLine.Clear;
End;

Function TimeLineAnime.AnimeEnd:Boolean;
Begin
 Case AnimeType Of
  atp_normal:Exit(DeltaTime-StdTime>=TotTime);
  atp_loop  :Exit(False)
 End;
 Exit(True)
End;

Procedure TimeLineAnime.SetFrame(Const _tl:TLAnimeObj);
Begin
 If _tl.Time>TotTime Then TotTime:=_tl.Time;
 TimeLine.Delete(_tl);
 TimeLine.Insert(_tl)
End;

Procedure TimeLineAnime.SetFrame(Const _t:Int64;Const _tl:AnimeObj);
Var tmp:TLAnimeObj;
Begin
 With Tmp Do Begin
  Time:=_t;
  BiasX:=_tl.BiasX;    tp_BiasX:=tp_Line;
  BiasY:=_tl.BiasY;    tp_BiasY:=tp_Line;
  ClipX1:=_tl.ClipX1;  tp_ClipX1:=tp_Line;
  ClipY1:=_tl.ClipY1;  tp_ClipY1:=tp_Line;
  ClipX2:=_tl.ClipX2;  tp_ClipX2:=tp_Line;
  ClipY2:=_tl.ClipY2;  tp_ClipY2:=tp_Line;
  Rotate:=_tl.Rotate;  tp_Rotate:=tp_Line;
  Alpha :=_tl.Alpha;   tp_Alpha :=tp_Line;
  ScaleX:=_tl.ScaleX;  tp_ScaleX:=tp_Line;
  ScaleY:=_tl.ScaleY;  tp_ScaleY:=tp_Line;
 End;
 SetFrame(tmp)
End;

Function TimeLineAnime.Apply(obj:pAnimeObj):ShortInt;
Var
 Id:Longint;
 tmp1,tmp2:TLAnimeObj;
 Tim:Real;

 Function Mix(Const vBegin,vEnd,vTime:Real;vStyle:ShortInt):Real;
 Var tmp:Real;
 Begin
  tmp:=tp_Count(vTime,vStyle);
  Exit(vBegin*(1-tmp)+vEnd*tmp)
 End;

Begin
 If obj=Nil Then Exit;
 Tim:=(DeltaTime-StdTime)/TotTime;
 If Tim>=1 Then
 Case AnimeType Of
  atp_normal:Tim:=1;
  atp_loop  :Tim:=Tim-Trunc(Tim);
 End;
 tmp1.Time:=Round(Tim*TotTime);
 Id:=TimeLine.LowerEqual(tmp1);
 If Id>TimeLine.Size Then tmp1:=TimeLine[TimeLine.Size] Else tmp1:=TimeLine[Id];
 If Id+1>TimeLine.Size Then tmp2:=TimeLine[TimeLine.Size] Else tmp2:=TimeLine[Id+1];
 If Id=0 Then Begin Fillchar(tmp1,Sizeof(tmp1),0); FillChar(tmp2,Sizeof(tmp2),0) End;
 If tmp2.Time-tmp1.Time=0 Then Tim:=1 Else Tim:=(Round(Tim*TotTime)-tmp1.Time)/(tmp2.Time-tmp1.Time);
 With Obj^ Do Begin
  BiasX:=Mix(tmp1.BiasX,tmp2.BiasX,Tim,tmp2.tp_BiasX);
  BiasY:=Mix(tmp1.BiasY,tmp2.BiasY,Tim,tmp2.tp_BiasY);
  ClipX1:=Mix(tmp1.ClipX1,tmp2.ClipX1,Tim,tmp2.tp_ClipX1);
  ClipY1:=Mix(tmp1.ClipY1,tmp2.ClipY1,Tim,tmp2.tp_ClipY1);
  ClipX2:=Mix(tmp1.ClipX2,tmp2.ClipX2,Tim,tmp2.tp_ClipX2);
  ClipY2:=Mix(tmp1.ClipY2,tmp2.ClipY2,Tim,tmp2.tp_ClipY2);
  Rotate:=Mix(tmp1.Rotate,tmp2.Rotate,Tim,tmp2.tp_Rotate);
  Alpha :=Mix(tmp1.Alpha ,tmp2.Alpha ,Tim,tmp2.tp_Alpha );
  ScaleX:=Mix(tmp1.ScaleX,tmp2.ScaleX,Tim,tmp2.tp_ScaleX);
  ScaleY:=Mix(tmp1.ScaleY,tmp2.ScaleY,Tim,tmp2.tp_ScaleY);
 End;
 Exit(12) //12=TimeLineAnime
End;

Function TimeLineAnime.Reproduce:pBaseAnime;
Var tmp:pTimeLineAnime;
Begin
 New(tmp,Create);
 Tmp^.AnimeType:=AnimeType;
 Tmp^.StdTime:=StdTime;
 Tmp^.TotTime:=TotTime;
 With Tmp^.TimeLine Do Begin
  Clear;
  Root:=TimeLine.Root;
  Size:=TimeLine.Size;
  Thing:=TimeLine.Thing.Clone(1,TimeLine.Thing.Size);
  ReUse:=TimeLine.ReUse.Clone(1,TimeLine.ReUse.Size);
 End;
 Exit(tmp)
End;



//Object-TimeLineAnime-End

//Object-AnimeLog-Begin

Constructor AnimeLog.Create;
begin
 Enable:=True;
 LastInner:=0;
 MouseEvent:=nil;
 KeyEvent:=nil;
 NonEvent:=nil
end;

procedure AnimeLog.DealMouse(Env:pSAMACEvent;Obj:pElement;Below:pGraph;Const E:SAMouseEvent);
var
 _inner:shortint;
 tmpobj:AnimeObj;
 tmptag:AnimeTag;
begin
 if MouseEvent=nil then exit;
 tmpobj:=Obj^.Role;
 If Obj^.Acts.Enable Then Obj^.Acts.Apply(@tmpobj);
 _inner:=ord(tmpobj.inner(E.x,E.y)); if _inner<>LastInner then _inner:=_inner or 2;
 MouseEvent(Env,Obj,Below,E,_inner);
 LastInner:=_inner and 1;
end;

procedure AnimeLog.DealKey(Env:pSAMACEvent;Obj:pElement;Below:pGraph;Const E:SAKeyEvent);
begin
 if KeyEvent=nil then exit;
 KeyEvent(Env,Obj,Below,E)
end;

procedure AnimeLog.DealNon(Env:pSAMACEvent;Obj:pElement;Below:pGraph);
begin
 if NonEvent<>nil then NonEvent(Env,Obj,Below)
end;

//Object-AnimeLog-End;

function NULLGraph:Graph;
begin
 NULLGraph.Create
end;

function NULLAnimeObj:AnimeObj;
begin
 NULLAnimeObj.Create
end;

function NULLAnimeTag:AnimeTag;
begin
 NULLAnimeTag.Create
end;

function NULLAnimeLog:AnimeLog;
begin
 NULLAnimeLog.Create
end;

function NowFPS:Longint;
begin
 if DeltaTime-2000>UpdateFPS then exit(0);
 exit(LastFPS)
end;

procedure Lock;
begin
 if Not ConsoleUsing then Exit;
 Screen.Create;
 Screen.Width:=Surface.Width;
 Screen.Height:=Surface.Height;
 Screen.Canvas:=Surface.lock
end;

procedure UnLock;
var tmp:Int64;
begin
 if Not ConsoleUsing then Exit;
 tmp:=DeltaTime-UpdateFPS;
 if tmp>=1000 then begin
  LastFPS:=FPSCount;
  FPSCount:=0;
  inc(UpdateFPS,tmp-tmp mod 1000)
 end;
 tmp:=DeltaTime-LastFresh;
 While tmp<FreshLimit Do Begin
  Sleep(1);
  tmp:=DeltaTime-LastFresh End;
 inc(LastFresh,tmp);
 if Not ConsoleUsing then Exit;
 surface.unlock;
 surface.copy(console);
 console.update;
 inc(FPSCount);
end;

procedure OpenGLScreenShot(var scr:Graph);
begin
 scr.Free;
 scr.Width:=Console.Width;
 scr.Height:=Console.Height;
 scr.Canvas:=GetMemory(scr.Width*scr.Height*4);
 glReadPixels(0,0,scr.Width,scr.Height,GL_BGRA_EXT,GL_UNSIGNED_BYTE,scr.Canvas);
 scr.Reverse(rev_Vertical)
end;

procedure ScreenClear(const c:Color);
begin
 Screen.Fill(1,1,Screen.Height,Screen.Width,c)
end;

procedure ScreenClear;
begin
 ScreenClear(Color_Black)
end;

procedure DrawTo(const pen:Graph;var goal:Graph;x,y:longint);
var i,j,k:longint;
begin
 With Goal do
 For i:=Max(0,x) To Min(Height,pen.Height+x)-1 Do
 Begin
  j:=Max(0,y);
  k:=Min(Width,Pen.Width+Y)-1;
  If j<=k Then
   Move(Pen.Canvas[(i-x)*Pen.Width+(j-y)],Canvas[i*Width+j],(k-j+1)<<2);
 End
end;

procedure PureBlendColor(var a:Color;const b:Color);
var _a:single;
begin
 _a:=b.a/255;
 a.r:=round(a.r*(1-_a)+b.r*_a);
 a.g:=round(a.g*(1-_a)+b.g*_a);
 a.b:=round(a.b*(1-_a)+b.b*_a);
end;

procedure BlendTo(const pen:Graph;var goal:Graph;x,y:longint);
var i,j,js,jt:longint; u,v:pColor;
begin
 js:=Max(0,y);
 jt:=Min(Goal.Width,Pen.Width+Y)-1-js;
 If jt<0 Then Exit;
 With Goal Do
 For i:=Max(0,x) To Min(Height,pen.Height+X)-1 Do
 Begin
  u:=@Canvas[i*Width+js];
  v:=@pen.Canvas[(i-x)*pen.Width+(js-y)];
  For j:=0 to jt Do PureBlendColor((u+j)^,(v+j)^)
 End
end;


//Object-Element-Begin

Constructor Element.Create;
begin
 role:=NULLAnimeObj;
 acts:=NULLAnimeTag;
 talk:=NULLAnimeLog;
end;

Constructor Element.Create(const A:AnimeObj);
begin
 role:=A.cut;
 acts:=NULLAnimeTag;
 talk:=NULLAnimeLog;
end;

Constructor Element.Create(const A:AnimeObj;const B:AnimeTag;const C:AnimeLog);
begin
 role:=A.cut;
 acts:=B;
 talk:=C;
end;

Function Element.Reproduce:pElement;
Var Tmp:pElement;
begin
 New(Tmp,Create(Role,Acts,Talk));
 Exit(Tmp)
end;

Destructor Element.Free;
Begin
 Role.Free
End;

FUnction Element.Width:Longint;
Begin Exit(Role.Source^.Width) End;

Function Element.Height:Longint;
Begin Exit(Role.Source^.Height) End;

//Object-Element-End

//Object-Stage-Begin

constructor Stage.Create;
begin
 Member.Clear;
 StageMAC:=NULLSAMACEvent;
 StageBiasX:=0;
 StageBiasY:=0;
end;

function Stage.Size:longint;
begin
 exit(Member.Size)
end;

function Stage.AddObj(const _role:AnimeObj):longint;
var Tmp:pElement;
begin
 New(Tmp,Create(_role));
 Member.Pushback(Tmp);
 exit(Member.Size)
end;

function Stage.AddObj(const _role:BaseGraph):longint;
var Tmp:pElement;
begin
 New(Tmp,Create);
 Tmp^.Role.Create(_role);
 Tmp^.Acts:=NULLAnimeTag;
 Tmp^.Talk:=NULLAnimeLog;
 Member.Pushback(Tmp);
 Exit(Member.Size)
end;

function Stage.AddObj(const _role:Element):Longint;
begin
 Member.Pushback(_Role.Reproduce);
 Exit(Member.Size)
end;

function Stage.LinkObj(const _role:Element):Longint;
begin
 Member.Pushback(@_Role);
 Exit(Member.Size)
end;

Function Stage.LinkObj(Const _role:BaseGraph):Longint;
Var Tmp:pElement;
Begin
 New(Tmp,Create);
 Tmp^.Role.CreateLink(_role);
 Tmp^.Acts:=NULLAnimeTag;
 Tmp^.Talk:=NULLAnimeLog;
 Member.PushBack(Tmp);
 Exit(Member.Size)
End;

Procedure Stage.AnimeBegin(id:Longint);
Begin
 With Member.Items[Id]^.Acts Do
 Begin
  On;
  Source^.Start
 End
End;

Procedure Stage.AnimeAllBegin;
Var i:Longint;
Begin
 For i:=1 to Member.Size Do AnimeBegin(i)
End;

function Stage.AnimeEnd(id:longint):boolean;
begin
 exit(not Member.Items[id]^.Acts.Enable)
end;

function Stage.AnimeAllEnd:boolean;
var i:longint;
begin
 for i:=1 to Member.Size do
 if not AnimeEnd(i) then exit(False);
 exit(True)
end;

function Stage.IsInner(id,x,y:longint):boolean;
var
 tmpobj:AnimeObj;
 tmptag:AnimeTag;
begin
 tmpobj:=Member.Items[id]^.Role;
 tmptag:=Member.Items[id]^.Acts;
 tmptag.Apply(@tmpobj);
 IsInner:=tmpobj.inner(x,y);
end;

function Stage.Get(id:longint):pAnimeObj;
begin
 exit(@Member.Items[id]^.Role)
end;

procedure Stage.DeleteObj(id:longint);
begin
 Member.Items[id]^.Role.Visible:=False;
 Member.Items[id]^.Acts.Off
end;

procedure Stage.ReplaceObj(id:longint;const _role:AnimeObj);
begin
 with Member.Items[id]^ do
 Begin
  Create;
  Role:=_role.cut;
  Acts:=NULLAnimeTag;
  Talk:=NULLAnimeLog
 End;
end;

procedure Stage.AttachAnime(id:longint;const _act:AnimeTag);
var tag:pAnimeTag;
begin
 tag:=@Member.Items[id]^.Acts;
 tag^:=_act.Cut;
end;

Procedure Stage.AttachAnime(Id:Longint;Const _act:BaseAnime);
var Tmp:AnimeTag;
Begin
 Tmp.Create(_act);
 AttachAnime(Id,Tmp);
 Tmp.Free
End;

procedure Stage.StopAnime(id:longint);
begin
 with Member.Items[id]^ do
 begin
  Acts.Apply(@Role);
  Acts.Off
 end
end;


 procedure Opt_Mask(var g:Graph;_x1,_y1,_x2,_y2:Single);
 var
  i,j:longint;
  x1,y1,x2,y2:Longint;
 begin
  x1:=Round((g.Height-1)*_x1)+1;
  x2:=Round((g.Height-1)*_x2)+1;
  y1:=Round((g.Width-1)*_y1)+1;
  y2:=Round((g.Width-1)*_y2)+1;
  if (x1<=1)and(y1<=1)and(x2>=g.Height)and(y2>=g.Width) then exit;
  with g do
  for i:=1 to Height do
  for j:=1 to Width do
   if (i<x1)or(i>x2)or(j<y1)or(j>y2) then
    Canvas[(i-1)*Width+(j-1)].a:=0
 end;

 procedure Opt_Scale(var g:Graph;x,y:single);
 begin
  if (abs(x-1)<1e-5)and(abs(y-1)<1e-5) then exit;
  g.Resize(Round(g.Height*x),Round(g.Width*y))
 end;

 procedure Opt_Alpha(var g:Graph;a:single);
 var
  i,j:longint;
 begin
  if abs(a-1)<1e-5 then exit;
  with g do
  for i:=0 to Height-1 do
  for j:=0 to Width-1 do
   g.Canvas[i*Width+j].a:=round(g.Canvas[i*Width+j].a*a)
 end;

 procedure Opt_Rotate(var g:Graph;r:single);
 var
  i,j,u,v:longint;
  Paper:Graph;
  _hx,_hy,_hx2,_hy2,_sin,_cos,_ru,_rv:real;
  tmp:pColor;

  procedure Max(var a:real;const b:real);
  begin if b>a then a:=b end;

  procedure Rot(const x,y:real);
  begin _ru:=x*_cos+y*_sin; _rv:=-x*_sin+y*_cos end;

 begin
  if abs(r)<1e-5 then exit;
  Paper.Canvas:=Nil;
  r:=r*pi/180;
  _sin:=sin(r);
  _cos:=cos(r);
  _hx:=(g.Height-1)*0.5;
  _hy:=(g.Width -1)*0.5;
  _hx2:=0;
  _hy2:=0;
  Rot( _hy, _hx); max(_hy2,_ru); max(_hx2,_rv);
  Rot( _hy,-_hx); max(_hy2,_ru); max(_hx2,_rv);
  Rot(-_hy, _hx); max(_hy2,_ru); max(_hx2,_rv);
  Rot(-_hy,-_hx); max(_hy2,_ru); max(_hx2,_rv);
  Paper.Create(round(_hx2*2)+1,round(_hy2*2)+1);
  _sin:=-_sin;
  for i:=0 to Paper.Height-1 do Begin Tmp:=@Paper.Canvas[i*Paper.Width];
  for j:=0 to Paper.Width-1 do
  begin
   Rot(j-_hy2,i-_hx2);
   u:=round(_rv+_hx); if (u<0)or(u>=g.Height) then Begin (Tmp+J)^:=Color_Alpha; continue End;
   v:=round(_ru+_hy); if (v<0)or(v>=g.Width) then Begin (Tmp+J)^:=Color_Alpha; continue End;
   (Tmp+J)^:=g.Canvas[u*g.Width+v]
  end End;
  g.Free;
  g:=Paper
 end;


procedure Stage.DisplayBlendObj(id:longint;tp:shortint;Var Below:Graph);
var
 tmp:AnimeObj;
 vir:AnimeTag;
 DTest:pGraph;
 DrawObj,DrawTmp:Graph;
begin
 with Member.Items[id]^ do
 if not Acts.Enable then
  tmp:=Role
 else
  begin
   Vir:=Acts;
   Tmp:=Role;
   Vir.Apply(@Tmp);
   if Vir.AnimeEnd then
   begin
    Acts.Off;
    Role:=Tmp
   end
  end;
 with Tmp do
 begin
  DTest:=Source^.Recovery(@StageMAC,Member.Items[id],@Below);
  if DTest=Nil then Exit;
  DrawObj:=DTest^;
  DrawObj.Reverse(Reverse);
  Opt_Mask(DrawObj,ClipX1,ClipY1,ClipX2,ClipY2);
  Opt_Scale(DrawObj,ScaleX,ScaleY);
  Opt_Alpha(DrawObj,Alpha);
  BiasX:=BiasX+DrawObj.Height*0.5;
  BiasY:=BiasY+DrawObj.Width *0.5;
  Opt_Rotate(DrawObj,Rotate);
  BiasX:=BiasX-DrawObj.Height*0.5;
  BiasY:=BiasY-DrawObj.Width *0.5;
  if tp=-1 then BlendTo(DrawObj,Below,Round(BiasX+StageBiasX),Round(BiasY+StageBiasY)) else begin
  DrawTmp:=Below.ColorBlend(DrawObj,Round(BiasX+StageBiasX),Round(BiasY+StageBiasY),tp);
  BlendTo(DrawTmp,Below,0,0); DrawTmp.Free end;
  DrawObj.Free;
 end;
end;

Procedure Stage.DisplayDirectObj(id:Longint;var Below:Graph);
var
 tmp:AnimeObj;
 vir:AnimeTag;
 DTest:pGraph;
begin
 with Member.Items[id]^ do
 if not Acts.Enable then
  tmp:=Role
 else
  begin
   Vir:=Acts;
   Tmp:=Role;
   Vir.Apply(@Tmp);
   if Vir.AnimeEnd then
   begin
    Acts.Off;
    Role:=Tmp
   end
  end;
 with Tmp do
 begin
  DTest:=Source^.Recovery(@StageMAC,Member.Items[id],@Below);
  if DTest=Nil then Exit;
  DrawTo(DTest^,Below,Round(BiasX+StageBiasX),Round(BiasY+StageBiasY));
  DTest^.Free
 end
End;

Procedure Stage.DisplayDirect(Var Below:Graph);
Var i:Longint;
Begin For i:=1 to Member.Size Do DisplayDirectObj(i,Below) End;

Procedure Stage.DisplayDirect;
Begin DisplayDirect(Screen) End;

procedure Stage.DisplayObj(id:longint;var Below:Graph);
begin
 DisplayBlendObj(id,-1,Below)
end;

procedure Stage.Display(Var Below:Graph);
var i:longint;
begin
 for i:=1 to Member.Size do
 if Member.Items[i]^.Role.Visible then DisplayObj(i,Below)
end;

procedure Stage.DisplayBlend(tp:shortint;Var Below:Graph);
var i:longint;
begin
 for i:=1 to Member.Size do
 if Member.Items[i]^.Role.Visible then DisplayBlendObj(i,tp,Below)
end;

Procedure Stage.DisplayBlendObj(id:Longint;tp:Shortint);
begin DisplayBlendObj(id,tp,Screen) end;

procedure Stage.DisplayObj(id:Longint);
begin DisplayObj(id,Screen) end;

procedure Stage.DisplayBlend(tp:Shortint);
begin DisplayBlend(tp,Screen) end;

procedure Stage.Display;
begin Display(Screen) end;

procedure Stage.AttachLogic(id:longint;const _log:AnimeLog);
begin
 Member.Items[id]^.Talk:=_Log
end;

procedure Stage.Communication(Below:pGraph);
var
 i:longint;
 tmpM:IPTCMouseEvent;
 tmpB:IPTCMouseButtonEvent;
 tmpK:IPTCKeyEvent;
 SAMe:SAMouseEvent;
 SAKe:SAKeyEvent;
begin
 If Not ConsoleUsing Then Exit;
 With StageMAC Do Begin
 MouseAccept:=False;
 KeyAccept:=False;
 while Console.NextEvent(Event,False,PTCAnyEvent) do
 begin
  If Supports(Event,IPTCMouseEvent) Then
   Begin
    if Supports(Event,IPTCMouseButtonEvent) then
    Begin
     tmpB:=Event as IPTCMouseButtonEvent;
     SAMe.x:=Round(tmpB.Y-StageBiasX+1);
     SAMe.y:=Round(tmpB.X-StageBiasY+1);
     SAMe.button:=GetMouseCode(tmpB.Button);
     SAMe.press:=tmpB.Press;
     SAMe.release:=tmpB.Release;
     If tmpB.Press Then Begin MouseDown:=True; MouseClickX:=SAMe.x; MouseClickY:=SAMe.y; MouseClickT:=DeltaTime End;
     If tmpB.Release Then Begin MouseDown:=False; MouseClickX:=-1; MouseClickY:=-1; MouseClickT:=-1  End;
     MouseX:=SAMe.x;
     MouseY:=SAMe.y;
    End
    Else
    Begin
     tmpM:=Event as IPTCMouseEvent;
     SAMe.x:=Round(tmpM.Y-StageBiasX+1);
     SAMe.y:=Round(tmpM.X-StageBiasY+1);
     SAMe.button:=GetMouseCode(tmpM.ButtonState);
     SAMe.press:=False;
     SAMe.release:=False;
     MouseX:=tmpM.x;
     MouseY:=tmpM.y;
    End;
    for i:=Member.Size Downto 1 do
     if Member.Items[i]^.Role.Visible then
     If Member.Items[i]^.Talk.Enable Then
      Member.Items[i]^.Talk.DealMouse(@StageMAC,Member.Items[i],Below,SAMe)
   end
  else
  if Supports(Event,IPTCKeyEvent) then
   begin
    tmpK:=Event as IPTCKeyEvent;
    SAKe.key:=tmpK.Code;
    SAKe.press:=tmpK.Press;
    SAKe.release:=tmpK.Release;
    SAKe.alt:=tmpK.Alt;
    SAKe.shift:=tmpK.Shift;
    SAKe.ctrl:=tmpK.Control;
    for i:=Member.Size Downto 1 do
     if Member.Items[i]^.Role.Visible then
     If Member.Items[i]^.Talk.Enable Then
      Member.Items[i]^.Talk.DealKey(@StageMAC,Member.Items[i],Below,SAKe)
   end;
 end;
 for i:=Member.Size Downto 1 do
 If Member.Items[i]^.Talk.Enable Then
  Member.Items[i]^.Talk.DealNon(@StageMAC,Member.Items[i],Below)
 End
end;

procedure Stage.Communication(Below:pGraph;Const L:EList);
var
 i,j:longint;
 tmpM:IPTCMouseEvent;
 tmpB:IPTCMouseButtonEvent;
 tmpK:IPTCKeyEvent;
 SAMe:SAMouseEvent;
 SAKe:SAKeyEvent;
begin
 If Not ConsoleUsing Then Exit;
 With StageMAC Do Begin
 MouseAccept:=False;
 KeyAccept:=False;
 For J:=1 to L.Size Do
 begin
  Event:=L[J];
  if Supports(Event,IPTCMouseEvent) then
   begin
    if Supports(Event,IPTCMouseButtonEvent) then
    Begin
     tmpB:=Event as IPTCMouseButtonEvent;
     SAMe.x:=Round(tmpB.Y-StageBiasX+1);
     SAMe.y:=Round(tmpB.X-StageBiasY+1);
     SAMe.button:=GetMouseCode(tmpB.Button);
     SAMe.press:=tmpB.Press;
     SAMe.release:=tmpB.Release;
     If tmpB.Press Then Begin MouseDown:=True; MouseClickX:=SAMe.x; MouseClickY:=SAMe.y; MouseClickT:=DeltaTime End;
     If tmpB.Release Then Begin MouseDown:=False; MouseClickX:=-1; MouseClickY:=-1; MouseClickT:=-1  End;
     MouseX:=SAMe.x;
     MouseY:=SAMe.y;
    End
    Else
    Begin
     tmpM:=Event as IPTCMouseEvent;
     SAMe.x:=Round(tmpM.Y-StageBiasX+1);
     SAMe.y:=Round(tmpM.X-StageBiasY+1);
     SAMe.button:=GetMouseCode(tmpM.ButtonState);
     SAMe.press:=False;
     SAMe.release:=False;
     MouseX:=tmpM.x;
     MouseY:=tmpM.y;
    End;
    for i:=Member.Size Downto 1 do
     if Member.Items[i]^.Role.Visible then
     If Member.Items[i]^.Talk.Enable Then
      Member.Items[i]^.Talk.DealMouse(@StageMAC,Member.Items[i],Below,SAMe)
   end
  else
  if Supports(Event,IPTCKeyEvent) then
   begin
    tmpK:=Event as IPTCKeyEvent;
    SAKe.key:=tmpK.Code;
    SAKe.press:=tmpK.Press;
    SAKe.release:=tmpK.Release;
    SAKe.alt:=tmpK.Alt;
    SAKe.shift:=tmpK.Shift;
    SAKe.ctrl:=tmpK.Control;
    for i:=Member.Size Downto 1 do
     if Member.Items[i]^.Role.Visible then
     If Member.Items[i]^.Talk.Enable Then
      Member.Items[i]^.Talk.DealKey(@StageMAC,Member.Items[i],Below,SAKe)
   end
 end;
 for i:=Member.Size Downto 1 do
 If Member.Items[i]^.Talk.Enable Then
  Member.Items[i]^.Talk.DealNon(@StageMAC,Member.Items[i],Below)
 End
end;

Procedure Stage.Communication;
Begin
 Communication(@Screen)
End;

Procedure Stage.Communication(Const L:EList);
Begin
 Communication(@Screen,L)
End;

Destructor Stage.Free;
Begin
 Member.Clear
End;

destructor Stage.FreeData;
var i:longint;
begin
 for i:=1 to Size do Member.Items[i]^.Role.Source^.Free;
 Member.Clear
end;


//Object-Stage-End

procedure ImageToSagFormat(const g:Graph;const path:ansistring);
var
 tmp:FColor;
 F:Text;
 i:Longint;
 procedure puts;begin with tmp do write(F,s[0],s[1],s[2],s[3]) end;
begin
 Assign(F,path);
 ReWrite(F);
 Writeln(F,'`imagedata');
 tmp.x:=g.Width;  puts;
 tmp.x:=g.Height; puts;
 for i:=0 to g.Width*g.Height-1 do
 begin tmp.c:=g.Canvas[i]; puts end;
 Close(F)
end;

procedure ImagesToSagFormat(const gs:GroupGraph;const path:ansistring);
var
 tmp:FColor;
 F:Text;
 s:Boolean=false;
 i,p:Longint;
 g:Graph;
 procedure puts;begin with tmp do write(F,s[0],s[1],s[2],s[3]) end;
begin
 Assign(F,path);
 ReWrite(F);
 Writeln(F,'`imagedata');
 for p:=1 to gs.Size do
 begin
  if s then write(F,'s') else s:=true;
  g:=gs.Pic.Items[p]^;
  tmp.x:=g.Width;  puts;
  tmp.x:=g.Height; puts;
  for i:=0 to g.Width*g.Height-1 do
  begin tmp.c:=g.Canvas[i]; puts end
 end;
 Close(F)
end;


Var
 lpRect:TRect;
begin
 ProgramStart:=GetTickCount64;
 GetWindowRect(GetDesktopWindow,lpRect);
 ScrWidth:=lpRect.Right-lpRect.Left;
 ScrHeight:=lpRect.Bottom-lpRect.Top;


 Main.Create;

end.
