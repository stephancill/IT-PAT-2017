unit Authenticate_U;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, StrUtils, pngimage;

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
    Image1: TImage;
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
      hashed: boolean;  // Is the password in the edit hashed or not

    function validateForm: boolean;
    procedure clearRegisterForm;
  public
    { Public declarations }
    procedure usePersistentLogin(bool: boolean);
  end;

var
  frmAuthenticate: TfrmAuthenticate;

implementation

uses Utilities_U, User_U, Teacher_Home_U, Logger_U, ApplicationDelegate_U,
  Student_Home_U;

var
   user: TUser;

{$R *.dfm}

procedure TfrmAuthenticate.btnLoginClick(Sender: TObject);
var
  frmStudent: TfrmStudentHome;
  frmTeacher: TfrmTeacherHome;
begin
  // TODO: Form validation
  if Utilities.loginUser(edtLoginEmail.Text, edtLoginPassword.Text, user, hashed) then
  begin
    if chkRememberMe.Checked or hashed then
    begin
      Utilities.persistLogin(edtLoginEmail.Text, edtLoginPassword.Text, hashed);
    end else
    begin
      Utilities.depersistLogin;
    end;

    edtLoginEmail.Text := ''; 
    edtLoginPassword.Text := '';
    
    case user.getType of
      teacher :
      begin
        frmTeacher := TfrmTeacherHome.Create(nil);
        frmTeacher.setUser(user);
        frmTeacher.Show;
        self.Hide;
      end;
      student :
      begin
        frmStudent := TfrmStudentHome.Create(nil);
        frmStudent.setUser(user);
        frmStudent.Show;
        self.Hide;
      end;
    end;
  end else
  begin
    Utilities.depersistLogin;
    // User not logged in
    if not hashed then
    begin
      showmessage('Could not find matching username/password');
    end else
    begin
      edtLoginPassword.text := '';
    end;

    hashed := false;
  end;


end;

procedure TfrmAuthenticate.btnRegisterClick(Sender: TObject);
begin
  // TODO: Form validation
  if not validateForm then
    Exit;

  if Utilities.registerUser(edtRegEmail.Text, edtRegPassword.Text, edtFirstName.Text, edtLastName.Text, rdoAccountType.ItemIndex+1, user) then
  begin
    // Registration successful
    pnlLogin.Visible := true;
    pnlRegister.Visible := false;
    Showmessage('Registered ' + user.getFirstname);
  end else
  begin
    // Something went wrong

  end;
end;

procedure TfrmAuthenticate.clearRegisterForm;
begin
  edtRegEmail.text := '';
  edtRegPassword.text := '';
  edtRegConfirmPassword.text := '';
  edtFirstName.text := '';
  edtLastName.text := '';
  rdoAccountType.itemIndex := 0;
end;

procedure TfrmAuthenticate.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Utilities.kill;
end;

procedure TfrmAuthenticate.FormCreate(Sender: TObject);
var
 email, password: string;
begin
  Show;

  clearRegisterForm;

  hashed := false;
  
  pnlLogin.Visible := true;
  pnlRegister.Visible := false;

  pnlLogin.Left := self.Width DIV 3 - pnlLogin.Width DIV 2;
  pnlRegister.Left := self.Width DIV 3 - pnlRegister.Width DIV 2;

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

procedure TfrmAuthenticate.usePersistentLogin(bool: boolean);
begin
  self.hashed := bool;
end;

function TfrmAuthenticate.validateForm: boolean;
var
  c, email, password, confirmPassword, firstName, LastName: string;
  flag1, flag2: boolean;
begin
  email := edtRegEmail.text;
  password := edtRegPassword.Text;
  confirmpassword := edtRegConfirmPassword.Text;
  firstName := edtFirstName.Text;
  lastName := edtLastName.Text;

  result := false;
  // Email
  if not ((pos('@', email) > 0) and (pos('.', email) > 0) and (length(email) > 3) and (length(email) < 64)) then
  begin
    ShowMessage('Invalid email address.');
    edtregemail.SetFocus;
    Exit;
  end;

  // Password
  // - Length
  if not (length(password) >= 6) then
  begin
    edtregPassword.SetFocus;
    ShowMessage('Pasword must be at least 6 characters long.');
    Exit;
  end;
  // - Strength
  flag1 := false;
  flag2 := false;
  for c in password do
  begin
    if uppercase(c) = c then
      flag1 := true;

    if lowercase(c) = c then
      flag2 := true;
  end;
  if not ((flag1) and (flag2)) then
  begin
    Showmessage('Password must contain at least one uppercase and one lowercase character.');
    edtRegPassword.SetFocus;
    Exit;
  end;
  // - Confirmation
  if not (password = confirmpassword) then
  begin
    Showmessage('Passwords do not match');
    edtRegConfirmPassword.SetFocus;
    Exit;
  end;

  // First Name
  if not (length(firstName) > 0) then
  begin
    ShowMessage('Please enter your first name');
    edtFirstName.SetFocus;
    Exit;
  end;

  // Last Name
  if not (length(firstName) > 0) then
  begin
    ShowMessage('Please enter your last name');
    edtLastname.SetFocus;
    Exit;
  end;

  result := true;

end;

end.
