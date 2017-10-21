object data_module: Tdata_module
  OldCreateOrder = False
  Height = 259
  Width = 358
  object connection: TADOConnection
    Connected = True
    ConnectionString = 
      'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=IT-PAT-2017.mdb;Per' +
      'sist Security Info=False'
    LoginPrompt = False
    Mode = cmShareDenyNone
    Provider = 'Microsoft.Jet.OLEDB.4.0'
    Left = 16
    Top = 16
  end
  object qry: TADOQuery
    Connection = connection
    Parameters = <>
    Left = 104
    Top = 16
  end
  object qryAux: TADOQuery
    Connection = connection
    Parameters = <>
    Left = 168
    Top = 32
  end
end
