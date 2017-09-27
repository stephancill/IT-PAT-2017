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
    procedure FormCreate(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAuthenticate: TfrmAuthenticate;

implementation

uses Utilities_U, User_U;

var
   user: TUser;

{$R *.dfm}

procedure TfrmAuthenticate.btnLoginClick(Sender: TObject);
begin
  // TODO: Form validation
  if Utilities.loginUser(edtLoginEmail.Text, edtLoginPassword.Text, user) then
  begin
    showmessage('Logged in ' + user.firstname);
  end else
  begin
    // User not logged in
    showmessage('Could not find matching username/password');
  end;

end;

procedure TfrmAuthenticate.btnRegisterClick(Sender: TObject);
begin
  // TODO: Form validation
  if Utilities.registerUser(edtRegEmail.Text, edtRegPassword.Text, 'test', 'test', rdoAccountType.ItemIndex+1, user) then
  begin
    // Registration successful
    Showmessage('Registered ' + user.firstname);
  end else
  begin
    // Something went wrong

  end;


end;

procedure TfrmAuthenticate.FormCreate(Sender: TObject);
begin
  pnlLogin.Visible := false;
  pnlRegister.Visible := true;

  pnlLogin.Left := self.Width DIV 2 - pnlLogin.Width DIV 2;
  pnlRegister.Left := self.Width DIV 2 - pnlRegister.Width DIV 2;
end;

procedure TfrmAuthenticate.lblSwitchClick(Sender: TObject);
begin
  pnlLogin.Visible := not pnlLogin.Visible;
  pnlRegister.Visible := not pnlRegister.Visible;
end;

end.
