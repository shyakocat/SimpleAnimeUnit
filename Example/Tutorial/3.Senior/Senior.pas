//��δ�����������SimpleAnimeUnit�̵̳�Senior.pas
uses SimpleAnimeUnit2,SysUtils;
Var
 b:GroupGraph;
 u:AnimeObj;       //AnimeObj���Ա��
 v:AnimeTag;       //AnimeTag�������
 w:AnimeLog;       //AnimeLog�߼����
//��ȻSA2��ĳ��Բ���������Ϸ
//����Ϊ��Ϸ�����ġ���Ⱦ�����߼���������е�
//ǰ���Basic��Junior���ڽ���Ⱦ��Ҳ����ͼ�λ��ƣ�
//��ξͽ��߼���Ҳ�����û�������Ϣ��

 Id:Longint;


 c:TextGraph;

 Procedure DealMouse(obj:pAnimeObj;tag:pAnimeTag;x,y,button,inner,press,release:Longint);
//���������һ��MouseEvent���������ĸ�ʽ��������
//x,y��ʾ���λ��
//button��ʾ���״̬�����������λ1����1��ʾ������
//inner��ʾ�Ƿ���ͼƬ�ڣ����������λ1����1��ʾ���ǡ��������ͼƬ��ָͼƬ�ĸ�Ӧ����
//pressΪ1��ʾ����
//releaseΪ1��ʾ����
 Begin
  if (button and 1=1)and(press=1)and(inner and 1=1) then
   obj^.Alpha:=1.5-obj^.Alpha   //�����������ͼƬ�ϰ����ˣ��ͱ仯ͼƬ��͸����
 End;

Begin
 b.Create;
 b.LoadGIF('SeniorTest.gif');

 u.Create(b);        //u�����ԣ�ͨ��һ��ͼƬ����
 u.SetXY(100,10);    //�����ڴ����е�λ����(X=100,Y=10)

 v.Create;                    //v�Ƕ���
 v.SetRotate(360,tp_Line);    //��������ת360��
 v.SetXY(0,200,tpb_Sin);      //��Sin��������ƽ��200������
 v.SetType(atp_loop);         //����ѭ������
 v.SetTime(2500);             //���һ�ζ�����ʱ2.5��

 w.Create;                    //w���߼�
 w.MouseEvent:=@DealMouse;    //ע�ắ������������¼�ʱ����DealMouse

 Id:=Main.AddObj(u);          //AddObj��ʵ�Ǹ�����������ֵ������Stage�еı��
 Main.AttachAnime(id,v);      //Ϊ�丽�϶���
 Main.AttachLogic(id,w);      //Ϊ�丽���߼�

 c.Create;
 c.FontColor:=Color_White;    //����������ɫΪ��ɫ

 Init('Senior',b.Width*2,b.Height*2);
 Repeat
  Lock;
  ScreenClear;         //ScreenClear�޲��������ú�ɫ���
  Main.Communication;  //Communication�Ǵ����߼�
  Main.Display;        //Display�Ǵ�����Ⱦ
  c.SetText(IntToStr(NowFPS));    //NowFPS�����ڵ�֡����α֡����
                                  //�ı��ı�������c.Text:=...����Ҫ��c.SetText(...)
                                  //��Ϊ�ı�������ص���ϢҲҪ�䣬ͬ��ı��СҪc.SetSize()
  c.WriteTo(Screen,1,1);          //��֡��д��Screen��(1,1)λ����
  UnLock;
 Until (Not ConsoleUsing)Or(Console.Keypressed)
End.