//This Unit Named PmdDeal.pas   Actually It is PmdDeal+.pas
{$M 100000000,0,100000000}
{$MODE objfpc}{$h+}
unit PmdDeal;

interface

uses
 gl,glu,Classes,SysUtils,windows,
 GUtil,GSet,Gmap,GVector,
 FPimage,
 FPreadBMP,FPwriteBMP,
 FPreadPNG,FPwritePNG,
 FPreadTGA,FPwriteTGA,
 FPreadXPM,FPwriteXPM,
 FPreadJPEG,FPwriteJPEG,
 Math,MatrixUnit,
 VMDDeal;

const
 PMDBONE_KNEENAME=#130#208#130#180;  //* Knee *//

 PMDIK_MINDISTANCE=1e-4;
 PMDIK_MINANGLE=1e-8;
 PMDIK_MINAXIS=1e-7;
 PMDIK_MINROTSUM=2e-3;
 PMDIK_MINROTATION=1e-5;

type

 Less_Int=Specialize TLess<Longint>;
 Less_String=Specialize TLess<Ansistring>;
 Vector_Int=Specialize TVector<Longint>;
 Map_Int=Specialize TMap<Longint,LongInt,Less_Int>;

 pPMDFormat=^PMDFormat;

 aName=array[0..19]of char;
 bName=array[0..49]of char;

 PmdVertex=packed record
  xpos,ypos,zpos,xnom,ynom,znom,utex,vtex:single;
  bone0,bone1:word;
  weight,edgeflag:char;
 end;

 PmdMaterial=packed record
  Rdif,Gdif,Bdif,alphadif,spemat,Rspe,Gspe,Bspe,Ramb,Gamb,Bamb:single;
  toon,edgeflag:byte;
  effectcnt:Dword;
  vetarr:array of Dword;
  Tex,Spa:ansistring
 end;

 PmdBone=packed record
  bonename:aname;
  parent,child:smallint;
  bonetype:byte;
  targetbone:smallint;
  xrot,yrot,zrot:single;
 end;

 pPmdIK=^PmdIK;
 PmdIK=packed record
  target,effector:smallint;
  linknum:byte;
  maxIteration:smallint;
  maxRotation:single;
  linklist:array of smallint;
 end;

 Pmd_FaceVertexList=packed record
  indexbase:dword;
  Xcod,Ycod,Zcod:single;
 end;

 pPmdMorph=^PmdMorph;
 PmdMorph=packed record
  morphname:aname;
  vetnum:dword;
  facetype:byte;
  vetlist:array of Pmd_FaceVertexList;
 end;

 pSkeleton=^Skeleton;
 Skeleton=packed object
  isLimitAngle:boolean;
  parent:^Skeleton;
  initialPosition,Position,Translation:Vector3;
  Orientation,Rotation:Quaternion;
  Transform,Matrix:Matrix4;
  procedure setup(const Pos:Vector3;const Ore:Quaternion;faBone:pSkeleton;Lim:Boolean);
  procedure Update;
 end;

 pBoneLib=^BoneLib;
 BoneLib=packed object
  nBone:Longint;
  aBone:array of Skeleton;
  bBone:array of pSkeleton;
  procedure Init;
  procedure Free;
  procedure Update;
  function CreateFromPmd(src:pPMDFormat):byte;
 end;

 IKLib=packed object
  IKBone:pBoneLib;
  target,effector:pSkeleton;
  chain:Array of pSkeleton;
  nChain,nIteration:Longint;
  maxRotation:single;
  procedure solve;
  function CreateFromPmd(src:pPMDFormat;IKid:Longint):byte;
 end;

 pMotionLib=^MotionLib;
 MotionLib=packed object
  Vmd:pVMDFormat;
  BoneMap,MorphMap:array of Longint;
  procedure Free;
 end;

 Map_Motion=Specialize TMap<Ansistring,MotionLib,Less_String>;

 PMDFormat=packed object
  //-----------------------Parameter--------------------------//
  LoadDirectory,LoadFile:Ansistring;
  resizeFactor:single;
  //-----------------------File header------------------------//
  pmdtag:array[0..2]of char;
  pmdver:single;
  //-----------------------Model head-------------------------//
  modelname:aName;
  modelcomment:array[0..255]of char;
  //-----------------------Vertex information-----------------//
  vertexnum:dword;
  vet:array of PmdVertex;
  //-----------------------Index information------------------//
  indexnum:dword;
  ind:array of GLushort;
  //-----------------------Material information---------------//
  materialnum:dword;
  mat:array of PmdMaterial;
  texid:array of GLuint;
  spaid:array of GLuint;
  //-----------------------Bone information-------------------//
  bonenum:word;
  bon:array of PmdBone;
  bonedeal:BoneLib;
  //-----------------------IK information---------------------//
  iknum:word;
  ivk:array of PmdIK;
  ikdeal:array of IKLib;
  //-----------------------Morph information------------------//
  morphnum:word;
  mop:array of PmdMorph;
  //-----------------------Motion-----------------------------//
  motion:Map_Motion;
  expression:Map_String;
  procedure Init;
  procedure Free;
  function Load(const filename:Ansistring):byte;
  procedure RegisterMotion(const MotionFlag:ansistring;vmd:pVMDFormat);
  procedure ApplyMotion(const MotionFlag:Ansistring;nFrame:Longint);
  procedure Draw;
  //Function/Procedure Below is Thought Protected
  function ReadFile(const filename:Ansistring):byte;
  function CreateBone:byte;
  function CreateIK:byte;
  function LoadTexture:byte;
  procedure ResetMotion;
  procedure CopyMotion(const mm:MotionLib;nFrame:Longint);
  procedure ResetMorph;
  procedure ApplyMorph(morphID:Longint;w:single);
  procedure CopyMorph(const mm:MotionLib;nFrame:Longint);
  procedure ApplyExpression(const exname:ansistring;w:single);
  procedure SolveIK;
  procedure DrawBone;
 end;

var
 p3dVertex,p3dNormal,p3dTexture:array of GLfloat;

implementation

procedure Skeleton.SetUp(const Pos:Vector3;const Ore:Quaternion;faBone:pSkeleton;Lim:BOolean);
begin
 initialPosition:=Pos;
 Orientation:=Ore;
 Parent:=faBone;
 isLimitAngle:=Lim;
 Translation:=Vec3_0;
 Rotation:=Quat_I;
end;

procedure Skeleton.Update;
begin
 if parent<>nil then
  begin
   Transform:=parent^.Transform*
              Translate(initialPosition-parent^.initialPosition+translation)*
              Quaternion_Cast4(orientation*rotation);
  end
 else
  begin
   Transform:=translate(initialPosition+translation)*
              Quaternion_Cast4(orientation*rotation);
  end;
 Position:=Vec3(Transform*Vec4(0,0,0,1));
 Matrix:=Transform*translate(-initialPosition)
end;

procedure BoneLib.Init;
begin
 fillchar(self,sizeof(BoneLib),0)
end;

procedure BoneLib.Free;
begin
 nBone:=0;
 SetLength(aBone,0);
 SetLength(bBone,0)
end;

procedure BoneLib.Update;
var i:Longint;
begin
 for i:=0 to nBone-1 do bBone[i]^.Update
end;

function BoneLib.CreateFromPMD(src:pPMDFormat):byte;
var
 i,parentID,Tot:Longint;
 parentPointer:pSkeleton;
 isKnee:Boolean;
 Tr:Map_Int;
 Fa,Id:Array of Longint;
begin
 Tr:=Map_Int.Create;
 with src^ do
 begin
  nBone:=bonenum;
  Tot:=nBone-1;
  SetLength(Fa,nBone);
  SetLength(Id,nBone);
  SetLength(aBone,nBone);
  SetLength(bBone,nBone);
  for i:=0 to nBone-1 do
  with bon[i] do
  begin
   parentID:=parent;
   Fa[i]:=parentID;
   if parentID=-1 then parentPointer:=nil
                  else parentPointer:=@aBone[parentID];
   isKnee:=bonename=PMDBONE_KNEENAME;
   aBone[i].SetUp(Vec3(xrot,yrot,zrot),
                  Quat_I,
                  parentpointer,
                  isKnee);
   if parentID<>-1 then
   if Tr.Find(parentID)=nil then Tr[parentID]:=1
   else Tr[ParentID]:=Tr[ParentID]+1
  end;
  for i:=0 to nBone-1 do
  if Tr.Find(i)=nil then
  begin
   Id[Tot]:=i;
   dec(Tot)
  end;
  i:=nBone-1;
  while i>Tot do
  begin
   parentID:=Fa[Id[i]];
   if parentID<>-1 then
   begin
    Tr[parentID]:=Tr[parentID]-1;
    if Tr[parentID]=0 then begin
     Tr.Delete(parentID);
     Id[Tot]:=parentID;
     dec(Tot)
    end
   end;
   dec(i)
  end;
  if Tot>-1 then exit(11);
  for i:=0 to nBone-1 do bBone[i]:=@aBone[Id[i]]
 end;
 Update;
 Tr.Destroy;
 exit(0)
end;

procedure IKLib.Solve;//ccd
var
 ang:single;
 R,Q:Quaternion;
 dir,tar,axis,del,cur:Vector3;
 pro:Matrix3;
 i,j,k:Longint;
 bone:pSkeleton;
begin
 for i:=1 to nIteration do begin
 for j:=0 to nChain-1 do
 begin
  bone:=chain[j];
  if (bone=effector)or(bone=target) then continue;
  dir:=effector^.Position-bone^.Position;
  tar:=target^.Position-bone^.Position;
  R:=Quat(Mat3(bone^.Transform)); R.w:=-R.w;
  pro:=Quaternion_Cast3(R);
  dir:=pro*dir;
  tar:=pro*tar;
  ang:=arccos(dot_product(Normalize(dir),Normalize(tar)));
  if (ang=nan)or(abs(ang)<1e-7) then continue;
  ang:=qBound(-MaxRotation,ang,MaxROtation);
  Axis:=cross_product(Tar,Dir);
  Q:=Quaternion_Rotate(Axis,Ang);
  if bone^.IsLimitAngle then
  if i=1 then
   Q:=Quaternion_Rotate(Vec3_X,abs(ang))
  else
  begin
   del:=EulerAngles(Q);
   cur:=EulerAngles(bone^.Rotation);
   if (del[1]=nan)or(abs(del[1])<1e-7) then continue;
   del[1]:=qBound(-0.002-cur[1],del[1],pi-cur[1]);
   del[1]:=qBound(-MaxRotation,del[1],MaxRotation);
   Del[2]:=0;
   Del[3]:=0;
   Q:=Quaternion_Euler(Del);
  end;
  bone^.Rotation:=bone^.Rotation*Q;
  for k:=j downto 0 do chain[k]^.Update;
  effector^.Update;
 end;
 if mold2(effector^.Position-target^.Position)<1e-7 then break end
end;

function IKLib.CreateFromPmd(src:pPMDFormat;IKid:Longint):byte;
var
 ikdata:pPmdIK;
 i,targetID,effectorID,boneID:Longint;
begin
 ikdata:=@src^.ivk[IKid];
 targetID:=ikdata^.target;
 target:=@src^.BoneDeal.aBone[targetID];
 effectorID:=ikdata^.effector;
 effector:=@src^.BoneDeal.aBone[effectorID];
 nChain:=ikdata^.linknum;
 SetLength(chain,nChain);
 for i:=0 to nChain-1 do
 begin
  boneID:=ikdata^.linklist[i];
  chain[i]:=@src^.BoneDeal.aBone[boneid]
 end;
 nIteration:=ikdata^.maxIteration;
 maxRotation:=ikdata^.maxRotation;
 IKBone:=@src^.BoneDeal;
 exit(0)
end;

procedure MotionLib.Free;
begin
 Vmd:=nil;
 SetLength(BoneMap,0);
 SetLength(MorphMap,0)
end;

procedure LoadTex(const s:ansistring;var id:Gluint);
var
 n,m:dword;
 suf:ansistring;
 img:TFPCustomImage;
 reader:TFPCustomImageReader;
 writer:TFPCustomImageWriter;
 fs:TMemoryStream;
begin
 id:=0;
 if not FileExists(s) then exit;
 img:=TFPMemoryImage.Create(0,0);
 suf:=copy(s,length(s)-3,4);
 if suf='.bmp' then reader:=TFPReaderBMP.Create else
 if suf='.png' then reader:=TFPReaderPNG.Create else
 if suf='.tga' then reader:=TFPReaderTARGA.Create else
 if (suf='.jpg')or(suf='jpeg') then reader:=TFPReaderJPEG.Create else exit;
 writer:=TFPWriterBMP.Create;
 img.LoadFromFile(s,reader);
 n:=img.Width;
 m:=img.Height;
 fs:=TMemoryStream.Create;
 img.SaveToStream(fs,writer);
 img.Free;
 reader.Free;
 writer.Free;
 glGenTextures(1,@id);
 glBindTexture(GL_TEXTURE_2D,id);
 glTexImage2D(GL_TEXTURE_2D,0,GL_RGB,n,m,
              0,32992,GL_UNSIGNED_BYTE,fs.Memory+54);
 fs.Free;
end;

procedure PMDFormat.Init;
begin
 fillchar(self,sizeof(PMDFormat),0)
end;

procedure PMDFormat.Free;
begin
 resizeFactor:=1;
 LoadDirectory:='';
 LoadFile:='';

 pmdtag:='';
 pmdver:=0;
 modelname:='';
 modelcomment:='';
 vertexnum:=0;   SetLength(vet,0);
 indexnum:=0;    SetLength(ind,0);
 materialnum:=0; SetLength(mat,0);
 bonenum:=0;     SetLength(bon,0);
 iknum:=0;       SetLength(ivk,0);
 morphnum:=0;    SetLength(mop,0);


end;

function PMDFormat.Load(const filename:Ansistring):byte;
var Err:byte; i:Longint;
begin
 resizeFactor:=1;
 Err:=ReadFile(filename); if Err<>0 then exit(Err);
 Err:=CreateBone;         if Err<>0 then exit(Err);
 Err:=CreateIK;           if Err<>0 then exit(Err);
 Err:=LoadTexture;        if Err<>0 then exit(Err);
 motion:=Map_Motion.Create;
 expression:=Map_String.Create;
 for i:=1 to morphnum-1 do expression[mop[i].morphname]:=i;
 SetLength(p3dVertex,vertexnum*3);
 SetLength(p3dNormal,vertexnum*3);
 SetLength(p3dTexture,vertexnum*2);
 exit(0)
end;

function PMDFormat.ReadFile(const filename:ansistring):byte;
var
 i,j:Longint;
 path,pmdname:ansistring;
 fs:TFileStream;
 tmpaname:aname;
begin
 if (Pos('/',filename)=0)and(Pos('\',filename)=0) then
 begin path:=''; pmdname:=filename; end
 else begin
  for i:=Length(FileName)DownTo 1 do
   if FileName[i]in ['/','\'] then Break;
  path:=copy(filename,1,i); pmdname:=copy(filename,i+1,Length(filename)) end;
 LoadDirectory:=path;
 LoadFile:=pmdname;
 fs:=TFileStream.Create(filename,fmOpenRead);
 //-----Header-----//
 fs.Read(pmdtag,3); if pmdtag<>'Pmd' then exit(1);
 fs.Read(pmdver,4); if pmdver<>1.0 then exit(2);
 //-----ModelHeader-----//
 fs.Read(modelname,20);
 fs.Read(modelcomment,256);
 //-----Vertex-----//
 fs.Read(vertexnum,4);
 SetLength(vet,vertexnum);
 for i:=0 to vertexnum-1 do
 with vet[i] do
 begin
  fs.Read(vet[i],38);
//  zpos:=-zpos;
//  znom:=-znom
 end;
 //-----Index-----//
 fs.Read(indexnum,4);
 SetLength(ind,indexnum);
 fs.Read(ind[0],indexnum*2);
 //-----Material-----//
 fs.Read(materialnum,4);
 SetLength(mat,materialnum);
 for i:=0 to materialnum-1 do
 with mat[i] do
 begin
  fs.Read(mat[i],50);
  SetLength(vetarr,effectcnt);
  fs.Read(tmpaname,20);
  j:=pos(tmpaname,'*');
  Tex:=''; Spa:='';
  if j<>0 then begin Tex:=copy(tmpaname,1,j); Spa:=copy(tmpaname,1+j,Length(tmpaname)) end else
  case Copy(tmpaname,Length(tmpaname)-3,4) of
   '.spa','.sph':Spa:=tmpaname; else Tex:=tmpaname; end
 end;
 //-----Bone-----//
 fs.Read(bonenum,2);
 SetLength(bon,bonenum);
 for i:=0 to bonenum-1 do
 with bon[i] do
 begin
  fs.Read(bon[i],39);
//  zrot:=-zrot
 end;
 //-----IK-----//
 fs.Read(iknum,2);
 SetLength(ivk,iknum);
 for i:=0 to iknum-1 do
 with ivk[i] do
 begin
  fs.Read(ivk[i],11);
  SetLength(linklist,linknum);
  fs.Read(linklist[0],linknum*2)
 end;
 //-----Morph-----//
 fs.Read(morphnum,2);
 SetLength(mop,morphnum);
 for i:=0 to morphnum-1 do
 with mop[i] do
 begin
  fs.Read(mop[i],25);
  SetLength(vetlist,vetnum);
  fs.Read(vetlist[0],vetnum*16);
//  for j:=0 to vetnum-1 do with vetlist[j] do zcod:=-zcod
 end;
 // Below is no need But listed out
 //-----DisplayName-----//
 //-----EnglishModel-----//
 //-----ToonTex-----//
 //-----RigidBody-----//
 //-----PhysicsConstraint-----//
 FreeAndNil(fs);
 exit(0)
end;

function PMDFormat.CreateBone:byte;
begin
 exit(BoneDeal.CreateFromPMD(@self))
end;

function PMDFormat.CreateIK:byte;
var i,Err:Longint;
begin
 SetLength(IKDeal,iknum);
 for i:=0 to iknum-1 do
 begin
  Err:=IKDeal[i].CreateFromPMD(@self,i);
  if Err<>0 then exit(Err)
 end;
 exit(0)
end;

function PMDFormat.LoadTexture:byte;
var i:Longint;
begin
 SetLength(Texid,materialnum);
 SetLength(Spaid,materialnum);
 for i:=0 to materialnum-1 do
 with mat[i] do
 begin
  loadTex(LoadDirectory+Tex,TexId[i]);
  loadTex(LoadDirectory+Spa,SpaId[i])
 end;
 exit(0)
end;

procedure PMDFormat.RegisterMotion(const MotionFlag:ansistring;vmd:pVMDFormat);
var
 i:Longint;
 mm:MotionLib;
 it:Map_String.TIterator;
begin
 mm.vmd:=vmd;
 SetLength(mm.BoneMap,BoneNum);
 for i:=0 to BoneNum-1 do
 begin
  it:=vmd^.BoneNameMap.Find(bon[i].bonename);
  if it<>nil then mm.BoneMap[i]:=it.Value
             else mm.BoneMap[i]:=-1
 end;
 SetLength(mm.MorphMap,MorphNum);
 for i:=0 to MorphNum-1 do
 begin
  it:=vmd^.MorphNameMap.Find(mop[i].morphname);
  if it<>nil then mm.MorphMap[i]:=it.Value
             else mm.MorphMap[i]:=-1
 end;
 if Motion.Find(MotionFlag)<>nil then Motion[MotionFlag].Free;
 Motion[MotionFlag]:=mm;
end;

procedure PMDFormat.ApplyExpression(const exname:ansistring;w:single);
var it:Map_String.TIterator;
begin
 it:=expression.Find(exname);
 if it=nil then exit;
 ApplyMorph(it.Value,w);
 it.Destroy
end;

procedure PMDFormat.ResetMotion;
var i:Longint;
begin
 for i:=0 to bonenum-1 do
 with BoneDeal.aBone[i] do
 begin
  Rotation:=Quat_I;
  Translation:=Vec3_0;
 end
end;

procedure PMDFormat.ApplyMotion(const MotionFlag:Ansistring;nFrame:Longint);
var
 MotionV:MotionLib;
begin
 ResetMotion;
 if Motion.Find(MotionFlag)=nil then exit;
 MotionV:=Motion[MotionFlag];
 CopyMotion(MotionV,nFrame);
 CopyMorph(MotionV,nFrame);
 SolveIK;
end;

procedure PMDFormat.copyMotion(const mm:MotionLib;nFrame:Longint);
var
 i,TimeLineId:Longint;
 kf:BoneKeyFrame;
begin
 for i:=0 to bonenum-1 do
 with BoneDeal.aBone[i] do
 begin
  TimeLineId:=mm.bonemap[i];
  if TimeLineId=-1 then continue;
  kf:=mm.vmd^.BoneTimeLine[TimeLineId].GetFrame(nFrame);
  Move(kf.Rotation,Rotation,16);
  Move(kf.Translation,Translation,12);
 end;
 BoneDeal.Update
end;

procedure PMDFormat.ResetMorph;
var i,j:Longint;
begin
 with mop[0] do
 for i:=0 to vetnum-1 do
 with vetlist[i] do
 with vet[indexbase] do
 begin
  xpos:=xcod;
  ypos:=ycod;
  zpos:=zcod
 end
end;

procedure PMDFormat.ApplyMorph(morphID:Longint;w:single);
var
 std:pPmdMorph;
 i:Longint;
begin
 std:=@mop[0];
 with mop[morphID] do
 for i:=0 to vetnum-1 do
 with vetlist[i] do
 with vet[std^.vetlist[indexbase].indexbase] do
 begin
  xpos:=xpos+w*xcod;
  ypos:=ypos+w*ycod;
  zpos:=zpos+w*zcod;
 end
end;

procedure PMDFormat.CopyMorph(const mm:MotionLib;nFrame:Longint);
var
 i,TimeLineId:Longint;
 kf:MorphKeyFrame;
begin
 ResetMorph;
 for i:=1 to morphnum-1 do
 begin
  TimeLineId:=mm.MorphMap[i];
  if TimeLineId=-1 then continue;
  kf:=mm.vmd^.morphTimeLIne[TimeLineId].GetFrame(nFrame);
  ApplyMorph(i,kf.weight)
 end
end;

procedure PMDFormat.SolveIK;
var i:Longint;
begin
 for i:=0 to iknum-1 do ikdeal[i].Solve
end;

procedure PMDFormat.DrawBone;
var
 e1,e2:byte;
 i,j:Longint;
 Trans:Matrix4;
begin
 e1:=glIsEnabled(GL_LIGHTING);
 e2:=glIsEnabled(GL_TEXTURE_2D);
 glDisable(GL_LIGHTING);
 glDisable(GL_TEXTURE_2D);
 for i:=0 to bonenum-1 do
 with bon[i] do
 begin
  if bonetype=2 then glColor3f(1,0.5,0)
                else glColor3f(0,0,0);
  glPushMatrix;
  trans:=BoneDeal.aBone[i].Transform;
  glScalef(resizeFactor,resizeFactor,resizeFactor);
  glMultMatrixf(@trans);
  glScalef(1/resizeFactor,1/resizeFactor,1/resizeFactor);
  glRotatef(90,1,0,0);
//  glutWireSphere(0.05,4,2);
  glPopMatrix;
  if BoneDeal.aBone[i].parent<>nil then
  begin
   glBegin(GL_LINES);
   glVertex3fv(Ptr(BoneDeal.aBone[i].Position*resizeFactor));
   glVertex3fv(Ptr(BoneDeal.aBone[i].Parent^.Position*resizeFactor));
   glEnd()
  end
 end;
 if e1<>0 then glEnable(GL_LIGHTING);
 if e2<>0 then glEnable(GL_TEXTURE_2D)
end;

procedure PMDFormat.Draw;
var
 e1:byte;
 i:Longint;
 startface:LongWord;
 nm,nm1,nm2:Vector3;
 vt,vt1,vt2:Vector4;
 m1,m2:Matrix4;
 w:single;
begin
 e1:=glIsEnabled(GL_TEXTURE_2D);
 glEnable(GL_TEXTURE_2D);
 glEnableClientState(GL_VERTEX_ARRAY);
 glEnableClientState(GL_TEXTURE_COORD_ARRAY);
 glEnableClientState(GL_NORMAL_ARRAY);
 for i:=0 to vertexnum-1 do
 with vet[i] do
 begin
  vt:=Vec4(xpos,ypos,zpos,1);
  nm:=Vec3(xnom,ynom,znom);
  m1:=BoneDeal.aBone[bone0].Matrix;
  m2:=BoneDeal.aBone[bone1].Matrix;
  vt1:=m1*vt;
  vt2:=m2*vt;
  nm1:=mat3(m1)*nm;
  nm2:=mat3(m2)*nm;
  w:=byte(weight)/100;
  vt:=vt1*w+vt2*(1-w);
  nm:=normalize(nm1*w+nm2*(1-w));
  vt:=vt*resizeFactor;
  p3dVertex[i*3  ]:=vt[1];
  p3dVertex[i*3+1]:=vt[2];
  p3dVertex[i*3+2]:=vt[3];
  p3dNormal[i*3  ]:=nm[1];
  p3dNormal[i*3+1]:=nm[2];
  p3dNormal[i*3+2]:=nm[3];
  p3dTexture[i*2  ]:=utex;
  p3dTexture[i*2+1]:=abs(1-vtex)
 end;
 glVertexPointer(3,GL_FLOAT,0,@p3dVertex[0]);
 glNormalPointer(GL_FLOAT,0,@p3dNormal[0]);
 glTexCoordPointer(2,GL_FLOAT,0,@p3dTexture[0]);
 startface:=0;
 for i:=0 to materialnum-1 do
 with mat[i] do
 begin
  glMaterialfv(GL_FRONT,GL_AMBIENT,@Ramb);
  glMaterialfv(GL_FRONT,GL_DIFFUSE,@Rdif);
  glMaterialfv(GL_FRONT,GL_SPECULAR,@Rspe);
  glMaterialf(GL_FRONT,GL_SHININESS,spemat);
  glBindTexture(GL_TEXTURE_2D,texid[i]);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
  glFrontFace(GL_CCW);
//  glEnable(GL_CULL_FACE);
  glDrawElements(GL_TRIANGLES,
                 effectcnt,
                 GL_UNSIGNED_SHORT,
                 @ind[startface]);
  inc(startface,effectcnt);
  glFlush
 end;
 glDisableClientState(GL_VERTEX_ARRAY);
 glDisableClientState(GL_TEXTURE_COORD_ARRAY);
 glDisableClientState(GL_NORMAL_ARRAY);
 if e1=0 then glDisable(GL_TEXTURE_2D)
end;

begin
end.
