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
    edtFirstName: TEdit;
    edtLastName: TEdit;
    chkRememberMe: TCheckBox;
    procedure lblSwitchClick(Sender: TObject);
    procedure btnRegisterClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    const
      TAG: string = 'FORM_AUTHENTICATE';
    var
      hashed: boolean;
  public
    { Public declarations }
  end;

var
  frmAuthenticate: TfrmAuthenticate;

implementation

uses Utilities_U, User_U, Teacher_Home_U, Logger_U, ApplicationDelegate_U;

var
   user: TUser;

{$R *.dfm}

procedure TfrmAuthenticate.btnLoginClick(Sender: TObject);
begin
  // TODO: Form validation
  if Utilities.loginUser(edtLoginEmail.Text, edtLoginPassword.Text, user, hashed) then
  begin
    if chkRememberMe.Checked then
    begin
      Utilities.persistLogin(edtLoginEmail.Text, edtLoginPassword.Text);
    end else
    begin
      Utilities.depersistLogin;
    end;

    edtLoginEmail.Text := ''; 
    edtLoginPassword.Text := '';
    
    case user.getType of
      teacher :
        begin
        frmTeacherHome.setUser(user);
        frmTeacherHome.Show;
        self.Hide;
        end;
      student : showmessage('student') // TODO: Student screen
    end;
  end else
  begin
    // User not logged in
    showmessage('Could not find matching username/password');
  end;

end;

procedure TfrmAuthenticate.btnRegisterClick(Sender: TObject);
begin
  // TODO: Form validation
  if Utilities.registerUser(edtRegEmail.Text, edtRegPassword.Text, edtFirstName.Text, edtLastName.Text, rdoAccountType.ItemIndex+1, user) then
  begin
    // Registration successful
    Showmessage('Registered ' + user.getFirstname);
  end else
  begin
    // Something went wrong

  end;
end;

procedure TfrmAuthenticate.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Utilities.kill;
end;

procedure TfrmAuthenticate.FormCreate(Sender: TObject);
var
 email, password: string;
begin
  frmApplicationDelegate.applicationReady;

  hashed := false;
  
  pnlLogin.Visible := true;
  pnlRegister.Visible := false;

  pnlLogin.Left := self.Width DIV 2 - pnlLogin.Width DIV 2;
  pnlRegister.Left := self.Width DIV 2 - pnlRegister.Width DIV 2;

  // Login persistence
  if FileExists(Utilities.persistentLoginDestination) then
  begin
    if Utilities.getPersistedLogin(email, password) then
    begin
      hashed := true;
      edtLoginEmail.Text := email;
      edtLoginPassword.Text := password;
      btnLoginClick(self);
    end;
  end;
end;

procedure TfrmAuthenticate.lblSwitchClick(Sender: TObject);
begin
  pnlLogin.Visible := not pnlLogin.Visible;
  pnlRegister.Visible := not pnlRegister.Visible;
end;

end.
