unit CommonTypeUnit;
interface
//Common Type
type

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
  function findvalue(Const V:T):Longint;
  property Arr[i:Longint]:T read GetValue write SetValue;default;
  property Get[Const V:T]:Longint Read FindValue;
 end;
 SList=specialize List<ansistring>;



implementation

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

 Function List.FindValue(Const V:T):Longint;
 Var i:Longint;
 Begin
  For i:=1 to Size Do
   If Items[i]=V Then Exit(I);
  Exit(0)
 End;

//GenericObject-List-End


end.