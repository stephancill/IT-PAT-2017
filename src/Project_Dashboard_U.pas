unit Project_Dashboard_U;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Assignment_U, User_U, Classroom_U, StdCtrls, Project_U, ShellAPI,
  TeEngine, TeeProcs, Chart, Series, ExtCtrls;

type
  TfrmProjectDashboard = class(TForm)
    btnCreateProject: TButton;
    edtLocation: TEdit;
    btnOpenProject: TButton;
    btnCloneRepo: TButton;
    btnAnalyzeCommits: TButton;
    chart: TChart;
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCreateProjectClick(Sender: TObject);
    procedure btnOpenProjectClick(Sender: TObject);
    procedure btnCloneRepoClick(Sender: TObject);
    procedure btnAnalyzeCommitsClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    const
      TAG: string = 'PROJECT_DASHBOARD';
    var
      assignment: TAssignment;
      user: TUser;
      sender: TForm;
      project: TProject;

      series: TBarSeries;

    function ShellExecute_AndWait(FileName: string; Params: string): bool;
    procedure createGraph(inputFileDir: string);
    procedure projectSet(project: TProject);
  public
    procedure load(assignment: TAssignment; user: TUser; sender: TForm); overload;
    procedure load(project: TProject; user: TUser; sender: TForm); overload;
    function getAssignment: TAssignment;
    function getUser: TUser;
  end;

var
  frmProjectDashboard: TfrmProjectDashboard;

implementation

uses Student_Home_U, Teacher_Home_U, Utilities_U, Logger_U;


{$R *.dfm}

{ TfrmProjectDashboard }

procedure TfrmProjectDashboard.btnAnalyzeCommitsClick(Sender: TObject);
var
  scmd, srcDirectory: string;
begin
  srcDirectory := GetCurrentDir;
  // Check if git repo exists
  if DirectoryExists(project.getLocalDirectory + '\.git') then
  begin
    // Change into project directory, run script and produce output
    scmd := Format('/c cd "%s" && git --no-pager log | python "%s\extract_dates.py"', [project.getLocalDirectory, srcDirectory]);
    if ShellExecute_AndWait('cmd.exe', scmd) then
    begin
      CreateGraph(project.getLocalDirectory + '\.LAST_COMMIT_HISTORY.txt');
//      DeleteFile(project.getLocalDirectory + '\.LAST_COMMIT_HISTORY.txt');
    end;
  end else
  begin
    Showmessage('Directory does not contain git repo');
  end;

end;

procedure TfrmProjectDashboard.btnCloneRepoClick(Sender: TObject);
var
  scmd: string;
begin
  // Clone git repo
  scmd := '/c git clone ' + edtLocation.text +' "' + project.getLocalDirectory + '"';
  if ShellExecute_AndWait('cmd.exe', PChar(scmd)) then
  begin
    btnAnalyzeCommitsClick(self);
    TLogger.log(TAG, Debug, 'Successfully cloned ' + edtLocation.text + ' into ' + project.getLocalDirectory);
    Utilities.updateProjectLocation(project)
  end else
  begin
    TLogger.log(TAG, Error, 'Failed to clone ' + edtLocation.text + ' into ' + project.getLocalDirectory);
  end;
end;

procedure TfrmProjectDashboard.btnCreateProjectClick(Sender: TObject);
var
  dir, localDir: string;
begin
  if user.getType = Teacher then
  begin
    Showmessage('Only students can create projects.');
    Exit;
  end;

  localDir := TProject.getLocalDirectory(assignment, user);

  if not DirectoryExists(localDir) then
  begin
    try
      if ForceDirectories(localDir) then
      begin
        // TODO: validation
        Utilities.createProject(edtLocation.Text, user, assignment, project);
        TLogger.log(TAG, Debug, 'Created project directory ' + localDir);
      end else
      begin
        TLogger.log(TAG, Error, 'Could not create directory ' + localDir);
        Exit;
      end;
    except
      on E: Exception do
      begin
        TLogger.logException(TAG, 'btnCreateProjectClick', e);
        Exit;
      end;
    end;
  end;

  if not Utilities.getProject(assignment, self.user, self.project) then
  begin
    if Utilities.createProject(edtLocation.Text, user, assignment, project) then
    begin
      showmessage('Created project');
    end;
  end else
  begin
    Showmessage('Project exists');
  end;

  btnCreateProject.enabled := false;
  edtLocation.enabled := true;
end;

procedure TfrmProjectDashboard.btnOpenProjectClick(Sender: TObject);
begin
  if DirectoryExists(project.getLocalDirectory) then
  begin
    ShellExecute(Application.Handle,PChar('explore'),PChar(project.getLocalDirectory),nil,nil,SW_SHOWNORMAL);
  end;

end;

procedure TfrmProjectDashboard.Button1Click(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar(edtLocation.Text), nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmProjectDashboard.createGraph(inputFileDir: string);
var
  f: TextFile;
  p, i: integer;
  points: array of integer;
  dates: array of string;
  s: string;
begin
  // Chart

  //  Initialise some chart title settings.
  chart.Title.Font.Name := 'Arial';
  chart.Title.Font.Size := 20;
  chart.Title.Font.Style := [fsBold];
  chart.Title.Font.Color := clBlack;
  //  Clear any existing title (if any - by default "TChart").
  chart.Title.Text.Clear();
  //  Add a new title to the chart.
  chart.Title.Text.Add('Commit Frequency');

  //  Hide the chart's legend.
  chart.Legend.Hide;

  chart.View3D := false;
  chart.LeftWall.Color := clWhite;

  //  Set some left axis settings.
  chart.LeftAxis.LabelsFont.Size := 11;
  chart.LeftAxis.Increment := 4;

  //  Set some bottom axis settings;
  chart.BottomAxis.LabelsFont.Size := 11;
  chart.BottomAxis.LabelsAngle := 90;
  chart.LeftAxis.Increment := 5;

  //  Create a new series.
  series := TBarSeries.Create(self);
  series.ParentChart := chart;

  // Data
  AssignFile(f, inputFileDir);
  try
    Reset(f);
  except
    on E: Exception do
    begin
      Showmessage('Something went wrong... Check logs for more information.');
      TLogger.logException(TAG, 'createGraph', e);
      Exit;
    end;
  end;

  i := 0;

  // Extract data from text file
  while not eof(f) do
  begin
    readln(f, s);

    setLength(points, i+1);
    setLength(dates, i+1);

    p := strtoint(Copy(s, pos(' ', s)+1, length(s)));
    points[i] := strtoint(Copy(s, pos(' ', s)+1, length(s)));
    dates[i] := Copy(s, 1, pos(' ', s)-1);
    // Populate chart
    chart.Series[0].Add(p, '', clWhite);
    chart.Series[0].Marks[i].Visible := false;
    chart.Series[0].XLabel[i] := '';

    inc(i);
  end;

  // Add first and last date labels
  chart.Series[0].XLabel[0] := dates[0];
  chart.Series[0].XLabel[length(dates)-1] := dates[length(dates)-1];

  CloseFile(f);

  chart.Visible := true;
end;

procedure TfrmProjectDashboard.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  try
    (self.sender as TFrmStudentHome).killProjectForm(self);
  except
    (self.sender as TFrmTeacherHome).killProjectForm(self);
  end;
end;

function TfrmProjectDashboard.getAssignment: TAssignment;
begin
  result := self.assignment;
end;

function TfrmProjectDashboard.getUser: TUser;
begin
  result := self.user;
end;

procedure TfrmProjectDashboard.load(project: TProject; user: TUser; sender: TForm);
begin
  // Teacher entry
  self.assignment := project.getAssignment;
  self.user := user;
  self.project := project;
  self.sender := sender;
  self.Caption := 'Viewing Project - ' + project.getAssignment.getTitle + ' by ' + project.getCreator.getFirstName + ' ' + project.getCreator.getLastName;

  btnCreateProject.Enabled := false;
  edtLocation.enabled := false;

  projectSet(project);

  TLogger.log(TAG, TLogType.Debug, 'Viewed project of student ID ' + user.getID + ' for assignment with ID: ' + assignment.getID);
end;

procedure TfrmProjectDashboard.projectSet(project: TProject);
begin
  // Load project
  edtLocation.Text := project.getLocation;
  if DirectoryExists(TProject.getLocalDirectory(assignment, user)) then
  begin
    if DirectoryExists(TProject.getLocalDirectory(assignment, user) + '\.git') then
    begin
      btnAnalyzeCommitsClick(self);
      edtLocation.Enabled := false;
      btnCloneRepo.Enabled := false;
    end;
    btnCreateProject.enabled := false;
  end else
  begin
    // Create project directory
    try
      if ForceDirectories(project.getLocalDirectory) then
      begin
        TLogger.log(TAG, Debug, 'Created project directory ' + project.getLocalDirectory);
      end else
      begin
        TLogger.log(TAG, Error, 'Could not create directory ' + project.getLocalDirectory);
      end;
    except
      on E: Exception do
        TLogger.logException(TAG, 'btnCreateProjectClick', e);
    end;
  end;
end;

procedure TfrmProjectDashboard.load(assignment: TAssignment; user: TUser; sender: TForm);
var
  localDir: string;
begin
  // Student entry
  self.assignment := assignment;
  self.user := user;
  self.sender := sender;
  self.Caption := 'Project Dashboard - ' + assignment.getTitle;

  localDir := TProject.getLocalDirectory(assignment, user);

  if Utilities.getProject(assignment, user, self.project) then
  begin
    projectSet(project);
  end else
  begin
    // Project loading failed
    btnOpenProject.Enabled := false;
    // TODO: delete directory
    edtLocation.enabled := false;
  end;


  TLogger.log(TAG, TLogType.Debug, 'Viewed project of student ID ' + user.getID + ' for assignment with ID: ' + assignment.getID);
end;

// https://stackoverflow.com/a/4295788
function TfrmProjectDashboard.ShellExecute_AndWait(FileName: string; Params: string): bool;
var
  exInfo: TShellExecuteInfo;
  Ph: DWORD;
begin
  TLogger.log(TAG, Debug, 'Executing command: ' + params);
  FillChar(exInfo, SizeOf(exInfo), 0);
  with exInfo do
  begin
    cbSize := SizeOf(exInfo);
    fMask := SEE_MASK_NOCLOSEPROCESS or SEE_MASK_FLAG_DDEWAIT;
    Wnd := GetActiveWindow();
    exInfo.lpVerb := nil;
    exInfo.lpParameters := PChar(Params);
    lpFile := PChar(FileName);
    nShow := SW_SHOWNORMAL;
  end;
  if ShellExecuteEx(@exInfo) then
    Ph := exInfo.hProcess
  else
  begin
    ShowMessage(SysErrorMessage(GetLastError));
    TLogger.log(TAG, Error, SysErrorMessage(GetLastError));
    Result := true;
    exit;
  end;
  while WaitForSingleObject(exInfo.hProcess, 50) <> WAIT_OBJECT_0 do
    Application.ProcessMessages;
  CloseHandle(Ph);

  Result := true;

end;

end.
