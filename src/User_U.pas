unit User_U;

interface

type
  TUserType = (Teacher=1, Student);
  TUser = Class(TObject)

    public
      email, id, firstname, lastname: string;
      userType: TUserType;
      constructor Create(id, email, firstname, lastname: string; userType: TUserType); overload;
  end;



implementation

{ User }

constructor TUser.Create(id, email, firstname, lastname: string; userType: TUserType);
begin
  self.id := id;
  self.email := email;
  self.firstname := firstname;
  self.lastname := lastname;
  self.userType := userType;
end;

end.
