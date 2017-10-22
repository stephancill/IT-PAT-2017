object frmCreateAssignment: TfrmCreateAssignment
  Left = 0
  Top = 0
  Caption = 'frmCreateAssignment'
  ClientHeight = 227
  ClientWidth = 351
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 8
    Width = 20
    Height = 13
    Caption = 'Title'
  end
  object Label2: TLabel
    Left = 24
    Top = 56
    Width = 53
    Height = 13
    Caption = 'Description'
  end
  object edtTitle: TEdit
    Left = 24
    Top = 24
    Width = 297
    Height = 21
    TabOrder = 0
    TextHint = 'Title'
  end
  object edtDescription: TRichEdit
    Left = 24
    Top = 73
    Width = 297
    Height = 102
    Hint = 'Description'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
  object btnCreate: TButton
    Left = 24
    Top = 189
    Width = 297
    Height = 25
    Caption = 'Create Assignment'
    Default = True
    TabOrder = 2
    OnClick = btnCreateClick
  end
end
