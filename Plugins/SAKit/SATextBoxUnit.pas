{$MODE OBJFPC}{$H+}
unit SATextBoxUnit;
interface
uses CommonTypeUnit,SimpleAnimeUnit2,SAKitUnit;

Const
 txb_cmd_non=0;
 txb_cmd_newline=1;
 txb_cmd_deleteline=2;
 txb_cmd_insertstr=3;
 txb_cmd_deletestr=4;



 txb_core_bruteforce=0;
// txb_core_blocksplay=1;


 txb_format_puretext=0;
 txb_format_onlyNumber=1;
 txb_format_onlyEnglish=2;
// txb_format_password=4;
// txb_format_richtext=5;
// txb_format_hex=6;
// txb_format_markdown=7;



 txb_lim_auto=0;
 txb_lim_autoW=1;
// txb_lim_autoH=2;
 txb_lim_still=3;


 txb_style_static=0;
// txb_style_dynamic=1;
// txb_style_input=2;


 txb_occasion_notepad=0;
// txb_occasion_dos=1;


 txb_bk_cache=0;
 txb_bk_nocache=1;

type

 pSATextBox=^SATextBox;

 SATextCmd=Class CmdType:ShortInt End;
 SATextCmd_aLine=Class(SATextCmd) I:Longint End;
 SATextCmd_aStr=Class(SATextCmd) I,L:Longint; Str:Ansistring End;


 SATextBSObj=Packed Class  //Block + Splay Obj
  Text:Ansistring;
  Father:SATextBSObj;
  Son:Array[0..1]Of SATextBSObj;
  TreeSize,
  CharNum,CharSize,
  PixeNum,PixeSize,
  LineNum,LineSize,
  ParaNum,ParaSize,
  TailBiasC,TailBiasP:Longint;
  Constructor Create;
  Constructor Create(aText:Ansistring;Ext:pSATextBox);
  Constructor Create(_pc:Pchar;_pcn:Longint;fa:SATextBSObj;Ext:pSATextBox);
  Destructor Destroy;
  Procedure PushUp;
  Function LocSC(Ln,Ch:Longint):SATextBSObj;  //Find Location For (S)how Line (C)har Number  //Besides, (T)rue Line (P)ixel Number
  Function LocSP(Ln,Px:Longint):SATextBSObj;
  Function LocTC(Ln,Ch:Longint):SATextBSObj;
  Function LocTP(Ln,Px:Longint):SATextBSObj;
  Procedure Recovery(_pc:PChar);
  Function Recovery:Ansistring;

 End;


 TextPosGraph=Packed Record Text:pTextGraph; Position:Rana End;
 SATextGAObj=Packed Class
  Sections:Specialize List<TextPosGraph>;
  CharNum,PixeNum,LineNum,ParaNum,
  enCharNum,zhCharNum,nmCharNum,ptCharNum,ctCharNum:Longint;
  Constructor Create;
  Destructor Destroy;
 End;


 SATextBox=Packed Object(Element)
  txCore,txFormat,txLim,txStyle,txOccasion,txBk:ShortInt;
  LimW,LimH,WinW,WinH,dw_BiasX,dw_BiasY:Longint;
  BackGround:pBaseGraph; BackGround_pad:ShortInt;
  Caption:TextGraph;
  CmdSequence:Specialize Queue<SATextCmd>;
  Text:Pointer;
  CursorL,CursorR:Longint;
  Cache:pGraph;
  Constructor Create;
  Function GeneralAnalyze(Summary:Ansistring;px,py:Longint):SATextGAObj;

 End;


implementation



//------------<SAText_Block_Splay>---Begin---------//

 Constructor SATextBSObj.Create;
 Begin
  Text:='';
  Father:=Nil;
  Son[0]:=Nil;
  SOn[1]:=Nil;
  TreeSize:=1;
  CharNum:=0; CharSize:=0;
  PixeNum:=0; PixeSize:=0;
  LineNum:=0; LineSize:=0;
  ParaNum:=0; ParaSize:=0;
  TailBiasC:=0; TailBiasP:=0;
 End;

 Constructor SATextBSObj.Create(aText:Ansistring;Ext:pSATextBox);
 Begin
  Create(GetPChar(aText),Length(aText),Nil,Ext)
 End;

 Constructor SATextBSObj.Create(_pc:PChar;_pcn:Longint;fa:SATextBSObj;Ext:pSATextBox);
 Var BlockNum:Longint;
 Begin
  Father:=fa;
  If _pcn<=1024 Then Begin
   SetString(Text,_pc,_pcn);
   Son[0]:=Nil; Son[1]:=Nil; TreeSize:=1;

   Exit
  End;
  BlockNum:=(_pcn-1)>>10+1;

 End;

 Destructor SATextBSObj.Destroy;
 Begin
 End;

 Procedure SATextBSObj.Pushup;
 Begin

 End;

 Function SATextBSObj.LocSC(Ln,Ch:Longint):SATextBSObj;
 Var Lnb,Chb:Longint;
 Begin
  If Son[0]=Nil Then Lnb:=1 Else Lnb:=Son[0].LineSize+1;
  If Ln<Lnb Then Begin If Son[0]=Nil Then Exit(Nil); Exit(Son[0].LocSC(Ln,Ch)) End;
  If Ln>Lnb+LineNum Then Begin If Son[1]=Nil Then Exit(Nil); Exit(Son[1].LocSC(Ln-Lnb-LineNum+1,Ch)) End;
  If Son[0]=Nil Then Chb:=1 Else Chb:=Son[0].TailBiasC;
  If Ch<Chb Then Begin If Son[0]=Nil Then Exit(Nil); Exit(Son[0].LocSC(Ln,Ch)) End;
  If Ch>Chb+CharNum-1 Then Begin If Son[1]=Nil Then Exit(Nil); Exit(Son[1].LocSC(Ln,Ch-Chb-CharNum+1)) End;
  Exit(Self)
 End;

 Function SATextBSObj.LocSP(Ln,Px:Longint):SATextBSObj;
 Var Lnb,Pxb:Longint;
 Begin
  If Son[0]=Nil Then Lnb:=1 Else Lnb:=Son[0].LineSize+1;
  If Ln<Lnb Then Begin If Son[0]=Nil Then Exit(Nil); Exit(Son[0].LocSP(Ln,Px)) End;
  If Ln>Lnb+LineNum Then Begin If Son[1]=Nil Then Exit(Nil); Exit(Son[1].LocSP(Ln-Lnb-LineNum+1,Px)) End;
  If Son[0]=Nil Then Pxb:=0 Else Pxb:=Son[0].TailBiasP;
  If Px<Pxb Then Begin If Son[0]=Nil Then Exit(Nil); Exit(Son[0].LocSP(Ln,Px)) End;
  If Px>Pxb+PixeNum Then Begin If Son[1]=Nil Then Exit(Nil); Exit(Son[1].LocSP(Ln,Px-Pxb-PixeNum)) End;
  Exit(Self)
 End;

 Function SATextBSObj.LocTC(Ln,Ch:Longint):SATextBSObj;
 Var Lnb,Chb:Longint;
 Begin
  If Son[0]=Nil Then Lnb:=1 Else Lnb:=Son[0].ParaSize+1;
  If Ln<Lnb Then Begin If Son[0]=Nil Then Exit(Nil); Exit(Son[0].LocTC(Ln,Ch)) End;
  If Ln>Lnb+ParaNum Then Begin If Son[1]=Nil Then Exit(Nil); Exit(Son[1].LocTC(Ln-Lnb-ParaNum+1,Ch)) End;
  If Son[0]=Nil Then Chb:=1 Else Chb:=Son[0].TailBiasC;
  If Ch<Chb Then Begin If Son[0]=Nil Then Exit(Nil); Exit(Son[0].LocTC(Ln,Ch)) End;
  If Ch>Chb+CharNum-1 Then Begin If Son[1]=Nil Then Exit(Nil); Exit(Son[1].LocTC(Ln,Ch-Chb-CharNum+1)) End;
  Exit(Self)
 End;

 Function SATextBSObj.LocTP(Ln,Px:Longint):SATextBSObj;
 Var Lnb,Pxb:Longint;
 Begin
  If Son[0]=Nil Then Lnb:=1 Else Lnb:=Son[0].ParaSize+1;
  If Ln<Lnb Then Begin If Son[0]=Nil Then Exit(Nil); Exit(Son[0].LocTP(Ln,Px)) End;
  If Ln>Lnb+ParaNum Then Begin If Son[1]=Nil Then Exit(Nil); Exit(Son[1].LocTP(Ln-Lnb-ParaNum+1,Px)) End;
  If Son[0]=Nil Then Pxb:=0 Else Pxb:=Son[0].TailBiasP;
  If Px<Pxb Then Begin If Son[0]=Nil Then Exit(Nil); Exit(Son[0].LocTP(Ln,Px)) End;
  If Px>Pxb+PixeNum Then Begin If Son[1]=Nil Then Exit(Nil); Exit(Son[1].LocTP(Ln,Px-Pxb-PixeNum)) End;
  Exit(Self)
 End;

 Procedure SATextBSObj.Recovery(_pc:PChar);
 Var Chb:Longint;
 Begin
  If Son[0]=Nil Then Chb:=0 Else Chb:=Son[0].CharSize;
  If Son[0]<>Nil Then Son[0].Recovery(_pc);
  Move(GetPChar(Text)^,(_pc+Chb)^,CharNum);
  If Son[1]<>Nil Then Son[1].Recovery(_pc+Chb+CharNum)
 End;

 Function SATextBSObj.Recovery:Ansistring;
 Var Buf:PChar;
 Begin
  GetMem(Buf,CharSize);
  Recovery(Buf);
  SetString(Result,Buf,CharSize)
 End;




//----------<SAText_Block_Splay>-------End--------//


//----------<SAText_General_Analyze>---Begin------//


 Constructor SATextGAObj.Create;
 Begin
  Sections.Clear;
  CharNum:=0;
  PixeNum:=0;
  LineNUm:=0;
  ParaNum:=0;
  enCharNum:=0;
  zhCharNum:=0;
  nmCharNum:=0;
  ptCharNum:=0;
  ctCharNum:=0;
 End;

 Destructor SATextGAObj.Destroy;
 Begin
  Sections.Clear
 End;



//----------<SAText_General_Analyze>---End--------//


  Function SATextBoxDraw(Env:pElement;Below:pGraph;Outer:Pointer):pGraph;
  Var
   tmp:pGraph;
   bk:Graph;
   book:SATextGAObj;
   i:Longint;
  Begin
   With pSATextBox(Env)^ Do Begin
    If BackGround<>Nil Then Begin
     tmp:=BackGround^.Recovery(Env,Below);
     If tmp<>Nil Then Begin
      bk:=PaddingGraph(tmp^,BackGround_pad,WinH,WinW);
      BlendTo(bk,Below^,Round(Role.BiasX),Round(Role.BiasY));
      bk.Free
     End;
     tmp^.Free;
    End;
    Case txCore Of
     txb_core_bruteforce:If Text<>Nil Then Begin
       book:=GeneralAnalyze(pAnsistring(Text)^,0,0);
       with Book Do
       For i:=1 to Sections.Size Do
        With Sections[i] Do
         Text^.WriteTo(Below^,Position.x,Position.y)
      End;
    End;
   End;
   Exit(Nil)
  End;


 Constructor SATextBox.Create;
 Var src:pScriptGraph;
 Begin
  txCore:=txb_core_bruteforce;
  txFormat:=txb_format_puretext;
  txLim:=txb_lim_still;
  txStyle:=txb_style_static;
  txOccasion:=txb_occasion_notepad;
  txBk:=txb_bk_cache;
  LimW:=400; LimH:=300;
  WinW:=400; WinH:=300;
  dw_BiasX:=0; dw_BiasY:=0;
  BackGround:=Nil; BackGround_pad:=pad_direct;
  Caption.Create;
  CmdSequence.Clear;
  Text:=Nil;
  New(src,Create(@SATextBoxDraw));
  Role.Create(Src^);
  Acts.Create;
  Talk.Create
 End;


 Function SATextBox.GeneralAnalyze(Summary:Ansistring;px,py:Longint):SATextGAObj;
 Var
  P,nowL,nowR,recX,recY:Longint;
  Xu:Boolean=False;
  tmp:pTextGraph;
  can:TextPosGraph;
  c,Filter:Ansistring;

  Procedure XuLine;
  Begin
   Inc(Result.LineNum);
   pX:=pX+Caption.Height;
   NowL:=0;
   NowR:=0;
  End;

  Procedure XuText;
  Begin
   If Filter<>'' Then Begin
    New(Tmp);
    Tmp^:=Caption;
    Tmp^.SetText(Filter);
    can.Text:=Tmp;
    can.Position.x:=recX-dw_BiasX;
    can.Position.y:=recY-dw_BiasY;
    Result.Sections.PushBack(Can);
    Filter:=''
   End;
   Xu:=False
  End;

  Procedure XuChar;
  Begin
   Caption.SetText(c);
   NowL:=NowR;
   NowR:=NowL+Caption.Width;
   If NowR>LimW Then Begin XuText; XuLine End;
   If (dw_BiasX<=px+Caption.Height)And(pX<=dw_BiasX+WinH) Then
   If (dw_BiasY<=NowR)And(NowL<=dw_BiasY+WinW) Then
    If Xu Then Filter:=Filter+c
    Else Begin Filter:=c; Xu:=True; recX:=px; recY:=NowL End
   Else
    If Xu Then XuText;
  End;

 Begin
  Result:=SATextGAObj.Create;
  Result.CharNum:=Length(Summary);
  nowL:=py;
  nowR:=py;
  Filter:='';
  P:=1;
  While P<=Length(Summary) Do Begin
// If pX>dw_BiasX+WinH Then Exit;
   c:=Summary[P];
   If c[1]>#127 Then Begin
    Inc(P);
    If P<=Length(Summary) Then Begin
     Inc(Result.zhCharNum);
     c:=c+Summary[P];
     XuChar
    End
   End
   Else
   If c[1]in[#32..#126] Then Begin
    XuChar;
    If c[1]in['a'..'z','A'..'Z'] Then Inc(Result.enCharNum) Else
    If c[1]in['0'..'9']          Then Inc(Result.nmCharNum) Else
                                      Inc(Result.ptCharNum);
   End
   Else Begin
    Inc(Result.ctCharNum);
    If c[1]=#13 Then Begin Inc(Result.ParaNum); XuText; XuLine End
   End;
   Inc(P)
  End;
  XuText;
  XuLine;
 End;


end.