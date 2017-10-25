object frmProjectDashboard: TfrmProjectDashboard
  Left = 0
  Top = 0
  Caption = 'Project Dashboard - $PROJECT'
  ClientHeight = 474
  ClientWidth = 762
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object btnCreateProject: TButton
    Left = 136
    Top = 112
    Width = 121
    Height = 25
    Caption = 'Create Project'
    TabOrder = 0
    OnClick = btnCreateProjectClick
  end
  object edtLocation: TEdit
    Left = 88
    Top = 72
    Width = 225
    Height = 21
    TabOrder = 1
    Text = 'edtLocation'
  end
  object btnOpenProject: TButton
    Left = 136
    Top = 152
    Width = 121
    Height = 25
    Caption = 'Open Project'
    TabOrder = 2
    OnClick = btnOpenProjectClick
  end
end
