object frmProjectDashboard: TfrmProjectDashboard
  Left = 0
  Top = 0
  Caption = 'Project Dashboard - $PROJECT'
  ClientHeight = 474
  ClientWidth = 768
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
  object Label1: TLabel
    Left = 16
    Top = 197
    Width = 77
    Height = 13
    Caption = 'Remote location'
  end
  object Label2: TLabel
    Left = 376
    Top = 248
    Width = 343
    Height = 13
    Caption = 
      'Clone a remote repo and click "Analyze Commits" to view commit h' +
      'istory'
  end
  object btnCreateProject: TButton
    Left = 64
    Top = 115
    Width = 121
    Height = 25
    Caption = 'Create Project'
    TabOrder = 0
    OnClick = btnCreateProjectClick
  end
  object edtLocation: TEdit
    Left = 16
    Top = 216
    Width = 225
    Height = 21
    TabOrder = 1
    Text = 'https://github.com/stephancill/spotify-analyzer.git'
  end
  object btnOpenProject: TButton
    Left = 64
    Top = 155
    Width = 121
    Height = 25
    Caption = 'Open Project'
    TabOrder = 2
    OnClick = btnOpenProjectClick
  end
  object btnCloneRepo: TButton
    Left = 64
    Top = 256
    Width = 121
    Height = 25
    Caption = 'Clone Remote'
    TabOrder = 3
    OnClick = btnCloneRepoClick
  end
  object btnAnalyzeCommits: TButton
    Left = 64
    Top = 304
    Width = 121
    Height = 25
    Caption = 'Analyze Commits'
    TabOrder = 4
    OnClick = btnAnalyzeCommitsClick
  end
  object chart: TChart
    Left = 296
    Top = 24
    Width = 448
    Height = 425
    Title.Text.Strings = (
      'TChart')
    DepthAxis.Automatic = False
    DepthAxis.AutomaticMaximum = False
    DepthAxis.AutomaticMinimum = False
    DepthAxis.Maximum = -0.500000000000000000
    DepthAxis.Minimum = -0.500000000000000000
    DepthTopAxis.Automatic = False
    DepthTopAxis.AutomaticMaximum = False
    DepthTopAxis.AutomaticMinimum = False
    DepthTopAxis.Maximum = -0.500000000000000000
    DepthTopAxis.Minimum = -0.500000000000000000
    LeftAxis.Automatic = False
    LeftAxis.AutomaticMaximum = False
    LeftAxis.AutomaticMinimum = False
    RightAxis.Automatic = False
    RightAxis.AutomaticMaximum = False
    RightAxis.AutomaticMinimum = False
    TabOrder = 5
    Visible = False
  end
  object Button1: TButton
    Left = 64
    Top = 352
    Width = 121
    Height = 25
    Caption = 'Open Remote Location'
    TabOrder = 6
    OnClick = Button1Click
  end
end
