object frmTeacherHome: TfrmTeacherHome
  Left = 0
  Top = 0
  Caption = 'Stephan'#39's Classroom - Teacher Home'
  ClientHeight = 469
  ClientWidth = 1130
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    1130
    469)
  PixelsPerInch = 96
  TextHeight = 13
  object lblClassrooms: TLabel
    Left = 24
    Top = 65
    Width = 54
    Height = 13
    Alignment = taCenter
    Caption = 'Classrooms'
  end
  object lblInstruction: TLabel
    Left = 384
    Top = 248
    Width = 136
    Height = 13
    Alignment = taCenter
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Select a Classroom to begin.'
  end
  object pnlHeader: TPanel
    Left = 8
    Top = 8
    Width = 1114
    Height = 41
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Welcome, $TEACHER'
    TabOrder = 0
    DesignSize = (
      1114
      41)
    object btnLogout: TButton
      Left = 8
      Top = 9
      Width = 75
      Height = 25
      Caption = 'Logout'
      TabOrder = 0
      OnClick = btnLogoutClick
    end
    object btnEditProfile: TButton
      Left = 1031
      Top = 9
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Edit Profile'
      TabOrder = 1
      OnClick = btnEditProfileClick
      ExplicitLeft = 680
    end
  end
  object lstClassrooms: TListBox
    Left = 24
    Top = 104
    Width = 210
    Height = 305
    Anchors = [akLeft, akTop, akBottom]
    ItemHeight = 13
    TabOrder = 1
    OnClick = lstClassroomsClick
  end
  object btnDeleteClassroom: TButton
    Left = 24
    Top = 424
    Width = 99
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Delete'
    TabOrder = 2
    OnClick = btnDeleteClassroomClick
  end
  object btnCreateClassroom: TButton
    Left = 135
    Top = 424
    Width = 99
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'New'
    TabOrder = 3
    OnClick = btnCreateClassroomClick
  end
  object edtFilterClassrooms: TEdit
    Left = 24
    Top = 84
    Width = 210
    Height = 21
    TabOrder = 4
    TextHint = 'Filter'
    OnChange = edtFilterClassroomsChange
  end
end
