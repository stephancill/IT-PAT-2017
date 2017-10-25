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
    Top = 115
    Width = 121
    Height = 25
    Caption = 'Create Project'
    TabOrder = 0
    OnClick = btnCreateProjectClick
  end
  object edtLocation: TEdit
    Left = 96
    Top = 216
    Width = 225
    Height = 21
    TabOrder = 1
    Text = 'https://github.com/stephancill/spotify-analyzer.git'
  end
  object btnOpenProject: TButton
    Left = 136
    Top = 155
    Width = 121
    Height = 25
    Caption = 'Open Project'
    TabOrder = 2
    OnClick = btnOpenProjectClick
  end
  object btnCloneRepo: TButton
    Left = 136
    Top = 256
    Width = 121
    Height = 25
    Caption = 'Clone'
    TabOrder = 3
    OnClick = btnCloneRepoClick
  end
end
