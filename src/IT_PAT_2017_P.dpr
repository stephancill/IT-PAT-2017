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
  Create_Assignment_U in 'Create_Assignment_U.pas' {frmCreateAssignment};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmAuthenticate, frmAuthenticate);
  Application.CreateForm(TfrmTeacherHome, frmTeacherHome);
  Application.CreateForm(TfrmCreateAssignment, frmCreateAssignment);
  Application.CreateForm(Tdata_module, data_module);
  Application.Run;
end.
