# SimpleAnimeUnit

Simple Pascal GUI Assistant    
简易Pascal图形界面辅助库    

## 前言

**SA库的初衷、作用、简介、前身**

  SimpleAnimeUnit2，正如其名——是一个shyakocat使用Pascal语言编写的一个支持简易图形界面的库。
 
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
  
  > 指针
  
	  Pointer，Pascal中泛用的指针。一般地，我们认为指针是一个4字节的指示地址的变量。
		
      指针p可以用GetMem(p,字节数)来申请一段连续且内容随机的内存；这里的GetMem是智能的，只有在使用到的时候才开出内存。
		
	  用FreeMem(p)来释放内存，FreeMem(p)必须保证p是指向有效内容的。
		
	  如果需要一段全部为0的内存则可用p:=AllocMem(字节数)。
		
	  p^表示指针指向的内容。对指针填充可以用FillChar(p^,字节数,填充字符)。这里FillChar按经验认为是比较快的。
		
	  将一段内存p复制到q可以用Move(p^,q^,字节数)。这里Move也是智能的，通常只有修改的时候才会进行复制，仅读取则依赖指针计数引用。
		
	  指针也可以通过Type  pint=^Longint;  pchar=^Char;这种形式定义出来，这样定义的指针是针对性的，但一般可以和pointer隐式转换。
		
	  我们假定p是一个^Longint，那么他是一个longint的指针。上述pointer的操作依然适用。
		
	  可以用p^读写longint的值，用p[i]或(p+i)^来类似数组地读写该指针后连续第i个longint变量的值。
		
	  特殊地，定义A:array[0..N]of longint，A实质上是一个指针。
		
	  New(p)可以新建一个longint变量（Pint的话是4字节，如果Pchar的话是1字节，依此类推），Dispose(p)可以销毁一个longint变量。
	
	
   > *更新中，更多详细内容建议结合源码理解*
	
  
- 面向对象Pascal简要说明


  > 对象 Object
  
	  暂无
	
	> 类 Class
  
	  暂无
	
	> *更新中，更多详细内容建议结合源码理解*
	

**关于CommonTypeUnit**

  CommonTypeUnit是一个基础的泛型数据结构库。清一色用Generic Object实现。现在包括List（动态数组）、ListTab、Treap（平衡树）、Queue（链表队列），甚至还提供了KMP字符串匹配、Sunday字符串匹配、字符串分析等基础函数。
  
  之所以分离出来，是因为其比SA库更为基础，旨在防止不同库中定义的对象被编译器视作不同的对象。
  
## 初阶

- Graph简介
  
  Graph是一个很有用的Object。他集成了丰富的函数过程使得操作图片变得容易。以下列举其部分操作：
  - `Width:Longint`	图片的宽
  - `Height:Longint`	图片的高
  - `Canvas:pColor`	图片的像素指针，pColor是Color的指针。Color是一个{b,g,r,a:Byte}组成的记录体
  - `Create`	创建并初始化
  - `Create(_h,_w:Longint)`	创建一张高为_h，宽为_w的图
  - `Load(Path:Ansistring)`	从给定路径导入一张图片，支持bmp,tga,jpg,png,gif等格式。
  - `SaveTGA/SaveBMP/SavePNG/SaveJPG(Path:Ansistring)`	保存当前图片内容为*格式并输出到给定路径
  - `Bits:Longint`	获得像素字节数
  - `GetP(x,y:Longint):Color`	获得(x,y)处的颜色，图片范围是(1,1)~(Height,Width)
  - `SetP(x,y:Longint;Const c:Color)`	设置(x,y)处的颜色
  - `Fill(x1,y1,x2,y2:Longint;Const c:Color)`	填充(x1,y1)~(x2,y2)矩形区域的颜色
  - `Cut(x1,y1,x2,y2:Longint):Graph`	复制(x1,y1)~(x2,y2)矩形区域图片为一个新的Graph
  - `Cut:Graph`	复制整个图片为一个新的Graph
  - `Resize(newH,newW:Longint)`	缩放图片
  - `Reverse(_rv:Longint)`	翻转图片,_rv二进制含rev_Horizontal则水平翻转，含rev_Vertival则竖直翻转
  - `inGraph(x,y:Longint):Boolean`	判断像素是否在图片内
  - `Items[i,j]/Items[i,j]:=c`	与GetP、SetP等价，在变量名后Items可忽略
