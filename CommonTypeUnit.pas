{$MODE OBJFPC}{$H+}
{$MODESWITCH ADVANCEDRECORDS}
unit CommonTypeUnit;
interface

//Common Record

Type

 Rana=Record
  x,y:Longint;
  Class Operator <(Const a,b:Rana)c:Boolean;
  Class Operator =(Const a,b:Rana)c:Boolean;
  Class Operator >(Const a,b:Rana)c:Boolean;
  Class Operator <=(Const a,b:Rana)c:Boolean;
  Class Operator >=(Const a,b:Rana)c:Boolean;
  Class Operator +(Const a,b:Rana)c:Rana;
  Class Operator -(Const a,b:Rana)c:Rana;
 End;


Const
 cmp_Less=1;
 cmp_Greater=2;

//Common Type
type

 Alphabet=Set Of Char;

 pInt=^Longint;

 generic List<T>=object
  Size:longint;
  Items:array of T;
  procedure swap(var a,b:T);
  procedure resize(n:longint);
  procedure clear;
  procedure pushback(const value:T);
  procedure pop;
  procedure insert(p:longint;const value:T);
  procedure insert(p:longint;const L:List);
  procedure delete(p,Len:longint);
  procedure reverse(l,r:longint);
  procedure fill(l,r:longint;const x:T);
  function clone(l,r:longint):List;
  function top:T;
  function isnil:boolean;
  function GetValue(i:Longint):T;
  procedure SetValue(i:Longint;const Value:T);
  property Arr[i:Longint]:T read GetValue write SetValue;default;
 end;
 IList=Specialize List<Longint>;
 SList=specialize List<ansistring>;

 Generic ListTab<T>=Object(Specialize List<T>)
  Function Cmp(Const a,b:T;_c:ShortInt):Boolean;
  Procedure Sort(L,R:Longint);
  Procedure Sort(L,R:Longint;_c:ShortInt);
  Function Find(Const value:T):Longint;
 End;

 Generic Treap<T>=Object
  Type
   TreapObj=Record Va:T; Ls,Rs,Rd,Ct:Longint End;
   TList=Specialize List<TreapObj>;
  Var
   Root,Size:Longint;
   Thing:TList;
   ReUse:IList;
  Protected
   Function NewTreapObj(Const _v:T;_l,_r,_x,_c:Longint):TreapObj;
   Procedure PushUp(k:Longint);
   Procedure RRotate(Var k:Longint);
   Procedure LRotate(Var k:Longint);
   Function Insert(k:Longint;Const _v:T):Longint;
   Function Delete(k:Longint;Const _v:T):Longint;
  Public
   Procedure Clear;
   Procedure Insert(Const _v:T);
   Procedure Delete(Const _v:T);
   Function Lower(Const _v:T):Longint;
   Function Upper(Const _v:T):Longint;
   Function LowerEqual(Const _v:T):Longint;
   Function UpperEqual(Const _V:T):Longint;
   Function LowerValue(Const _v:T):T;
   Function UpperValue(Const _v:T):T;
   Function LowerEqualValue(Const _v:T):T;
   Function UpperEqualValue(Const _V:T):T;
   Function GetRank(Const _v:T):Longint;
   Function AskRank(_r:Longint):T;
   Property Rank[_r:Longint]:T read AskRank;Default;
 End;

 Generic Queue<T>=Object
  Type
   pQObj=^QObj;
   QObj=Record Data:T; L,R:pQObj End;
  Var
   Size:Longint;
   Head,Tail,Now:pQObj;
  Procedure Create;
  Procedure Clear;
  Procedure HeadAdd(Const V:T);
  Procedure TailAdd(Const V:T);
  Procedure NowLAdd(Const V:T);
  Procedure NowRAdd(Const V:T);
  Procedure HeadPop;
  Procedure TailPop;
  Procedure NowPop;
  Function MoveR:Boolean;
  Function MoveL:Boolean;
 End;



Function ListPart(Src:Ansistring;Const Sep:Alphabet):SList;
Function ListPart(Src:Ansistring):SList;
Function ListPair(Src,pairL,pairR:Ansistring):SList;



//Algorithm Type
Type
 Str_KMP=Object
  Patt:Ansistring;
  Next:pInt;
  Procedure Create(Src:Ansistring);
  Function Search(Chf:Ansistring;_pos:Longint):Longint;
  Procedure Free;
 End;

 Str_Sunday=Object
  Patt:Ansistring;
  Bias:pInt;
  Procedure Create(Src:Ansistring);
  Function Search(Chf:Ansistring;_pos:Longint):Longint;
  Procedure Free;
 End;


implementation

 Class Operator Rana.<(Const a,b:Rana)c:Boolean;Begin Exit(a.x<b.x) End;
 Class Operator Rana.>(Const a,b:Rana)c:Boolean;Begin Exit(a.x>b.x) End;
 Class Operator Rana.=(Const a,b:Rana)c:Boolean;Begin Exit(a.x=b.x) End;
 Class Operator Rana.<=(Const a,b:Rana)c:Boolean;Begin Exit(a.x<=b.x) End;
 Class Operator Rana.>=(Const a,b:Rana)c:Boolean;Begin Exit(a.x>=b.x) End;
 Class Operator Rana.+(Const a,b:Rana)c:Rana;Begin c.x:=a.x+b.x; c.y:=a.y+b.y End;
 Class Operator Rana.-(Const a,b:Rana)c:Rana;Begin c.x:=a.x-b.x; c.y:=a.y-b.y End;



//GenericObject-List-Begin

function List.isnil:boolean;
 begin
  exit(Size=0)
 end;

 procedure List.clear;
 begin
  Size:=0;
  SetLength(Items,0)
 end;

 procedure List.resize(n:longint);
 begin
  Size:=n;
  if Size<10 Then Begin If high(Items)<9 then setlength(Items,10) End else
  if Size>=high(Items) then setlength(Items,Size<<1) else
  if Size<high(Items)>>2 then setlength(Items,Size>>1)
 end;

 procedure List.pushback(const value:T);
 begin
  Resize(size+1);
  Items[Size]:=value
 end;

 procedure List.pop;
 begin
  if Size>0 then dec(Size);
  Resize(Size)
 end;

 function List.top:T;
 begin
  exit(Items[size])
 end;

 procedure List.swap(var a,b:T);
 var c:T; begin c:=a; a:=b; b:=c end;

 procedure List.Reverse(l,r:longint);
 var i:longint;
 begin
  for i:=l to (l+r)>>1 do swap(Items[i],Items[l+r-i])
 end;

 function List.Clone(l,r:longint):List;
 var i:longint;
 begin
  Clone.Clear;
  if l>r then exit;
  for i:=l to r do Clone.pushback(Items[i])
 end;

 procedure List.insert(p:longint;const value:T);
 var i:longint;
 begin
  if p>Size then exit;
  Resize(Size+1);
  for i:=Size downto p+1 do Items[i]:=Items[i-1];
  Items[p]:=value
 end;

 procedure List.insert(p:longint;const L:List);
 var i:longint;
 begin
  if p>Size then exit;
  Resize(Size+L.Size);
  for i:=Size downto p+L.Size do Items[i]:=Items[i-L.Size];
  for i:=1 to L.Size do Items[p-1+i]:=L.Items[i]
 end;

 procedure List.delete(p,Len:longint);
 var i:longint;
 begin
  if p>Size then exit;
  if p-1+Len>=Size then begin Resize(p-1); exit end;
  for i:=p+Len to Size do Items[i-Len]:=Items[i];
  Resize(Size-Len)
 end;

 procedure List.fill(l,r:longint;const x:T);
 var i:longint;
 begin
  for i:=l to r do Items[i]:=x
 end;

 function List.GetValue(i:Longint):T;
 begin
  exit(Items[i])
 end;

 procedure List.SetValue(i:Longint;const value:T);
 begin
  Items[i]:=value
 end;

//GenericObject-List-End


 Function ListTab.Find(Const value:T):Longint;
 Var i:Longint;
 Begin
  For i:=1 to Size Do If Items[i]=Value Then Exit(i);
  Exit(0)
 End;

 Procedure ListTab.Sort(L,R:Longint);
 Var i,j:Longint; tmp:T;
 Begin
  If (L<1)Or(R>Size) Then Exit;
  If L>R Then Exit;
  i:=L; j:=R;
  tmp:=Items[L+Random(R-L+1)];
  Repeat
   While Items[i]<tmp Do Inc(I);
   While tmp<Items[j] Do Dec(J);
   If Items[j]<Items[i] Then Begin Swap(Items[i],Items[j]); Inc(I); Dec(J) End
  Until I>J;
  If I<R Then Sort(I,R);
  If L<J Then Sort(L,J)
 End;

 Function ListTab.Cmp(Const a,b:T;_c:ShortInt):Boolean;
 Begin
  Case _c Of
   cmp_Less:Exit(a<b);
   cmp_Greater:Exit(a>b)
  End
 End;

 Procedure ListTab.Sort(L,R:Longint;_c:ShortInt);
 Var i,j:Longint; tmp:T;
 Begin
  If (L<1)Or(R>Size) Then Exit;
  If L>R Then Exit;
  i:=L; j:=R;
  tmp:=Items[L+Random(R-L+1)];
  Repeat
   While Cmp(Items[i],tmp,_c) Do Inc(I);
   While Cmp(tmp,Items[j],_c) Do Dec(J);
   If Cmp(Items[j],Items[i],_c) Then Begin Swap(Items[i],Items[j]); Inc(i); Dec(J) End
  Until I>J;
  If I<R Then Sort(I,R);
  If L<J Then Sort(L,J)
 End;


 Procedure Queue.Create;
 Begin
  Size:=0;
  Head:=Nil;
  Tail:=Nil;
  Now:=Nil;
 End;

 Procedure Queue.Clear;
 Var i,CheckMate:pQObj;
 Begin
  i:=Head;
  While i<>Nil Do
  Begin
   CheckMate:=i;
   i:=i^.R;
   Dispose(CheckMate)
  End;
  Size:=0;
  Head:=Nil;
  Tail:=Nil;
  Now:=Nil
 End;

 Procedure Queue.HeadAdd(Const V:T);
 Var Tmp:^QObj;
 Begin
  Inc(Size);
  New(Tmp);
  Tmp^.Data:=V;
  Tmp^.L:=Nil;
  Tmp^.R:=Head;
  If Size=1 Then Begin Head:=Tmp; Tail:=Tmp; Now:=Tmp End
            Else Begin Head^.L:=Tmp; Head:=Tmp End
 End;

 Procedure Queue.TailAdd(Const V:T);
 Var Tmp:^QObj;
 Begin
  Inc(Size);
  New(Tmp);
  Tmp^.Data:=V;
  Tmp^.R:=Nil;
  Tmp^.L:=Tail;
  If Size=1 Then Begin Head:=Tmp; Tail:=Tmp; Now:=Tmp End
            Else Begin Tail^.R:=Tmp; Tail:=Tmp End
 End;

 Procedure Queue.NowLAdd(Const V:T);
 Var Tmp:^QObj;
 Begin
  If Now=Nil Then Exit;
  Inc(Size);
  New(Tmp);
  Tmp^.Data:=V;
  Tmp^.R:=Now;
  Tmp^.L:=Now^.L;
  If Now^.L<>Nil Then Now^.L^.R:=Tmp;
  Now^.L:=Tmp;
 End;

 Procedure Queue.NowRAdd(Const V:T);
 Var Tmp:^QObj;
 Begin
  If Now=Nil Then Exit;
  Inc(Size);
  New(Tmp);
  Tmp^.Data:=V;
  Tmp^.L:=Now;
  Tmp^.R:=Now^.R;
  If Now^.R<>Nil Then Now^.R^.L:=Tmp;
  Now^.R:=Tmp;
 End;

 Procedure Queue.HeadPop;
 Begin
  If Size=0 Then Exit;
  Dec(Size);
  If Size=0 Then Begin Dispose(Head); Head:=Nil; Tail:=Nil; Now:=Nil; Exit End;
  If Now=Head Then Now:=Nil;
  Head:=Head^.R;
  Dispose(Head^.L);
  Head^.L:=Nil
 End;

 Procedure Queue.TailPop;
 Begin
  If Size=0 Then Exit;
  Dec(Size);
  If Size=0 Then Begin Dispose(Tail); Head:=Nil; Tail:=Nil; Now:=Nil; Exit End;
  If Now=Tail Then Now:=Nil;
  Tail:=Tail^.L;
  Dispose(Tail^.R);
  Head^.R:=Nil
 End;

 Procedure Queue.NowPop;
 Begin
  If Now=Nil Then Exit;
  If Now^.L<>Nil Then Now^.L^.R:=Now^.R;
  If Now^.R<>Nil Then Now^.R^.L:=Now^.L;
  Dispose(Now);
  Now:=Nil
 End;

 Function Queue.MoveR:Boolean;
 Begin
  If (Now=Nil)Or(Now^.R=Nil) then Exit(False);
  Now:=Now^.R; Exit(True)
 End;

 Function Queue.MoveL:Boolean;
 Begin
  If (Now=Nil)Or(Now^.L=Nil) then Exit(False);
  Now:=Now^.L; Exit(True)
 End;






 Procedure Str_KMP.Create(Src:Ansistring);
 Var n,i,j:Longint;
 Begin
  n:=Length(Src);
  Patt:=Src;
  Next:=GetMem((N+1)<<2);
  Next[0]:=0;
  Next[1]:=0;
  i:=1;
  j:=0;
  While i<=n Do
  If (j=0)Or(Src[i]=Src[j]) Then
  Begin
   Inc(i);
   Inc(j);
   Next[i]:=j
  End
  Else
   j:=Next[j]
 End;

 Function Str_KMP.Search(Chf:Ansistring;_pos:Longint):Longint;
 Var n,m,i,j:Longint; u,v:pChar;
 Begin
  n:=Length(Chf);
  m:=Length(Patt);
  If m<9 Then
  Begin
   u:=@Chf[1];
   v:=@Patt[1];
   For i:=_pos-1 to n-m Do
   If CompareChar((u+i)^,v^,m)=0 Then Exit(i+1);
   Exit(-1)
  End;
  u:=@Chf[1]-1;
  v:=@Patt[1]-1;
  i:=_pos;
  j:=1;
  While (i<=n)And(j<=m) Do
  Begin
   If (j=0)Or(u[i]=v[j]) Then
   Begin
    Inc(i);
    Inc(j)
   End
   Else
    j:=Next[j]
  End;
  If j>m Then Exit(i-m);
  Exit(-1)
 End;

 Procedure Str_KMP.Free;
 Begin
  Patt:='';
  FreeMemory(Next);
  Next:=Nil
 End;

 Procedure Str_Sunday.Create(Src:Ansistring);
 Var n,i:Longint;
 Begin
  Patt:=Src;
  n:=Length(Src);
  GetMem(Bias,1024);
  For i:=0 to 255 Do Bias[i]:=n;
  For i:=1 to n Do Bias[Byte(Src[i])]:=n-i+1
 End;

 Function Str_Sunday.Search(Chf:Ansistring;_pos:Longint):Longint;
 Var n,m,i:Longint; u,v:PByte;
 Begin
  n:=Length(Chf)+1;
  m:=Length(Patt);
  If m<9 Then
  Begin
   u:=@Chf[1];
   v:=@Patt[1];
   For i:=_pos-1 to n-m Do
   If CompareChar((u+i)^,v^,m)=0 Then Exit(i+1);
   Exit(-1)
  End;
  u:=@Chf[1]-1;
  v:=@Patt[1];
  i:=_pos+m;
  While i<=n Do
  Begin
   If CompareChar((u+i-m)^,v^,m)=0 Then Exit(i-m);
   If i=n Then Break;Inc(i,Bias[(u+i)^])
  End;
  Exit(-1)
 End;

 Procedure Str_Sunday.Free;
 Begin
  Patt:='';
  FreeMemory(Bias)
 End;



Function ListPart(Src:Ansistring):SList;
Begin
 Exit(ListPart(Src,[#0..#32]))
End;

Function ListPart(Src:Ansistring;Const sep:Alphabet):SList;
Var i,j:Longint;
Begin
 Result.Clear;
 j:=1;
 For i:=1 to Length(Src) Do
 If Src[i]in Sep Then
 Begin
  If i>j Then Result.PushBack(Copy(Src,j,i-j));
  j:=i+1
 End;
 If i+1>j Then Result.PushBack(Copy(Src,j,i+1-j))
End;

Function ListPair(Src,pairL,pairR:Ansistring):SList;
Var
 i,j,k,c,x:Longint;
 tmpL,tmpR:Str_KMP;
Begin
 tmpL.Create(pairL);
 tmpR.Create(pairR);
 Result.Clear;
 x:=-1;
 i:=1;
 j:=tmpL.Search(Src,1);
 k:=tmpR.Search(Src,1);
 While i<=Length(Src) Do
 Begin
  If x=-1 Then
   If j=-1 Then Break
           Else Begin x:=j+Length(PairL); i:=x; c:=1 End
  Else
   If k=-1 Then Break Else
    If (j<>-1)And(j<k) Then Begin inc(c); i:=j+Length(PairL) End
                       Else Begin dec(c); i:=k+Length(PairR);
                                  If c=0 Then Begin Result.PushBack(Copy(Src,x,k-x)); x:=-1 End End;
  If j<i Then j:=tmpL.Search(Src,i);
  If k<i Then k:=tmpR.Search(Src,i)
 End;
 tmpL.Free;
 tmpR.Free;
End;


 Procedure Treap.Clear;
 Begin
  Root:=0;
  Size:=0;
  Thing.Clear;
  ReUse.Clear;
 End;

 Procedure Treap.Pushup(k:Longint);
 Begin
  Thing.Items[k].Ct:=Thing[Thing[k].Ls].Ct+Thing[Thing[k].Rs].Ct+1
 End;

 Procedure Treap.RRotate(Var k:Longint);
 Var z:Longint;
 Begin
  z:=Thing[k].Ls;
  Thing.Items[k].Ls:=Thing[z].Rs;
  Thing.Items[z].Rs:=k;
  k:=z
 End;

 Procedure Treap.LRotate(Var k:Longint);
 Var z:Longint;
 Begin
  z:=Thing[k].Rs;
  Thing.Items[k].Rs:=Thing[z].Ls;
  Thing.Items[z].Ls:=k;
  k:=z
 End;

 Function Treap.NewTreapObj(Const _v:T;_l,_r,_x,_c:Longint):TreapObj;
 Begin
  With Result Do Begin
   Va:=_v;
   Ls:=_l;
   Rs:=_r;
   Rd:=_x;
   Ct:=_c
  End
 End;

 Function Treap.Insert(k:Longint;Const _v:T):Longint;
 Var tmp:Longint;
 Begin
  If k=0 Then Begin
   Inc(Size);
   If ReUse.Size=0 Then
   Begin
    Thing.PushBack(NewTreapObj(_v,0,0,Random(MaxLongint),1));
    k:=Thing.Size
   End
   Else
   Begin
    k:=ReUse.Top;
    ReUse.Pop;
    Thing.Items[k]:=NewTreapObj(_v,0,0,Random(MaxLongint),1);
   End;
   Exit(k)
  End;
  If _v<Thing[k].Va Then Begin
   tmp:=Insert(Thing[k].Ls,_v);
   Thing.Items[k].Ls:=tmp;
   If Thing[tmp].Rd<Thing[k].Rd Then RRotate(K)
  End Else Begin
   tmp:=Insert(Thing[k].Rs,_v);
   Thing.Items[k].Rs:=tmp;
   If Thing[tmp].Rd<Thing[k].Rd Then LRotate(K)
  End;
  PushUp(k);
  Exit(k)
 End;

 Function Treap.Delete(k:Longint;Const _v:T):Longint;
 Begin
  If k=0 Then Exit(0);
  If _v=Thing[k].Va Then Begin
   If (Thing[k].Ls=0)Or(Thing[k].Rs=0) Then Begin
    Dec(Size);
    ReUse.PushBack(k);
    Exit(Thing[k].Ls Or Thing[k].Rs)
   End;
   If Thing[Thing[k].Ls].Rd<Thing[Thing[k].Rs].Rd Then
    Begin
     RRotate(K);
     Thing.Items[k].Rs:=Delete(Thing[k].Rs,_v)
    End
   Else
    Begin
     LRotate(K);
     Thing.Items[k].Ls:=Delete(Thing[k].Ls,_v)
    End
  End Else
  If _v<Thing[k].Va Then Thing.Items[k].Ls:=Delete(Thing[k].Ls,_v)
                    Else Thing.Items[k].Rs:=Delete(Thing[k].Rs,_v);
  PushUp(k);
  Exit(k)
 End;

 Procedure Treap.Insert(Const _v:T);
 Begin
  Root:=Insert(Root,_v);
 End;

 Procedure Treap.Delete(Const _v:T);
 Begin
  Root:=Delete(Root,_v)
 End;

 Function Treap.Lower(Const _v:T):Longint;
 Var k,z:Longint;
 Begin
  Result:=0;
  k:=Root;
  z:=0;
  While k<>0 Do
   If Thing[k].Va<_v Then Begin
    Inc(z,Thing[Thing[k].Ls].Ct+1);
    Result:=z;
    k:=Thing[k].Rs
   End
   Else
    k:=Thing[k].Ls
 End;

 Function Treap.Upper(Const _v:T):Longint;
 Var k,z:Longint;
 Begin
  Result:=0;
  k:=Root;
  z:=0;
  While k<>0 Do
   If Thing[k].Va>_v Then Begin
    Inc(z,Thing[Thing[k].Ls].Ct+1);
    Result:=z;
    k:=Thing[k].Ls
   End
   Else
    k:=Thing[k].Rs
 End;

 Function Treap.LowerEqual(Const _v:T):Longint;
 Var k,z:Longint;
 Begin
  Result:=0;
  k:=Root;
  z:=0;
  While k<>0 Do
   If Thing[k].Va<=_v Then Begin
    Inc(z,Thing[Thing[k].Ls].Ct+1);
    Result:=z;
    k:=Thing[k].Rs
   End
   Else
    k:=Thing[k].Ls
 End;

 Function Treap.UpperEqual(Const _V:T):Longint;
 Var k,z:Longint;
 Begin
  Result:=0;
  k:=Root;
  z:=0;
  While k<>0 Do
   If Thing[k].Va>=_v Then Begin
    Inc(z,Thing[Thing[k].Ls].Ct+1);
    Result:=z;
    k:=Thing[k].Rs
   End
   Else
    k:=Thing[k].Ls
 End;

 Function Treap.LowerValue(Const _v:T):T;
 Var k:Longint;
 Begin
  k:=Root;
  While k<>0 Do
   If Thing[k].Va<_v Then Begin
    Result:=Thing[k].Va;
    k:=Thing[k].Rs
   End
   Else
    k:=Thing[k].Ls
 End;

 Function Treap.UpperValue(Const _v:T):T;
 Var k:Longint;
 Begin
  k:=Root;
  While k<>0 Do
   If Thing[k].Va>_v Then Begin
    Result:=Thing[k].Va;
    k:=Thing[k].Ls
   End
   Else
    k:=Thing[k].Rs
 End;

 Function Treap.LowerEqualValue(Const _v:T):T;
 Var k:Longint;
 Begin
  k:=Root;
  While k<>0 Do
   If Thing[k].Va<=_v Then Begin
    Result:=Thing[k].Va;
    k:=Thing[k].Rs
   End
   Else
    k:=Thing[k].Ls
 End;

 Function Treap.UpperEqualValue(Const _V:T):T;
 Var k:Longint;
 Begin
  k:=Root;
  While k<>0 Do
   If Thing[k].Va>=_v Then Begin
    Result:=Thing[k].Va;
    k:=Thing[k].Rs
   End
   Else
    k:=Thing[k].Ls
 End;

 Function Treap.GetRank(Const _v:T):Longint;
 Var k,z:Longint;
 Begin
  Result:=0;
  k:=Root;
  z:=0;
  While k<>0 Do Begin
   If Thing[k].Va=_v Then Result:=Thing[Thing[k].Ls].Ct+1+z;
   If Thing[k].Va<_v Then Begin
    Inc(z,Thing[Thing[k].Ls].Ct+1);
    k:=Thing[k].Rs
   End
   Else
    k:=Thing[k].Ls
  End
 End;

 Function Treap.AskRank(_r:Longint):T;
 Var k,z:Longint;
 Begin
  If _r>Size Then Exit;
  k:=Root;
  While k<>0 Do Begin
   z:=Thing[Thing[k].Ls].Ct+1;
   If _r=z Then Exit(Thing[k].Va);
   If _r<z Then Begin k:=Thing[k].Ls; Continue End;
   Dec(_r,z); k:=Thing[k].Rs
  End
 End;


end.
