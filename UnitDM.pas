unit UnitDM;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.FMXUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FMX.Dialogs, FMX.Controls, System.IOUtils, Types,
  System.UITypes;

type
  TDM = class(TDataModule)
    FDConnection1: TFDConnection;
    FDQueryTovar: TFDQuery;
    FDQuery1: TFDQuery;
    FDQueryNakl: TFDQuery;
    FDQueryZakup: TFDQuery;
    FDQueryRecNakl: TFDQuery;
    procedure FDConnection1BeforeConnect(Sender: TObject);
    procedure UpDateBd(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
   function ConnectToTovar: Boolean;
   function ConnectToAgent: Boolean;
   function ConnectToNakl: Boolean;
   function ConnectToZakup: Boolean;
   function ConnectToRecNakl: Boolean;

  end;

var
  DM: TDM;
const
  BDNameWin : string = 'd:\Tel\BaseSQLite\Test.s3db';

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

uses Unit1
//, Vcl.Forms.TScreen.Cursor
;

{$R *.dfm}

function TDM.ConnectToAgent: Boolean;
var QuerSt : string;
     SaveCursor : TCursor;
begin
try
//    SaveCursor := Screen.Cursor;
//    Screen.Cursor := crHourglass;    { Show hourglass cursor }

    SaveCursor := Form1.Cursor;
    Form1.Cursor := crSQLWait;    { Show  cursor }

    QuerSt:= 'Select ProizvName from Proizv where (Activ=1) Order By  ProizvName';
    FDQuery1.Close;
    FDQuery1.Sql.Clear;
    FDQuery1.Sql.Add(QuerSt);

  FDQuery1.Open;
  FDQuery1.First;
  while not FDQuery1.Eof do begin
    if FDQuery1.FieldByName('ProizvName').AsString<>'' then
      Form1.ComboBoxProizv.Items.Add(FDQuery1.FieldByName('ProizvName').AsString)
    else
     Form1.ComboBoxProizv.Items.Add(AllProizv);
    FDQuery1.Next;
  end;

    QuerSt:= 'Select AgentName from Agent where (Activ=1) Order By AgentName';
    FDQuery1.Close;
    FDQuery1.Sql.Clear;
    FDQuery1.Sql.Add(QuerSt);

  FDQuery1.Open;
  FDQuery1.First;
  while not FDQuery1.Eof do begin
   if FDQuery1.FieldByName('AgentName').AsString<>'' then begin
    Form1.ComboBoxAgent.Items.Add(FDQuery1.FieldByName('AgentName').AsString);
    Form1.ComboBoxAgentFrom.Items.Add(FDQuery1.FieldByName('AgentName').AsString);
    Form1.ComboBoxAgentTo.Items.Add(FDQuery1.FieldByName('AgentName').AsString);
    Form1.ComboBoxAgentZakup.Items.Add(FDQuery1.FieldByName('AgentName').AsString);
   end
   else begin
    Form1.ComboBoxAgent.Items.Add(AllAgentFrom);
    Form1.ComboBoxAgentFrom.Items.Add(AllAgentFrom);
    Form1.ComboBoxAgentTo.Items.Add(AllAgentFrom);
    Form1.ComboBoxAgentZakup.Items.Add(AllAgentFrom);
   end;

    FDQuery1.Next;
  end;

    QuerSt:= 'Select NaklName from NaklName';
    FDQuery1.Close;
    FDQuery1.Sql.Clear;
    FDQuery1.Sql.Add(QuerSt);

  FDQuery1.Open;
  FDQuery1.First;
  while not FDQuery1.Eof do begin
    if FDQuery1.FieldByName('NaklName').AsString<>'' then
      Form1.ComboBoxNaklName.Items.Add(FDQuery1.FieldByName('NaklName').AsString)
    else
      Form1.ComboBoxNaklName.Items.Add(AllNakl);
    FDQuery1.Next;
  end;
  FDQuery1.Close;

//  Form1.ComboBoxNaklName.ItemIndex:=0;
//  Form1.ComboBoxAgent.ItemIndex:=0;

except
      on E: Exception do
      begin
//      ApplicationShowException(E);
//      ('��� ����������� � ���� ��������� ������. '+ E.Message);
   ShowMessage('������ '+FDConnection1.Params.Values['Database']);
      end;
end;
 Result:= True;
 // Screen.Cursor := SaveCursor;  { Always restore to normal }

 Form1.Cursor := SaveCursor;
 // Form1.Cursor := crDefault;

end;

function TDM.ConnectToTovar: Boolean;
var I : Integer;
     SaveCursor : TCursor;

begin
    SaveCursor := Form1.Cursor;
    Form1.Cursor := crSQLWait;    { Show  cursor }

try
//  Form1.Pb1.Visible:= True;
//  Form1.Timer1.Enabled:=True;
(*Select T.TovarName,T. Fasovka, P.ProizvName, A.AgentName, T.ZenaRozn, T.ZenaZakupka,(T.ZenaRozn-T.ZenaZakupka)/T.ZenaRozn*100 as PerC
from Tovar T, Proizv P, Agent A
where( T.ProizvCod=P._id) and (T.AgentCod=A._id)


Order By  T.TovarName,T.Fasovka, P.ProizvName
*)
  FDQueryTovar.Open;

except
      on E: Exception do
      begin
      ApplicationShowException(E);
//      ('��� ����������� � ���� ��������� ������. '+ E.Message);
//   ShowMessage('������ '+FDConnection1.Params.Values['Database']);
      end;
end;
 Result:= True;
 Form1.StringGridTovarSet;
 //  if Form1.StringGridTovar.ColumnCount>5 then
//    Form1.StringGridTovar.Columns[6].Width:=50;

//  Form1.Pb1.Visible:= False;
//  Form1.Timer1.Enabled:=False;

  Form1.Cursor := SaveCursor;

end;

function TDM.ConnectToNakl: Boolean;
var      SaveCursor : TCursor;

begin
(*
Select  N.DocN, N.DocDate, N.'Sum'
, AFrom.AgentName                 1
, ATo.AgentName                   2
,  N.Pr,  N._id
from Nakl N                       4
, Agent AFrom                     5
, Agent ATo                       6

where (N.Kind=1)                  8
and (N.AgentCodFrom=AFrom._id)    9
and (N.AgentCodTo=ATo._id)        10

Order By N.DocDate                12
*)
    SaveCursor := Form1.Cursor;
    Form1.Cursor := crSQLWait;    { Show  cursor }

//    Form1.Pb1.Visible:= True;
//    Form1.Timer1.Enabled:=True;

try
//  Form1.Pb1.Visible:= True;
//  Form1.Timer1.Enabled:=True;

  FDQueryNakl.Close;
  FDQueryNakl.Sql[2]:= '';
  FDQueryNakl.Sql[6]:= '';
  FDQueryNakl.Sql[10]:= '';

  FDQueryNakl.Open;
  FDQueryNakl.Last;

except
      on E: Exception do
      begin
        ApplicationShowException(E);
      end;
end;
 Result:= True;
  Form1.StringGridNaklSet;

//  Form1.Pb1.Visible:= False;
//  Form1.Timer1.Enabled:=False;

  Form1.Cursor := SaveCursor;

 end;


function TDM.ConnectToZakup: Boolean;
var      SaveCursor : TCursor;
begin
(*
SELECT T.TovarName, T.Fasovka, P.ProizvName,
               Rec.Zena as ����,
               N."DocDate" as ����,
               A.AgentName,
               N.DocN  as N��,
               Rec.Kolvo as �����,
               (Rec.Kolvo*Rec.Zena) as �����

From     Nakl N, RecNakl Rec, Tovar T, Proizv P,  Agent A


where   N._id=Rec.NaklCod  and N.Kind=1  and Rec.TovarCod=T._id
             and T.ProizvCod=P._id
             and N.AgentCodFrom=A._id

Order by  T.TovarName, T.Fasovka, P.ProizvName, N."DocDate"

*)
    SaveCursor := Form1.Cursor;
    Form1.Cursor := crSQLWait;    { Show  cursor }
try
//  Form1.Pb1.Visible:= True;
//  Form1.Timer1.Enabled:=True;

  FDQueryZakup.Close;

  FDQueryZakup.Open;

except
      on E: Exception do
      begin
        ApplicationShowException(E);
      end;
end;
 Result:= True;

  Form1.StringGridZakupSet;

//  Form1.Pb1.Visible:= False;
//  Form1.Timer1.Enabled:=False;
  Form1.Cursor := SaveCursor;
end;

function TDM.ConnectToRecNakl: Boolean;
var      SaveCursor : TCursor;

begin
(*
SELECT Rec.N, T.TovarName, T.Fasovka, P.ProizvName,
		 Rec.Kolvo,
     Rec.Zena,
		 (Rec.Kolvo*Rec.Zena) as ����

From   RecNakl Rec,
		 Tovar T, Proizv P

where Rec.TovarCod=T._id and T.ProizvCod=P._id and
		 Rec.NaklCod=0


Order By Rec.N

*)
   SaveCursor := Form1.Cursor;
   Form1.Cursor := crSQLWait;    { Show  cursor }
try
  FDQueryRecNakl.Close;

  FDQueryRecNakl.Open;

except
      on E: Exception do
      begin
        ApplicationShowException(E);
      end;
end;
 Result:= True;
 Form1.Cursor := SaveCursor;

end;

procedure TDM.FDConnection1BeforeConnect(Sender: TObject);
begin
{$IFDEF MSWINDOWS}
   FDConnection1.Params.Values['Database'] := BDNameWin;
{$ENDIF}

{$IFDEF ANDROID}
  FDConnection1.Params.Values['Database'] :=
    System.IOUtils.TPath.GetPublicPath+System.SysUtils.PathDelim + 'Test.s3db';
{$ENDIF}

 // ���� ����������� ����� ���������� ��, �� ��������� ����� �� �� ��������� ������
 // ���� ���� ��� �������������� �������  FDConnection1.Connected := � False
 // � ��������� ��� ����������

  // FDConnection1.Connected := True;

   UpDateBd(Sender);
end;

procedure TDM.UpDateBd(Sender: TObject);
Const Test: Boolean=False;
var BDDownLoadName, DBDownLoadPath, BDName  : string;
     BDDownLoadTime, BDTime : TDateTime;
     SDA :  TStringDynArray;  // in unit Types
     i : Integer;
     Finded : Boolean;


procedure CopyDB;
  begin
  if Test then ShowMessage('���� ����������');
  //���� ��� ����.����� ����� ��� � ����������� �� �� GetCreationTime
   BDDownLoadTime:= TFile.GetCreationTime (BDDownLoadName);   // GetLastWriteTime
   BDTime        := TFile.GetCreationTime (BDName);  // GetLastWriteTime
   if BDDownLoadTime> BDTime then
   begin
      if Test then
        ShowMessage('���� BD '+BDDownLoadName+' from �������� '+DateTimeToStr(BDDownLoadTime)+
        ' ����� ������� ���� '+   DateTimeToStr(BDTime)+' '+BDName+' ���������');
     //������� ���. ��
     TFile.Delete( FDConnection1.Params.Values['Database'] );
     //�������� �� �� ����� ���� �� �� ����� DownLoad
     TFile.Copy(BDDownLoadName, BDName, true);
     Finded := True;
   end
   else
    if Test then
     ShowMessage('���� BD '+BDDownLoadName+' from �������� '+DateTimeToStr(BDDownLoadTime)+
   ' �� ����� ������� ���� '+   DateTimeToStr(BDTime)+' '+BDName);
   // ����� ������ ����, ������������� ����� � apk, = ������� ���������
   // GetLastWriteTime ����� ������ ����, ��� ��������� ������� = ������� �������
   // GetCreationTime ����� ������ ����, ��� ��������� ������� = ������� ���������
   //���� ���� � �������� ����� =>  ����� ������ ���� ���������� = ������� �������
   //�� ��������� �� ����������
  end;

begin
(*
Deployment
 All-Configurations - Android platform and make sure Employees.s3db is set to be deployed to
 StartUp\Documents\ for iOs
  or assets\internal\ for Android

  if not System.IOutils.TFile.Exists(DBFileName) then
    ShowMessage('���� ���-�� �������');

*)


{$IFDEF ANDROID}
// I deployed to assets\, not to assets\internal\
  BDName := System.IOUtils.TPath.GetPublicPath+System.SysUtils.PathDelim + 'Test.s3db';
  //���� FDConnection1.Params.Values['Database'] :=   BDName;
  //  ����������� ����� ���������� ��, �� ��������� ����� �� �� ��������� ������

// ��������� ���� �� ���� �� � ����� DownLoad
//  GetDownLoadsPath ��������� �� ����� ������ ������ ���������� +DownLoad
//  GetSharedDownloadsPath ��������� �� ����� ����� DownLoad  �� Android 4.4 ��� ��������
// �� ����� Android 9 ���� �� ������������ �� ����� ��������= /storege/emulated/0/download
  BDDownLoadName:= System.IOUtils.TPath.GetSharedDownloadsPath+System.SysUtils.PathDelim + 'Test.s3db';
  if Test then ShowMessage('��������� ������� ����� BD '+BDDownLoadName);
  //GetDirectories

  Finded := False;
  if TFile.Exists(BDDownLoadName) then CopyDB;
  // if file BD was loaded then in CopyDB Finded:= True;

(*
  if not Finded then begin
  // ����� ����� � ����� Bluetooth
  //  BDDownLoadName:= System.IOUtils.TPath.GetSharedDownloadsPath+System.SysUtils.PathDelim+'Bluetooth'+
  //                     System.SysUtils.PathDelim+ 'Test.s3db';

  // seach it subpath
    SDA:= TDirectory.GetDirectories(System.IOUtils.TPath.GetSharedDownloadsPath);

    for I := 0 to High(SDA) do
      if not Finded then
      begin
        BDDownLoadName:= System.IOUtils.TPath.GetSharedDownloadsPath+System.SysUtils.PathDelim +
          SDA[i]+ System.SysUtils.PathDelim +
          'Test.s3db';

        if TFile.Exists(BDDownLoadName) then CopyDB;
      end;

  end;
*)

// ���� �� HighScreen
//  FDConnection1.Params.Values['Database'] :='/mnt/sdcard/Android/data/com.embarcadero.ProjectMuDeTest/files/Test.s3db';
// ��� ���� ��������� �� ���� � ���� �����
// /mnt/sdcard
// /sdcard
// /storege/sdcard0

//  FDConnection1.Params.Values['Database'] :=TPath.Combine(TPath.GetDocumentsPath +'Test.s3db');
//TPath ���� ������ ��� ���������

// if I deployed to assets\internal\ -->  GetDocumentsPath
//http://delphifmandroid.blogspot.ru/2014/02/deployment-manager.html?m=1

//  FDConnection1.Params.Values['Database'] :=System.IOUtils.TPath.GetDocumentsPath+System.SysUtils.PathDelim +'Test.s3db';
// GetDocumentsPath=/data/data/com.embarcadero.ProjectMuDeTest/files
  // '$(DOC)/Test.s3db';


{$ENDIF}
//������� �� ���� ��� ������� ���� ���� � �����=
// /mnt/sdcard/Android/data/com.embarcadero.ProjectMuDeTest/files
//  ����� ������� ���������� ���� com.embarcadero.ProjectMuDeTest/files/Test.s3db
// � �������� �������
//
// ����� �������� ���� ��� ������ "������� ������", ���� �� ���������
//  "������� ������" ������� �����= /mnt/sdcard/Android/data/com.embarcadero.ProjectMuDeTest

(* ��� ��������� ����� ������ ��������� � ����� ����������� �����
���� ���� �� �����������. �� �������� �������� ������ ����.
����� �������� ���� ���� ������ ������������ ������� ���� ����
*)

// getExternalFilesDirs;
// Environment.getExternalStorageDirectory()  ���������� ������� ������
// getExternalSdCardPath
end;

initialization
//  if DM.ConnectToDB then;

finalization

end.
