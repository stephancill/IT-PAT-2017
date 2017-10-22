unit Student_Home_U;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, User_U, Classroom_U, Assignment_U;

type
  TfrmStudentHome = class(TForm)
    pnlHeader: TPanel;
    btnJoinClassroom: TButton;
    lstClassrooms: TListBox;
    btnLeaveClassroom: TButton;
    btnLogout: TButton;
    lblClassrooms: TLabel;
    btnEditProfile: TButton;
    lblInstruction: TLabel;
    edtFilterClassrooms: TEdit;
    procedure btnJoinClassroomClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnLeaveClassroomClick(Sender: TObject);
    procedure btnLogoutClick(Sender: TObject);
    procedure lstClassroomsClick(Sender: TObject);
    procedure tbClassroomChange(Sender: TObject);
    procedure btnNewAssignmentClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edtFilterChange(Sender: TObject);
    procedure btnEditProfileClick(Sender: TObject);
    procedure edtFilterClassroomsChange(Sender: TObject);
  private
  { Private declarations }
  const
    TAG: string = 'FORM_TEACHER_HOME';

  var
    // Dynamic components
    tbClassroom: TTabControl;
    lstClassroom: TListBox;
    edtFilter: TEdit;

    user: TUser;
    classrooms: TClassroomArray;
    selectedClassroom: TClassroom;
    assignments: TAssignmentArray;
    selectedAssignment: TAssignment;
    students: TUserArray;
    selectedStudent: TUser;

    procedure createDynamicComponents;
  public
    { Public declarations }
    procedure setUser(user: TUser);
    procedure setSelectedAssignment(assignment: TAssignment);
    procedure refreshClassrooms;
    procedure deselectCurrentClassroom;
  end;

var
  frmStudentHome: TfrmStudentHome;

implementation

uses Utilities_U, Authenticate_U, Create_Assignment_U, Logger_U,
  Edit_User_Profile_U;
{$R *.dfm}
{ TfrmStudentHome }

procedure TfrmStudentHome.btnJoinClassroomClick(Sender: TObject);
var
  classroom: TClassroom;
  success: boolean;
  id: string;
begin

  while not success do

    repeat
      id := inputbox('Join a classroom', 'Classroom code:', '');
      if id = '' then
        Exit;
      try
        strtoint(id);
        success := Utilities.joinClassroom(self.user, id, classroom);
      except
        Showmessage('Classroom codes are exclusively numeric.');
      end;
    until success;

    refreshClassrooms;
end;

procedure TfrmStudentHome.btnLeaveClassroomClick(Sender: TObject);
var
  buttonSelected: Integer;
begin
  buttonSelected := messagedlg('Are you sure you want to leave ' +
      selectedClassroom.getName + '?', TMsgDlgType.mtConfirmation, mbOKCancel,
    0);

  if buttonSelected = mrCancel then
    Exit;

  if Utilities.leaveClassroom(self.user, selectedClassroom) then
  begin
    Showmessage('You have left ' + selectedClassroom.getName);
    selectedClassroom.free;
  end;
  refreshClassrooms;
end;

procedure TfrmStudentHome.btnEditProfileClick(Sender: TObject);
begin
  frmEditUserProfile.setUser(user);
  frmEditUserProfile.Show;
end;

procedure TfrmStudentHome.btnLogoutClick(Sender: TObject);
begin
  self.Hide;
  frmAuthenticate.usePersistentLogin(false);
  frmAuthenticate.Show;
  self.user.Free;
  Utilities.depersistLogin;
  TLogger.log(TAG, TLogType.Debug, 'Logged out user');
end;

procedure TfrmStudentHome.btnNewAssignmentClick(Sender: TObject);
begin
  frmCreateAssignment.setClassroom(self.selectedClassroom);
  frmCreateAssignment.Show;
end;

procedure TfrmStudentHome.createDynamicComponents;

begin
  // Tab Controller
  tbClassroom := TTabControl.Create(self);
  with tbClassroom do
  begin
    Parent := self;
    Width := lstClassrooms.Width;
    Height := lstClassrooms.Height + 21;
    Left := lstClassrooms.Left + lstClassrooms.Width + 50;
    Top := lstClassrooms.Top - 21;
    Tabs.Add('Assignments');
    Tabs.Add('Peers');
    Visible := false;
    OnChange := tbClassroomChange;
    Anchors := [akLeft,akTop,akBottom];
  end;

  // List inside Tab Controller
  lstClassroom := TListBox.Create(self);
  with lstClassroom do
  begin
    Parent := tbClassroom;
    Width := tbClassroom.Width;
    Height := tbClassroom.Height - 42;
    Left := 0;
    Top := 42;
    Anchors := [akLeft,akTop,akBottom];
  end;

  // Filter inside tab controller
  edtFilter := TEdit.Create(self);
  with edtFilter do
  begin
    Parent := tbClassroom;
    Width := tbClassroom.Width;
    Height := 21;
    Left := 0;
    Top := 20;
    TextHint := 'Filter';
    OnChange := edtFilterChange;
    Anchors := [akLeft,akTop];
  end;

end;

procedure TfrmStudentHome.deselectCurrentClassroom;
begin
  if Assigned(selectedClassroom) then
  begin
    selectedClassroom := nil;
    refreshClassrooms;
  end;
end;

procedure TfrmStudentHome.edtFilterChange(Sender: TObject);
var
  query: string;
  a: TAssignment;
  s: TUser;
begin
  query := (Sender as TEdit).Text;

  lstClassroom.Clear;
  case tbClassroom.TabIndex of
    0: // Assignments
      begin
        for a in assignments do
        begin
          if (pos(lowercase(query), lowercase(a.getTitle)) > 0) or (query = '')
            then
          begin
            lstClassroom.Items.Add(a.getTitle);
          end;
        end;
      end;
    1: // Students
      begin
        for s in students do
        begin
          if (pos(lowercase(query),
              lowercase(s.getFirstName + s.getLastName + s.getEmail)) > 0) or
            (query = '') then
          begin
            lstClassroom.Items.Add(s.getLastName + ', ' + s.getFirstName);
          end;
        end;
      end;
  end;
end;

procedure TfrmStudentHome.edtFilterClassroomsChange(Sender: TObject);
var
  query: string;
  c: TClassroom;
begin
  query := (Sender as TEdit).Text;

  lstClassrooms.Clear;
  for c in classrooms do
  begin
    if (pos(lowercase(query), lowercase(c.getName)) > 0) or (query = '')
      then
    begin
      lstClassrooms.Items.Add(c.getName);
      if c.getID = selectedClassroom.getID then
      begin
        lstClassrooms.ItemIndex := lstClassrooms.Items.IndexOf(c.getName);
        // Make other components visible
        tbClassroom.Visible := true;
        lblInstruction.Visible := false;
      end;
    end;
  end;

  if lstClassrooms.Items.Count = 0 then
  begin
    // Make other components invisible
    tbClassroom.Visible := false;
    lblInstruction.Visible := true;
  end;

end;

procedure TfrmStudentHome.FormActivate(Sender: TObject);
begin
  if not Assigned(self.user) then
  begin
    setUser(TUser.Create('9971', 'a', 'a', 'a', TUserType.Teacher));
  end;
end;

procedure TfrmStudentHome.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Utilities.kill;
end;

procedure TfrmStudentHome.FormCreate(Sender: TObject);
begin
  createDynamicComponents;
end;

procedure TfrmStudentHome.lstClassroomsClick(Sender: TObject);
begin
  if lstClassrooms.ItemIndex > -1 then
  begin
    selectedClassroom := classrooms[lstClassrooms.ItemIndex];

    // Make other components visible
    tbClassroom.Visible := true;
    lblInstruction.Visible := false;

    // Update the tab bar
    tbClassroomChange(self);
  end;
end;

procedure TfrmStudentHome.refreshClassrooms;
var
  c: TClassroom;
begin
  lstClassrooms.Clear;
  // Get Classrooms
  classrooms := Utilities.getStudentClassrooms(self.user);
  if length(classrooms) = 0 then
  begin
    // Make other components invisible
    tbClassroom.Visible := false;
    lblInstruction.Visible := true;
  end else
  begin
    for c in classrooms do
      lstClassrooms.Items.Add(c.getName);
  end;

end;

procedure TfrmStudentHome.setSelectedAssignment(assignment: TAssignment);
begin
  self.selectedAssignment := assignment;
end;

procedure TfrmStudentHome.setUser(user: TUser);
begin

  self.user := user;

  // Refresh UI
  pnlHeader.Caption := 'Welcome ' + user.getFirstName;
  refreshClassrooms;
end;

procedure TfrmStudentHome.tbClassroomChange(Sender: TObject);
var
  a: TAssignment;
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

end.
