uses SimpleAnimeUnit2,MMDDeal,PMDDeal,VMDDeal;
//更多BUG待修补
//SA2可提供OpenGL绘制环境
//MMDDeal提供方便的操作，如绘制的预处理、镜头的计算
//PMDDeal提供模型的读取和变换
//VMDDeal提供动作的读取
Var
 Model:PMDFormat;     //Pmd模型
 Motion:VMDFormat;    //Vmd动作
 Frame:int64;         //计算当前帧
Begin
 OpenGLInit('MMDTest_Demo',700,700);      //注：必须以OpenGLInit替代Init，双缓冲绘制
 Model.Load('Model\Remu.pmd');            //灵梦的pmd模型
                                          //注意路径，相关贴图、素材默认在同路径下获取
 Motion.Load('Motion\DeepSeaGirl.vmd');   //深海少女的vmd动作
                                          //vmd镜头如今（2017/9/13）不支持
                                          //反向动力学的ccd算法计算有问题
                                          //无物理引擎

 Model.RegisterMotion('DSG',@Motion);     //注册动作并以'DSG'作为代号
                                          //规则同mmd仅应用同名动作
 Repeat
  Frame:=DeltaTime*3 div 100;             //每秒30帧
  Model.ApplyMotion('DSG',Frame);         //动作设置为第Frame帧
  MMDCamera.Communication;                //Camera（镜头）计算
  MMDDraw(Model);                         //绘制
 Until Console.Keypressed
End.