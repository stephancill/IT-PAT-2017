program IT_PAT_2017_P;

uses
  Forms,
  Login_U in 'Login_U.pas' {frmLogin},
  Register_U in 'Register_U.pas' {frmRegister},
  Data_Module_U in 'Data_Module_U.pas' {data_module: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmLogin, frmLogin);
  Application.CreateForm(TfrmRegister, frmRegister);
  Application.CreateForm(Tdata_module, data_module);
  Application.Run;
end.
