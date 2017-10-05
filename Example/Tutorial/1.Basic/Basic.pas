//这段代码是隶属于SimpleAnimeUnit教程的Basic.pas
//在最开始说明一下，建议使用FP3.0.2
//使用过程如有PTCError问题，但Exe文件可以运行
//可能是需要把根目录设置为该代码所在目录才行，否则会读取不到图片
//建议把SA2库放在与该代码同一目录下
uses SimpleAnimeUnit2;   //调用SimpleAnimeUnit2库
Var
 a:Graph;   //Graph是SA2库中很有用的一个类型，即图片的意思
Begin
 a.Create;  //初始化
 a.Load('BasicTest.Jpg');         //载入图片
 Init('Basic',a.Width,a.Height);  //建立窗口，设定名称、宽、高
 Lock;                    //绘图前必须锁定像素
 DrawTo(a,Screen,0,0);    //把图片a绘制到Screen上，Screen也是Graph，且其指针指向屏幕像素
 UnLock;                  //绘制后解锁才能更新屏幕的内容
 GetClose                 //等待用户关闭窗口
End.
