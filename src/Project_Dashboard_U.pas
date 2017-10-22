unit Project_Dashboard_U;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Assignment_U, User_U;

type
  TfrmProjectDashboard = class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    assignment: TAssignment;
    user: TUser;
    sender: TForm;
  public
    procedure load(assignment: TAssignment; user: TUser; sender: TForm);
    function getAssignment: TAssignment;
    function getUser: TUser;
  end;

var
  frmProjectDashboard: TfrmProjectDashboard;

implementation

uses Student_Home_U, Teacher_Home_U;


{$R *.dfm}

{ TfrmProjectDashboard }

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

end.
