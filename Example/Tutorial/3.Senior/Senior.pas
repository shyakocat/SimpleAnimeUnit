//这段代码是隶属于SimpleAnimeUnit教程的Senior.pas
uses SimpleAnimeUnit2,SysUtils;
Var
 b:GroupGraph;
 a:SimpleAnime;    //简易的动画
 u:AnimeObj;       //AnimeObj属性标记
 v:AnimeTag;       //AnimeTag动画标记
 w:AnimeLog;       //AnimeLog逻辑标记
//虽然SA2库的初衷不是主攻游戏
//但作为游戏基础的【渲染】【逻辑】概念还是有的
//前面的Basic和Junior都在讲渲染（也就是图形绘制）
//这次就讲逻辑（也就是用户输入信息）

 Id:Longint;


 c:TextGraph;

 Procedure DealMouse(Env:pElement;Below:pGraph;Const E:SAMouseEvent;inner:ShortInt);
//这个过程是一个MouseProc，他参数的格式必须如上
//Env是Element的指针，Element即{Role=AnimeObj,Acts=AnimeTag,Talk=AnimeLog}
//Below是下垫面Graph的指针
//注：前置的Env,Below在SA2中被认为是标准的必要操作参数
//SAMouseEvent是一个集成的鼠标信息记录
//Longint类型的E.x,E.y表示鼠标位置，E.button表示鼠标状态，如果二进制位1上有1表示鼠标左键
//Boolean类型的E.press表示鼠标按下（的瞬间），E.release表示鼠标弹起（的瞬间）
//inner表示是否在图片内，如果二进制位1上有1表示“是”，这里的图片内指图片的感应区内
 Begin
  if (E.button and 1=1)and(E.press)and(inner and 1=1) then
   Env^.Role.Alpha:=1.5-Env^.Role.Alpha   //如果鼠标左键在图片上按下了，就变化图片的透明度
 End;

Begin
 b.Create;
 b.LoadGIF('SeniorTest.gif');

 u.Create(b);        //u是属性，通过一张图片创建
 u.SetXY(100,10);    //设置在窗口中的位置是(X=100,Y=10)

 a.Create;                    //SimpleAnime是简易的动画，可以把若干个属性在一段时间内以某种规律变化
 a.SetRotate(360,tp_Line);    //以线性旋转360°
 a.SetXY(0,200,tpb_Sin);      //以Sin函数向右平移200个像素
 a.SetType(atp_loop);         //动画循环播放
 a.SetTime(2500);             //完成一次动画用时2.5秒

 v.Create(a);                 //v是动画

 w.Create;                    //w是逻辑
 w.MouseEvent:=@DealMouse;    //注册函数，当有鼠标事件时调用DealMouse

 Id:=Main.AddObj(u);          //AddObj其实是个函数，返回值就是在Stage中的编号
 Main.AttachAnime(id,v);      //为其附上动画
 Main.AttachLogic(id,w);      //为其附上逻辑

 c.Create;
 c.FontColor:=Color_White;    //设置字体颜色为白色

 Init('Senior',b.Width*2,b.Height*2);
 Repeat
  Lock;
  ScreenClear;         //ScreenClear无参数就是用黑色填充
  Main.Communication;  //Communication是处理逻辑
  Main.Display;        //Display是处理渲染
  c.SetText(IntToStr(NowFPS));    //NowFPS是现在的帧数（伪帧数）
                                  //改变文本不能用c.Text:=...，而要用c.SetText(...)
                                  //因为文本变了相关的信息也要变，同理改变大小要c.SetSize()
  c.WriteTo(Screen,1,1);          //把帧数写到Screen的(1,1)位置上
  UnLock;
 Until (Not ConsoleUsing)Or(TestKeyPress)
End.
