program IT_PAT_2017_P;

uses
  Forms,
  Authenticate_U in 'Authenticate_U.pas' {frmAuthenticate},
  Data_Module_U in 'Data_Module_U.pas' {data_module: TDataModule},
  Utilities_U in 'Utilities_U.pas',
  User_U in 'User_U.pas',
  Teacher_Home_U in 'Teacher_Home_U.pas' {frmTeacherHome},
  Classroom_U in 'Classroom_U.pas',
  Assignment_U in 'Assignment_U.pas',
  Create_Assignment_U in 'Create_Assignment_U.pas' {frmCreateAssignment},
  Logger_U in 'Logger_U.pas',
  ApplicationDelegate_U in 'ApplicationDelegate_U.pas' {frmApplicationDelegate},
  Edit_User_Profile_U in 'Edit_User_Profile_U.pas' {frmEditUserProfile},
  Student_Home_U in 'Student_Home_U.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.ShowMainForm := false;
  Application.CreateForm(TfrmApplicationDelegate, frmApplicationDelegate);
  Application.CreateForm(Tdata_module, data_module);
  Application.CreateForm(TfrmTeacherHome, frmTeacherHome);
  Application.CreateForm(TfrmStudentHome, frmStudentHome);
  Application.CreateForm(TfrmCreateAssignment, frmCreateAssignment);
  Application.CreateForm(TfrmAuthenticate, frmAuthenticate);
  Application.CreateForm(TfrmEditUserProfile, frmEditUserProfile);
  Application.Run;

end.
