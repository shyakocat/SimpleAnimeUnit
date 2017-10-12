//此库原本由SimpleAnimeUnit编写
//版本升为SimpleAnimeUnit2后粗略地修改了一下
//存在一些兼容问题
//存在旧版的低效率、复杂的写法
{$M 100000000,0,100000000}
{$MODE OBJFPC}{$H+}
uses MATH,PTC,SimpleAnimeUnit2,SysUtils,Windows,PascalScriptUnit;
var
 Commence,BackGround,Character,Dialog,Selection,Mask,Saves,Cache:Stage;
 GameName,Chapter_Name:Ansistring;
 Prelude:Ansistring;
 NowMusicid,NowSoundid:longint;
 ClickText:Boolean;
 SelectHouse:SList;
 Run:PSLib;
 GameOverFlag:boolean;

 NowChapter,NowBackGround,NowMusic,NowChar,NowPerson,NowText:Ansistring;
 NowBias:Longint;

 SaveChapter,SaveBackGround,SaveMusic,SaveChar,SavePerson,SaveText:Array[1..4,1..6]of Ansistring;
 SaveBias:Array[1..4,1..6]of longint;
 SaveSelect:Array[1..4,1..6]of SList;
 SaveThumbnail:Array[1..4,1..6]of Graph;
 SaveScript:Array[1..4,1..6]of SList;
 SaveNil:Array[1..4,1..6]of Boolean;



Var
 Color_BELOW:Color;


procedure ShowCommence;forward;
procedure ShowBackGround(const idx:ansistring);forward;
procedure ShowBackGround(const idx,showtype:ansistring);forward;
procedure ShowCharacter(const idx:ansistring);forward; //Pos=1~5
procedure ShowCharacter(const idx,showtype:ansistring);forward;
procedure ShowPicture(const idx:ansistring;x,y:longint);forward;
procedure ShowText(const Person:Ansistring;const Say:ansistring);forward;
procedure ShowChapter(const idx:ansistring;pBorder:Longint);forward;
procedure ShowMusic(const idx:ansistring);forward;
procedure ShowSound(const idx:ansistring);forward;
Procedure ShowTitle(Const title:Ansistring);forward;
function ShowSelection(const Select:SList;const TimeLimit:int64):longint;forward;
procedure SaveSchedule();forward;


Var

 tmpFile:Text;
 tmpFileStr:Ansistring;

 DialogFrame_pic:Graph;
 DialogFrame:AnimeObj;

 SaveFrame_pic,SaveFrame_nil:Graph;

 ExitLog,ExitAndSaveLog:AnimeLog;

 NoteMasking_pic,NoteLoading_pic:Graph;


function Clean(S:Ansistring):Ansistring;Forward;
Function Split(S:Ansistring):SList;Forward;
Function Link(Const S:SList;L,R:Longint):Ansistring;Forward;

Procedure ObjectInitial;
Var i,j:Longint;
Begin

 DialogFrame_pic.Create;
 SaveFrame_pic.Create;
 SaveFrame_nil.Create;
 NoteMasking_pic.Create;
 NoteLoading_pic.Create;
 For i:=1 to 4 do
 For j:=1 to 6 do SaveThumbnail[i,j].Create;

 Color_BELOW:=Color_Black

End;

function Grad_Disappear(_tp,t:longint):SimpleAnime;
begin with Grad_Disappear do begin Create; SetAlpha(-1,_tp); SetTime(t) end end;

function Grad_Appear(_tp,t:longint):SimpleAnime;
begin with Grad_Appear do begin Create; SetAlpha(1,_tp); SetTime(t) end end;

procedure DisplayMain;
begin
 ScreenClear(Color_BELOW);
 BackGround.Display;
 Character.Display;
 Dialog.Display;
 Selection.Display;
 Mask.Display
end;

 function __AddSelect(const a:VList):PSValue;
 var i:longint;
 begin
  for i:=1 to a.Size do SelectHouse.pushback(a.Items[i])
 end;

 function __ClrSelect(Const a:VList):PSValue;
 Begin
  SelectHouse.Clear;
 End;

 function __DoSelect(const a:VList):PSValue;
 var Tim:longint;
 begin
  if a.Size=0 then Tim:=-1 else Tim:=a.Items[1];
  Run.Assign('result',ShowSelection(SelectHouse,Tim));
  SelectHouse.Clear
 end;

 function __showselect(Const A:VList):PSValue;
 Var i:Longint; Temp:SList;
 Begin
  Temp.Clear;
  For i:=1 to a.Size Do Temp.PushBack(a.Items[i]);
  Run.Assign('result',ShowSelection(Temp,-1));
  Result:=Run.Get('result');
  Temp.Clear;
 End;

 function __showbackground(const a:VList):PSValue;
 begin if a.Size=0 then ShowBackGround('nil') else
       if a.Size=1 then ShowBackGround(a.Items[1]) else
                        ShowBackGround(a.Items[1],a.Items[2]) end;

 function __showcharacter(const a:VList):PSValue;
 begin if a.Size=0 then ShowCharacter('') else
       if a.Size=1 Then ShowCharacter(a.Items[1]) else
                        ShowCharacter(a.Items[1],a.Items[2]) end;

 function __showtext(const a:VList):PSValue;
 begin if a.Size=0 then ShowText(NowPerson,'nil') else
       if a.Size=1 then ShowText(NowPerson,a.Items[1])
                   else ShowText(a.Items[1],a.Items[2]) end;

 function __showmusic(const a:VList):PSValue;
 begin if a.Size=0 then ShowMusic('nil')
                   else ShowMusic(a.Items[1]) end;

 function __showsound(const a:VList):PSValue;
 begin if a.Size=0 then ShowSound('nil')
                   else ShowSound(a.Items[1]) end;

 function __showchapter(const a:VList):PSValue;

  Function ChapterSearch(path,findtag:Ansistring):Longint;
  Var F:Text; Buf:Ansistring; Line:Longint=0;
  Begin
   FindTag:=Clean(FindTag);
   Assign(F,Path); Reset(F);
   While Not EOF(F) Do
   Begin ReadLn(F,Buf); Inc(Line);
         If Clean(Buf)=FindTag Then Begin Close(F); Exit(Line) End End;
   Close(F); Exit(0)
  End;

 begin if a.Size=1 then ShowChapter(a.Items[1],0)
       else if a.Items[2].Tp=PSInt Then ShowChapter(a.Items[1],a.Items[2])
                                   Else ShowChapter(a.Items[1],ChapterSearch(a.Items[1],a.Items[2])) end;

 function __showtitle(Const a:VList):PSValue;
 Begin ShowTitle(a.Items[1]) End;

 function __gameover(const a:VList):PSValue;
 begin GameOverFlag:=True end;

procedure PascalScriptInit;
begin
 Run.Clear;
 Run.UsesSystem;
 Run.Assign('addselect',TFunc(@__AddSelect));
 Run.Assign('doselect',TFunc(@__DoSelect));
 Run.Assign('clrselect',TFunc(@__ClrSelect));
 Run.Assign('showselect',TFunc(@__showselect));
 Run.Assign('showbackground',TFunc(@__showbackground));
 Run.Assign('showcharacter',TFunc(@__showcharacter));
 Run.Assign('showtext',TFunc(@__showtext));
 Run.Assign('showmusic',TFunc(@__showmusic));
 Run.Assign('showsound',TFunc(@__showsound));
 Run.Assign('showchapter',TFunc(@__showchapter));
 Run.Assign('showtitle',TFunc(@__showtitle));
 Run.Assign('gameover',TFunc(@__gameover));
 Run.Assign('result',0);
end;

 procedure exit_key(Env:pElement;Below:pGraph;Const E:SAKeyEvent);
 begin
  if Not E.Release then Exit;
  if E.key=27 then halt
 end;

 procedure exitsave_key(Env:pElement;Below:pGraph;Const E:SAKeyEvent);
 begin
  if Not E.Release then Exit;
  if E.key=27 then halt;
  if E.key=83 then SaveSchedule
 end;

 procedure text_mouse(Env:pElement;Below:pGraph;Const E:SAMouseEvent;inner:Shortint);
 begin
  if (E.button=1)and(E.press) then ClickText:=True
 end;

 procedure text_key(Env:pElement;Below:pGraph;Const E:SAKeyEvent);
 begin
  if Not E.Release then Exit;
  if E.key=27 then halt;
  if (E.key=10)or(E.key=32)or(E.key=90) then ClickText:=True;
  if E.key=83 then SaveSchedule
 end;

 procedure select_mouse(Env:pElement;Below:pGraph;Const E:SAMouseEvent;inner:ShortInt);
 begin
  if inner=3 then Env^.Role.Alpha:=0.85 else
  if inner=2 then Env^.Role.Alpha:=0.5;
  if (inner and 1=1)and(E.button=1)and(E.press) then Env^.Role.Alpha:=1
 end;

procedure DialogInit(c:Color;const a:real);
var
 i,j,k:longint;
 tmpc:Color;
 text_log:AnimeLog;
begin
 C.A:=round(255*a);

 DialogFrame_pic.Create;
 DialogFrame_pic.Create(Surface.Height div 3,Surface.Width);

 with DialogFrame_pic do
 for i:=1 to Height do
 begin
  tmpc:=C;
  k:=round((6*i/Height)*C.A);
  if k>C.A then k:=C.A;
  tmpc.A:=k;
  for j:=1 to Width do setp(i,j,tmpc)
 end;

 DialogFrame.Create(DialogFrame_pic);
 DialogFrame.Visible:=False;
 DialogFrame.SetXY(Surface.Height-DialogFrame_pic.Height,0);
 Dialog.AddObj(DialogFrame);

 text_log.Create;
 text_log.MouseEvent:=MouseProc(@text_mouse);
 text_log.KeyEvent:=KeyProc(@text_key);
 Dialog.AttachLogic(1,text_log);

end;

procedure SaveInit(const savimg:Ansistring);
begin
 if not FileExists(savimg) then begin MessageBox(0,pchar('标准存储图片['+savimg+']未找到'),'错误：找不到"NoData"的图片',mb_ok); halt end;
 SaveFrame_pic.Load(savimg);
 SaveFrame_nil:=SaveFrame_pic.Cut;
 With SaveFrame_nil do Fill(1,1,Height,Width,Color_Black)
end;

procedure NoteInit;
begin
 NoteMasking_pic.Create(Surface.Height,Surface.Width);
 NoteMasking_pic.Fill(1,1,Surface.Height,Surface.Width,RGBA(252,56,135,63));

end;

procedure ShowBackGround(const idx:ansistring);
var
 a:Graph;
 ra:AnimeObj;
begin
 NowBackGround:=idx;
 if idx<>'nil' then
 if not FileExists(idx) then begin MessageBox(0,pchar('背景图片['+idx+']未找到'),'错误：找不到背景图片',mb_ok); halt end;
 if Dialog.Size>0 then Dialog.Member.Items[1]^.Role.Visible:=False;
 if BackGround.Size<>0 then
 begin
  BackGround.AttachAnime(1,Grad_DisAppear(tp_Sin,700));
  Repeat
   If Not ConsoleUsing Then Halt;
   Lock;
   DisplayMain;
   UnLock
  Until BackGround.AnimeEnd(1)
 end;
 if idx='nil' then Exit;
 a.Create;
 a.Load(idx);
 ra.Create;
 ra.Create(a);
 ra.SetAlpha(0);
 if BackGround.Size=0 then
  BackGround.AddObj(ra)
 else
  BackGround.ReplaceObj(1,ra);
 BackGround.AttachAnime(1,Grad_Appear(tp_Sin,700));
 Repeat
  If Not ConsoleUsing Then Halt;
  Lock;
  DisplayMain;
  UnLock
 Until BackGround.AnimeEnd(1)
end;

Procedure ShowBackGroundInstant(Const Idx:Ansistring);
Var
 a:Graph;
Begin
 NowBackGround:=idx;
 if idx<>'nil' then
 if not FileExists(idx) then begin MessageBox(0,pchar('背景图片['+idx+']未找到'),'错误：找不到背景图片',mb_ok); halt end;
 BackGround.Free;
 If Idx<>'nil' Then Begin
  a.Create;
  a.Load(Idx);
  BackGround.AddObj(A); End;
 Lock;
 DisplayMain;
 UnLock;
End;

Procedure ShowBackGroundOver(Const Idx:Ansistring);
Var
 a:Graph;
 Tmp:^Stage;
 i:Longint;
// b:SimpleAnime;
Begin
 NowBackGround:=idx;
 if idx<>'nil' then
 if not FileExists(idx) then begin MessageBox(0,pchar('背景图片['+idx+']未找到'),'错误：找不到背景图片',mb_ok); halt end;
 a.Create;
 a.Load(Idx);
 New(Tmp,Create);
 Tmp^.AddObj(A);
 For i:=1 to BackGround.Size Do
  BackGround.AttachAnime(i,Grad_DisAppear(tp_Sqr,500));
 Repeat
  If Not ConsoleUsing Then Halt;
  Lock;
  ScreenClear(Color_BELOW);
  Tmp^.Display;
  BackGround.Display;
  Character.Display;
  Dialog.Display;
  Selection.Display;
  Mask.Display;
  UnLock
 Until BackGround.AnimeAllEnd;
 BackGround.Free;
 BackGround:=Tmp^;
 Lock;
 DisplayMain;
 UnLock;
End;

Procedure ShowBackGround(Const Idx,showtype:Ansistring);
Begin
 Case lowercase(showtype) Of
  'instant':ShowBackGroundInstant(Idx);
  'over':ShowBackGroundOver(Idx);
  Else ShowBackGround(Idx);    //Default :  Gradual Fade-Out And Fade-In
 End
End;

procedure ShowCharacter(const idx:ansistring); //Pos=1~5
var
 MemberSize:longint=0;
 PosFlag:Boolean=True;
 Member:SList;
 i,j:longint;
 tPath,tPos,Temp:Ansistring;
 Girl:array[0..2]of Graph;
 Girl_id:array[0..2]of longint;
 Girl_obj:array[0..2]of AnimeObj;
 Girl_tag:array[0..2]of SimpleAnime;
 Girl_pos:array[0..2]of Real;
begin
 NowChar:=idx;
 Member:=Split(Idx);
 For i:=1 to Member.Size Do
 Begin
  tPath:=Member.Items[i];
  j:=Pos('?',tPath);
  If j>0 Then Begin tPos:=Copy(tPath,j+1,Length(tPath)); tPath:=Copy(tPath,1,j-1); PosFlag:=False;
  If Copy(tPos,1,4)<>'pos=' Then ; tPos:=Copy(tPos,5,Length(tPos));
  Val(tPos,Girl_Pos[i-1]) End;
  Member.Items[i]:=tPath;
  if not FileExists(tPath) then
  begin MessageBox(0,pchar('人物图片['+tPath+']未找到'),'错误：找不到人物图片',mb_ok); halt end;
  if MemberSize=3 then
  begin MessageBox(0,'加载人物数量超过最大限度3个','错误：加载过多人物',mb_ok); halt end;
  Member.pushback(tPath);
  Inc(MemberSize);
 end;

 If PosFlag Then
 Case MemberSize of
  1:Girl_Pos[0]:=0.5;
  2:begin Girl_Pos[0]:=1/3; Girl_Pos[1]:=2/3 end;
  3:begin Girl_Pos[0]:=1/6; Girl_Pos[1]:=0.5; Girl_Pos[2]:=5/6 end
 end;

 Character.Free;
 for i:=0 to MemberSize-1 do
 begin
  Girl[i].Create;
  Girl[i].Load(Member.Items[i+1]);
  Girl_obj[i].Create;
  Girl_obj[i].Create(Girl[i]);
  Girl_obj[i].SetXY(Surface.Height-Girl[i].Height,Round(Surface.Width*Girl_pos[i]-Girl[i].Width*0.5)+10);
  Girl_obj[i].SetAlpha(0);
  Girl_id[i]:=Character.AddObj(Girl_Obj[i]);
  Girl_tag[i].Create;
  Girl_tag[i].SetAlpha(1,tp_Sqrt);
  Girl_tag[i].an_BiasY:=-10;
  Girl_tag[i].tp_BiasY:=tp_Sqrt;
  Girl_tag[i].SetTime(500);
  Character.AttachAnime(Girl_id[i],Girl_tag[i])
 end;

 Repeat
  If Not ConsoleUsing Then Halt;
  Lock;
  DisplayMain;
  UnLock
 Until Character.AnimeAllEnd;

end;

Procedure ShowCharacterInstant(Const Idx:Ansistring);
var
 MemberSize:longint=0;
 PosFlag:Boolean=True;
 Member:SList;
 i,j:longint;
 tPath,tPos:Ansistring;
 Girl:array[0..2]of Graph;
 Girl_obj:array[0..2]of AnimeObj;
 Girl_pos:array[0..2]of Real;
 Tmp:^Stage;
Begin
 NowChar:=idx;
 Member:=Split(Idx);
 For i:=1 to Member.Size Do
 Begin
  tPath:=Member.Items[i];
  j:=Pos('?',tPath);
  If j>0 Then Begin tPos:=Copy(tPath,j+1,Length(tPath)); tPath:=Copy(tPath,1,j-1); PosFlag:=False;
  If Copy(tPos,1,4)<>'pos=' Then ; tPos:=Copy(tPos,5,Length(tPos));
  Val(tPos,Girl_Pos[i-1]) End;
  Member.Items[i]:=tPath;
  if not FileExists(tPath) then
  begin MessageBox(0,pchar('人物图片['+tPath+']未找到'),'错误：找不到人物图片',mb_ok); halt end;
  if MemberSize=3 then
  begin MessageBox(0,'加载人物数量超过最大限度3个','错误：加载过多人物',mb_ok); halt end;
  Member.pushback(tPath);
  inc(MemberSize);
 end;

 If PosFlag Then
 Case MemberSize of
  1:Girl_Pos[0]:=0.5;
  2:begin Girl_Pos[0]:=1/3; Girl_Pos[1]:=2/3 end;
  3:begin Girl_Pos[0]:=1/6; Girl_Pos[1]:=0.5; Girl_Pos[2]:=5/6 end
 end;

 Character.Free;
 for i:=0 to MemberSize-1 do
 begin
  Girl[i].Create;
  Girl[i].Load(Member.Items[i+1]);
  Girl_obj[i].Create(Girl[i]);
  Girl_obj[i].SetXY(Surface.Height-Girl[i].Height,Round(Surface.Width*Girl_pos[i]-Girl[i].Width*0.5));
  Character.AddObj(Girl_Obj[i])
 end;

 Lock;
 DisplayMain;
 UnLock;

End;

Procedure ShowCharacterOver(Const Idx:Ansistring);
var
 MemberSize:longint=0;
 PosFlag:Boolean=True;
 Member:SList;
 i,j:longint;
 tPath,tPos:Ansistring;
 Girl:array[0..2]of Graph;
 Girl_obj:array[0..2]of AnimeObj;
 Girl_pos:array[0..2]of Real;
 Tmp:^Stage;
Begin
 NowChar:=idx;
 Member:=Split(Idx);
 For i:=1 to Member.Size Do
 Begin
  tPath:=Member.Items[i];
  j:=Pos('?',tPath);
  If j>0 Then Begin tPos:=Copy(tPath,j+1,Length(tPath)); tPath:=Copy(tPath,1,j-1); PosFlag:=False;
  If Copy(tPos,1,4)<>'pos=' Then ; tPos:=Copy(tPos,5,Length(tPos));
  Val(tPos,Girl_Pos[i-1]) End;
  Member.Items[i]:=tPath;
  if not FileExists(tPath) then
  begin MessageBox(0,pchar('人物图片['+tPath+']未找到'),'错误：找不到人物图片',mb_ok); halt end;
  if MemberSize=3 then
  begin MessageBox(0,'加载人物数量超过最大限度3个','错误：加载过多人物',mb_ok); halt end;
  Member.pushback(tPath);
  inc(MemberSize);
 end;

 If PosFlag Then
 Case MemberSize of
  1:Girl_Pos[0]:=0.5;
  2:begin Girl_Pos[0]:=1/3; Girl_Pos[1]:=2/3 end;
  3:begin Girl_Pos[0]:=1/6; Girl_Pos[1]:=0.5; Girl_Pos[2]:=5/6 end
 end;

 New(Tmp,Create);
 for i:=0 to MemberSize-1 do
 begin
  Girl[i].Create;
  Girl[i].Load(Member.Items[i+1]);
  Girl_obj[i].Create(Girl[i]);
  Girl_obj[i].SetXY(Surface.Height-Girl[i].Height,Round(Surface.Width*Girl_pos[i]-Girl[i].Width*0.5));
  Girl_obj[i].SetAlpha(0);
  Tmp^.AttachAnime(Tmp^.AddObj(Girl_Obj[i]),Grad_Appear(tp_Sqrt,500))
 end;

 For i:=1 to Character.Size Do
  Character.AttachAnime(i,Grad_DisAppear(tp_Pow,500));

 Tmp^.AnimeAllBegin;
 Character.AnimeAllBegin;
 Repeat
  If Not ConsoleUsing Then Halt;
  Lock;
  ScreenClear(Color_BELOW);
  BackGround.Display;
  Tmp^.Display;
  Character.Display;
  Dialog.Display;
  Selection.Display;
  Mask.Display;
  UnLock
 Until Tmp^.AnimeAllEnd And Character.AnimeAllEnd;

 Character.Free;
 Character:=Tmp^;

 Lock;
 DisplayMain;
 UnLock;

End;


Procedure ShowCharacter(Const Idx,showtype:Ansistring);
Begin
 Case lowercase(showtype) of
  'instant':ShowCharacterInstant(Idx);
  'over':ShowCharacterOver(IDx);
  Else ShowCharacter(Idx)  //Default : Fade-Out And Fade-In
 End
End;

procedure ShowPicture(const idx:ansistring;x,y:longint);
begin
end;

procedure ShowText(const Person:Ansistring;const Say:ansistring);
var
 W,H,name_x,name_y,text_x,text_y,Lim,i,j:longint;
 Sclip:Ansistring;
 Split:Specialize List<WideString>;
 tmp:Graph;
 textp,textq:longint;
 _StdTime,_TotTime:Int64;

 Event:IPTCEvent;
begin
 NowPerson:=Person;
 NowText:=Say;

 if Dialog.Size=0 then DialogInit(Color_Black,0.5);

 if Say='nil' then
 begin

  Dialog.Get(1)^.Visible:=False;
  Lock;
  DisplayMain;
  UnLock;

  Repeat
   Console.NextEvent(Event,True,PTCAnyEvent);
   If Supports(Event,IPTCCloseEvent) Then Halt Else
   if Supports(Event,IPTCMouseEvent)and(PTCMouseButton1 in (Event as IPTCMouseEvent).ButtonState) then break;
   if Supports(Event,IPTCKeyEvent) then
   begin
    i:=(Event as IPTCKeyEvent).Code;
    if i=27 then halt;
    if (i=10)or(i=32)or(i=90) then break;
    if (i=83)and(Event as IPTCKeyEvent).Release then SaveSchedule
   end
  Until False;

  exit

 end;

 ClickText:=False;

 tmp:=DialogFrame_pic.Cut;

 W:=tmp.Width;
 H:=tmp.Height;

 name_x:=H div 8;
 name_y:=W div 10;

 text_x:=H div 3;
 text_y:=W div 6;

 tmp.AddText(Person,30,Color_White,H div 32*5,W div 7);

 Dialog.Get(1)^.Free;
 Dialog.Get(1)^.Create(tmp);
 Dialog.Get(1)^.BiasX:=Surface.Height-tmp.Height;

 Split.Clear;

 Lim:=Surface.Width*2 div 30;
 SClip:=Say;
 while Length(SClip)>Lim do
 begin
  j:=0;
  for i:=1 to Lim do
  if j=1 then j:=0 else
  if ord(SClip[i])>127 then j:=1;
  Split.pushback(Copy(SClip,1,Lim-j));
  Delete(Sclip,1,Lim-j)
 end;
 if SClip<>'' then Split.pushback(Sclip);

 Dialog.Get(1)^.Visible:=True;

 _TotTime:=2000;

 i:=1;
 while (i<=Split.Size)and(not ClickText) do
 begin

  textp:=0;
  _StdTime:=DeltaTime;

  Sclip:=Split.Items[i];

  Repeat

   If Not ConsoleUsing Then Halt;

   textp:=round(Lim/_TotTime*(DeltaTime-_StdTime));
   textp:=min(textp,Length(Sclip));

   textq:=0;
   For j:=1 to textp Do textq:=textq Xor Ord(Sclip[textp]>#127);

   Dialog.Get(1)^.Free;
   Dialog.Get(1)^.Create(tmp);
   Dialog.Get(1)^.BiasX:=Surface.Height-tmp.Height;
   pGraph(Dialog.Get(1)^.Source)^.AddText(Copy(Sclip,1,textp-textq),20,Color_White,text_x,text_y);

   Dialog.Communication;

   Lock;
   DisplayMain;
   UnLock;

  Until ClickText or (textp=Length(Sclip));

  tmp.AddText(Sclip,20,Color_White,text_x,text_y);

  inc(text_x,25);

  inc(i)

 end;

 ClickText:=False;

 Dialog.Get(1)^.Free;
 Dialog.Get(1)^.Create(DialogFrame_pic);
 Dialog.Get(1)^.BiasX:=Surface.Height-DialogFrame_pic.Height;
 pGraph(Dialog.Get(1)^.Source)^.AddText(Person,30,Color_White,H div 32*5,W div 7);

 text_x:=H div 3;
 text_y:=W div 6;

 for i:=1 to Split.Size do
 begin
  pGraph(Dialog.Get(1)^.Source)^.AddText(Split.Items[i],20,Color_White,text_x,text_y);
  inc(text_x,25)
 end;

 Repeat

  If Not ConsoleUsing Then Halt;

  Dialog.Communication;

  Lock;
  DisplayMain;
  UnLock

 Until ClickText;

 tmp.Free

end;

 function Clean(S:Ansistring):Ansistring;
 var
  i:longint;
 begin
  i:=1; while i<=Length(s) do begin if s[i]<>' ' then break; inc(i) end;
  Delete(S,1,i-1);
  i:=Length(s); while i>0 do begin if s[i]<>' ' then break; dec(i) end;
  Delete(S,i+1,Length(S));
  Exit(LowerCase(S))
 end;

 Function Split(S:Ansistring):SList;
 Var D:Longint;
 Begin
  Result.Clear;
  Repeat
   S:=Clean(S);
   D:=Pos(' ',S);
   If D=0 Then Break;
   Result.PushBack(Copy(S,1,D-1));
   Delete(S,1,D)
  Until False;
  If S<>'' Then Result.PushBack(S)
 End;

 Function Link(Const S:SList;L,R:Longint):Ansistring;
 Var i:Longint;
 Begin
  Result:='';
  If L>R Then Exit;
  For i:=L to R-1 Do Result:=Result+S.Items[i]+' ';
  Result:=Result+S.Items[R]
 End;


Procedure SAGSleep(T:Int64);
Begin
 GetClose(T,100)
End;

Function ShowCmd(S:Ansistring):Boolean;
Begin
 S:=LowerCase(S);
 Exit((S='instant')Or
      (S='over'))
End;

Procedure ShowTitle(Const Title:Ansistring);
Begin
 SetTitle('SAG模拟器 by shyakocat    '+Title)
End;

Procedure ShowChapter(const idx:ansistring;pBorder:Longint);
var
 pBias:longint=0;
 F:text;
 S:Ansistring;
 Talker_Name:ansistring;
 d:longint;
 Scripting:Boolean=False;
 Ss:SList;

 procedure Get(var S:Ansistring);
 var i:longint;
 begin
  S:='';
  while (not Eof(F))and(S='') do readln(F,S)
 end;

begin
 NowChapter:=idx;

 if not FileExists(idx) then begin MessageBox(0,pchar('脚本['+idx+']未找到'),'错误：找不到章节',mb_ok); halt end;

 Talker_Name:='';

 Assign(F,idx); Reset(F);

 while Not Eof(F) do
 Begin

  if GameOverFlag then break;

  inc(pBias);
  NowBias:=pBias;

  Get(S);

  case lowercase(clean(s)) of
   '&selection':Scripting:=True;
   '&selectionend':Scripting:=False
  end;

  if pBias<pBorder then continue;

  if Scripting then Run.Exec(s) else
  If S<>'' Then
  if S[1]='`' Then Continue Else
  if S[1]='#' then
   Begin
    If Chapter_Name='' Then
    Begin
     Chapter_Name:=Copy(S,2,length(S)-1);
     Run.Assign('Chapter_Name',Chapter_Name)
    End
   End else
  if s[1]='&' then
   begin
    SS:=Split(S);
    Case SS.Items[1] Of
     '&background':If ShowCmd(SS.Items[SS.Size]) Then ShowBackGround(Link(SS,2,SS.Size-1),SS.Items[3])
                                                 Else ShowBackGround(Link(SS,2,SS.Size));
     '&character' :If ShowCmd(SS.Items[SS.Size]) Then ShowCharacter(Link(SS,2,SS.SIze-1),SS.Items[SS.Size])
                                                 Else ShowCharacter(Link(SS,2,SS.Size));
     '&music':ShowMusic(SS.Items[2]);
     '&sound':ShowSound(SS.Items[2]);
     '&delay':SAGSleep(StrToInt(SS.Items[2]));
     '&gameover':GameOverFlag:=True;
    End
   end
  else
   begin
    if (s[1]='\')and(s[2]='`') then delete(s,1,1);
    d:=pos('：',s);
    if d<>0 then
    if (d>1)and(s[d-1]='\') then Delete(S,d-1,1)
    else begin Talker_Name:=Copy(S,1,d-1); Delete(S,1,d+1) end;
    ShowText(Talker_Name,S)
   end;


 End;

 Close(F)
end;

procedure ShowMusic(const idx:ansistring);
begin
 NowMusic:=idx;
 if idx='nil' then
 begin
  if NowMusicid<>0 then StopMusic(NowMusicid);
  exit
 end;
 if not FileExists(idx) then begin MessageBox(0,pchar('音乐['+idx+']未找到'),'错误：找不到音乐',mb_ok); halt end;
 if NowMusicid<>0 then StopMusic(NowMusicid);
 NowMusicid:=OpenMusic(idx);
 PlayMusicRepeat(NowMusicid)
end;

procedure ShowSound(const idx:ansistring);
begin
 if idx='nil' then
 begin
  if NowSoundid<>0 then StopMusic(NowSoundid);
  exit
 end;
 if not FileExists(idx) then begin MessageBox(0,pchar('音效['+idx+']未找到'),'错误：找不到音效',mb_ok); halt end;
 if NowSoundid<>0 then StopMusic(NowSoundid);
 NowSoundid:=OpenMusic(idx);
 PlayMusic(NowSoundid)
end;

function ShowSelection(const Select:SList;const TimeLimit:int64):longint;
var
 tmp,tmpsel:Graph;
 obj:AnimeObj;
 StdSelLog:AnimeLog;
 i,Option:longint;
 PassTime,RegTime:int64;
begin
 stdSelLog.Create;
 stdSelLog.MouseEvent:=@select_mouse;
 tmp.Create;
 tmp.Create(40,Surface.Width div 2);
 tmp.Fill(1,1,tmp.Height,tmp.Width,Color_Cyan);
 tmp.Fill(4,4,tmp.Height-4,tmp.Width-4,Color_Alpha);
 tmp.Fill(6,6,tmp.Height-6,tmp.Width-6,Color_Cyan);
 obj.Create;
 Selection.Free;
 for i:=1 to Select.Size do
 begin
  tmpsel:=tmp.cut;
  tmpsel.AddText(Select.Items[i],20,Color_Black,
                 10,tmp.Width div 2-Length(Select.Items[i])*5);
  obj.Create(tmpsel);
  obj.SetAlpha(0.5);
  obj.SetXY(Surface.Height div 3*2 div(Select.Size+1)*i-14,Surface.Width div 2-tmpsel.Width div 2);
  Selection.AttachLogic(Selection.AddObj(obj),StdSelLog)
 end;

 tmp.Free;

 stdSelLog.KeyEvent:=KeyProc(@exitsave_key);
 Selection.AttachLogic(1,StdSelLog);

 PassTime:=0;

 Repeat
  If Not ConsoleUsing Then Halt;

  Selection.Communication;

  RegTime:=DeltaTime;

  Option:=0;

  for i:=1 to Selection.Size do
  if Selection.Member.Items[i]^.Role.Alpha=1 then
  begin
   Option:=i;
   Break
  end;

  Lock;
  DisplayMain;
  UnLock;

  inc(PassTime,DeltaTime-RegTime);

  if (TimeLimit<>-1)and(PassTime>TimeLimit) then Break;

 Until Option<>0;

 Selection.Free;

 exit(Option)
end;

procedure LoadSaves;
var
 F:Text;
 i,j,k,w,h:longint;
 fs,s,t:ansistring;
 tmp,tmpc:Graph;
begin
 tmp.Create;
 tmpc.Create;

 Saves.Free;

 w:=SaveFrame_pic.Width;
 h:=SaveFrame_pic.Height;

 FillChar(SaveNil,Sizeof(SaveNil),0);

 For i:=1 to 4 do
 For j:=1 to 4 do SaveThumbnail[i,j].Create;

 for i:=1 to 4 do
 for j:=1 to 6 do
 begin
  SaveThumbnail[i,j].Free;
  SaveThumbnail[i,j].Create;
  SaveScript[i,j].Clear;
  fs:='save/'+IntToStr((i-1)*6+j)+'.sag';
  if FileExists(fs) then
  begin
   Assign(F,fs);
   Reset(F);

   Readln(F,s);
   if lowercase(Clean(s))='`savedata' then
   begin

    Readln(F,SaveChapter[i,j]);
    Readln(F,SaveBackground[i,j]);
    Readln(F,SaveMusic[i,j]);
    Readln(F,SaveChar[i,j]);
    Readln(F,SavePerson[i,j]);
    Readln(F,SaveText[i,j]);
    Readln(F,SaveBias[i,j]);
    Readln(F,K);
    SaveSelect[i,j].Clear;
    for K:=1 to K do
    begin
     Readln(F,t);
     SaveSelect[i,j].Pushback(t)
    end;

    if FileExists(SaveBackGround[i,j]) then
    begin
     tmp.Load(SaveBackground[i,j]);
     tmpc:=tmp.LinearMapped(1,1,1,w,h,1,h,w);
     SaveThumbnail[i,j]:=tmpc.cut(1,1,h,w);
     tmpc.Free
    end
    else
     SaveThumbnail[i,j]:=saveframe_nil.cut;

    while Not Eof(F) do
    begin
     Readln(F,t);
     SaveScript[i,j].PushBack(t)
    end

   end
   else
   begin
    SaveThumbnail[i,j]:=saveframe_pic.cut;
    SaveNil[i,j]:=True
   end;
   Close(F);
  end
  else
  begin
   SaveThumbnail[i,j]:=saveframe_pic.cut;
   SaveNil[i,j]:=True
  end;

  k:=Saves.AddObj(SaveThumbnail[i,j]);
  Saves.Get(k)^.SetXY(Surface.Height div 5*i-h div 2,Surface.Width div 7*j-w div 2);

 end;

 tmp.Free

end;


Var
 MouseLast:Array[1..24]of Int64;
 MouseClick:Array[1..24]of Shortint;


procedure SaveSchedule;
const TimeBorder=300;
Var
 tmpM:SAMouseEvent;
 tmpK:SAKeyEvent;
 absX,absY,X,Y,Z,i,j,Key,KeyRelease:longint;
 PartTmp,PartStd,PartDelta:Int64;

 theta,w,h,Len,Lambda,_sin,_cos,Bx,By:real;
 tmp,tmpc:Graph;

 procedure SaveNow(id:longint);
 var
  F:Text;
  i:longint;
 begin
  Assign(F,'save/'+IntToStr(id)+'.sag');
  Rewrite(F);

  Writeln(F,'`savedata');
  Writeln(F,NowChapter);
  Writeln(F,NowBackGround);
  Writeln(F,NowMusic);
  Writeln(F,NowChar);
  Writeln(F,NowPerson);
  Writeln(F,NowText);
  Writeln(F,NowBias);
  Writeln(F,SelectHouse.Size);
  for i:=1 to SelectHouse.Size do
   Writeln(F,SelectHouse.Items[i]);
  with Run do
  for i:=1 to Size do
  case vData.Items[i].Tp of
   PSInt   :writeln(F,vname.node.items[i],':=',Longint(vData.Items[i]));
   PSDouble:writeln(F,vname.node.items[i],':=',Extended(vData.Items[i]));
   pSStr   :writeln(F,vname.node.items[i],':=''',Ansistring(vData.Items[i]),#39)
  end;

  Close(F)
 end;

begin
 tmp.Create;
 tmpc.Create;

 FillChar(MouseLast,Sizeof(MouseLast),0);
 FillChar(MouseClick,Sizeof(MouseClick),0);

 w:=SaveFrame_Pic.Width;
 h:=SaveFrame_Pic.Height;
 Len:=Math.max(w,h)*2.5;

 absX:=0;
 absY:=0;


 LoadSaves;

 Cache.Free;
 Lock;
 Cache.AddObj(Screen);
 Cache.Get(1)^.SetAlpha(0.32);
 UnLock;


 PartStd:=DeltaTime;
 PartDelta:=0;
 Repeat

  If Not ConsoleUsing Then Halt;

  PartTmp:=PartStd;
  PartStd:=DeltaTime;
  PartDelta:=PartStd-PartTmp;

  TestMouse(tmpM);
  TestKey(tmpK);
  if tmpM.X<>0 Then Begin X:=TmpM.X; Y:=TmpM.Y; Z:=TmpM.Button End;
  Key:=TmpK.Key; KeyRelease:=Ord(TmpK.Release);
  if x<>-1 then
  begin
   absX:=Y;
   absY:=X
  end;
  if Key=27 then halt;

  for i:=1 to Saves.Size do
  begin
   if Saves.IsInner(i,absX,absY) then
   begin inc(MouseLast[i],PartDelta); if Z=1 then MouseClick[i]:=(1-MouseClick[i]and 1)*2or 1 end else
   begin dec(MouseLast[i],PartDelta); MouseClick[i]:=(MouseClick[i]and 1)<<1 end;

   if MouseClick[i]=3 then
   begin
    SaveNow(i);
    tmp.Create;
    tmp.Load(NowBackGround);
    tmpc:=tmp.LinearMapped(1,1,1,w,h,1,h,w);
    SaveThumbnail[(i-1)div 6+1,(i-1)mod 6+1].Free;
    SaveThumbnail[(i-1)div 6+1,(i-1)mod 6+1]:=tmpc.Cut(1,1,Round(h),Round(w));
    tmp.Free;
    tmpc.Free
   end;

   if MouseLast[i]<0          then MouseLast[i]:=0;
   if MouseLast[i]>TimeBorder then MouseLast[i]:=TimeBorder;


   theta:=MouseLast[i]/450*30*pi/180;
   _sin:=Sin(theta);
   _cos:=Cos(theta);
   Lambda:=Len/(Len+w*_sin);
   By:=w*(0.5+(_cos-0.5)*Lambda);
   Bx:=h*0.5*(1+Lambda);

   if not((abs(Bx-1)<1e-6)and(abs(By-w)<1e-6)) then
   begin
    pGraph(Saves.Get(i)^.Source)^.Free;
    pGraph(Saves.Get(i)^.Source)^:=SaveThumbnail[(i-1)div 6+1,(i-1)mod 6+1].LinearMapped(1,1,h-Bx,By,h,1,Bx,By)
   end

  end;

  Lock;
  ScreenClear;
  Cache.Display;
  Saves.Display;
  UnLock
 Until (Key=83)And(KeyRelease=1);

 Saves.Free;
 for i:=1 to 4 do
 for j:=1 to 6 do
 Begin
  SaveThumbnail[i,j].Free;
  SaveThumbnail[i,j].Create
 End;

 Cache.Get(1)^.SetAlpha(1);
 Lock;
 Cache.Display;
 UnLock

end;

procedure LoadSchedule;
const TimeBorder=300;
Var
 tmpM:SAMouseEvent;
 tmpK:SAKeyEvent;
 absX,absY,X,Y,Z,i,j,Key,KeyRelease,LoadObj:longint;
 PartTmp,PartStd,PartDelta:Int64;

 theta,w,h,Len,Lambda,_sin,_cos,Bx,By:real;
 tmp,tmpc:Graph;

begin
 tmp.Create;
 tmpc.Create;

 FillChar(MouseLast,Sizeof(MouseLast),0);
 FillChar(MouseClick,Sizeof(MouseClick),0);

 w:=SaveFrame_Pic.Width;
 h:=SaveFrame_Pic.Height;
 Len:=Math.max(w,h)*2.5;

 absX:=0;
 absY:=0;

 LoadObj:=0;

 LoadSaves;

 Cache.Free;
 Lock;
 Cache.AddObj(Screen);
 Cache.Get(1)^.SetAlpha(0.32);
 UnLock;



 PartStd:=DeltaTime;
 PartDelta:=0;
 Repeat

  If Not ConsoleUsing Then Halt;

  PartTmp:=PartStd;
  PartStd:=DeltaTime;
  PartDelta:=PartStd-PartTmp;

  TestMouse(tmpM);
  TestKey(tmpK);
  if tmpM.X<>0 Then Begin X:=tmpM.X; Y:=tmpM.Y; Z:=tmpM.Button End;
  Key:=TmpK.Key; KeyRelease:=Ord(TmpK.Release);
  if x<>-1 then
  begin
   absX:=Y;
   absY:=X
  end;
  if Key=27 then halt;

  for i:=1 to Saves.Size do
  begin
   if Saves.IsInner(i,absX,absY) then
   begin inc(MouseLast[i],PartDelta); if Z=1 then MouseClick[i]:=(1-MouseClick[i]and 1)*2or 1 end else
   begin dec(MouseLast[i],PartDelta); MouseClick[i]:=(MouseClick[i]and 1)<<1 end;

   if (MouseClick[i]=3)And(not SaveNil[(i-1)div 6+1,(i-1)mod 6+1]) then
   begin
    LoadObj:=i;
    Break
   end;

   if MouseLast[i]<0          then MouseLast[i]:=0;
   if MouseLast[i]>TimeBorder then MouseLast[i]:=TimeBorder;


   theta:=MouseLast[i]/450*30*pi/180;
   _sin:=Sin(theta);
   _cos:=Cos(theta);
   Lambda:=Len/(Len+w*_sin);
   By:=w*(0.5+(_cos-0.5)*Lambda);
   Bx:=h*0.5*(1+Lambda);

   if not((abs(Bx-1)<1e-6)and(abs(By-w)<1e-6)) then
   begin
    pGraph(Saves.Get(i)^.Source)^.Free;
    pGraph(Saves.Get(i)^.Source)^:=SaveThumbnail[(i-1)div 6+1,(i-1)mod 6+1].LinearMapped(1,1,h-Bx,By,h,1,Bx,By)
   end

  end;

  Lock;
  ScreenClear;
  Cache.Display;
  Saves.Display;
  UnLock
 Until (Key=83)or(LoadObj<>0);

 Saves.Free;
 for i:=1 to 4 do
 for j:=1 to 6 do
 Begin
  SaveThumbnail[i,j].Free;
  SaveThumbnail[i,j].Create
 End;


 if LoadObj<>0 then
 begin
  X:=(LoadObj-1)div 6+1;
  Y:=(LoadObj-1)mod 6+1;

  SelectHouse.Clear;
  BackGround.Free;
  Character.Free;
  Selection.Free;
  ShowSound('nil');

  Mask.Free;
  Mask.AddObj(notemasking_pic);

  ShowMusic(SaveMusic[x,y]);
  ShowBackGround(SaveBackGround[x,y]);
  ShowCharacter(SaveChar[x,y]);
  ShowText(SavePerson[x,y],SaveText[x,y]);

  Mask.Free;

  For i:=1 to SaveSelect[x,y].Size do SelectHouse.pushback(SaveSelect[x,y].Items[i]);
  PascalScriptInit;
  Run.Exec(SaveScript[x,y]);
  ShowChapter(SaveChapter[x,y],SaveBias[x,y])

 end

end;




var
 FreshMust:Boolean=True;
 HaveShow:Boolean=False;


procedure GameStart;
begin

 BackGround.Free;
 Character.Free;
 Dialog.Free;
 Selection.Free;

 GameOverFlag:=False;

 Chapter_Name:='';

 FreshMust:=True;

 ShowChapter(prelude,0);

 FreshMust:=True;

 HaveShow:=False

end;

procedure GameContinue;
begin

 GameOverFlag:=False;

 LoadSchedule;

 FreshMust:=True;

 HaveShow:=False;

end;

procedure GameExit;
begin
 Endit;
 halt
end;

 procedure SelStart(Env:pElement;Below:pGraph;Const E:SAMouseEvent;inner:Shortint);
 begin
  If Not HaveShow Then Exit;
  If Inner And 2<>0 Then FreshMust:=True;

  if inner and 1=1 then Env^.Role.SetAlpha(1)
                   else Env^.Role.SetAlpha(0.6);

  if (inner and 1=1)and(E.button=1)and(E.press) then GameStart
 end;

 procedure SelContinue(Env:pElement;Below:pGraph;Const E:SAMouseEvent;inner:Shortint);
 begin
  If Not HaveShow Then Exit;
  If Inner And 2<>0 Then FreshMust:=True;

  if inner and 1=1 then Env^.Role.SetAlpha(1)
                   else Env^.Role.SetAlpha(0.6);

  if (inner and 1=1)and(E.button=1)and(E.press) then GameContinue
 end;

 procedure SelExit(Env:pElement;Below:pGraph;Const E:SAMouseEvent;inner:ShortInt);
 begin
  If Not HaveShow Then Exit;
  If Inner And 2<>0 Then FreshMust:=True;

  if inner and 1=1 then Env^.Role.SetAlpha(1)
                   else Env^.Role.SetAlpha(0.6);

  if (inner and 1=1)and(E.button=1)and(E.press) then GameExit
 end;

var
 CommenceText:Stage;

procedure ShowCommence;
var
 CoBack    ,CoTitle    ,CoStart    ,CoRead    ,CoExit    :Graph;
 CoBack_obj,CoTitle_obj,CoStart_obj,CoRead_obj,CoExit_obj:AnimeObj;
 CoBack_id ,CoTitle_id ,CoStart_id ,CoRead_id ,CoExit_id :longint;
            CoTitle_tg ,CoSel_tg                         :SimpleAnime;
                        CoStart_lg ,CoRead_lg ,CoExit_lg :AnimeLog;

 backimage,backmusic:Ansistring;

 NowFresh:Int64;

 x,y,button:longint;
 tmp:pAnimeObj;
begin
 BackGround.Free;
 Character.Free;
 Dialog.Free;
 Selection.Free;
 Mask.Free;

 NowMusicid:=0;
 NowSoundid:=0;

 backimage:='image/bg000.png';
 backmusic:='music/bgm000.mp3';
 freshlimit:=0;

 prelude:='chapter/序章.sag';

 if not FileExists('chapter/序章.sag') then begin MessageBox(0,pchar('进入点[序章.sag]未找到'),'错误：找不到进入章节',mb_ok); halt end;

 if FileExists('chapter/序章.sag') then Assign(TmpFile,'chapter/序章.sag');

 Reset(TmpFile);
 Repeat
  Readln(TmpFile,TmpFileStr);
  if (TmpFileStr='')Or(TmpFileStr[1]<>'`') then Break;
  if lowercase(Copy(TmpFileStr,1,9))='`gamename' then
   GAMENAME:=Copy(TmpFileStr,10,Length(TmpFileStr))
  else
  if lowercase(Copy(TmpFileStr,1,15))='`gamebackground' then
   backimage:=Clean(Copy(TmpFileStr,16,Length(TmpFileStr)))
  else
  if lowercase(Copy(TmpFileStr,1,14))='`gamebackmusic' then
   backmusic:=Clean(Copy(TmpFileStr,15,Length(TmpFileStr)))
  else
  if lowercase(Copy(TmpFileStr,1,13))='`gamelanguage' then
   case Clean(Copy(TmpFileStr,14,Length(TmpFileStr))) of
    'chinese':prelude:='chapter/序章.sag';
    'english':prelude:='chapter/prologue.sag';
    'japanese':prelude:='chapter/じょしょう.sag';
   end
  else
  if lowercase(Copy(TmpFileStr,1,10))='`gameframe' then
  begin
   x:=StrToInt(Clean(Copy(TmpFileStr,11,Length(TmpFileStr))));
   if (0<x)and(x<200) then FreshLimit:=1000 div x
  end
 Until False;
 Close(TmpFile);

 NowMusic:='nil';
 if FileExists(backmusic) then ShowMusic(backmusic)
 Else backmusic:='nil';

 PascalScriptInit;

 ExitLog.Create;
 ExitLog.KeyEvent:=@exit_key;

 ExitAndSaveLog.Create;
 ExitAndSaveLog.KeyEvent:=@exitsave_key;


 CoBack.Create;
 CoBack.LoadPNG(backimage);
 CoBack_obj.Create;
 CoBack_obj.Create(CoBack);
 CoBack_obj.SetAlpha(0);
 CoBack_id:=Commence.AddObj(CoBack_obj);
 Commence.AttachAnime(CoBack_id,Grad_Appear(tp_Sin,1000));

 CoTitle.Create;
 CoTitle.CreateText(GAMENAME,60,Color_Black);
 CoTitle.Change(RGBA(0,0,0,0),RGBA(255,255,255,255));
 CoTitle_obj.Create;
 CoTitle_obj.Create(CoTitle);
 CoTitle_obj.SetAlpha(0);
 CoTitle_obj.SetXY(CoBack.Height div 10,CoBack.Width div 15);
 CoTitle_tg.Create;
 CoTitle_tg.SetAlpha(1,tp_Sin);
 CoTitle_tg.an_BiasX:=CoBack.Height/6-CoTitle_obj.BiasX;
 coTitle_tg.tp_BiasX:=tp_Sin;
 CoTitle_tg.SetTime(1000);
 CoTitle_id:=CommenceText.AddObj(CoTitle_obj);
 CommenceText.AttachAnime(CoTitle_id,CoTitle_tg);
 CommenceText.AttachLogic(CoTitle_id,ExitLog);
 CommenceText.AnimeAllBegin;

 Init('SAG模拟器 by shyakocat    '+GAMENAME,CoBack.Width,CoBack.Height);
 repeat
  If Not ConsoleUsing Then Halt;
  Lock;
  ScreenClear;
  Commence.Display;
  CommenceText.DisplayBlend(blend_multiply);
  UnLock
 until CommenceText.AnimeEnd(CoBack_id);

 CoStart.Create;
 CoStart.CreateText('Start',40,Color_Black);
 CoStart.Change(RGBA(0,0,0,0),RGBA(255,255,255,255));
 CoStart_obj.Create;
 CoStart_obj.Create(CoStart);
 CoStart_obj.SetAlpha(0);
 CoStart_obj.SetXY(CoBack.Height*2 div 5,CoBack.Width div 3*2);
 CoSel_tg.Create;
 CoSel_tg.SetAlpha(0.6,tp_Sin);
 CoSel_tg.an_BiasY:=-CoBack.Width div 20;
 coSel_tg.tp_BiasY:=tp_Sin;
 CoSel_tg.SetTime(300);
 CoStart_id:=CommenceText.AddObj(CoStart_obj);
 CommenceText.AttachAnime(CoStart_id,CoSel_tg);
 CommenceText.AnimeBegin(CoStart_id);

 repeat
  If Not ConsoleUsing Then Halt;
  Lock;
  ScreenClear;
  Commence.Display;
  CommenceText.DisplayBlend(blend_multiply);
  UnLock
 until CommenceText.AnimeEnd(CoStart_id);

 CoRead.Create;
 CoRead.CreateText('Continue',40,Color_Black);
 CoRead.Change(RGBA(0,0,0,0),RGBA(255,255,255,255));
 CoRead_obj.Create;
 CoRead_obj.Create(CoRead);
 CoRead_obj.SetAlpha(0);
 CoRead_obj.SetXY(CoBack.Height div 2,CoBack.Width div 3*2+CoBack.Width div 40);
 CoRead_id:=CommenceText.AddObj(CoRead_obj);
 CommenceText.AttachAnime(CoRead_id,CoSel_tg);
 CommenceText.AnimeBegin(CoRead_id);

 repeat
  If Not ConsoleUsing Then Halt;
  Lock;
  ScreenClear;
  Commence.Display;
  CommenceText.DisplayBlend(blend_multiply);
  UnLock
 until CommenceText.AnimeEnd(CoRead_id);

 CoExit.Create;
 CoExit.CreateText('Exit',40,Color_Black);
 CoExit.Change(RGBA(0,0,0,0),RGBA(255,255,255,255));
 CoExit_obj.Create;
 CoExit_obj.Create(CoExit);
 CoExit_obj.SetAlpha(0);
 CoExit_obj.SetXY(CoBack.Height*3 div 5,CoBack.Width div 3*2+CoBack.Width div 20);
 CoExit_id:=CommenceText.AddObj(CoExit_obj);
 CommenceText.AttachAnime(CoExit_id,CoSel_tg);
 CommenceText.AnimeBegin(CoExit_id);

 repeat
  If Not ConsoleUsing Then Halt;
  Lock;
  ScreenClear;
  Commence.Display;
  CommenceText.DisplayBlend(blend_multiply);
  UnLock
 until CommenceText.AnimeEnd(CoExit_id);

 CoStart_lg.Create;
 CoStart_lg.MouseEvent:=@SelStart;
 CommenceText.AttachLogic(CoStart_id,CoStart_lg);

 CoRead_lg.Create;
 CoRead_lg.MouseEvent:=@SelContinue;
 CommenceText.AttachLogic(CoRead_id,CoRead_lg);

 CoExit_lg.Create;
 CoExit_lg.MouseEvent:=@SelExit;
 CommenceText.AttachLogic(CoExit_id,CoExit_lg);

 DialogInit(Color_Black,0.5);
 SaveInit('image/sv000.jpg');
 NoteInit;

 FreshMust:=True;
 repeat
  If Not ConsoleUsing Then Halt;
  CommenceText.Communication;
  If FreshMust Then
  Begin
   Lock;
   ScreenClear;
   Commence.Display;
   CommenceText.DisplayBlend(blend_multiply);
   UnLock;
   HaveShow:=True
  End
  Else
   Sleep(FreshLimit);
  FreshMust:=False;
 until false;

end;



Begin
 ObjectInitial;
 ShowCommence;
end.