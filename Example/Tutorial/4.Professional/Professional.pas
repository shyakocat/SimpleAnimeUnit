//这段代码是隶属于SimpleAnimeUnit教程的Professional.pas
{$APPTYPE GUI}   //用于隐去控制台
uses SimpleAnimeUnit2;
Type
 pCustomGraph=^CustomGraph;    //Pascal中的指针先行定义
//这里是进阶（Professional）的教程，但不包含SA2库的所有细节
//本教程即制作了一个“生命游戏”
//通过本教程可以更了解SA2库的原理

//SA2库相对于第一代的SimpleAnimeUnit库主要区别在于内核是以对象(Object)为基础的，（官方吐槽：虽然第一代也是用对象写的，但没有用到精髓）
//对于之前几份代码中，可能你会疑惑Graph,GroupGraph,TextGraph是不同的变量类型，为什么都可以直接在Stage中添加（AddObj）
//并不是shyakocat（也就是作者shy）对每一个类型都写了一个AddObj
//而是Graph,GroupGraph,TextGraph，包括CompressGraph（压缩图，为了解决运行时内存过大的问题），他们都继承于BaseGraph
//BaseGraph是一个仅有感应区（Width和Height）的基础对象（object），是所有衍生出的图片类型的父类
//同样，你也可以继续在子类上继承，示例如下

 CustomGraph=Object(Graph)   //CustomGraph，自定义图，继承自Graph
  Const StdX=4; StdY=4;      //每个格子的像素大小
  Var CX,CY:Longint;         //格子每列、行的个数
  Constructor CreateGrid(_X,_Y:Longint);            //Constructor是构析函数，区别于普通object或record，他可以构建VMT
  Destructor Free;Virtual;                          //Destructor是折析函数，释放VMT
                                                    //关于以上两种函数，如果你熟悉了那就最好，否则写代码时要小心
                                                    //关于修饰词Virtual是虚函数的意思，重写了Graph中的Free（释放空间）
  Function GetColor(_X,_Y:Longint):Color;           //获取(_X,_Y)格子的颜色
  Procedure SetColor(_X,_Y:Longint;Const _C:Color); //设置(_X,_Y)格子的颜色
  Procedure RandomStatus;                           //随机状态
  Procedure NextStatus;                             //下一个状态，满足生命游戏定义：周围8格——3个细胞则生；2个细胞则保持；其他则死
  Function Cut:CustomGraph;                         //复制
//SA2库中，虚函数在BaseGraph中是Abstract（抽象）的，所以BaseGraph不会对其有实现，需要在子类中实现！
  Function Reproduce:pBaseGraph;Virtual;                        //复制，但返回的是指针
  Function Recovery(Env:pElement;Below:pGraph):pGraph;Virtual;  //还原，Env表示Element（元素，即AnimeObj+AnimeTag+AnimeLog），Below表示下垫的图片
                                                                //Recovery要求把CustomGraph根据需要的信息制作成Graph，并返回pGraph（Graph的指针）
 End;

 Constructor CustomGraph.CreateGrid(_X,_Y:Longint);
 Begin
  Create(_X*StdX,_Y*StdY);
  CX:=_X;
  CY:=_Y;
  Fill(1,1,Height,Width,Color_White)     //Fill是Graph内置函数，即填充
 End;

 Destructor CustomGraph.Free;
 Begin
  inherited Free         //inherted Free指调用父类中的释放操作
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
  Exit(Items[(_X-1)*StdX+1,(_Y-1)*StdY+1])        //Items是Graph中的一个property，而且是default的，可以返回单点像素
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
  Cut:=Self;                                 //self即类自身，顺便一说objfpc中result即函数返回值（cut）自身
  Cut.Canvas:=GetMem(Bits);                  //bits是Graph的内置函数，返回像素个数，即Width*Height*4
                                             //Canvas（画布）是Graph存储图片的指针，即pColor
  Move(Canvas^,Cut.Canvas^,bits)             //Move是复制的意思，但是对指针有优化，有的情况可以省时省空间
 End;

 Function CustomGraph.Reproduce:pBaseGraph;
 Var Tmp:^CustomGraph;
 Begin
  New(Tmp);                                  //这里要非常注意，有些人可能会写Tmp:CustomGraph，然后返回@Tmp
                                             //这样是不行的，因为函数一结束，object的折析函数（类似Destroy）就会自动调用，Tmp就会被删除掉
                                             //所以，要用指针构建
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

 FreshLimit:=33;                   //FreshLimit表示限制更新的时间（毫秒），33即限帧1000 div 33=30帧
                                   //之所以要限帧是为了防止CPU使用率过高
 Init('LifeGame',Field.Width,Field.Height);
 Repeat
  Lock;
  All.Communication;
  All.Display;
  If Not StopGame Then
   pCustomGraph(All.Get(FieldId)^.Source)^.NextStatus;      //Stage.Get(id)指获得编号为id的AnimeObj的指针
                                                            //Source是pBaseGraph，是AddObj时复制的图片的指针
                                                            //从理论上讲DrawTo或BlendTo是基础的，所以会比用Stage来得更底层、更快
                                                            //DrawTo是像素的直接复制，BlendTo会根据透明度复制颜色
                                                            //但使用Stage在多图时会更方便些，故要酌情兼顾效率和编码复杂度
  UnLock;
 Until Not ConsoleUsing;
 EndIt    //EndIt和Init相对，可以不写
//写完程序用任务管理器看下内存，观察有无内存泄漏
End.
//等你看完代码后发现：咦？为什么这个一定要继承Graph做呢？
//不是慢了么，直接用Graph搞没毛病啊
//因为shy只是想说明一下这个原理而已。。。
