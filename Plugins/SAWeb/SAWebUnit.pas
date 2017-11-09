{$MODE OBJFPC}{$H+}
unit SAWebUnit;
interface
uses Classes,WinInet,RegExpr,SysUtils,CommonTypeUnit;

Type pUint=^Dword;


Function GetPChar(S:Ansistring):PChar;
Function DownLoadToStream(Url:Ansistring):TMemoryStream;
Function DownLoad(Url:Ansistring):Ansistring;
Function DownLoadToFile(Url,FileName:Ansistring):Boolean;
Function Html_ExtractImg(Html:Ansistring):SList;

implementation

Function DownLoadToStream(Url:Ansistring):TMemoryStream;
Const
 BufSize=1024;
var
 hSession,hOpenUrl:HINTERNET;
 buf:array[0..bufsize-1]of byte;
 dwRead,dwResult:DWORD;
begin
 hSession:=InternetOpen('',INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0);
 if hSession=nil then exit;
 hOpenUrl:=InternetOpenUrl(hSession,GetPChar(Url),nil,0,0,0);
 if hOpenUrl=nil then exit;
 Result:=TMemoryStream.Create;
 dwRead:=1;
 While dwRead>0 Do Begin
  InternetReadFile(hOpenUrl,@Buf,BufSize,dwRead);
  Result.Write(Buf,dwRead)
 End;
 InternetCloseHandle(hOpenUrl);
 InternetCloseHandle(hSession)
End;

Function DownLoad(Url:Ansistring):Ansistring;
Var tmp:TMemoryStream;
Begin
 tmp:=DownLoadToStream(Url);
 SetString(Result,tmp.Memory,tmp.Size);
 tmp.Destroy
End;

function DownloadToFile(Url,FileName:Ansistring):boolean;
const
 bufsize=1024;
var
 hSession,hOpenUrl:HINTERNET;
 buf:array[0..bufsize-1]of byte;
 dwRead,dwResult:DWORD;
 stdout:file of char;
begin
 hSession:=InternetOpen('',INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0);
 if hSession=nil then exit(False);
 hOpenUrl:=InternetOpenUrl(hSession,GetPChar(Url),nil,0,0,0);
 if hOpenUrl=nil then exit(False);
 assign(stdout,filename); Rewrite(stdout,1);
 dwRead:=1;
 while dwRead>0 do
 begin
  InternetReadFile(hOpenUrl,@buf,bufsize,dwRead);
  BlockWrite(stdout,buf,dwRead)
 end;
 close(stdout);
 InternetCloseHandle(hOpenUrl);
 InternetCloseHandle(hSession);
 Exit(True)
end;

Function GetPChar(s:Ansistring):PChar;
Begin
 Exit(PChar(pUint(@s)^))
End;


Function Html_ExtractImg(Html:Ansistring):SList;
Var
 r:TRegExpr;
 tmpurl:Ansistring;
Begin
 Result.Clear;
 r:=TRegExpr.Create('src="(.*?)"');
 If r.Exec(html) Then
  Repeat
   tmpurl:=r.Match[1];
   If tmpUrl='' Then Continue;
   If tmpUrl[1]='$' Then Continue;
   If Copy(tmpUrl,1,2)='//' Then tmpUrl:='https:'+tmpUrl;
   Result.PushBack(r.Match[1])
  Until Not r.ExecNext
End;


end.
