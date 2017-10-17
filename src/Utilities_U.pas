unit Utilities_U;

interface

uses DB, ADODB, SysUtils, StrUtils, Math, Dialogs, IdGlobal, IdHash, IdHashMessageDigest, User_U;

type
  Utilities = Class
  private
    class function queryDatabase(query: string): TADOQuery;
    class procedure modifyDatabase(sql: string);
    class function userExists(email, password: string): boolean;
    class function getMD5Hash(s: string): string;
  public
    class function registerUser(email, password, firstname, lastname: string; userType: Integer; var user: TUser): boolean;
    class function loginUser(email, password: string; var user: TUser): boolean;
  end;

implementation

uses Data_Module_U;

{ Utilities }

class function Utilities.registerUser(email, password, firstname, lastname: string; userType: Integer; var user: TUser): boolean;
var
  id: string;
begin
  {
    1. Check if user exists
    2. Create user in Users table
    3. Get generated ID
    4. Create user in Teacher/Student table with generated ID
    5. Create and return TUser object
  }

  // 1. Check if user exists
  if userExists(email, password) then
  begin
    Showmessage('Email already in use.');
    result := false;
    Exit;
  end;

  try
    // 2. Create user in Users table
    modifyDatabase
      ('INSERT INTO Users (Email, [Password], Type) VALUES (' +
      quotedStr(email) + ',' + quotedStr(getMD5Hash(password)) + ',' + inttostr(userType) +
      ')');

    // 3. Get generated ID
    id := queryDatabase('SELECT ID FROM Users WHERE Email LIKE ' + quotedStr(email)).FieldByName('ID').AsString;

    // 4. Create user in Teacher or Student table with generated ID
    modifyDatabase
      ('INSERT INTO ' + IfThen(userType=1, 'Student', 'Teacher') + ' ([ID], Email, FirstName, LastName) VALUES (' +
      id + ',' + quotedStr(email) + ',' + quotedStr(firstname) + ',' + quotedStr(lastname) +
      ')');

  except
    on E : Exception do
     begin
       ShowMessage('Exception class name = '+E.ClassName + #13 + 'Exception message = '+E.Message);
       result := false;
       Exit;
     end;
  end;

  // 5. Create and return TUser object
  user := TUser.Create(id, email, firstname, lastname, TUserType(userType));
  result := true;
end;

class function Utilities.loginUser(email, password: string; var user: TUser): boolean;
var
  qry: TADOQuery;
  id, firstname, lastname: string;
  userType: integer;
begin
  {
    1. Check if user exists
    2. Retrieve **user type** and ID with entered email/password combination
    3. Retrieve user from Teacher/Student table with ID
    4. Create and return TUser object
  }

  qry := queryDatabase('SELECT * FROM Users WHERE email = ' + quotedStr
      (email) + ' AND password = ' + quotedStr(getMD5Hash(password)));

  // 1. Check if user exists
  if not qry.Eof then
  begin
    // 2. Retrieve **user type** and ID with entered email/password combination
    id := qry.FieldByName('ID').AsString;
    userType := qry.FieldByName('Type').AsInteger;

    // 3. Retrieve user from Teacher/Student table with ID
    qry := queryDatabase('SELECT * FROM ' + IfThen(userType=1, 'Student', 'Teacher') + ' WHERE ID = ' + quotedStr
      (id));

    firstname := qry.FieldByName('FirstName').AsString;
    lastname := qry.FieldByName('LastName').AsString;

    // 4. Create and return TUser object
    user := TUser.Create(id, email, firstname, lastname, TUserType(userType));
    result := true;
    Exit;
  end else
    result := false;

end;

class function Utilities.userExists(email, password: string): boolean;
begin
  result := not queryDatabase('SELECT * FROM Users WHERE email = ' + quotedStr
      (email) + ' AND password = ' + quotedStr(getMD5Hash(password))).Eof;
end;

// https://stackoverflow.com/a/18233500
class function Utilities.getMD5Hash(s: string): string;
var
    hashMessageDigest5 : TIdHashMessageDigest5;
begin
    hashMessageDigest5 := nil;
    try
        hashMessageDigest5 := TIdHashMessageDigest5.Create;
        Result := IdGlobal.IndyLowerCase ( hashMessageDigest5.HashStringAsHex ( s ) );
    finally
        hashMessageDigest5.Free;
    end;
end;

class procedure Utilities.modifyDatabase(sql: string);
begin
  data_module.qry.Close;
  data_module.qry.sql.Clear;
  data_module.qry.sql.Add(sql);

  data_module.qry.ExecSQL;
end;

class function Utilities.queryDatabase(query: string): TADOQuery;
begin
  data_module.qry.Close;
  data_module.qry.sql.Clear;
  data_module.qry.sql.Add(query);

  data_module.qry.Open;

  result := data_module.qry;
end;

end.
