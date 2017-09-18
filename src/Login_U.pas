unit Login_U;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmLogin = class(TForm)
    edtEmail: TEdit;
    edtPassword: TEdit;
    lblRegister: TLabel;
    btnLogin: TButton;
    procedure lblRegisterClick(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLogin: TfrmLogin;

implementation

uses Register_U, Utilities_U;

{$R *.dfm}

procedure TfrmLogin.btnLoginClick(Sender: TObject);
begin
  // TODO: Form validation
  showmessage(booltostr(Utilities.userExists('test@example.com', 'example123')));

end;

procedure TfrmLogin.lblRegisterClick(Sender: TObject);
begin
  self.Hide;
  frmRegister.Show;
end;

end.
