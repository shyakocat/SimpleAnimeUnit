{$mode objfpc}{$h+}
unit VmdDeal;

interface
uses
 gl,glu,Classes,SysUtils,
 Gmap,GUtil,GVector,
 MatrixUnit;

const
 VMD_VERSION_OLD=1;
 VMD_VERSION_NEW=2;

type
 //2017.07.26
 //Resume the Project Which Stopped on 2016.08.27
 //Reserve the Style of PmxDeal.pas ( Method to Read )
 Varied=record
  case integer of
   0:(c:array[1..4]of char);
   1:(ubyte:byte);
   2:(byte:shortint);
   3:(ushort:word);
   4:(short:integer);
   5:(int:longint);
   6:(uint:dword);
   7:(float:single)
 end;
 //However the Method Above Will not Be Used in This Unit
 //Merely For Commemorate


 //Common Type
 generic Arrays<T>=class
  type pT=^T;
  constructor Create;
  procedure Swap(var a,b:T);
  procedure Sort(L,R:pT);
 end;

 Less_Int=Specialize TLess<Longint>;
 Less_String=Specialize TLess<Ansistring>;
 Vector_Int=Specialize TVector<Longint>;
 Map_Int=Specialize TMap<Longint,Longint,Less_Int>;
 Map_String=Specialize TMap<Ansistring,Longint,Less_String>;




 //Adjust the Style of PmxDeal.pas ( Object/Class Rather than Record )
 pVMDFormat=^VMDFormat;

 BoneFrame=packed record
  targetBone:array[0..14]of char;
  FrameNum:Longint;
  Translation:Vector3;
  Rotation:Quaternion;
  Interpolation:array[0..63]of char;
 end;

 MorphFrame=packed record
  targetMorph:array[0..14]of char;
  FrameNum:Longint;
  Weight:single
 end;

 KeyFrame=class
  pFrame:Longint;
  procedure mix(const U,V:KeyFrame;a:single);virtual;abstract;
 end;

 BoneKeyFrame=class(KeyFrame)
  Translation:Vector3;
  Rotation:Quaternion;
  procedure mix(const U,V:BoneKeyFrame;a:single);
  constructor get(const F:BoneFrame);
 end;

 MorphKeyFrame=class(KeyFrame)
  weight:single;
  procedure mix(const U,V:MorphKeyFrame;a:single);
  constructor get(const F:MorphFrame);
 end;

 generic TimeLine<T:KeyFrame>=object
  Size:Longint;
  Frames:array of T;
  function GetFrame(nFrame:Longint):T;
 end;

 TLBone=Specialize TimeLine<BoneKeyFrame>;
 TLMorph=Specialize TimeLine<MorphKeyFrame>;
 pTLBone=^TLBone;
 pTLMorph=^TLMorph;
 Array_BoneKeyFrame=Specialize Arrays<BoneKeyFrame>;
 Array_MorphKeyFrame=Specialize Arrays<MorphKeyFrame>;


 VMDFormat=packed object
  //------------------------Header--------------------------------//
  magic_byte:array[0..29]of Char;
  Version:Longint;
  OriginalModelName:array[0..19]of char;
  //-----------------------Bone Data------------------------------//
  BoneCnt:Longint;
  BoneFrameData:array of BoneFrame;
  BoneTLcnt:Longint;
  BoneTimeLine:Array of TLBone;
  BoneNameMap:Map_String;
  //-----------------------Morph Data-----------------------------//
  MorphCnt:Longint;
  MorphFrameData:array of MorphFrame;
  MorphTLcnt:Longint;
  MorphTimeLine:Array of TLMorph;
  MorphNameMap:Map_String;
  procedure Init;
  procedure Free;
  function ReadFile(const filename:ansistring):byte;
  function CreateBoneLine:byte;
  function CreateMorphLine:byte;
  function Load(const filename:ansistring):byte;
 end;


 operator <(const a,b:KeyFrame)c:Boolean;

implementation


 constructor Arrays.Create;
 begin
 end;

 procedure Arrays.Swap(var a,b:T);
 var c:T; begin c:=a; a:=b; b:=c end;

 procedure Arrays.Sort(L,R:pT);
 var i,j:pT; m:T;
 begin
  if L>=R then exit;
  if R-L<15 then
  begin
   i:=L; while i<R do begin
   j:=i+1; while j<=R do begin if j^<i^ then Swap(i^,j^); inc(j) end;
   inc(i) end;
   exit
  end;
  i:=L; j:=R; m:=(L+random(R-L+1))^;
  repeat
   while i^<m do inc(i);
   while m<j^ do dec(j);
   if i<=j then begin Swap(i^,j^); inc(i); dec(j) end
  until i>j;
  Sort(i,R);
  Sort(L,j)
 end;

 operator <(const a,b:KeyFrame)c:Boolean;
 begin exit(a.pFrame<b.pFrame) end;

 procedure BoneKeyFrame.mix(const U,V:BoneKeyFrame;a:single);
 var i:byte;
 begin
  Translation:=MatrixUnit.mix(U.Translation,V.Translation,a);
  Rotation:=MatrixUnit.Quaternion_Slerp(U.Rotation,V.Rotation,a);
 end;

 constructor BoneKeyFrame.get(const F:BoneFrame);
 begin
  pFrame:=F.FrameNum;
  TransLation:=F.TransLation;
  Rotation:=F.Rotation
 end;

 procedure MorphKeyFrame.mix(const U,V:MorphKeyFrame;a:single);
 begin
  weight:=U.weight*(1-a)+V.weight*a
 end;

 constructor MorphKeyFrame.get(const F:MorphFrame);
 begin
  pFrame:=F.FrameNum;
  weight:=F.weight
 end;

 function TimeLine.GetFrame(nFrame:Longint):T;
 var
  L,R,M:Longint;
  U,V:T;
  a:single;
 begin
  L:=0;
  R:=Size-1;
  while L<R do
  begin
   M:=(L+R+1)>>1;
   if Frames[M].pFrame<=nFrame then l:=M
   else R:=M-1
  end;
  U:=Frames[L]; if L<>Size-1 then inc(L);
  V:=Frames[L];
  if U.pFrame<v.pFrame then a:=(nFrame-U.pFrame)/(V.pFrame-U.pFrame)
  else a:=0;
  result:=T.Create;
  result.mix(U,V,a)
 end;

 procedure VMDFormat.Init;
 begin
  BoneCnt:=0;
  BoneTLCnt:=0;
  BoneFrameData:=nil;
  BoneTimeLine:=nil;
  BoneNameMap:=nil;
  MorphCnt:=0;
  MorphTLCnt:=0;
  MorphFrameData:=nil;
  MorphTimeLine:=nil;
  MorphNameMap:=nil;
 end;

 procedure VMDFormat.Free;
 begin
  BoneCnt:=0;
  BoneTLCnt:=0;
  SetLength(BoneFrameData,0);
  SetLength(BoneTimeLine,0);
  BoneNameMap.Destroy;
  MorphCnt:=0;
  MorphTLCnt:=0;
  SetLength(MorphFrameData,0);
  SetLength(MorphTimeLine,0);
  MorphNameMap.Destroy;
 end;

 Function VMDFormat.ReadFile(const filename:ansistring):byte;
 var
  i:Longint;
  fs:TFileStream;
 begin

  fs:=TFileStream.Create(filename,fmOpenRead);
  fs.Read(magic_byte,30);
  if magic_byte='Vocaloid Motion Data File' then Version:=VMD_VERSION_OLD else
  if magic_byte='Vocaloid Motion Data 0002' then Version:=VMD_VERSION_NEW else exit(1);
  if Version=VMD_VERSION_OLD then fs.Read(OriginalModelName,10) else
  if Version=VMD_VERSION_NEW then fs.Read(OriginalModelName,20);

  fs.Read(BoneCnt,4);
  SetLength(BoneFrameData,BoneCnt);
  for i:=0 to BoneCnt-1 do
  with BoneFrameData[i] do
  begin
   fs.Read(targetBone,15);
   fs.Read(framenum,4);
   fs.Read(Translation,12);
//   Translation[1]:=-Translation[1];
   fs.Read(Rotation,16);
   Rotation.x:=-Rotation.x;
   Rotation.y:=-Rotation.y;
   Rotation.z:=-Rotation.z;
   fs.Read(interpolation,64);
  end;

  fs.Read(MorphCnt,4);
  SetLength(MorphFrameData,MorphCnt);
  for i:=0 to MorphCnt-1 do
  with MorphFrameData[i] do
  begin
   fs.Read(targetMorph,15);
   fs.Read(framenum,4);
   fs.Read(weight,4);
  end;

  FreeAndNil(fs);

  exit(0)

 end;

 function VMDFormat.CreateBoneLine:byte;
 var
  i,Lineid,KeyFrameId:Longint;
  KeyFrame:Map_Int=nil;
  it:Map_String.TIterator=nil;
  KeyFrameIt:Vector_Int=nil;
  tmp:pTLBone;
 begin
  BoneTLCnt:=0;
  BoneNameMap:=Map_String.Create;
  //*******Count*******//
  KeyFrame:=Map_Int.Create;
  for i:=0 to BoneCnt-1 do
  with BoneFrameData[i] do
  begin
   it:=BoneNameMap.Find(targetBone);
   if it=nil then
    begin
     BoneNameMap[targetBone]:=BoneTLcnt;
     KeyFrame[BoneTLcnt]:=1;
     inc(BoneTLcnt)
    end
   else
    KeyFrame[it.Value]:=KeyFrame[it.Value]+1
  end;
  //*******Arrange*******//
  SetLength(BoneTimeLine,BoneTLcnt);
  for i:=0 to BoneTLcnt-1 do
  with BoneTimeLine[i] do
  begin
   Size:=KeyFrame[i];
   SetLength(Frames,Size);
  end;
  KeyFrameIt:=Vector_Int.Create;
  KeyFrameIt.ReSize(BoneTLcnt);
  for i:=0 to BoneTLcnt-1 do KeyFrameIt[i]:=0;
  for i:=0 to BoneCnt-1 do
  with BoneFrameData[i] do
  begin
   LineId:=BoneNameMap[targetBone];
   KeyFrameId:=KeyFrameIt[LineId];
   KeyFrameIt[LineId]:=KeyFrameId+1;
   BoneTimeLine[LineId].Frames[KeyFrameId]:=BoneKeyFrame.Get(BoneFrameData[i])
  end;
  //*******sort*******//
  for i:=0 to BoneTLcnt-1 do
  begin
   tmp:=@BoneTimeLine[i];
   Array_BoneKeyFrame.Create.Sort(@tmp^.Frames[0],@tmp^.Frames[tmp^.Size-1]);
  end;
  if         It<>nil then It.Destroy;
  if   KeyFrame<>nil then KeyFrame.Destroy;
  if KeyFrameIt<>nil then KeyFrameIt.Destroy;
  exit(0)
 end;

 function VMDFormat.CreateMorphLine:byte;
 var
  i,Lineid,KeyFrameId:Longint;
  KeyFrame:Map_Int=nil;
  it:Map_String.TIterator=nil;
  KeyFrameIt:Vector_Int=nil;
  tmp:pTLMorph;
 begin
  MorphTLCnt:=0;
  MorphNameMap:=Map_String.Create;
  //*******Count*******//
  KeyFrame:=Map_Int.Create;
  for i:=0 to MorphCnt-1 do
  with MorphFrameData[i] do
  begin
   it:=MorphNameMap.Find(targetMorph);
   if it=nil then
    begin
     MorphNameMap[targetMorph]:=MorphTLcnt;
     KeyFrame[MorphTLcnt]:=1;
     inc(MorphTLcnt)
    end
   else
    KeyFrame[it.Value]:=KeyFrame[it.Value]+1
  end;
  //*******Arrange*******//
  SetLength(MorphTimeLine,MorphTLcnt);
  for i:=0 to MorphTLcnt-1 do
  with MorphTimeLine[i] do
  begin
   Size:=KeyFrame[i];
   SetLength(Frames,Size)
  end;
  KeyFrameIt:=Vector_Int.Create;
  KeyFrameIt.ReSize(MorphTLcnt);
  for i:=0 to MorphTLcnt-1 do KeyFrameIt[i]:=0;
  for i:=0 to MorphCnt-1 do
  with MorphFrameData[i] do
  begin
   LineId:=MorphNameMap[targetMorph];
   KeyFrameId:=KeyFrameIt[LineId];
   KeyFrameIt[LineId]:=KeyFrameId+1;
   MorphTimeLine[LineId].Frames[KeyFrameId]:=MorphKeyFrame.Get(MorphFrameData[i])
  end;
  //*******sort*******//
  for i:=0 to MorphTLcnt-1 do
  begin
   tmp:=@MorphTimeLine[i];
   Array_MorphKeyFrame.Create.Sort(@tmp^.Frames[0],@tmp^.Frames[tmp^.Size-1]);
  end;
  if         It<>nil then It.Destroy;
  if   KeyFrame<>nil then KeyFrame.Destroy;
  if KeyFrameIt<>nil then KeyFrameIt.Destroy;
  exit(0)
 end;

 function VMDFormat.Load(const filename:ansistring):byte;
 var Err:byte;
 begin
  Err:=ReadFile(filename); if Err<>0 then begin Free; exit(Err) end;
  Err:=CreateBoneLine;     if Err<>0 then begin Free; exit(Err) end;
  Err:=CreateMorphLine;    if Err<>0 then begin Free; exit(Err) end;
  exit(0)
 end;

end.
