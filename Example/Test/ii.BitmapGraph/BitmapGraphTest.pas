//本代码是隶属于SA2库及SAKit库的测试代码的BitmapGraphTest.pas
//主要参考网址：http://www.cnblogs.com/yangdanny/p/4634536.html
//对于熟悉WinApi者，其他GDI中的绘制方式如GradientFill等可自行写码
Uses SimpleAnimeUnit2,SAKitUnit,Windows;
Var
 b:BitmapGraph;      //设备上下文内置
 c:TextGraph;
 i:Longint;

 Pt:Array[0..3]Of Point=((X:90;Y:130),(X:60;Y:40),(X:140;Y:150),(X:160;Y:80));
// Pl:Array[0..4]Of Point=((X:
Begin
 b.Create(400,360);  //BitmapGraph可直接构建（Create）一张特定大小的全黑图
                     //也可由Graph构建出来（损失透明度）
//值得注意的是，与SA基本Graph的风格不同
//BitmapGraph中所有操作都满足是先列后行的，颜色是COLOREF（可认为Longint）
 b.Fill(0,0,b.Width,b.Height,RGB(255,255,255));  //填充区域为某色

 For i:=1 to 10 Do
  b.SetPixel(i*4,10,RGB(0,0,0));                           //单点像素绘制，低效率不建议使用
 b.DrawLine(120,30,200,30,PS_SOLID,2,RGB(0,0,0));          //绘制线条，设定初末位置、样式、粗细、颜色
 b.DrawLine(120,50,200,50,PS_DASH,1,RGB(100,0,200));
 b.DrawLine(120,70,200,70,PS_DASHDOT,1,RGB(100,250,100));  //不同样式的线条

 b.DrawArc(10,30,40,50,40,30,10,40,RGB(10,255,255),RGB(0,0,0));    //绘制弧线，后面两个参数分别是填充色、轮廓色
 b.DrawChord(10,60,40,80,40,60,10,70,RGB(10,255,255),RGB(0,0,0));  //绘制弦割线
 b.DrawPie(10,90,40,110,40,90,10,100,RGB(10,255,255),RGB(0,0,0));  //绘制饼图

 b.DrawCircle(100,180,30,RGB(0,250,250),RGB(255,255,255));                    //绘制圆
 b.DrawEllipse(Pt[0].x,Pt[0].y,Pt[1].x,Pt[1].y,RGB(128,128,128),RGB(0,0,0));  //绘制椭圆
 b.DrawRect(Pt[2].x,Pt[2].y,Pt[3].x,Pt[3].y,RGB(90,90,90),RGB(255,0,255));    //绘制矩形
 b.DrawPolygon(@Pt,4,1,RGB(255,255,128),RGB(10,20,30));                       //绘制多边形
 b.DrawBezier(@Pt,4,1,RGB(0,0,0));                                            //绘制贝塞尔曲线
 b.DrawCircle(Pt[0].x,Pt[0].y,8,RGB(0,255,0),RGB(0,0,0));                     //标出贝塞尔曲线的四个锚点
 b.DrawCircle(Pt[1].x,Pt[1].y,8,RGB(0,0,255),RGB(0,0,0));
 b.DrawCircle(Pt[2].x,Pt[2].y,8,RGB(0,0,0),RGB(0,0,0));
 b.DrawCircle(Pt[3].x,Pt[3].y,8,RGB(255,0,0),RGB(0,0,0));


 b.DrawRect(220,20,280, 60,HS_BDIAGONAL,RGB(255,0,0),RGB(10,10,10));    //绘制不同模式的矩形
 b.DrawRect(220,80,280,120,HS_CROSS    ,RGB(0,255,0),RGB(10,10,10));
 b.DrawRect(290,20,350, 60,HS_DIAGCROSS,RGB(0,0,255),RGB(10,10,10));
 b.DrawRect(290,80,350,120,HS_VERTICAL ,RGB(0,0,0)  ,RGB(10,10,10));

 b.DrawBmp(180,140,360,240,'SABitmapTest.bmp');    //绘制位图

 b.DrawText(20,220,'Program Sample以上',18);       //绘制文字
 c.Create('参上TextGraph？');
 b.DrawText(20,240,c);



 Init('SAK-BitmapGraphTest',b.Width,b.Height);
 Main.AddObj(b);
 Lock;
 Main.Display;
 UnLock;

 GetClose

End.
