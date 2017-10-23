unit Teacher_Home_U;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, User_U, Classroom_U, Assignment_U, Project_Dashboard_U;

type
  TfrmTeacherHome = class(TForm)
    pnlHeader: TPanel;
    btnCreateClassroom: TButton;
    lstClassrooms: TListBox;
    btnDeleteClassroom: TButton;
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

    // Left panel
    procedure btnCreateClassroomClick(Sender: TObject);
    procedure btnDeleteClassroomClick(Sender: TObject);
    procedure lstClassroomsClick(Sender: TObject);
    procedure edtFilterClassroomsChange(Sender: TObject);

    // Middle panel
    procedure tbClassroomChange(Sender: TObject);
    procedure edtFilterChange(sender: TObject);
    procedure lstClassroomClick(Sender: TObject);
    procedure btnNewAssignmentClick(Sender: TObject);

    // Right Panel
    procedure btnViewProjectClick(Sender: TObject);
    procedure btnRemoveFromClassroomClick(Sender: TObject);

    // Project list


  private
    { Private declarations }
    const
      TAG: string = 'FORM_TEACHER_HOME';
    var
      // Dynamic components
      tbClassroom : TTabControl;
      lstClassroom: TListBox;
      edtFilter: TEdit;
      lblClassroomCode: TLabel;
      btnNewAssignment: TButton;
      pnlInfo: TPanel;
      edtInfoTitle: TEdit;
      edtInfoDescription: TRichEdit;
      btnInfoPanel: TButton;
      lblProjects: TLabel;
      lstProjects: TListBox;

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
    procedure refreshTabController;
  end;

var
  frmTeacherHome: TfrmTeacherHome;

implementation

uses Utilities_U, Authenticate_U, Create_Assignment_U, Logger_U,
  Edit_User_Profile_U;

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

procedure TfrmTeacherHome.btnEditProfileClick(Sender: TObject);
var
  frm: TfrmEditUserProfile;
begin
  frm := TfrmEditUserProfile.Create(self);
  frm.load(user, self);
  frm.Show;
end;

procedure TfrmTeacherHome.btnLogoutClick(Sender: TObject);
begin
  self.Hide;
  frmAuthenticate.usePersistentLogin(false);
  frmAuthenticate.show;
  self.user.Free;
  Utilities.depersistLogin;
  TLogger.log(TAG, TLogType.Debug, 'Logged out user');
end;

procedure TfrmTeacherHome.btnNewAssignmentClick(Sender: TObject);
var
  frm: TfrmCreateAssignment;
begin
  frm := TfrmCreateAssignment.Create(nil);
  try
    frm.load(self.selectedClassroom, self);
    frm.ShowModal;
  finally
    frm.Free;
  end;
end;

procedure TfrmTeacherHome.btnRemoveFromClassroomClick(Sender: TObject);
var
  buttonSelected : integer;
  name: string;
begin
  name := selectedStudent.getFirstName + ' ' + selectedStudent.getLastName;
  buttonSelected := messagedlg('Are you sure you want to remove ' +
        name + '?', TMsgDlgType.mtConfirmation, mbOKCancel,
      0);

    if buttonSelected = mrCancel then
      Exit;

  if Utilities.removeStudent(selectedClassroom, selectedStudent) then
  begin
    selectedStudent := nil;
    tbClassroomChange(self);
  end;
end;

procedure TfrmTeacherHome.btnViewProjectClick(Sender: TObject);
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
    on E: Exception do
    begin
      Showmessage('Something went wrong... Check logs for more information.');
      TLogger.logException(TAG, 'btnViewProjectClick', e);
      Exit;
    end;
  end;

end;

procedure TfrmTeacherHome.createDynamicComponents;

begin
  // Tab Controller
  tbClassroom := TTabControl.Create(self);
  with tbClassroom do
  begin
    Parent := self;
    Width := lstClassrooms.Width;
    Height := lstClassrooms.Height;
    Left := lstClassrooms.Left + lstClassrooms.Width + 50;
    Top := lstClassrooms.Top;
    Tabs.Add('Assignments');
    Tabs.Add('Students');
    Visible := false;
    Anchors := [akLeft,akTop,akBottom];
    OnChange := tbClassroomChange;
  end;

  // Classroom code
  lblClassroomCode := Tlabel.Create(self);
  with lblClassroomCode do
  begin
    Parent := self;
    Top := tbClassroom.Top - 20;
    Left := tbClassroom.Left;
    Width := tbClassroom.Width;
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
    OnClick := lstClassroomClick;
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

  // Create assignment button
  btnNewAssignment := TButton.Create(self);
  with btnNewAssignment do
  begin
    Parent := self;
    Top := btnCreateClassroom.Top;
    Left := tbClassroom.Left + tbClassroom.Width - 99;
    Width := 99;
    Height := btnCreateClassroom.Height;
    Caption := 'New Assignment';
    Visible := false;
    OnClick := btnNewAssignmentClick;
    Anchors := [akLeft,akBottom];
  end;

  // Panel
  pnlInfo := TPanel.Create(self);
  with pnlInfo do
  begin
    Parent := self;
    Top := tbClassroom.Top;
    Left := tbClassroom.Left + tbClassroom.Width + 50;
    Width := tbClassroom.Width;
    Height := tbClassroom.Height;
    Anchors := [akLeft, akTop, akBottom];
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
    Anchors := [akLeft, akTop];
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
    Anchors := [akLeft, akTop];
  end;

  // Panel button
  btnInfoPanel := TButton.Create(self);
  with btnInfoPanel do
  begin
    Parent := pnlInfo;
    Left := 10;
    Top := edtInfoDescription.Top + edtInfoDescription.Height + 10;
    Width := edtInfoTitle.width;
    Anchors := [akLeft, akTop];
    OnClick := btnViewProjectClick;
  end;

  // Project list
  lstProjects := TListBox.Create(self);
  with lstProjects do
  begin
    Parent := self;
    Left := pnlInfo.Left + pnlInfo.Width + 50;
    Top := lstClassrooms.Top;
    Width := lstClassrooms.Width;
    Height := lstClassrooms.Height;
  end;

  lblProjects := TLabel.Create(self);
  with lblProjects do
  begin
    Parent := self;
    Left := lstProjects.Left;
    Top := lblClassrooms.Top;
    Caption := 'Projects'
  end;
end;

procedure TfrmTeacherHome.edtFilterChange(sender: TObject);
var
  query: string;
  a: TAssignment;
  s: TUser;
begin
  query := (sender as Tedit).Text;

  lstClassroom.Clear;
  case tbClassroom.TabIndex of
    0: // Assignments
    begin
      for a in assignments do
      begin
        if (pos(lowercase(query), lowercase(a.getTitle)) > 0) or (query = '') then
        begin
          lstClassroom.Items.Add(a.getTitle);
        end;
      end;
    end;
    1: // Students
    begin
      for s in students do
      begin
        if (pos(lowercase(query), lowercase(s.getFirstName + s.getLastName + s.getEmail)) > 0) or (query = '') then
        begin
          lstClassroom.Items.Add(s.getLastName + ', ' + s.getFirstName);
        end;
      end;
    end;
  end;
end;

procedure TfrmTeacherHome.edtFilterClassroomsChange(Sender: TObject);
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
          lblClassroomCode.Visible := true;
          btnNewAssignment.Visible := true;
          lblInstruction.Visible := false;
        end;
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
  createDynamicComponents;
end;

procedure TfrmTeacherHome.killProjectForm(project: TFrmProjectDashboard);
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

procedure TfrmTeacherHome.lstClassroomClick(Sender: TObject);
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
//    btnInfoPanel.visible := true;
//    btnInfoPanel.onClick := btnViewProjectClick;
//    btnInfoPanel.Caption := 'View Project';
  end else
  begin
  // Find the student in case filter is applied
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
    btnInfoPanel.caption := 'Remove Student';
    btnInfoPanel.onClick :=  btnRemoveFromClassroomClick;
    btnInfoPanel.visible := true;
  end;

end;

procedure TfrmTeacherHome.lstClassroomsClick(Sender: TObject);
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
    lblClassroomCode.Caption := 'Classroom Code: '  + selectedClassroom.getID;

    // Make other components visible
    tbClassroom.Visible := true;
    lblClassroomCode.Visible := true;
    btnNewAssignment.Visible := true;
    lblInstruction.Visible := false;
    pnlInfo.Visible := false;

    // Update the tab bar
    tbClassroomChange(self);
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

procedure TfrmTeacherHome.refreshTabController;
begin
  // Update tab
  tbClassroomChange(self);
end;

end.
