object frmAuthenticate: TfrmAuthenticate
  Left = 0
  Top = 0
  Caption = 'Stephan'#39's Classroom'
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
  object pnlRegister: TPanel
    Left = 208
    Top = 24
    Width = 217
    Height = 251
    TabOrder = 0
    Visible = False
    object lblLogin: TLabel
      Left = 44
      Top = 215
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
      OnClick = lblSwitchClick
    end
    object Label2: TLabel
      Left = 80
      Top = 12
      Width = 57
      Height = 19
      Caption = 'Register'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object btnRegister: TButton
      Left = 48
      Top = 184
      Width = 121
      Height = 25
      Caption = 'Register'
      Default = True
      TabOrder = 0
      OnClick = btnRegisterClick
    end
    object edtRegConfirmPassword: TEdit
      Left = 48
      Top = 93
      Width = 121
      Height = 21
      PasswordChar = '*'
      TabOrder = 1
      TextHint = 'Confirm Password'
    end
    object edtRegEmail: TEdit
      Left = 48
      Top = 40
      Width = 121
      Height = 21
      TabOrder = 2
      TextHint = 'Email'
    end
    object edtRegPassword: TEdit
      Left = 48
      Top = 67
      Width = 121
      Height = 21
      PasswordChar = '*'
      TabOrder = 3
      TextHint = 'Password'
    end
    object rdoAccountType: TRadioGroup
      Left = 48
      Top = 121
      Width = 121
      Height = 57
      Caption = 'Account Type'
      ItemIndex = 0
      Items.Strings = (
        'Student'
        'Teacher')
      TabOrder = 4
    end
  end
  object pnlLogin: TPanel
    Left = 208
    Top = 72
    Width = 217
    Height = 155
    TabOrder = 1
    object lblRegister: TLabel
      Left = 68
      Top = 126
      Width = 86
      Height = 13
      Cursor = crHandPoint
      Alignment = taCenter
      Caption = 'Need an account?'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clHotLight
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsUnderline]
      ParentColor = False
      ParentFont = False
      OnClick = lblSwitchClick
    end
    object Label1: TLabel
      Left = 88
      Top = 12
      Width = 39
      Height = 19
      Caption = 'Login'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object edtLoginEmail: TEdit
      Left = 48
      Top = 41
      Width = 121
      Height = 21
      TabOrder = 0
      TextHint = 'Email'
    end
    object edtLoginPassword: TEdit
      Left = 48
      Top = 68
      Width = 121
      Height = 21
      TabOrder = 1
      TextHint = 'Password'
    end
    object btnLogin: TButton
      Left = 48
      Top = 95
      Width = 121
      Height = 25
      Caption = 'Login'
      Default = True
      TabOrder = 2
      OnClick = btnRegisterClick
    end
  end
end
