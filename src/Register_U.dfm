object frmRegister: TfrmRegister
  Left = 0
  Top = 0
  Caption = 'Register'
  ClientHeight = 299
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lblLogin: TLabel
    Left = 260
    Top = 231
    Width = 125
    Height = 13
    Cursor = crHandPoint
    Alignment = taCenter
    Caption = 'Already have an account?'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHotLight
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsUnderline]
    ParentColor = False
    ParentFont = False
    OnClick = lblLoginClick
  end
  object edtEmail: TEdit
    Left = 264
    Top = 56
    Width = 121
    Height = 21
    TabOrder = 0
    TextHint = 'Email'
  end
  object edtPassword: TEdit
    Left = 264
    Top = 83
    Width = 121
    Height = 21
    PasswordChar = '*'
    TabOrder = 1
    TextHint = 'Password'
  end
  object btnRegister: TButton
    Left = 264
    Top = 200
    Width = 121
    Height = 25
    Caption = 'Register'
    Default = True
    TabOrder = 2
    OnClick = btnRegisterClick
  end
  object edtConfirmPassword: TEdit
    Left = 264
    Top = 109
    Width = 121
    Height = 21
    PasswordChar = '*'
    TabOrder = 3
    TextHint = 'Confirm Password'
  end
  object rdoAccountType: TRadioGroup
    Left = 264
    Top = 137
    Width = 121
    Height = 57
    Caption = 'Account Type'
    Items.Strings = (
      'Student'
      'Teacher')
    TabOrder = 4
  end
end
