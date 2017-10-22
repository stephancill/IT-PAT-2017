object frmTeacherHome: TfrmTeacherHome
  Left = 0
  Top = 0
  Caption = 'Stephan'#39's Classroom - Teacher Home'
  ClientHeight = 469
  ClientWidth = 779
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
  object pnlHeader: TPanel
    Left = 8
    Top = 8
    Width = 763
    Height = 41
    Caption = 'Welcome, $TEACHER'
    TabOrder = 0
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
      Left = 680
      Top = 9
      Width = 75
      Height = 25
      Caption = 'Edit Profile'
      TabOrder = 1
      OnClick = btnEditProfileClick
    end
  end
  object lstClassrooms: TListBox
    Left = 24
    Top = 84
    Width = 210
    Height = 325
    ItemHeight = 13
    TabOrder = 1
    OnClick = lstClassroomsClick
  end
  object btnDeleteClassroom: TButton
    Left = 24
    Top = 424
    Width = 99
    Height = 25
    Caption = 'Delete'
    TabOrder = 2
    OnClick = btnDeleteClassroomClick
  end
  object btnCreateClassroom: TButton
    Left = 135
    Top = 424
    Width = 99
    Height = 25
    Caption = 'New'
    TabOrder = 3
    OnClick = btnCreateClassroomClick
  end
end
