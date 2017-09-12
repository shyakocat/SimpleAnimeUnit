//��δ�����������SimpleAnimeUnit�̵̳�Professional.pas
{$APPTYPE GUI}   //������ȥ����̨
uses SimpleAnimeUnit2;
Type
 pCustomGraph=^CustomGraph;    //Pascal�е�ָ�����ж���
//�����ǽ��ף�Professional���Ľ̳̣���������SA2�������ϸ��
//���̳̼�������һ����������Ϸ��
//ͨ�����̳̿��Ը��˽�SA2���ԭ��

//SA2������ڵ�һ����SimpleAnimeUnit����Ҫ���������ں����Զ���(Object)Ϊ�����ģ����ٷ��²ۣ���Ȼ��һ��Ҳ���ö���д�ģ���û���õ����裩
//����֮ǰ���ݴ����У���������ɻ�Graph,GroupGraph,TextGraph�ǲ�ͬ�ı������ͣ�Ϊʲô������ֱ����Stage����ӣ�AddObj��
//������shyakocat��Ҳ��������shy����ÿһ�����Ͷ�д��һ��AddObj
//����Graph,GroupGraph,TextGraph������CompressGraph��ѹ��ͼ��Ϊ�˽������ʱ�ڴ��������⣩�����Ƕ��̳���BaseGraph
//BaseGraph��һ�����и�Ӧ����Width��Height���Ļ�������object������������������ͼƬ���͵ĸ���
//ͬ������Ҳ���Լ����������ϼ̳У�ʾ������

 CustomGraph=Object(Graph)   //CustomGraph���Զ���ͼ���̳���Graph
  Const StdX=4; StdY=4;      //ÿ�����ӵ����ش�С
  Var CX,CY:Longint;         //����ÿ�С��еĸ���
  Constructor CreateGrid(_X,_Y:Longint);            //Constructor�ǹ�����������������ͨobject��record�������Թ���VMT
  Destructor Free;Virtual;                          //Destructor�������������ͷ�VMT
                                                    //�����������ֺ������������Ϥ���Ǿ���ã�����д����ʱҪС��
                                                    //�������δ�Virtual���麯������˼����д��Graph�е�Free���ͷſռ䣩
  Function GetColor(_X,_Y:Longint):Color;           //��ȡ(_X,_Y)���ӵ���ɫ
  Procedure SetColor(_X,_Y:Longint;Const _C:Color); //����(_X,_Y)���ӵ���ɫ
  Procedure RandomStatus;                           //���״̬
  Procedure NextStatus;                             //��һ��״̬������������Ϸ���壺��Χ8�񡪡�3��ϸ��������2��ϸ���򱣳֣���������
  Function Cut:CustomGraph;                         //����
//SA2���У��麯����BaseGraph����Abstract�����󣩵ģ�����BaseGraph���������ʵ�֣���Ҫ��������ʵ�֣�
  Function Reproduce:pBaseGraph;Virtual;                        //���ƣ������ص���ָ��
  Function Recovery(Env:pElement;Below:pGraph):pGraph;Virtual;  //��ԭ��Env��ʾElement��Ԫ�أ���AnimeObj+AnimeTag+AnimeLog����Below��ʾ�µ��ͼƬ
                                                                //RecoveryҪ���CustomGraph������Ҫ����Ϣ������Graph��������pGraph��Graph��ָ�룩
 End;

 Constructor CustomGraph.CreateGrid(_X,_Y:Longint);
 Begin
  Create(_X*StdX,_Y*StdY);
  CX:=_X;
  CY:=_Y;
  Fill(1,1,Height,Width,Color_White)     //Fill��Graph���ú����������
 End;

 Destructor CustomGraph.Free;
 Begin
  inherited Free         //inherted Freeָ���ø����е��ͷŲ���
 End;

 Procedure CustomGraph.SetColor(_X,_Y:Longint;Const _C:Color);
 Begin
  _X:=(_X-1)*StdX;
  _Y:=(_Y-1)*StdY;
  Fill(_X+1,_Y+1,_X+StdX,_Y+StdY,_C)
 End;

 Function CustomGraph.GetColor(_X,_Y:Longint):Color;
 Begin
  if (_X<1)or(_Y<1)or(_X>CX)or(_Y>CY) then Exit(Color_White);
  Exit(Items[(_X-1)*StdX+1,(_Y-1)*StdY+1])        //Items��Graph�е�һ��property��������default�ģ����Է��ص�������
 End;

 Procedure CustomGraph.RandomStatus;
 Var i,j:Longint;
 Begin
  For i:=1 to CX do
  For j:=1 to CY do
  if Random(2)=0 then SetColor(i,j,Color_White)
                 else SetColor(i,j,Color_Black)
 End;

 Procedure CustomGraph.NextStatus;
 Var
  a:pCustomGraph;
  i,j:Longint;

  Function Cnt(i,j:Longint):Longint;
  Begin Exit(Ord(GetColor(i,j)<>Color_White)) End;

 Begin
  New(a,CreateGrid(CX,CY));
  For i:=1 to CX do
  For j:=1 to CY do
  Case Cnt(i-1,j-1)+Cnt(i-1,j)+Cnt(i-1,j+1)+
       Cnt(i  ,j-1)           +Cnt(i  ,j+1)+
       Cnt(i+1,j-1)+Cnt(i+1,j)+Cnt(i+1,j+1) of
   3:a^.SetColor(i,j,Color_Black);
   2:a^.SetColor(i,j,GetColor(i,j));
   Else a^.SetColor(i,j,Color_White)
  End;
  Free;
  Self:=a^
 End;

 Function CustomGraph.Cut:CustomGraph;
 Begin
  Cut:=Self;                                 //self��������˳��һ˵objfpc��result����������ֵ��cut������
  Cut.Canvas:=GetMem(Bits);                  //bits��Graph�����ú������������ظ�������Width*Height*4
                                             //Canvas����������Graph�洢ͼƬ��ָ�룬��pColor
  Move(Canvas^,Cut.Canvas^,bits)             //Move�Ǹ��Ƶ���˼�����Ƕ�ָ�����Ż����е��������ʡʱʡ�ռ�
 End;

 Function CustomGraph.Reproduce:pBaseGraph;
 Var Tmp:^CustomGraph;
 Begin
  New(Tmp);                                  //����Ҫ�ǳ�ע�⣬��Щ�˿��ܻ�дTmp:CustomGraph��Ȼ�󷵻�@Tmp
                                             //�����ǲ��еģ���Ϊ����һ������object����������������Destroy���ͻ��Զ����ã�Tmp�ͻᱻɾ����
                                             //���ԣ�Ҫ��ָ�빹��
  Tmp^:=Cut;
  Exit(Tmp)
 End;

 Function CustomGraph.Recovery(Env:pElement;Below:pGraph):pGraph;
 Var Tmp:^Graph;
 Begin
  New(Tmp);
  Tmp^:=Cut;
  Exit(Tmp)
 End;


Var
 BackGround:Graph;
 Field:CustomGraph;
 All:Stage;
 FieldId:Longint;
 FieldLog:AnimeLog;
 StopGame:Boolean=False;

 Procedure KeyDeal(obj:pAnimeObj;tag:pAnimeTag;key,press,release:Longint);
 Begin
  if (key=32)and(release=1) then StopGame:=Not StopGame Else
  if key=27 then Halt
 End;

Begin
 BackGround.Create;
 BackGround.Load('ProTest.jpg');

 Field.CreateGrid(100,100);
 Field.RandomStatus;

 All.AddObj(BackGround);
 FieldId:=All.AddObj(Field);
 All.Get(FieldId)^.SetAlpha(0.55);
 FieldLog.Create;
 FieldLog.KeyEvent:=@KeyDeal;
 All.AttachLogic(FieldId,FieldLog);

 FreshLimit:=33;                   //FreshLimit��ʾ���Ƹ��µ�ʱ�䣨���룩��33����֡1000 div 33=30֡
                                   //֮����Ҫ��֡��Ϊ�˷�ֹCPUʹ���ʹ���
 Init('LifeGame',Field.Width,Field.Height);
 Repeat
  Lock;
  All.Communication;
  All.Display;
  If Not StopGame Then
   pCustomGraph(All.Get(FieldId)^.Source)^.NextStatus;      //Stage.Get(id)ָ��ñ��Ϊid��AnimeObj��ָ��
                                                            //Source��pBaseGraph����AddObjʱ���Ƶ�ͼƬ��ָ��
                                                            //�������Ͻ�DrawTo��BlendTo�ǻ����ģ����Ի����Stage���ø��ײ㡢����
                                                            //DrawTo�����ص�ֱ�Ӹ��ƣ�BlendTo�����͸���ȸ�����ɫ
                                                            //��ʹ��Stage�ڶ�ͼʱ�������Щ����Ҫ������Ч�ʺͱ��븴�Ӷ�
  UnLock;
 Until Not ConsoleUsing;
 EndIt    //EndIt��Init��ԣ����Բ�д
//д���������������������ڴ棬�۲������ڴ�й©
End.
//���㿴�������֣��ף�Ϊʲô���һ��Ҫ�̳�Graph���أ�
//��������ô��ֱ����Graph��ûë����
//��Ϊshyֻ����˵��һ�����ԭ����ѡ�����
