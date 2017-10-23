unit Project_Dashboard_U;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Assignment_U, User_U, Classroom_U, StdCtrls, Project_U, ShellAPI;

type
  TfrmProjectDashboard = class(TForm)
    btnCreateProject: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCreateProjectClick(Sender: TObject);
  private
    { Private declarations }
    const
      TAG: string = 'PROJECT_DASHBOARD';
    var
      assignment: TAssignment;
      user: TUser;
      sender: TForm;
      project: TProject;
    function stripText(raw: string): string;
    procedure SelectFileInExplorer(const Fn: string);
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

procedure TfrmProjectDashboard.btnCreateProjectClick(Sender: TObject);
var
  dir: string;
begin
  dir := Format('Projects\%s\%s\%s', [assignment.getClassroom.getTeacherID, stripText(assignment.getClassroom.getName), striptext(user.getLastname + user.getFirstName)]);
  showmessage(GetCurrentDir);
  if not DirectoryExists(dir) then
  begin
    try
      if ForceDirectories(dir) then
      begin
        Utilities.createProject(dir, user, assignment, project);
        showmessage(GetCurrentDir);
      end;
    except
      on E: Exception do
      begin
        TLogger.logException(TAG, 'btnCreateProjectClick', e);
      end;
    end;



  end else
  begin
    showmessage('project exists');
  end;


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
  self.assignment := project.getAssignment;
  self.user := user;
  self.project := project;
  self.sender := sender;
  self.Caption := 'Viewing Project - ' + project.getAssignment.getTitle + ' by ' + project.getCreator.getFirstName + ' ' + project.getCreator.getLastName;

  TLogger.log(TAG, TLogType.Debug, 'Viewed project of student ID ' + user.getID + ' for assignment with ID: ' + assignment.getID);
end;

// https://stackoverflow.com/a/1261589
procedure TfrmProjectDashboard.SelectFileInExplorer(const Fn: string);
begin
  ShellExecute(Application.Handle, 'open', 'explorer.exe',
    PChar('/select,"' + Fn+'"'), nil, SW_NORMAL);
end;

procedure TfrmProjectDashboard.load(assignment: TAssignment; user: TUser; sender: TForm);
begin
  self.assignment := assignment;
  self.user := user;
  self.sender := sender;
  self.Caption := 'Project Dashboard - ' + assignment.getTitle;

  TLogger.log(TAG, TLogType.Debug, 'Viewed project of student ID ' + user.getID + ' for assignment with ID: ' + assignment.getID);
end;

function TfrmProjectDashboard.stripText(raw: string): string;
var
  c: char;
begin
  for c in raw do
  begin
    if ischaralphanumeric(c) then
      result := result + c;
  end;
end;

end.
