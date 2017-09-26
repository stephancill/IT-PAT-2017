program IT_PAT_2017_P;

uses
  Forms,
  Authenticate_U in 'Authenticate_U.pas' {frmAuthenticate},
  Data_Module_U in 'Data_Module_U.pas' {data_module: TDataModule},
  Utilities_U in 'Utilities_U.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tdata_module, data_module);
  Application.CreateForm(TfrmAuthenticate, frmAuthenticate);
  Application.Run;
end.
