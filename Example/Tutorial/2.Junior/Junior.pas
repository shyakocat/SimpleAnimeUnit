//��δ�����������SimpleAnimeUnit�̵̳�Junior.pas
uses SimpleAnimeUnit2;
Var
 a:Graph;
 b:GroupGraph;      //GroupGraph��ͼ
 c:TextGraph;       //TextGraph����
Begin
 a.Create;
 a.Load('JuniorTest.png');
 b.Create;
 b.LoadGIF('JuniorTest.gif');   //��ͼ����ͨ���������Graph������Ҳ����ֱ�Ӷ�ȡgif
 c.Create('����GB2312����__how??');

 Main.AddObj(a);
 Main.AddObj(b);
 Main.AddObj(c);
//Main��һ��Stage����̨������
//������AddObj������Stage���������

 Init('Junior',a.Width,a.Height);
//Gif�Ƕ�ͼ������ֻ���Ƶ����ǲ��еģ�Ҫ��ͣ�ظ�����Ļ
 Repeat
  Lock;
  ScreenClear(Color_White);  //��Screenȫ���ɰ�ɫ��Color��һ������BGRA�����ͣ�Color_White��(r=g=b=a=255)
  Main.Display;              //��Main���Stage�е��������λ��Ƴ���
  UnLock;
 Until (Not ConsoleUsing)Or(TestKeypress)    //ֱ���û���������ֹ
                                 //Console.KeyPressed�ǲ��õģ���������SA2��ֱ�ӷ���PTC������
                                 //��ΪConsole�����ڣ�һ���رպ�ʹ��Console.KeyPressed�ᱨ��
                                 //��������֮ǰʹ��SA2�ṩ��ConsoleUsing����ⴰ�ڵ�ʹ�����
End.