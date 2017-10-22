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
  object lblClassroomCode: TLabel
    Left = 287
    Top = 65
    Width = 84
    Height = 13
    Caption = 'Classroom Code: '
  end
  object pnlHeader: TPanel
    Left = 8
    Top = 8
    Width = 763
    Height = 41
    Caption = 'Welcome, $TEACHER'
    TabOrder = 0
    object btnCreateClassroom: TButton
      Left = 656
      Top = 9
      Width = 99
      Height = 25
      Caption = 'Create Classroom'
      TabOrder = 0
      OnClick = btnCreateClassroomClick
    end
    object btnLogout: TButton
      Left = 8
      Top = 9
      Width = 75
      Height = 25
      Caption = 'Logout'
      TabOrder = 1
      OnClick = btnLogoutClick
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
    Width = 210
    Height = 25
    Caption = 'Delete'
    TabOrder = 2
    OnClick = btnDeleteClassroomClick
  end
  object tbClassroom: TTabControl
    Left = 287
    Top = 84
    Width = 210
    Height = 325
    TabOrder = 3
    Tabs.Strings = (
      'Assignments'
      'Students')
    TabIndex = 0
    OnChange = tbClassroomChange
    object lstClassroom: TListBox
      Left = 0
      Top = 19
      Width = 207
      Height = 305
      ItemHeight = 13
      TabOrder = 0
    end
  end
  object btnNewAssignment: TButton
    Left = 400
    Top = 424
    Width = 94
    Height = 25
    Caption = 'New assignment'
    TabOrder = 4
    OnClick = btnNewAssignmentClick
  end
end
