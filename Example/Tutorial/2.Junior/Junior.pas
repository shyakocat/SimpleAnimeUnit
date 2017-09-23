//这段代码是隶属于SimpleAnimeUnit教程的Junior.pas
uses SimpleAnimeUnit2;
Var
 a:Graph;
 b:GroupGraph;      //GroupGraph组图
 c:TextGraph;       //TextGraph文字
Begin
 a.Create;
 a.Load('JuniorTest.png');
 b.Create;
 b.LoadGIF('JuniorTest.gif');   //组图可以通过依次添加Graph构建，也可以直接读取gif
 c.Create('中文GB2312测试__how??');

 Main.AddObj(a);
 Main.AddObj(b);
 Main.AddObj(c);
//Main是一个Stage（舞台）类型
//可以用AddObj过程向Stage中添加内容

 Init('Junior',a.Width,a.Height);
//Gif是动图，所以只绘制单次是不行的，要不停地更新屏幕
 Repeat
  Lock;
  ScreenClear(Color_White);  //把Screen全填充成白色，Color是一个包含BGRA的类型，Color_White即(r=g=b=a=255)
  Main.Display;              //把Main这个Stage中的内容依次绘制出来
  UnLock;
 Until (Not ConsoleUsing)Or(TestKeypress)    //直到用户按键后终止
                                 //Console.KeyPressed是不好的，不建议在SA2下直接访问PTC的内容
                                 //因为Console（窗口）一旦关闭后，使用Console.KeyPressed会报错
                                 //所以在那之前使用SA2提供的ConsoleUsing来检测窗口的使用情况
End.