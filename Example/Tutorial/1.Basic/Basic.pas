//��δ�����������SimpleAnimeUnit�̵̳�Basic.pas
//���ʼ˵��һ�£�����ʹ��FP3.0.2
//ʹ�ù�������PTCError���⣬��Exe�ļ���������
//��������Ҫ�Ѹ�Ŀ¼����Ϊ�ô�������Ŀ¼���У�������ȡ����ͼƬ
//�����SA2�������ô���ͬһĿ¼��
uses SimpleAnimeUnit2;   //����SimpleAnimeUnit2��
Var
 a:Graph;   //Graph��SA2���к����õ�һ�����ͣ���ͼƬ����˼
Begin
 a.Create;  //��ʼ��
 a.Load('BasicTest.Jpg');         //����ͼƬ
 Init('Basic',a.Width,a.Height);  //�������ڣ��趨���ơ�����
 Lock;                    //��ͼǰ������������
 DrawTo(a,Screen,0,0);    //��ͼƬa���Ƶ�Screen�ϣ�ScreenҲ��Graph������ָ��ָ����Ļ����
 UnLock;                  //���ƺ�������ܸ�����Ļ������
 GetClose                 //�ȴ��û��رմ���
End.
