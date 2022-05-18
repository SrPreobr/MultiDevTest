unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client, FMX.StdCtrls,
  FMX.Controls.Presentation,
  UnitDM, System.Rtti, Data.Bind.EngExt, Fmx.Bind.DBEngExt, Fmx.Bind.Grid,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.Components,
  Data.Bind.Grid, Data.Bind.DBScope, FMX.Layouts, FMX.Grid, FMX.ListBox,
  FMX.TabControl, FMX.Gestures,
  FMX.Header, FMX.Ani, FMX.Grid.Style, FMX.ScrollBox
  ;

type
  TForm1 = class(TForm)
    GestureManager1: TGestureManager;
    GroupBox2: TGroupBox;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    GroupBox1: TGroupBox;
    ComboBoxProizv: TComboBox;
    ComboBoxAgent: TComboBox;
    TabItem2: TTabItem;
    GroupBox3: TGroupBox;
    ComboBoxAgentFrom: TComboBox;
    ComboBoxAgentTo: TComboBox;
    Label1: TLabel;
    ComboBoxNaklName: TComboBox;
    StringGridNakl: TStringGrid;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    BindSourceDB2: TBindSourceDB;
    TabItem3: TTabItem;
    GroupBox4: TGroupBox;
    ComboBoxAgentZakup: TComboBox;
    StringGridZakup: TStringGrid;
    BindSourceDB3: TBindSourceDB;
    LinkGridToDataSourceBindSourceDB3: TLinkGridToDataSource;
    TabItem4: TTabItem;
    StringGridRecNakl: TStringGrid;
    BindSourceDB4: TBindSourceDB;
    LinkGridToDataSourceBindSourceDB4: TLinkGridToDataSource;
    GroupBox6: TGroupBox;
    Label2: TLabel;
    StringGridTovar: TStringGrid;
    lnkgrdtdtsrcBindSourceDB: TLinkGridToDataSource;
    procedure ComboBoxChangeTovar(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormGesture(Sender: TObject;
      const [Ref] EventInfo: TGestureEventInfo; var Handled: Boolean);
    procedure ComboBoxChangeNakl(Sender: TObject);
    procedure TabControl1Change(Sender: TObject);
    procedure ComboBoxAgentZakupChange(Sender: TObject);
    procedure StringGridNaklDblClick(Sender: TObject);
    procedure StringGridNaklLongTap(Sender: TObject);
    procedure StringGridNaklMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure StringGridZakupSet;
    procedure StringGridNaklSet;
    procedure StringGridTovarSet;
    procedure StringGridRecNaklSet;
  private
    { Private declarations }
  public
    { Public declarations }
    NaklN, NaklCod : Integer;
    NaklDate : TDateTime;
    NaklSum: Currency;
    NaklKindName, AgentNameFrom, AgentNameTo,
    NaklKindNameRecNakl : string;   // тип накладной выводимой в RecNakl
  end;
var
  Form1: TForm1;
  FLastDistance, HLastDistance: Integer;
  RLastLocation : Single;

const AllProizv    ='Произв';
      AllAgentFrom ='Поставщ';
      AllAgentTo   ='';
      AllNakl      ='';

implementation

{$R *.fmx}
{$R *.SmXhdpiPh.fmx ANDROID}
{$R *.NmXhdpiPh.fmx ANDROID}

procedure TForm1.StringGridTovarSet;
var I : Integer;
begin
  if StringGridTovar.ColumnCount>0 then
    StringGridTovar.Columns[0].Width:=240;
  for I := 0 to StringGridTovar.ColumnCount-1 do
    if StringGridTovar.Columns[I].Header='PerC' then StringGridTovar.Columns[I].Width:= 50;
end;

procedure TForm1.ComboBoxChangeTovar(Sender: TObject);
var AgentName, ProizvName, QuerSt: string;
     AgentCod, ProizvCod : Integer;
begin
//  Pb1.Visible:= True;
//  Timer1.Enabled:=True;

//  AniIndicator1.Visible := True;
//  AniIndicator1.Enabled := True;

  if ComboBoxAgent.ItemIndex>=0  then AgentName:= ComboBoxAgent.Items[ComboBoxAgent.ItemIndex]
  else  AgentName:=AllAgentFrom;

  if ComboBoxProizv.ItemIndex>=0 then ProizvName:= ComboBoxProizv.Items[ComboBoxProizv.ItemIndex]
  else ProizvName:= AllProizv;

  if AgentName<>AllAgentFrom then begin
    QuerSt:= 'Select _id from Agent where AgentName='''+AgentName+'''';
    DM.FDQuery1.Close;
    DM.FDQuery1.Sql.Clear;
    DM.FDQuery1.Sql.Add(QuerSt);
    DM.FDQuery1.Open;
    AgentCod:= DM.FDQuery1.FieldByName('_id').AsInteger;
    DM.FDQuery1.Close;
  end;

  if ProizvName<>AllProizv then begin
    QuerSt:= 'Select _id from Proizv where ProizvName='''+ProizvName+'''';
    DM.FDQuery1.Close;
    DM.FDQuery1.Sql.Clear;
    DM.FDQuery1.Sql.Add(QuerSt);
    DM.FDQuery1.Open;
    ProizvCod:= DM.FDQuery1.FieldByName('_id').AsInteger;
    DM.FDQuery1.Close;
  end;

  DM.FDQueryTovar.Close;

  if (AgentName<>AllAgentFrom) and (ProizvName=AllProizv) then DM.FDQueryTovar.Sql.Strings[0]:=
   'Select T.TovarName,T. Fasovka, P.ProizvName, T.ZenaRozn, T.ZenaZakupka,(T.ZenaRozn-T.ZenaZakupka)/T.ZenaRozn*100 as PerC';
  if (ProizvName<>AllProizv) and (AgentName=AllAgentFrom) then DM.FDQueryTovar.Sql.Strings[0]:=
   'Select T.TovarName,T. Fasovka, A.AgentName, T.ZenaRozn, T.ZenaZakupka,(T.ZenaRozn-T.ZenaZakupka)/T.ZenaRozn*100 as PerC';
  if (AgentName<>AllAgentFrom) and (ProizvName<>AllProizv) then DM.FDQueryTovar.Sql.Strings[0]:=
   'Select T.TovarName,T. Fasovka, T.ZenaRozn, T.ZenaZakupka,(T.ZenaRozn-T.ZenaZakupka)/T.ZenaRozn*100 as PerC';
  if (AgentName=AllAgentFrom) and (ProizvName=AllProizv) then DM.FDQueryTovar.Sql.Strings[0]:=
   'Select T.TovarName,T. Fasovka, P.ProizvName, A.AgentName, T.ZenaRozn, T.ZenaZakupka,(T.ZenaRozn-T.ZenaZakupka)/T.ZenaRozn*100 as PerC';

  if AgentName<>AllAgentFrom then  DM.FDQueryTovar.Sql.Strings[4]:='and (T.AgentCod='+IntToStr(AgentCod)+')'
  else  DM.FDQueryTovar.Sql.Strings[4]:='';
  if ProizvName<>AllProizv then   DM.FDQueryTovar.Sql.Strings[3]:='and (T.ProizvCod='+IntToStr(ProizvCod)+')'
  else  DM.FDQueryTovar.Sql.Strings[3]:='';


    DM.FDQueryTovar.Sql.Strings[5]:='Order By  T.TovarName,T.Fasovka';
  DM.FDQueryTovar.Open;

  StringGridTovarSet;

//  Timer1.Enabled:=False;
//  Pb1.Visible:= False;

//  AniIndicator1.Visible := False;
//  AniIndicator1.Enabled := False;

end;

procedure TForm1.StringGridZakupSet;
begin
  if StringGridZakup.ColumnCount=9 then
  begin
    StringGridZakup.Columns[0].Width:=200; //tovar
    StringGridZakup.Columns[1].Width:=50;  //fas
    StringGridZakup.Columns[2].Width:=60;  //proizv

    StringGridZakup.Columns[3].Width:=60;  // zena
    StringGridZakup.Columns[4].Width:=80; //data

    StringGridZakup.Columns[5].Width:=60; //agent
    StringGridZakup.Columns[6].Width:=60; //n
    StringGridZakup.Columns[7].Width:=40; //kolvo
    StringGridZakup.Columns[8].Width:=60; //sum

  end;
  if StringGridZakup.ColumnCount=8 then
  begin
    StringGridZakup.Columns[0].Width:=200; //tovar
    StringGridZakup.Columns[1].Width:=50;  //fas
    StringGridZakup.Columns[2].Width:=60;  //proizv

    StringGridZakup.Columns[3].Width:=60;  // zena
    StringGridZakup.Columns[4].Width:=80; //data

//    StringGridZakup.Columns[5].Width:=60; //agent
    StringGridZakup.Columns[5].Width:=60; //n
    StringGridZakup.Columns[6].Width:=40; //kolvo
    StringGridZakup.Columns[7].Width:=60; //sum

  end;
end;

procedure TForm1.ComboBoxAgentZakupChange(Sender: TObject);
var AgentNameZakup, QuerSt: string;
    AgentZakupCod : Integer;
begin
//  AniIndicator1.Visible := True;
//  AniIndicator1.Enabled := True;

  if ComboBoxAgentZakup.ItemIndex>=0  then AgentNameZakup:= ComboBoxAgentZakup.Items[ComboBoxAgentZakup.ItemIndex]
  else AgentNameZakup:=AllAgentFrom;

  if AgentNameZakup<>AllAgentFrom then begin
    QuerSt:= 'Select _id from Agent where AgentName='''+AgentNameZakup+'''';
    DM.FDQuery1.Close;
    DM.FDQuery1.Sql.Clear;
    DM.FDQuery1.Sql.Add(QuerSt);
    DM.FDQuery1.Open;
    AgentZakupCod:= DM.FDQuery1.FieldByName('_id').AsInteger;
    DM.FDQuery1.Close;
  end;

  DM.FDQueryZakup.Close;
  if AgentNameZakup<>AllAgentFrom then begin
// не выводить AgentTo
    DM.FDQueryZakup.Sql[3]:= '';
    DM.FDQueryZakup.Sql[8]:= 'From     Nakl N, RecNakl Rec, Tovar T, Proizv P';
    DM.FDQueryZakup.Sql[13]:= 'and (N.AgentCodFrom='+IntToStr(AgentZakupCod)+')';
  end else
  begin
    DM.FDQueryZakup.Sql[3]:= 'A.AgentName,';
    DM.FDQueryZakup.Sql[8]:= 'From     Nakl N, RecNakl Rec, Tovar T, Proizv P,  Agent A';
    DM.FDQueryZakup.Sql[13]:= '  and N.AgentCodFrom=A._id';
  end;
  DM.FDQueryZakup.Open;

  StringGridZakupSet;

//  AniIndicator1.Visible := False;
//  AniIndicator1.Enabled := False;
end;

procedure TForm1.StringGridNaklSet;
begin
  if StringGridNakl.ColumnCount=5 then
  begin
    StringGridNakl.Columns[0].Header:='№';
    StringGridNakl.Columns[0].Width:=50;   //n
    StringGridNakl.Columns[1].Width:=120;   //data
    StringGridNakl.Columns[2].Width:=90;   //sum
    StringGridNakl.Columns[3].Width:=350;   // pr
    StringGridNakl.Columns[4].Width:=90;  //  _id
  end;
  if StringGridNakl.ColumnCount>5 then
  begin
    StringGridNakl.Columns[0].Header:='№';
    StringGridNakl.Columns[0].Width:=50;   //n
    StringGridNakl.Columns[1].Width:=110;   //data
    StringGridNakl.Columns[2].Width:=90;   //sum
    StringGridNakl.Columns[3].Width:=90;   // AgentName
    StringGridNakl.Columns[4].Width:=350;  //  pr
    StringGridNakl.Columns[5].Width:=80;  //_id
  end;
end;

procedure TForm1.ComboBoxChangeNakl(Sender: TObject);
var   QuerSt: string;
    AgentFromCod, AgentToCod, NaklNameCod : Integer;
begin
//  Pb1.Visible:= True;
//  Timer1.Enabled:=True;
//  AniIndicator1.Visible := True;
//  AniIndicator1.Enabled := True;

  if ComboBoxAgentFrom.ItemIndex>=0  then AgentNameFrom:= ComboBoxAgentFrom.Items[ComboBoxAgentFrom.ItemIndex]
  else AgentNameFrom:=AllAgentFrom;
  if ComboBoxAgentTo.ItemIndex>=0  then AgentNameTo:= ComboBoxAgentTo.Items[ComboBoxAgentTo.ItemIndex]
  else AgentNameTo:=AllAgentTo;
  if ComboBoxNaklName.ItemIndex>=0 then NaklKindName:= ComboBoxNaklName.Items[ComboBoxNaklName.ItemIndex]
  else NaklKindName:=AllNakl;

  if AgentNameFrom<>AllAgentFrom then begin
    QuerSt:= 'Select _id from Agent where AgentName='''+AgentNameFrom+'''';
    DM.FDQuery1.Close;
    DM.FDQuery1.Sql.Clear;
    DM.FDQuery1.Sql.Add(QuerSt);
    DM.FDQuery1.Open;
    AgentFromCod:= DM.FDQuery1.FieldByName('_id').AsInteger;
    DM.FDQuery1.Close;
  end;

  if AgentNameTo<>AllAgentTo then begin
    QuerSt:= 'Select _id from Agent where AgentName='''+AgentNameTo+'''';
    DM.FDQuery1.Close;
    DM.FDQuery1.Sql.Clear;
    DM.FDQuery1.Sql.Add(QuerSt);
    DM.FDQuery1.Open;
    AgentToCod:= DM.FDQuery1.FieldByName('_id').AsInteger;
    DM.FDQuery1.Close;
  end;

  if NaklKindName<>AllNakl then begin
    QuerSt:= 'Select _id from NaklName where NaklName='''+NaklKindName+'''';
    DM.FDQuery1.Close;
    DM.FDQuery1.Sql.Clear;
    DM.FDQuery1.Sql.Add(QuerSt);
    DM.FDQuery1.Open;
    NaklNameCod:= DM.FDQuery1.FieldByName('_id').AsInteger;
    DM.FDQuery1.Close;
  end;
  DM.FDQueryNakl.Close;

  DM.FDQueryNakl.Sql.Strings[8]:='where (N.Kind='+IntToStr(NaklNameCod)+')';

// не выводить AgentTo
  DM.FDQueryNakl.Sql[2]:= '';
  DM.FDQueryNakl.Sql[6]:= '';
  DM.FDQueryNakl.Sql[10]:= '';

  if AgentNameFrom<>AllAgentFrom then begin
// не выводить AgentTo
    DM.FDQueryNakl.Sql[1]:= '';  //  не выводим имя агента
    DM.FDQueryNakl.Sql[5]:= '';
    DM.FDQueryNakl.Sql[9]:= 'and (N.AgentCodFrom='+IntToStr(AgentFromCod)+')';
  end
  else begin
    DM.FDQueryNakl.Sql[1]:= ', AFrom.AgentName';  //   выводим имя агента
    DM.FDQueryNakl.Sql[5]:= ', Agent AFrom';
    DM.FDQueryNakl.Sql[9]:= 'and (N.AgentCodFrom=AFrom._id)';
  end;

  DM.FDQueryNakl.Open;
  DM.FDQueryNakl.Last;

  StringGridNaklSet;

//  Timer1.Enabled:=False;
//  Pb1.Visible:= False;

//  AniIndicator1.Visible := False;
//  AniIndicator1.Enabled := False;

end;

procedure TForm1.FormActivate(Sender: TObject);
begin
try
  DM.FDConnection1.Connected := True;
  if DM.ConnectToAgent then ;
  DM.ConnectToTovar;
// т.к. в ConnectToAgent устанавливается выбор накл закупок то вызывается там
//  if TabControl1.TabIndex=1 then  DM.ConnectToNakl;

except
      on E: Exception do
      begin
        ApplicationShowException(E);
      end;
end;

end;

procedure TForm1.FormGesture(Sender: TObject;
  const [Ref] EventInfo: TGestureEventInfo; var Handled: Boolean);
var   LObj: IControl;
begin
// если Handled далее жест не обрабатывается
   LObj := Self.ObjectAtPoint(ClientToScreen(EventInfo.Location));
    //SelControlByPoint()

 case EventInfo.GestureID of //проверка того, какой жест был использован

  sgiRight:  //
      if (LObj is THeader) or (LObj is THeaderItem) then begin
        if (not(TInteractiveGestureFlag.gfBegin in EventInfo.Flags)) and
           (not(TInteractiveGestureFlag.gfEnd in EventInfo.Flags)) then
//        THeader(LObj).Width:= THeader(LObj).Width + (EventInfo.Location.X- RLastLocation);
        TStringGrid(Sender).Columns[TStringGrid(Sender).ColumnIndex].Width:=
        TStringGrid(Sender).Columns[TStringGrid(Sender).ColumnIndex].Width+
          (EventInfo.Location.X- RLastLocation);
        RLastLocation := EventInfo.Location.X;
  (*      TStringGrid(Sender).Column
    if Sender is TStringGrid then
      if TStringGrid(Sender).CellControlByPoint(EventInfo.Location.X,EventInfo.Location.Y) is THeader then
      begin
  //    if RowByPoint()=0
       TStringGrid(Sender).ColumnByPoint(EventInfo.Location.X,EventInfo.Location.Y).Width:=
       TStringGrid(Sender).ColumnByPoint(EventInfo.Location.X,EventInfo.Location.Y).Width+
       (EventInfo.Distance- HLastDistance);
       HLastDistance := EventInfo.Distance;
      end;
    //SelControlByPoint()
*)
  end;
  sgiRightLeft:  ;//

  igiZoom :
    if Sender is TStringGrid then begin  // TapLocation-начальная точка жеста работает не правильно
//      If EventInfo.Flags = gfEnd then
      LObj := Self.ObjectAtPoint(ClientToScreen(EventInfo.Location));
//      if LObj.='' then;
      if (not(TInteractiveGestureFlag.gfBegin in EventInfo.Flags)) and
        (not(TInteractiveGestureFlag.gfEnd in EventInfo.Flags)) then
        TStringGrid(Sender).ColumnByPoint(EventInfo.Location.X,EventInfo.Location.Y).Width:=
        TStringGrid(Sender).ColumnByPoint(EventInfo.Location.X,EventInfo.Location.Y).Width+
          (EventInfo.Distance- FLastDistance);
//        TColumn(LObj).Width:= TColumn(LObj).Width + (EventInfo.Distance- FLastDistance);
// дает ошибку видимо LObj имеет тип не TColumn возможно=ячейка
       FLastDistance := EventInfo.Distance;
    //SelControlByPoint()
  end;

  igiDoubleTap :
    if Sender = StringGridNakl then begin  //
      StringGridNakl.OnDblClick(Sender);
    end;

  igiLongTap :
    if Sender = StringGridNakl then begin  //
      StringGridNaklLongTap(Sender);
    end;

 end;

end;

procedure TForm1.StringGridNaklDblClick(Sender: TObject);
var AgentCodFrom: Integer;
    QuerSt : string;
begin
  NaklN       := DM.FDQueryNakl.FieldByName('DocN').AsInteger;
  NaklCod     := DM.FDQueryNakl.FieldByName('_id').AsInteger;
  NaklDate    := DM.FDQueryNakl.FieldByName('DocDate').AsDateTime;
  NaklSum     := DM.FDQueryNakl.FieldByName('Sum').AsCurrency;
  if ComboBoxAgentFrom.ItemIndex>0  then AgentNameFrom:= ComboBoxAgentFrom.Items[ComboBoxAgentFrom.ItemIndex]
  else AgentNameFrom:= DM.FDQueryNakl.FieldByName('AgentName').AsString;

(*
  AgentName   := DM.FDQueryNakl.FieldByName('AgentName').AsString;
  AgentCodFrom:= DM.FDQueryNakl.FieldByName('AgentCodFrom').AsInteger;
    QuerSt:= 'Select AgentRedName from Agent where _id='''+IntToStr(AgentCodFrom)+'''';
    DM.FDQuery1.Close;
    DM.FDQuery1.Sql.Clear;
    DM.FDQuery1.Sql.Add(QuerSt);
    DM.FDQuery1.Open;
    AgentName:= DM.FDQuery1.FieldByName('AgentRedName').AsString;
    DM.FDQuery1.Close;
*)

  if not DM.FDQueryRecNakl.Active then DM.ConnectToRecNakl;
// может быть первое подключение

  DM.FDQueryRecNakl.Close;
  DM.FDQueryRecNakl.Sql.Strings[9]:='(Rec.NaklCod='+IntToStr(NaklCod)+')';
  DM.FDQueryRecNakl.Open;
  DM.FDQueryRecNakl.First;

  NaklKindNameRecNakl:=NaklKindName;
  TabControl1.TabIndex:=2;
end;

procedure TForm1.StringGridNaklLongTap(Sender: TObject);
var AgentCodFrom: Integer;
    QuerSt : string;
begin
 if NaklKindName='Закупка' then
 begin
  if ComboBoxAgentFrom.ItemIndex>0  then AgentNameFrom:= ComboBoxAgentFrom.Items[ComboBoxAgentFrom.ItemIndex]
  else AgentNameFrom:= DM.FDQueryNakl.FieldByName('AgentName').AsString;

  // определяем код наклодной-сына т.е прихода на основе этой закупки
  NaklCod     := DM.FDQueryNakl.FieldByName('_id').AsInteger;

    QuerSt:= 'Select SonCod from Parent where ParentCod='''+IntToStr(NaklCod)+'''';
    DM.FDQuery1.Close;
    DM.FDQuery1.Sql.Clear;
    DM.FDQuery1.Sql.Add(QuerSt);
    DM.FDQuery1.Open;
    NaklCod:= DM.FDQuery1.FieldByName('SonCod').AsInteger;
    // код накладной-сына
    DM.FDQuery1.Close;

  //  определяем параметры накладной-сына
    QuerSt:= 'Select * from Nakl where _id='''+IntToStr(NaklCod)+'''';
    DM.FDQuery1.Close;
    DM.FDQuery1.Sql.Clear;
    DM.FDQuery1.Sql.Add(QuerSt);
    DM.FDQuery1.Open;

    NaklN       := DM.FDQuery1.FieldByName('DocN').AsInteger;
    NaklDate    := DM.FDQuery1.FieldByName('DocDate').AsDateTime;
    NaklSum     := DM.FDQuery1.FieldByName('Sum').AsCurrency;
    DM.FDQuery1.Close;

    // тип накладной - считаем Приход
    NaklKindNameRecNakl:= 'Приход';


  if not DM.FDQueryRecNakl.Active then DM.ConnectToRecNakl;
// может быть первое подключение

  DM.FDQueryRecNakl.Close;
  DM.FDQueryRecNakl.Sql.Strings[9]:='(Rec.NaklCod='+IntToStr(NaklCod)+')';
  DM.FDQueryRecNakl.Open;
  DM.FDQueryRecNakl.First;
  TabControl1.TabIndex:=2;
 end
 else StringGridNaklDblClick(Sender);
end;

procedure TForm1.StringGridNaklMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
//  if Button=System.UITypes.mbRight then  then StringGridNaklLongTap(Sender);  // mbRight
if ssShift in Shift then  StringGridNaklLongTap(Sender);

end;

procedure TForm1.StringGridRecNaklSet;
begin
  if StringGridRecNakl.ColumnCount>=7 then
  begin
    StringGridRecNakl.Columns[0].Width:=30; // №
    StringGridRecNakl.Columns[1].Width:=200;  //tovarName
    StringGridRecNakl.Columns[2].Width:=50;  //fas

    StringGridRecNakl.Columns[3].Width:=80;  // proizv
    StringGridRecNakl.Columns[4].Width:=30; //kolvo

    StringGridRecNakl.Columns[5].Width:=70; //zena
    StringGridRecNakl.Columns[6].Width:=70; //sum
  end;
end;

procedure TForm1.TabControl1Change(Sender: TObject);
begin
//  AniIndicator1.Visible := True;
//  AniIndicator1.Enabled := True;

  if TabControl1.TabIndex=0  then
  begin
//   DM.FDQueryNakl.Close;
//   DM.ConnectToTovar;
  end;
  if TabControl1.TabIndex=1  then
  begin
//   DM.FDQueryTovar.Close;
   if ComboBoxNaklName.ItemIndex<0 then  // обращение к вкладке Nakl первый раз
   begin
     ComboBoxNaklName.ItemIndex:=0;
     DM.ConnectToNakl;
   end;
  end;

  if TabControl1.TabIndex=2  then  // RecNakl
  begin
   if not DM.FDQueryRecNakl.Active then DM.ConnectToRecNakl;
   Label2.Text:=
//     Format('%.4s',[NaklKindNameRecNakl])+
     NaklKindNameRecNakl+
     ' №='+IntToStr(NaklN)+
     ' дата='+ FormatDateTime('dd.mm',NaklDate)+   //DateToStr
     ' Сумма='+ CurrToStr(NaklSum);
   if AgentNameFrom<>'' then Label2.Text:=Label2.Text+
     ' от=' + AgentNameFrom;

   StringGridRecNaklSet;

   end;

  if TabControl1.TabIndex=3  then
  begin
   if not DM.FDQueryZakup.Active then DM.ConnectToZakup;
   StringGridZakupSet;
   end;

//  AniIndicator1.Visible := False;
//  AniIndicator1.Enabled := False;
  end;



end.
