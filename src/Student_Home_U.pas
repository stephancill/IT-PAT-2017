unit Student_Home_U;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, User_U, Classroom_U, Assignment_U, Project_Dashboard_U;

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

    // Form
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure killProjectForm(project: TFrmProjectDashboard);

    // Top panel
    procedure btnLogoutClick(Sender: TObject);
    procedure btnEditProfileClick(Sender: TObject);

    // Left Panel
    procedure btnJoinClassroomClick(Sender: TObject);
    procedure btnLeaveClassroomClick(Sender: TObject);
    procedure lstClassroomsClick(Sender: TObject);
    procedure edtFilterClassroomsChange(Sender: TObject);

    // Middle Panel
    procedure tbClassroomChange(Sender: TObject);
    procedure btnNewAssignmentClick(Sender: TObject);
    procedure edtFilterChange(Sender: TObject);
    procedure lstClassroomClick(Sender: TObject);

    // Right Panel
    procedure btnViewProjectClick(Sender: TObject);
    procedure btnRemoveFromClassroomClick(Sender: TObject);

  private
  { Private declarations }
  const
    TAG: string = 'FORM_TEACHER_HOME';

  var
    // Dynamic components
    tbClassroom: TTabControl;
    lstClassroom: TListBox;
    edtFilter: TEdit;
    pnlInfo: TPanel;
    edtInfoTitle: TEdit;
    edtInfoDescription: TRichEdit;
    btnInfoPanel: TButton;

    user: TUser;
    classrooms: TClassroomArray;
    selectedClassroom: TClassroom;
    assignments: TAssignmentArray;
    selectedAssignment: TAssignment;
    students: TUserArray;
    selectedStudent: TUser;

    projectForms: array of TFrmProjectDashboard;

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

procedure TfrmStudentHome.btnRemoveFromClassroomClick(Sender: TObject);
begin
  showmessage('remove from classroom');
end;

procedure TfrmStudentHome.btnViewProjectClick(Sender: TObject);
var
  frmProject: TfrmProjectDashboard;
  
begin
  for frmProject in projectForms do
  begin
    if Assigned(frmProject) then
    begin
      if (frmProject.getAssignment.getID = selectedAssignment.getID) and (frmProject.getUser.getID = user.getID) then
      begin
        frmProject.show;
        Exit;
      end;
    end;
  end;

  SetLength(projectForms, length(projectForms)+1);  
  frmProject := TfrmProjectDashboard.Create(self);
  try
    projectForms[length(projectForms)-1] := frmProject;
    frmProject.load(selectedAssignment, user, self);
    frmProject.Show;
  except
  end;
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
    Onclick := lstClassroomClick;
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

  // Panel
  pnlInfo := TPanel.Create(self);
  with pnlInfo do
  begin
    Parent := self;
    Top := tbClassroom.Top;
    Left := tbClassroom.Left + tbClassroom.Width + 50;
    Width := self.Width - pnlInfo.Left - 50;
    Height := tbClassroom.Height;
    Anchors := [akLeft, akRight, akTop, akBottom];
    Visible := false
  end;

  // Panel title
  edtInfoTitle := TEdit.Create(self);
  with edtInfoTitle do
  begin
    Parent := pnlInfo;
    Left := 10;
    Top := 10;
    Width := pnlInfo.Width - 20;
    ReadOnly := true;
    Anchors := [akLeft, akRight, akTop];
  end;

  // Panel description
  edtInfoDescription := TRichEdit.Create(self);
  with edtInfoDescription do
  begin
    Parent := pnlInfo;
    Left := 10;
    Top := edtInfoTitle.Top + edtInfoTitle.Height + 10;
    Width := edtInfoTitle.width;
    Height := 100;
    ReadOnly := true;
    Anchors := [akLeft, akRight, akTop];
  end;

  // Panel button
  btnInfoPanel := TButton.Create(self);
  with btnInfoPanel do
  begin
    Parent := pnlInfo;
    Left := 10;
    Top := edtInfoDescription.Top + edtInfoDescription.Height + 10;
    Width := edtInfoTitle.width;
    OnClick := btnViewProjectClick;
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
      if Assigned(selectedClassroom) then
      begin
        if c.getID = selectedClassroom.getID then
        begin
          lstClassrooms.ItemIndex := lstClassrooms.Items.IndexOf(c.getName);
          // Make other components visible
          tbClassroom.Visible := true;
          lblInstruction.Visible := false;
          pnlInfo.Visible := false;
        end;
      end;
    end;
  end;

  if lstClassrooms.Items.Count = 0 then
  begin
    // Make other components invisible
    tbClassroom.Visible := false;
    lblInstruction.Visible := true;
    pnlInfo.Visible := false;
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

procedure TfrmStudentHome.killProjectForm(project: TFrmProjectDashboard);
var
  f : TFrmProjectDashboard;
  i : integer;
begin
  for I := 0 to length(projectForms) -1 do
  begin
    f := projectForms[i];
    if assigned(projectForms[i]) then
    begin
      if (f.getAssignment.getID = project.getAssignment.getID) and (f.getUser.getID = project.getUser.getID) then
    begin
      project.Free;
      projectForms[i] := nil;
      break;
    end;
    end;
    
  end;
end;

procedure TfrmStudentHome.lstClassroomClick(Sender: TObject);
var
  a: TAssignment;
  s: TUser;
  query: string;
begin
  if lstClassroom.ItemIndex = -1 then
  begin
    Exit;
  end;

  if tbClassroom.TabIndex = 0 then
  begin
    // Find the assignment in case filter is applied
    if edtFilter.Text <> '' then
    begin
      for a in assignments do
      begin
        if (pos(lowercase(query), lowercase(a.getTitle)) > 0) or (query = '')
          then
        begin
          selectedAssignment := a;
          Break;
        end;
      end;
    end else
    begin
      selectedAssignment := assignments[lstClassroom.itemIndex];
    end;

    // Prepare panel
    pnlInfo.Visible := true;
    edtInfoTitle.Text := selectedAssignment.getTitle;
    edtInfoDescription.Text := 'Date issued: ' + selectedAssignment.getDateIssued + #13#13 + selectedAssignment.getDescription;
    btnInfoPanel.visible := true;
    btnInfoPanel.Caption := 'View Project';
  end else
  begin
  // Find the assignment in case filter is applied
    if edtFilter.Text <> '' then
    begin
      for s in students do
      begin
        if (pos(lowercase(query), lowercase(a.getTitle)) > 0) or (query = '')
          then
        begin
          selectedStudent := s;
          Break;
        end;
      end;
    end else
    begin
      selectedStudent := students[lstClassroom.itemIndex];
    end;

    // Prepare panel
    pnlInfo.Visible := true;
    edtInfoTitle.Text := 'Student';
    edtInfoDescription.Text := selectedStudent.getLastName + ', ' + selectedStudent.getFirstName + #13#13 + 'mailto:' + selectedStudent.getEmail;
    btnInfoPanel.visible := false;
  end;
end;



procedure TfrmStudentHome.lstClassroomsClick(Sender: TObject);
begin
  if lstClassrooms.ItemIndex > -1 then
  begin
    // Avoid unnecessarily updating
    if Assigned(selectedClassroom) then
    begin
      if selectedClassroom.getID = classrooms[lstClassrooms.ItemIndex].getID then
      Exit;
    end;

    selectedClassroom := classrooms[lstClassrooms.ItemIndex];

    // Make other components visible
    tbClassroom.Visible := true;
    lblInstruction.Visible := false;
    pnlInfo.Visible := false;

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
    pnlInfo.Visible := false
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
  pnlInfo.visible := false;
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
