# SimpleAnimeUnit

Simple Pascal GUI Assistant    
简易Pascal图形界面辅助库    

## 前言

**SA库的初衷、作用、简介、前身**

  SimpleAnimeUnit2，正如其名——是由shyakocat使用Pascal语言编写的一个支持简易图形界面的库。是基于Pascal的ptc库的，其源代码为OpenPTC。

  起初shy只是为了可以方便地查看、整理并预览本地的mmd模型而计划编写一个小程序，之后就演变成编写一个基础库。（如果借LinkClinton的话来讲就是锻炼自己）

  SimpleAnimeUnit本意在于可以令开发者比较方便地开发出一个可实用的图形界面程序，免于纠结大量的细节。此外，支持的图片功能还可供简易的图片操作，使一些计算机图形学方面的研究在图片操作上可以简化（比如研究高斯模糊、图片压缩、识图识字等，就不必过于烦恼图片的读入输出）。

  SimpleAnimeUnit主要提供的功能有：

  - 图片的绘制
  - 一些WinAPI的封装
  - 作为一些扩展库的基础

  SA2库的前身是SimpleAnimeUnit。SA2继承其主体代码，新增了大量内容并发展至今。弃用第一代SA库的原因是其没有善用面向对象Pascal的方便之处。

**Pascal知识的补充**

  请注意，这段内容并非从零开始教授Pascal语言。而是假定读者已经熟悉了noip层面的Pascal语法知识，在那个基础上shyakocat对其进行关于之后代码必要知识的选讲。对于编程水平较高者可以跳过这段。

- Pascal基础知识的扩充

  - 写法

    `#`后跟数字，表示ASCII码为该数字的字符。如`#97`就表示`'a'`。连续的字符当做字符串，比如`'I''m '#115#104'y'`即`I'm shy`。

    `%`后跟二进制数，表示对应的十进制数。如`%1001`就表示9。

    `&`后跟八进制数，表示对应的十进制数。如`&47`就表示39。

    `$`后跟十六进制数，表示对应的十进制数。如`%20`就表示32。

    上述写法在Val过程中适用。比如`Val('&47',Num);`后`Num`的值就是39。

  - 指针 `Pointer`

	`Pointer`，Pascal中泛用的指针。一般地，32位系统中，我们认为指针是一个4字节的指示地址的变量。

	指针`p`可以用`GetMem(p,字节数)`来申请一段连续且内容随机的内存；这里的`GetMem`是智能的，只有在使用到的时候才开出内存。

	用`FreeMem(p)`来释放内存，`FreeMem(p)`必须保证p是指向有效内容的。

	如果需要一段全部为0的内存则可用`p:=AllocMem(字节数)`。

	`p^`表示指针指向的内容。对指针填充可以用`FillChar(p^,字节数,填充字符)`。这里`FillChar`按经验认为是比较快的。

	将一段内存p复制到q可以用`Move(p^,q^,字节数)`。这里`Move`也是智能的，通常只有修改的时候才会进行复制，仅读取则依赖指针计数引用。

	指针也可以通过`Type  pint=^Longint;  pchar=^Char;`这种形式定义出来，这样定义的指针是针对性的，但一般可以和`pointer`隐式转换。

	特殊地，Pchar与Windows的定义是相符的。即Pchar可以转为一个字符串，其为该指针之后以#0结尾之前的那部分。

	我们假定`p`是一个`^Longint`，那么他是一个指向`longint`的指针。而且上述`pointer`的操作依然适用。

	可以用`p^`读写`longint`的值，用`p[i]`或`(p+i)^`来类似数组地读写该指针后连续第`i`个`longint`变量的值。

	特殊地，定义`A:array[0..N]of longint`，`A`实质上是一个指针。

	`New(p)`可以新建一个`longint`变量（`Pint`的话是4字节，如果`Pchar`的话是1字节，依此类推），`Dispose(p)`可以销毁一个`longint`变量。

	特别特别要注意的是，之后我也会再三提到。`Dispose(p)`会先调用折析函数，再清理内存空间。同样地，一个函数/过程结束之际所有在函数中开出的对象（即`Object`）都会被销毁，他们的折析函数会被调用，存储在 `VMT`中的虚函数将会被清空。可能导致210错误（对象未初始化）。

  - *更新中，更多详细内容建议结合源码理解*


- 面向对象Pascal简要说明

  - 对象 `Object`

	  暂无

  - 类 `Class`

	  暂无

  - *更新中，更多详细内容建议结合源码理解*


**关于CommonTypeUnit**

  CommonTypeUnit是一个基础的泛型数据结构库。清一色用Generic Object实现。现在包括List（动态数组）、ListTab（可排序List）、Treap（平衡树）、Queue（链表队列），甚至还提供了KMP字符串匹配、Sunday字符串匹配、字符串分析等基础函数。

  之所以分离出来，是因为其比SA库更为基础，旨在防止不同库中定义的对象被编译器视作不同的对象。

## 初阶

- ### Graph(图片)简介

  Graph是一个很有用的Object。他集成了丰富的函数过程使得操作图片变得容易。

  Graph的像素数据存储在Canvas中，Canvas是一个指针。Canvas的类型是pColor，即^Color。Color是一个{b,g,r,a:Byte}构成的记录体。一般地，访问图像的(x,y)位置是指第x行第y列，其颜色数据存储在Canvas[(x-1)*Width+(y-1)]上。且注意图像的范围是(1,1)~(Height,Width)的。


  以下列举其部分操作：
  - `Width:Longint`	图片的宽
  - `Height:Longint`	图片的高
  - `Canvas:pColor`	图片的像素指针
  - `Create`	创建并初始化
  - `Create(_h,_w:Longint)`	创建一张高为_h，宽为_w的图
  - `Free`	释放图片内存——shy注：基本上所有对象都有该过程，之后有些介绍时会省略，请再三注意以防内存泄漏
  - `Load(Path:Ansistring)`	从给定路径导入一张图片，支持bmp,tga,jpg,png,gif等格式。
  - `SaveTGA/SaveBMP/SavePNG/SaveJPG(Path:Ansistring)`	保存当前图片内容为*格式并输出到给定路径
  - `Bits:Longint`	获得像素字节数
  - `GetP(x,y:Longint):Color`	获得(x,y)处的颜色
  - `SetP(x,y:Longint;c:Color)`	设置(x,y)处的颜色
  - `Fill(x1,y1,x2,y2:Longint;c:Color)`	填充(x1,y1)~(x2,y2)矩形区域的颜色
  - `Cut(x1,y1,x2,y2:Longint):Graph`	复制(x1,y1)~(x2,y2)矩形区域图片为一个新的Graph
  - `Cut:Graph`	复制整个图片为一个新的Graph
  - `Resize(newH,newW:Longint)`	缩放图片
  - `Reverse(_rv:Longint)`	翻转图片,_rv二进制含rev_Horizontal则水平翻转，含rev_Vertival则竖直翻转
  - `inGraph(x,y:Longint):Boolean`	判断像素是否在图片内
  - `Items[i,j]/Items[i,j]:=c`	与GetP、SetP等价，在变量名后Items可忽略

  还有一些对Graph的操作：
  - `Opt_Mask(g:Graph;x1,y1,x2,y2:Single)`	后面4个参数表示的是比例。图片中矩形区域外的内容全变成透明(Color_Alpha,{a=0})
  - `Opt_Scale(g:Graph;x,y:Single)`	后面2个参数表示的是比例。将图片x,y轴缩放
  - `Opt_Alpha(g:Graph;a:Single)`	后面1个参数取值范围[0,1]。将图片透明化
  - `Opt_Rotate(g:Graph;r:Single)`	后面1个参数取值范围[0,360]。将图片旋转(旋转后宽高可能会变化)

- ### 基础的绘制操作

  SimpleAnimeUnit2基于ptc提供了一些底层绘制功能，一般之后的代码中凡使用绘制都不直接调用ptc而是根据以下函数进行的：
  - `Lock`	锁定屏幕像素，并赋给Screen.Canvas。Screen是一个Graph，绘制操作一般都会进行或最终进行到Screen上
  - `UnLock`	解锁屏幕像素。将Screen的内容更新到屏幕
  - `ScreenClear/ScreenClear(c:Color)`	刷屏，默认颜色是黑色(Color_Black,{r=g=b=0,a=255})
  - `DrawTo(pen,goal:Graph;x,y:Longint)`	将pen的内容拷贝到goal中，偏移位置x,y(x=0,y=0表示左上角重合)
  - `BlendTo(pen,goal:Graph;x,y:Longint)`	将pen的内容渲染到goal中，考虑颜色透明度，偏移位置x,y

- ### Stage(舞台)简介

  Stage是一群图片对象的集合，并且含有描述图片对象的元(Element)。

  SA库中自带一个名为Main的Stage。

  Stage的实现是很普遍的"渲染+逻辑"思路。一方面掌握"渲染"，即图形界面的绘制；一方面掌握"逻辑"，即与用户的信息交互和运算。

  接下来快速介绍AnimeObj,AnimeTag,AnimeLog的基本构成与工作原理。

  #### AnimeObj(动画对象)

	描述一张图片参数的Object，主要成员有：
	- `Visible:Boolean`	可见与否
	- `Reverse:Longint`	图像的翻转、二进制位上含rev_Horizontal则水平翻转；二进制位上含rev_Vertical则竖直翻转
    - `BiasX,BiasY:Single`	图像显示的位置
	- `ClipX1,ClipY1,ClipX2,ClipY2:Single`	图像的裁剪
	- `Rotate:Single`	图像的旋转角度,旋转时以图像中心点为旋转中心，取值范围[0,360]
	- `Alpha:Single`	图像的透明度,取值范围[0,1]
	- `ScaleX,ScaleY:Single`	图像的缩放
	- `Source:pBaseGraph`	图像的指针
	- `Inner(x,y:Longint):Boolean`	判断(x,y)是否在经过上述变更后的图像内
	- `Create/Create(a:BaseGraph)/CreateLink(a:BaseGraph)`	创建空对象/创建图片a复制品的对象/创建图片a的对象

  #### AnimeTag(动画标记)

    描述一张图片的动画，主要成员有：
	- `Enable:Boolean`	可用与否
	- `Source:pBaseAnime`	动画的指针、动画当前有SimpleAnime(简单动画)和TimeLineAnime(时间轴动画)
	- `On`	动画启用(Enable=True)
	- `Off`	动画停用(Enable=False)
	- `TotTime:Int64`	动画总时长
	- `StdTime:Int64`	动画开始时刻(以程序开始时算)
	- `AnimeType:ShortInt`	动画类型、atp_normal即只播放一遍；atp_loop即循环播放
	- `AnimeEnd:Boolean`	返回动画是否已结束
	- `Apply(obj:pAnimeObj)`	将动画的当前时刻的参数应用到AnimeObj上
	- `Create/Create(a:BaseAnime)`	创建空动画标记/创建动画a的动画标记

  #### AnimeLog(动画逻辑)

    描述事件发生时当前组合的处理，主要成员有：
	- `Enable:Boolean`	可用于否
	- `MouseEvent:MouseProc`	鼠标事件、MouseProc=Procedure(Env:pSAMACEvent;Obj:pElement;Below:pGraph;Const E:SAMouseEvent;inner:ShortInt);
	- `KeyEvent:KeyProc`	键盘事件、KeyProc=Procedure(Env:pSAMACEvent;Obj:pElement;Below:pGraph;Const E:SAKeyEvent);
	- `NonEvent:NonProc`	无事件、NonProc=Procedure(Env:pSAMACEvent;Obj:pElement;Below:pGraph);

	`SAMouseEvent`的构造是`{x,y,button:Longint;press,release:Boolean}`，分别表示鼠标的行列坐标、鼠标的按键(1=左键,2=右键,4=中键)、鼠标是否按下、弹起

	`SAKeyEvent`的构造是`{key:Longint;press,release,alt,shift,ctrl:Boolean}`，分别表示按键的ASCII码、按键是否按下、弹起、alt,shift,ctrl键是否按下

  #### Element(元素)

    Element即Stage中数组的基本单元，他具体地描述了一张图片应当如何绘制出来。主要成员有：
	- `Role:AnimeObj`	角色，即绘制的主体内容
	- `Acts:AnimeTag`	行为，即动画
	- `Talk:AnimeLog`	交流，即与用户的交互


  Stage可以使绘制变得简易（当然代价是效率会降低）。然后让我们浏览一下Stage中的部分操作：
  - `Create`	创建
  - `Free`	清空
  - `FreeData`	清空并清除记录的图片数据
  - `Size:Longint`	获得当前对象数量
  - `AddObj(_role:BaseGraph)/AddObj(_role:AnimeObj)/AddObj(_role:Element):Longint`	添加一个对象的复制品，返回值为对象的编号
  - `LinkObj(_role:BaseGraph)/LinkObj(_role:Element):Longint`	添加一个对象，返回值为对象的编号
  - `DeleteObj(Id:Longint)`	  终止一个对象
  - `AnimeEnd(Id:Longint)/AnimeAllEnd:Boolean`	询问某个动画/所有动画是否已结束
  - `AnimeBegin(Id:Longint)/AnimeAllBegin`	开始某个动画/所有动画
  - `AttachAnime(Id:Longint;_act:BaseAnime)/AttachAnime(Id:Longint;_act:AnimeTag)`	为编号Id的对象附加动画
  - `AttachLogic(Id:Longint;_log:AnimeLogic)`	为编号Id的对象附加逻辑
  - `Display`	绘制。先添加者先绘制。原理为每次对每个对象复制一份图像，根据参数操作获得结果图，`BlendTo`到Screen上
  - `DisplayDirect`	绘制。与`Display`不同在于参数仅受位置影响且使用`DrawTo`，一般用在效率要求较高的场合
  - `Communication`	交互。后添加者先交互。若得到鼠标事件、键盘事件则触发"注册"的MouseEvent、KeyEvent函数。不论是否有事件都会触发NonEvent


- ### 一些实用的图片简介

  除了Graph，还有一些实用的图片对象被定义在SA2库中。

  #### TextGraph(文字图)

    TextGraph主要用于输出文字，主要成员有：

    - `Text:Ansistring`	文本
	- `FontType:Ansistring`	字体、默认字体是"幼圆"，字体不存在则使用系统默认字体
	- `FontSize:Longint`	字体大小，即文字的像素高度
	- `FontAngle:Single`	字体旋转角度，取值范围[0,360]
	- `FontColor:Color`		字体颜色
	- `Bold,Italic,UnderLine,StrikeOut:Boolean`	分别是粗体、斜体、下划线、删除线
	- `CharSet:DWord`	字符集，常用有EASTEUROPE_CHARSET、GB2312_CHARSET、SHIFTJIS_CHARSET、RUSSIAN_CHARSET
	- `Create/Create(str:Ansistring)`	创建
	- `Update`	当设定过文字的参数后，必须进行Update来更新宽高防止不必要的错误
	- `WriteTo(a:Graph;x,y:Longint)·	在a图(x,y)位置输出当前设定的文本

  #### GroupGraph(组图)

    组图可以依时间绘制一组图片，主要成员有：

	- `Pic:Specialize List<pGraph>`	图片库
	- `Res:Specialize LIst<Int64>`	绘制时间的前缀和
	- `Create`	创建
	- `LoadGIF(Path:Ansistring)`	读取gif图(透明度、时间等已自动适用)
	- `AddPic(a:Graph)/AddPic(a:Graph;b:Int64)`	添加图片，b表示图片显示的延迟时间
	- `Split(a:Graph;n,m,sz:Longint)`	添加图片，把大图分成n×m块，取前sz块小图（可用于一些小游戏获得动图资源）
	- `SetSpTime(_t:Int64)`	集体设置每张图平均延迟显示_t毫秒
	- `GetFrame(Time:Int64)`	获取第Time毫秒正显示的图片

  #### CompressGraph(压缩图)

    压缩图主要用于解决运行时图片内存过大的问题，主要成员有：

	- `Create`	创建
	- `Compress(a:Graph;_cp:Longint)`	压缩a图为_cp格式、cp_non为不压缩；cp_jpg为压缩成jpg图；cp_png为压缩成png图；cp_RLC为使用游程编码压缩
	- `DeCompress():Graph`	解压缩

## 进阶
