unit Project_Dashboard_U;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Assignment_U, User_U, Classroom_U, StdCtrls, Project_U, ShellAPI;

type
  TfrmProjectDashboard = class(TForm)
    btnCreateProject: TButton;
    edtLocation: TEdit;
    btnOpenProject: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCreateProjectClick(Sender: TObject);
    procedure btnOpenProjectClick(Sender: TObject);
  private
    { Private declarations }
    const
      TAG: string = 'PROJECT_DASHBOARD';
    var
      assignment: TAssignment;
      user: TUser;
      sender: TForm;
      project: TProject;

    procedure DeleteDirectory(const Name: string);
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
      end;
    except
      on E: Exception do
      begin
        TLogger.logException(TAG, 'btnCreateProjectClick', e);
      end;
    end;
  end else
  begin
    showmessage('Project exists');
  end;
end;

procedure TfrmProjectDashboard.btnOpenProjectClick(Sender: TObject);
begin
  if DirectoryExists(project.getLocalDirectory) then
  begin
    ShellExecute(Application.Handle,PChar('explore'),PChar(project.getLocalDirectory),nil,nil,SW_SHOWNORMAL);
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
  // Teacher entry
  self.assignment := project.getAssignment;
  self.user := user;
  self.project := project;
  self.sender := sender;
  self.Caption := 'Viewing Project - ' + project.getAssignment.getTitle + ' by ' + project.getCreator.getFirstName + ' ' + project.getCreator.getLastName;

  TLogger.log(TAG, TLogType.Debug, 'Viewed project of student ID ' + user.getID + ' for assignment with ID: ' + assignment.getID);
end;

procedure TfrmProjectDashboard.load(assignment: TAssignment; user: TUser; sender: TForm);
begin
  // Student entry
  self.assignment := assignment;
  self.user := user;
  self.sender := sender;
  self.Caption := 'Project Dashboard - ' + assignment.getTitle;

  if DirectoryExists(TProject.getLocalDirectory(assignment, user)) then
  begin
    if Utilities.getProject(assignment, user, self.project) then
    begin
      // Load project
    end else
    begin
      // Project loading failed

    end;
  end;

  TLogger.log(TAG, TLogType.Debug, 'Viewed project of student ID ' + user.getID + ' for assignment with ID: ' + assignment.getID);
end;

procedure TfrmProjectDashboard.DeleteDirectory(const Name: string);
var
  F: TSearchRec;
begin
  if FindFirst(Name + '\*', faAnyFile, F) = 0 then begin
    try
      repeat
        if (F.Attr and faDirectory <> 0) then begin
          if (F.Name <> '.') and (F.Name <> '..') then begin
            DeleteDirectory(Name + '\' + F.Name);
          end;
        end else begin
          DeleteFile(Name + '\' + F.Name);
        end;
      until FindNext(F) <> 0;
    finally
      FindClose(F);
    end;
    RemoveDir(Name);
  end;
end;
end.
