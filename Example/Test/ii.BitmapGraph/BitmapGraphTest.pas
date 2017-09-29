//��������������SA2�⼰SAKit��Ĳ��Դ����BitmapGraphTest.pas
//��Ҫ�ο���ַ��http://www.cnblogs.com/yangdanny/p/4634536.html
//������ϤWinApi�ߣ�����GDI�еĻ��Ʒ�ʽ��GradientFill�ȿ�����д��
Uses SimpleAnimeUnit2,SAKitUnit,Windows;
Var
 b:BitmapGraph;      //�豸����������
 c:TextGraph;
 i:Longint;

 Pt:Array[0..3]Of Point=((X:90;Y:130),(X:60;Y:40),(X:140;Y:150),(X:160;Y:80));
// Pl:Array[0..4]Of Point=((X:
Begin
 b.Create(400,360);  //BitmapGraph��ֱ�ӹ�����Create��һ���ض���С��ȫ��ͼ
                     //Ҳ����Graph������������ʧ͸���ȣ�
//ֵ��ע����ǣ���SA����Graph�ķ��ͬ
//BitmapGraph�����в��������������к��еģ���ɫ��COLOREF������ΪLongint��
 b.Fill(0,0,b.Width,b.Height,RGB(255,255,255));  //�������Ϊĳɫ

 For i:=1 to 10 Do
  b.SetPixel(i*4,10,RGB(0,0,0));                           //�������ػ��ƣ���Ч�ʲ�����ʹ��
 b.DrawLine(120,30,200,30,PS_SOLID,2,RGB(0,0,0));          //�����������趨��ĩλ�á���ʽ����ϸ����ɫ
 b.DrawLine(120,50,200,50,PS_DASH,1,RGB(100,0,200));
 b.DrawLine(120,70,200,70,PS_DASHDOT,1,RGB(100,250,100));  //��ͬ��ʽ������

 b.DrawArc(10,30,40,50,40,30,10,40,RGB(10,255,255),RGB(0,0,0));    //���ƻ��ߣ��������������ֱ������ɫ������ɫ
 b.DrawChord(10,60,40,80,40,60,10,70,RGB(10,255,255),RGB(0,0,0));  //�����Ҹ���
 b.DrawPie(10,90,40,110,40,90,10,100,RGB(10,255,255),RGB(0,0,0));  //���Ʊ�ͼ

 b.DrawCircle(100,180,30,RGB(0,250,250),RGB(255,255,255));                    //����Բ
 b.DrawEllipse(Pt[0].x,Pt[0].y,Pt[1].x,Pt[1].y,RGB(128,128,128),RGB(0,0,0));  //������Բ
 b.DrawRect(Pt[2].x,Pt[2].y,Pt[3].x,Pt[3].y,RGB(90,90,90),RGB(255,0,255));    //���ƾ���
 b.DrawPolygon(@Pt,4,1,RGB(255,255,128),RGB(10,20,30));                       //���ƶ����
 b.DrawBezier(@Pt,4,1,RGB(0,0,0));                                            //���Ʊ���������
 b.DrawCircle(Pt[0].x,Pt[0].y,8,RGB(0,255,0),RGB(0,0,0));                     //������������ߵ��ĸ�ê��
 b.DrawCircle(Pt[1].x,Pt[1].y,8,RGB(0,0,255),RGB(0,0,0));
 b.DrawCircle(Pt[2].x,Pt[2].y,8,RGB(0,0,0),RGB(0,0,0));
 b.DrawCircle(Pt[3].x,Pt[3].y,8,RGB(255,0,0),RGB(0,0,0));


 b.DrawRect(220,20,280, 60,HS_BDIAGONAL,RGB(255,0,0),RGB(10,10,10));    //���Ʋ�ͬģʽ�ľ���
 b.DrawRect(220,80,280,120,HS_CROSS    ,RGB(0,255,0),RGB(10,10,10));
 b.DrawRect(290,20,350, 60,HS_DIAGCROSS,RGB(0,0,255),RGB(10,10,10));
 b.DrawRect(290,80,350,120,HS_VERTICAL ,RGB(0,0,0)  ,RGB(10,10,10));

 b.DrawBmp(180,140,360,240,'SABitmapTest.bmp');    //����λͼ

 b.DrawText(20,220,'Program Sample����',18);       //��������
 c.Create('����TextGraph��');
 b.DrawText(20,240,c);



 Init('SAK-BitmapGraphTest',b.Width,b.Height);
 Main.AddObj(b);
 Lock;
 Main.Display;
 UnLock;

 GetClose

End.
