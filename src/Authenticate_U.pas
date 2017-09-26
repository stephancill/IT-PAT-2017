unit Authenticate_U;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, StrUtils;

type
  TfrmAuthenticate = class(TForm)
    edtRegConfirmPassword: TEdit;
    edtRegEmail: TEdit;
    edtRegPassword: TEdit;
    lblLogin: TLabel;
    btnRegister: TButton;
    rdoAccountType: TRadioGroup;
    pnlRegister: TPanel;
    pnlLogin: TPanel;
    edtLoginEmail: TEdit;
    edtLoginPassword: TEdit;
    btnLogin: TButton;
    lblRegister: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    procedure lblSwitchClick(Sender: TObject);
    procedure btnRegisterClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAuthenticate: TfrmAuthenticate;

implementation

uses Utilities_U;

{$R *.dfm}

procedure TfrmAuthenticate.btnRegisterClick(Sender: TObject);
begin
  // TODO: Form validation
  showmessage(booltostr(Utilities.registerUser(edtRegEmail.Text, edtRegPassword.Text, IfThen(rdoAccountType.ItemIndex = 0, 'student', 'teacher'))));
end;

procedure TfrmAuthenticate.lblSwitchClick(Sender: TObject);
begin
  pnlLogin.Visible := not pnlLogin.Visible;
  pnlRegister.Visible := not pnlRegister.Visible;
end;

end.
