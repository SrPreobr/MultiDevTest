object DM: TDM
  OldCreateOrder = False
  Height = 328
  Width = 379
  object FDConnection1: TFDConnection
    Params.Strings = (
      'Database=D:\Tel\BaseSQLite\Test.s3db'
      'DriverID=SQLite')
    Connected = True
    LoginPrompt = False
    BeforeConnect = FDConnection1BeforeConnect
    Left = 9
    Top = 6
  end
  object FDQueryTovar: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      
        'Select T.TovarName,T. Fasovka, P.ProizvName, A.AgentName, T.Zena' +
        'Rozn, T.ZenaZakupka,(T.ZenaRozn-T.ZenaZakupka)/T.ZenaRozn*100 as' +
        ' PerC'
      'from Tovar T, Proizv P, Agent A'
      'where( T.ProizvCod=P._id) and (T.AgentCod=A._id)'
      ''
      ''
      'Order By  T.TovarName,T.Fasovka, P.ProizvName')
    Left = 27
    Top = 56
  end
  object FDQuery1: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      '')
    Left = 18
    Top = 112
  end
  object FDQueryNakl: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'Select  N.DocN, N.DocDate, N.'#39'Sum'#39
      ', AFrom.AgentName'
      ', ATo.AgentName'
      ',  N.Pr,  N._id'
      'from Nakl N'
      ', Agent AFrom'
      ', Agent ATo'
      ''
      'where (N.Kind=1)'
      'and (N.AgentCodFrom=AFrom._id)'
      'and (N.AgentCodTo=ATo._id)'
      ''
      'Order By N.DocDate')
    Left = 115
    Top = 40
  end
  object FDQueryZakup: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'SELECT T.TovarName, T.Fasovka, P.ProizvName,'
      '               Rec.Zena as '#1062#1077#1085#1072','
      '               N."DocDate" as '#1044#1072#1090#1072','
      '               A.AgentName,'
      '               N.DocN  as N,'
      '               Rec.Kolvo as '#1050#1086#1083','
      '               (Rec.Kolvo*Rec.Zena) as '#1057#1091#1084
      ''
      'From     Nakl N, RecNakl Rec, Tovar T, Proizv P,  Agent A'
      ''
      ''
      'where   N._id=Rec.NaklCod  and N.Kind=1  and Rec.TovarCod=T._id'
      '             and T.ProizvCod=P._id'
      '             and N.AgentCodFrom=A._id'
      '            '
      'Order by  T.TovarName, T.Fasovka, P.ProizvName, N."DocDate"')
    Left = 315
    Top = 64
  end
  object FDQueryRecNakl: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'SELECT Rec.N, T.TovarName, T.Fasovka, P.ProizvName,'
      #9#9' Rec.Kolvo,'
      '     Rec.Zena,'
      #9#9' (Rec.Kolvo*Rec.Zena) as '#1057#1091#1084#1084
      ''
      'From   RecNakl Rec,'
      #9#9' Tovar T, Proizv P'
      ''
      'where Rec.TovarCod=T._id and T.ProizvCod=P._id and'
      #9#9' Rec.NaklCod=0'
      ''
      ''
      'Order By Rec.N')
    Left = 212
    Top = 48
  end
end
