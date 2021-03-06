unit Edit_User_Profile_U;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, User_U;

type
  TfrmEditUserProfile = class(TForm)
    btnUpdate: TButton;
    edtEmail: TEdit;
    edtFirstName: TEdit;
    edtLastName: TEdit;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    edtNewPassword: TEdit;
    edtOldPassword: TEdit;
    Label2: TLabel;
    edtNewPasswordConfirm: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    btnChangePassword: TButton;
    procedure fieldSelected(sender: TObject);
    procedure profileFieldChanged(sender: TObject);
    procedure passwordFieldChanged(sender: TObject);
    procedure btnChangePasswordClick(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
  private
    { Private declarations }
    userOld: TUser;
    userNew: TUser;
    sender: Tform;
  public
    { Public declarations }
    procedure load(user: TUser; sender: Tform);
  end;

var
  frmEditUserProfile: TfrmEditUserProfile;

implementation

uses Utilities_U, Teacher_Home_U, Student_Home_U;

{$R *.dfm}

{ TfrmEditUserProfile }


procedure TfrmEditUserProfile.btnChangePasswordClick(Sender: TObject);
begin
  // TODO: Validation
  if Utilities.changePassword(userOld, edtOldPassword.Text, edtNewPassword.Text) then
  begin
    showmessage('Password changed successfully');
  end else
  begin
    Showmessage('Could not change password. Try again.');
  end;
end;

procedure TfrmEditUserProfile.btnUpdateClick(Sender: TObject);
begin
  userNew := TUser.Create(userOld.getID, edtEmail.Text, edtFirstName.Text, edtLastName.Text, userOld.getType);

  if Utilities.updateUserInformation(userOld, userNew) then
  begin
    case userOld.getType of
      Student: (self.sender as TfrmStudentHome).setUser(userNew);
      Teacher: (self.sender as TfrmTeacherHome).setUser(userNew);
    end;

    showmessage('Information changed successfully');
  end else
  begin
    Showmessage('Could not change information. Try again.')
  end;


end;

procedure TfrmEditUserProfile.fieldSelected(sender: TObject);
begin
  (sender as TEdit).SelectAll;
end;

procedure TfrmEditUserProfile.passwordFieldChanged(sender: TObject);
begin
  if not ((edtOldPassword.Text = '') and (edtNewPassword.Text = '') and (edtNewPasswordConfirm.Text = '')) then
  begin
    btnChangePassword.Enabled := true;
  end else
  begin
    btnChangePassword.Enabled := false;
  end;
end;

procedure TfrmEditUserProfile.profileFieldChanged(sender: TObject);
begin
  // TODO: Validation
  if not ((edtEmail.Text = userOld.getEmail) and
    (edtFirstName.Text = userold.getFirstName) and
    (edtLastName.Text = userold.getLastName)) then
  begin
    btnUpdate.Enabled := true;
  end else
  begin
    btnUpdate.Enabled := false;
  end;
end;

procedure TfrmEditUserProfile.load(user: TUser; sender: TForm);
begin
  self.userOld := user;
  edtEmail.Text := user.getEmail;
  edtFirstName.Text := user.getFirstName;
  self.sender := sender;
  edtLastName.Text := user.getLastName;
end;

end.
