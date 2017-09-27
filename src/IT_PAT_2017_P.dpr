program IT_PAT_2017_P;

uses
  Forms,
  Authenticate_U in 'Authenticate_U.pas' {frmAuthenticate},
  Data_Module_U in 'Data_Module_U.pas' {data_module: TDataModule},
  Utilities_U in 'Utilities_U.pas',
  User_U in 'User_U.pas',
  Teacher_Home_U in 'Teacher_Home_U.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(Tdata_module, data_module);
  Application.CreateForm(TfrmAuthenticate, frmAuthenticate);
  Application.Run;
end.
