uses SimpleAnimeUnit2,MMDDeal,PMDDeal,VMDDeal;
//����BUG���޲�
//SA2���ṩOpenGL���ƻ���
//MMDDeal�ṩ����Ĳ���������Ƶ�Ԥ������ͷ�ļ���
//PMDDeal�ṩģ�͵Ķ�ȡ�ͱ任
//VMDDeal�ṩ�����Ķ�ȡ
Var
 Model:PMDFormat;     //Pmdģ��
 Motion:VMDFormat;    //Vmd����
 Frame:int64;         //���㵱ǰ֡
Begin
 OpenGLInit('MMDTest_Demo',700,700);      //ע��������OpenGLInit���Init��˫�������
 Model.Load('Model\Remu.pmd');            //���ε�pmdģ��
                                          //ע��·���������ͼ���ز�Ĭ����ͬ·���»�ȡ
 Motion.Load('Motion\DeepSeaGirl.vmd');   //���Ů��vmd����
                                          //vmd��ͷ���2017/9/13����֧��
                                          //������ѧ��ccd�㷨����������
                                          //����������

 Model.RegisterMotion('DSG',@Motion);     //ע�ᶯ������'DSG'��Ϊ����
                                          //����ͬmmd��Ӧ��ͬ������
 Repeat
  Frame:=DeltaTime*3 div 100;             //ÿ��30֡
  Model.ApplyMotion('DSG',Frame);         //��������Ϊ��Frame֡
  MMDCamera.Communication;                //Camera����ͷ������
  MMDDraw(Model);                         //����
 Until Console.Keypressed
End.