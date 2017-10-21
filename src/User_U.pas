unit User_U;

interface

type
  TUserType = (Student = 1, Teacher);

  TUser = Class(TObject)
  private
    email, id, firstname, lastname: string;
    userType: TUserType;

  public
    // Setters
    procedure setEmail(email: string);
    procedure setFirstName(firstname: string);
    procedure setLastName(lastname: string);

    // Getters
    function getEmail(): string;
    function getID(): string;
    function getFirstName: string;
    function getLastName: string;
    function getType: TUserType;

    constructor Create(id, email, firstname, lastname: string;
      userType: TUserType); overload;
  end;

  TUserArray = array of TUser;

implementation

{ User }

constructor TUser.Create(id, email, firstname, lastname: string;
  userType: TUserType);
begin
  self.id := id;
  self.email := email;
  self.firstname := firstname;
  self.lastname := lastname;
  self.userType := userType;
end;

function TUser.getEmail: string;
begin
  result := self.email;
end;

function TUser.getFirstName: string;
begin
  result := self.firstname;
end;

function TUser.getID: string;
begin
  result := self.id;
end;

function TUser.getLastName: string;
begin
   result := self.lastname;
end;

function TUser.getType: TUserType;
begin
  result := self.userType;
end;

procedure TUser.setEmail(email: string);
begin
  self.email := email;
end;

procedure TUser.setFirstName(firstname: string);
begin
  self.firstname := firstname;
end;

procedure TUser.setLastName(lastname: string);
begin
  self.lastname := lastname;
end;

end.
