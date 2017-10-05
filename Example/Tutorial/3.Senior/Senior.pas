//��δ�����������SimpleAnimeUnit�̵̳�Senior.pas
uses SimpleAnimeUnit2,SysUtils;
Var
 b:GroupGraph;
 a:SimpleAnime;    //���׵Ķ���
 u:AnimeObj;       //AnimeObj���Ա��
 v:AnimeTag;       //AnimeTag�������
 w:AnimeLog;       //AnimeLog�߼����
//��ȻSA2��ĳ��Բ���������Ϸ
//����Ϊ��Ϸ�����ġ���Ⱦ�����߼���������е�
//ǰ���Basic��Junior���ڽ���Ⱦ��Ҳ����ͼ�λ��ƣ�
//��ξͽ��߼���Ҳ�����û�������Ϣ��

 Id:Longint;


 c:TextGraph;

 Procedure DealMouse(Env:pElement;Below:pGraph;Const E:SAMouseEvent;inner:ShortInt);
//���������һ��MouseProc���������ĸ�ʽ��������
//Env��Element��ָ�룬Element��{Role=AnimeObj,Acts=AnimeTag,Talk=AnimeLog}
//Below���µ���Graph��ָ��
//ע��ǰ�õ�Env,Below��SA2�б���Ϊ�Ǳ�׼�ı�Ҫ��������
//SAMouseEvent��һ�����ɵ������Ϣ��¼
//Longint���͵�E.x,E.y��ʾ���λ�ã�E.button��ʾ���״̬�����������λ1����1��ʾ������
//Boolean���͵�E.press��ʾ��갴�£���˲�䣩��E.release��ʾ��굯�𣨵�˲�䣩
//inner��ʾ�Ƿ���ͼƬ�ڣ����������λ1����1��ʾ���ǡ��������ͼƬ��ָͼƬ�ĸ�Ӧ����
 Begin
  if (E.button and 1=1)and(E.press)and(inner and 1=1) then
   Env^.Role.Alpha:=1.5-Env^.Role.Alpha   //�����������ͼƬ�ϰ����ˣ��ͱ仯ͼƬ��͸����
 End;

Begin
 b.Create;
 b.LoadGIF('SeniorTest.gif');

 u.Create(b);        //u�����ԣ�ͨ��һ��ͼƬ����
 u.SetXY(100,10);    //�����ڴ����е�λ����(X=100,Y=10)

 a.Create;                    //SimpleAnime�Ǽ��׵Ķ��������԰����ɸ�������һ��ʱ������ĳ�ֹ��ɱ仯
 a.SetRotate(360,tp_Line);    //��������ת360��
 a.SetXY(0,200,tpb_Sin);      //��Sin��������ƽ��200������
 a.SetType(atp_loop);         //����ѭ������
 a.SetTime(2500);             //���һ�ζ�����ʱ2.5��

 v.Create(a);                 //v�Ƕ���

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
 Until (Not ConsoleUsing)Or(TestKeyPress)
End.
