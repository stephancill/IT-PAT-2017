unit Project_Dashboard_U;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Assignment_U, User_U, Classroom_U, StdCtrls, Project_U;

type
  TfrmProjectDashboard = class(TForm)
    btnCreateProject: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCreateProjectClick(Sender: TObject);
  private
    { Private declarations }
    assignment: TAssignment;
    user: TUser;
    sender: TForm;
    project: TProject;
    function stripText(raw: string): string;
  public
    procedure load(assignment: TAssignment; user: TUser; sender: TForm);
    function getAssignment: TAssignment;
    function getUser: TUser;
  end;

var
  frmProjectDashboard: TfrmProjectDashboard;

implementation

uses Student_Home_U, Teacher_Home_U, Utilities_U;


{$R *.dfm}

{ TfrmProjectDashboard }

procedure TfrmProjectDashboard.btnCreateProjectClick(Sender: TObject);
var
  dir: string;
begin
  dir := Format('Projects\%s\%s\%s', [assignment.getClassroom.getTeacherID, stripText(assignment.getClassroom.getName), striptext(user.getLastname + user.getFirstName)]);

  if not DirectoryExists(dir) then
  begin
    Utilities.createProject(dir, user, assignment, project);
  end;

end;

procedure TfrmProjectDashboard.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  try
    (self.sender as TFrmStudentHome).killProjectForm(self);
  except
//    (self.sender as TFrmTeacherHome).killProjectForm(self);
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

procedure TfrmProjectDashboard.load(assignment: TAssignment; user: TUser; sender: TForm);
begin
  self.assignment := assignment;
  self.user := user;
  self.sender := sender;
  self.Caption := 'Project Dashboard - ' + assignment.getTitle;
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
