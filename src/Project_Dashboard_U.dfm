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
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object btnCreateProject: TButton
    Left = 296
    Top = 184
    Width = 115
    Height = 25
    Caption = 'Create Project'
    TabOrder = 0
    OnClick = btnCreateProjectClick
  end
end
