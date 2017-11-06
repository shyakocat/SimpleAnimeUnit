unit SAPackageUnit;
interface
uses SysUtils,Classes,CommonTypeUnit;

const
 sapkg_directory=1;
 sapkg_file=2;
 sapkg_outfile=3;

 sapkg_Root=1;

type

 pInt=^Longint;
 pUInt=^Dword;
 pBool=^Boolean;

 pSAPackageObj=^SAPackageObj;
 SAPackageObj=Packed Record
  fname:Ansistring;
  ftype:ShortInt;
  Id:Longint;
  Data:TMemoryStream;
  Father:Longint;
  Son:Specialize List<Longint>;
 End;

 SAPackage=Packed Object
  Struct:Specialize List<pSAPackageObj>;
  Constructor Create;
  Destructor Free;
  Destructor FreeData;
  Procedure Load(Path:Ansistring);
  Procedure Save(Path:Ansistring);
  Function Count:Longint;
  Function Get(DId:Longint):pSAPackageObj;
  Function GetSon(DId:Longint;_FName:Ansistring):Longint;
  Function GetSize(Did:Longint):Int64;
  Function AddFile(Path:Ansistring;Const _obj:SAPackageObj):Longint;
  Function AddFile(DId:Longint;Const _obj:SAPackageObj):Longint;
  Function AddDirectory(Path:Ansistring):Longint;
  Function AddDirectory(FName:Ansistring;DId:Longint):Longint;
  Procedure Print;
  Procedure Extract(Path:Ansistring;DId:Longint);
  Procedure Extract;
 End;


 Function GetFileSize(_fname:Ansistring):Int64;
 Procedure CopyFile(_fnameinput,_fnameoutput:Ansistring);


 Function sapkg_NewFile(_fname:Ansistring;_data:TMemoryStream):SAPackageObj;
 Function sapkg_NewFile(_fname:Ansistring;_pointer:Pointer;Const _len:Int64):SAPackageObj;
 Function sapkg_NewFile(_fname,_outfname:Ansistring):SAPackageObj;
 Function sapkg_NewOutFile(_fname,_outfname:Ansistring):SAPackageObj;
 Function sapkg_NewDirectory(_fname:Ansistring):SAPackageObj;

implementation

Function GetFileSize(_fname:Ansistring):Int64;
Var tmp:TFileStream;
Begin
 tmp:=TFileStream.Create(_fname,fmOpenRead);
 GetFileSize:=tmp.Size;
 tmp.Destroy
End;

Procedure CopyFile(_fnameinput,_fnameoutput:Ansistring);
Var f,g:File; NumRead,NumWrite:Word; Buf:Array[0..8191]Of Byte;
Begin
 Assign(F,_fnameinput); Reset(F,1);
 Assign(G,_fnameoutput); Rewrite(G,1);
 Repeat
  BlockRead(F,Buf,SizeOf(Buf),NumRead);
  BlockWrite(G,Buf,NumRead,NumWrite);
 Until (NumRead=0)Or(NumWrite<>NumRead);
 Close(F); Close(G)
End;

Function sapkg_NewFile(_fname:Ansistring;_data:TMemoryStream):SAPackageObj;
Begin
 With sapkg_NewFile Do Begin
  fname:=_fname;
  ftype:=sapkg_file;
  id:=-1;
  Data:=_data;
  Father:=0;
  Son.Clear;
 End
End;

Function sapkg_NewFile(_fname:Ansistring;_pointer:Pointer;Const _len:Int64):SAPackageObj;
Var tmp:TMemoryStream;
Begin
 tmp:=TMemoryStream.Create;
 tmp.ReadBuffer(_pointer,_len);
 Exit(sapkg_NewFile(_fname,tmp))
End;

Function sapkg_NewFile(_fname,_outfname:Ansistring):SAPackageObj;
var tmp:TMemoryStream;
Begin
 tmp:=TMemoryStream.Create;
 tmp.LoadFromFile(_outfname);
 Exit(sapkg_NewFile(_fname,tmp))
End;

Function sapkg_NewOutFile(_fname,_outfname:Ansistring):SAPackageObj;
var tmp:TMemoryStream;
Begin
 tmp:=TMemoryStream.Create;
 tmp.WriteAnsistring(_outfname);
 With sapkg_NewOutFile Do Begin
  fname:=_fname;
  ftype:=sapkg_outfile;
  id:=-1;
  data:=tmp;
  father:=0;
  son.Clear
 End
End;

Function sapkg_NewDirectory(_fname:Ansistring):SAPackageObj;
Begin
 With sapkg_NewDirectory Do Begin
  fname:=_fname;
  ftype:=sapkg_directory;
  id:=-1;
  Data:=Nil;
  Father:=0;
  Son.Clear;
 End
End;

Constructor SAPackage.Create;
Var Root:pSAPackageObj;
Begin
 Struct.Clear;
 New(Root);
 With Root^ Do Begin
  fname:='';
  ftype:=sapkg_directory;
  Id:=1;
  Data:=Nil;
  Father:=0;
  Son.Clear;
 End;
 Struct.PushBack(Root);
End;

Destructor SAPackage.FreeData;
Var i:Longint;
Begin
 For i:=1 to Struct.Size Do
 If (Struct.Items[i]<>Nil)And(Struct.Items[i]^.Data<>Nil) Then
  Struct.Items[i]^.Data.Destroy;
 Struct.Clear
End;

Destructor SAPackage.Free;
Begin
 Struct.Clear
End;

Function SAPackage.Count:Longint;
Begin
 Exit(Struct.Size)
End;

Function SAPackage.Get(DId:Longint):pSAPackageObj;
Begin
 If (Did<1)Or(Did>Struct.Size) Then Exit(Nil);
 Exit(Struct.Items[DId])
End;

Function SAPackage.GetSon(DId:Longint;_FName:Ansistring):Longint;
Var i:Longint; tmp:pSAPackageObj;
Begin
 If Get(Did)=Nil Then Exit(0);
 with Get(Did)^ Do
 Begin
  For i:=1 to Son.Size Do
  Begin
   tmp:=Get(Son[i]);
   If (tmp<>nil)And(tmp^.fname=_FName) Then Exit(tmp^.id)
  End
 End;
 Exit(0)
End;

Function SAPackage.GetSize(Did:Longint):Int64;
Var i:Longint; tmp:TFileStream;
Begin
 With Get(Did)^ Do
 Case ftype Of
  sapkg_file:If Data=Nil Then Exit(0) Else Exit(Data.Size);
  sapkg_directory:Begin
                   GetSize:=0;
                   With Son Do
                   For i:=1 to Size Do
                    Inc(GetSize,GetSize(Son[i]))
                  End;
  sapkg_outfile:Exit(GetFileSize(Data.ReadAnsistring))
 End
End;

Function SAPackage.AddFile(Path:Ansistring;Const _obj:SAPackageObj):Longint;
var catalog:SList; i,nowid:Longint;
Begin
 catalog:=ListPart(Path,['/','\']);
 If catalog.Size=0 Then Exit(0);
 nowid:=1;
 For i:=1+Ord(catalog[1]='') to catalog.Size Do
  nowid:=AddDirectory(catalog[i],nowid);
 Exit(AddFile(nowid,_obj))
End;

Function SAPackage.AddFile(DId:Longint;Const _obj:SAPackageObj):Longint;
Var a,tmp:pSAPackageObj;
Begin
 tmp:=Get(Did);
 If tmp=Nil Then Exit(0);
 New(a);
 Struct.PushBack(A);
 a^:=_obj;
 a^.id:=Struct.Size;
 a^.father:=Did;
 tmp^.Son.PushBack(a^.id);
 Exit(a^.id)
End;

Function SAPackage.AddDirectory(Path:Ansistring):Longint;
Var catalog:SList; i,nowid:Longint;
Begin
 catalog:=ListPart(Path,['/','\']);
 nowid:=0;
 If catalog.Size>0 Then Begin
  nowid:=1;
  For i:=1+Ord(catalog[1]='') to catalog.Size Do
   nowid:=AddDirectory(catalog[i],nowid);
 End;
 Exit(nowid)
End;

Function SAPackage.AddDirectory(FName:Ansistring;Did:Longint):Longint;
Var a,tmp:pSAPackageObj;
Begin
 AddDirectory:=GetSon(Did,FName);
 If AddDirectory<>0 Then Exit;
 tmp:=Get(Did);
 If tmp=Nil Then Exit(0);
 New(a);
 Struct.PushBack(A);
 a^:=sapkg_NewDirectory(Fname);
 a^.id:=Struct.Size;
 a^.father:=Did;
 tmp^.Son.PushBack(a^.id);
 Exit(a^.id)
End;

Procedure SAPackage.Load(Path:Ansistring);
Var
 F:TFileStream;
 sapkgtag:Ansistring;
 tmpfname:Pchar;
 version:Single;
 I,structSize,j,k:Longint;
 tmp:pSAPackageObj;
Begin
 Struct.Clear;
 F:=TFileStream.Create(Path,fmOpenRead);
 GetMem(tmpfname,10);
 F.Read(tmpfname^,9);
 tmpfname[9]:=#0;
 sapkgtag:=tmpfname;
 FreeMem(tmpfname);
 F.Read(version,4);
 If (LowerCase(sapkgtag)<>'sapackage')And(version<>1.0) Then Exit;
 F.Read(StructSize,4);
 For i:=1 to StructSize Do Begin
  New(Tmp); With Tmp^ Do Begin
   F.Read(j,4);
   GetMem(tmpfname,j+1);
   F.Read(tmpfname^,j); tmpfname[j]:=#0;
   fname:=tmpfname;
   FreeMem(tmpfname);
   F.Read(ftype,1);
   Case ftype Of
    sapkg_file,sapkg_outfile:Begin
      F.Read(j,4);
      Data:=TMemoryStream.Create;
      Data.SetSize(j);
      F.Read(Data.Memory^,j)
     End;
    sapkg_directory:;
   End;
   F.Read(father,4);
   F.Read(j,4);
   Son.Clear;
   For j:=1 to j Do Begin F.Read(k,4); Son.PushBack(k) End
  End;
  Struct.PushBack(Tmp)
 End;
 FreeAndNil(F)
End;

Procedure SAPackage.Save(Path:Ansistring);
Var
 F:TFileStream;
 version:Single=1.0;
 i,j:Longint;
Begin
 F:=TFileStream.Create(Path,fmCreate);
 F.Write('SAPACKAGE',9);
 F.Write(Version,4);
 F.Write(Struct.Size,4);
 For i:=1 to Struct.Size Do
 If Struct[i]<>Nil Then
 With Struct.Items[i]^ Do Begin
  j:=Length(fname);
  F.Write(j,4);
  F.Write(Pointer(pUInt(@fname)^)^,j);
  F.Write(ftype,1);
  Case ftype Of
   sapkg_file,sapkg_outfile:Begin
     If Data=Nil Then j:=0 Else j:=Data.Size;
     F.Write(j,4);
     If Data<>Nil Then F.Write(Data.Memory^,j);
    End;
   sapkg_directory:;
  End;
  F.Write(Father,4);
  F.Write(Son.Size,4);
  For j:=1 to Son.Size Do F.Write(Son[j],4);
 End;
 FreeAndNil(F)
End;

Procedure SAPackage.Print;
Var
 FlagN:Longint;
 Flag:pBoolean;

 Procedure SearchPrint(Did,Level:Longint);
 Var i:Longint;
 Begin
  If Get(Did)=Nil Then Exit;
  With Get(Did)^ Do Begin
   If Not Flag[Did] Then Begin
    For i:=1 to Level Do Write('-');
    WriteLn(fname);
    Flag[Did]:=True
   End;
   For i:=1 to Son.Size Do SearchPrint(Son[i],Level+1)
  End
 End;

Begin
 FlagN:=Count+1;
 GetMem(Flag,FlagN);
 FillChar(Flag^,FlagN,0);
 SearchPrint(1,1);
 FreeMem(Flag)
End;

Procedure SAPackage.Extract(Path:Ansistring;Did:Longint);

 Procedure ExtractOutput(Path:Ansistring;Did:Longint);
 Var i:Longint;
 Begin
  If Get(Did)=Nil Then Exit;
  With Get(Did)^ Do Begin
   If fname<>'' Then Begin
    Case ftype Of
     sapkg_file:data.SaveToFile(Path+fname);
     sapkg_outfile:CopyFile(data.ReadAnsistring,Path+fname);
     sapkg_directory:CreateDir(Path+fname);
    End;
    Path:=Path+fname+'/'
   End;
   For i:=1 to Son.Size Do
    ExtractOutput(Path,Son[i])
  End
 End;

Begin
 If (Path<>'')And(Not(Path[Length(Path)]in['\','/'])) Then Path:=Path+'/'; //Windows='\'  Linux='/'
 ExtractOutput(Path,Did)
End;

Procedure SAPackage.Extract;
Begin
 Extract('',1)
End;



end.