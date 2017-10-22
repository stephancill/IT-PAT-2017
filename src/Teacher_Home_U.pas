unit Teacher_Home_U;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, User_U, Classroom_U, Assignment_U;

type
  TfrmTeacherHome = class(TForm)
    pnlHeader: TPanel;
    btnCreateClassroom: TButton;
    lstClassrooms: TListBox;
    btnDeleteClassroom: TButton;
    btnLogout: TButton;
    lblClassrooms: TLabel;
    tbClassroom: TTabControl;
    lstClassroom: TListBox;
    btnNewAssignment: TButton;
    lblClassroomCode: TLabel;
    procedure btnCreateClassroomClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnDeleteClassroomClick(Sender: TObject);
    procedure btnLogoutClick(Sender: TObject);
    procedure lstClassroomsClick(Sender: TObject);
    procedure tbClassroomChange(Sender: TObject);
    procedure btnNewAssignmentClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    const
      TAG: string = 'FORM_TEACHER_HOME';
    var
      user: TUser;
      classrooms: TClassroomArray;
      selectedClassroom: TClassroom;
      assignments: TAssignmentArray;
      selectedAssignment: TAssignment;
  public
    { Public declarations }
    procedure setUser(user: TUser);
    procedure setSelectedAssignment(assignment: TAssignment);
    procedure refreshClassrooms;
    procedure refreshTabController;
  end;

var
  frmTeacherHome: TfrmTeacherHome;

implementation

uses Utilities_U, Authenticate_U, Create_Assignment_U, Logger_U;

{$R *.dfm}

{ TfrmTeacherHome }

procedure TfrmTeacherHome.btnCreateClassroomClick(Sender: TObject);
var
  classroom : TClassroom;
begin
  Utilities.createClassroom(self.user, inputbox('Create a classroom', 'Classroom name:', 'Grade X - Subject'), classroom);
  refreshClassrooms;
end;

procedure TfrmTeacherHome.btnDeleteClassroomClick(Sender: TObject);
begin
  Utilities.deleteClassroom(self.user, classrooms[lstClassrooms.ItemIndex]);
  refreshClassrooms;
end;

procedure TfrmTeacherHome.btnLogoutClick(Sender: TObject);
begin
  self.Hide;
  frmAuthenticate.show;
  self.user.Free;
  Utilities.depersistLogin;
  TLogger.log(TAG, TLogType.Debug, 'Logged out user');
end;

procedure TfrmTeacherHome.btnNewAssignmentClick(Sender: TObject);
begin
  frmCreateAssignment.setClassroom(self.selectedClassroom);
  frmCreateAssignment.show;
end;

procedure TfrmTeacherHome.FormActivate(Sender: TObject);
begin
  if not Assigned (self.user) then
  begin
    setUser( TUser.Create('9971', 'a', 'a', 'a', TUserType.Teacher));
  end;
end;

procedure TfrmTeacherHome.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Utilities.kill;
end;

procedure TfrmTeacherHome.FormCreate(Sender: TObject);
begin
  btnNewAssignment.Enabled := false;
end;

procedure TfrmTeacherHome.lstClassroomsClick(Sender: TObject);
begin
  if lstClassrooms.ItemIndex > -1 then
  begin
    selectedClassroom := classrooms[lstClassrooms.ItemIndex];
    lblClassroomCode.Caption := 'Classroom Code: ' + selectedClassroom.getID;
    btnNewAssignment.enabled := true;
    refreshTabController;
  end;
end;

procedure TfrmTeacherHome.refreshClassrooms;
var
  c: TClassroom;
begin
  lstClassrooms.clear;
  // Get Classrooms
  classrooms := Utilities.getTeachingClassrooms(self.user);
  for c in classrooms do
  begin
    lstClassrooms.Items.Add(c.getName);
  end;
end;

procedure TfrmTeacherHome.setSelectedAssignment(assignment: TAssignment);
begin
  self.selectedAssignment := assignment;
end;

procedure TfrmTeacherHome.setUser(user: TUser);
begin
  self.user := user;

  // Refresh UI
  pnlHeader.Caption := 'Welcome ' + user.getFirstName;
  refreshClassrooms;
end;

procedure TfrmTeacherHome.tbClassroomChange(Sender: TObject);
var
  assignments: TAssignmentArray;
  a: TAssignment;
  students: TUserArray;
  s: TUser;
begin
  lstClassroom.Clear;
  case tbClassroom.TabIndex of
    0: // Assignments
    begin
      if Assigned(selectedClassroom) then
      begin
        assignments := Utilities.getAssignments(self.selectedClassroom);
        for a in assignments do
          lstClassroom.Items.Add(a.getTitle);
      end;
    end;
    1: // Students
    begin
      if Assigned(selectedClassroom) then
      begin
        students := Utilities.getStudents(self.selectedClassroom);
        for s in students do
          lstClassroom.Items.Add(s.getLastName + ', ' + s.getFirstName);
      end;
    end;
  end;
end;

procedure TfrmTeacherHome.refreshTabController;
begin
  // Update tab
  tbClassroomChange(self);
end;

end.
