unit Utilities_U;

interface

uses DB, ADODB, SysUtils, StrUtils, Math, Dialogs;

type
  Utilities = Class
  private
    class function queryDatabase(query: string): TADOQuery;
    class procedure modifyDatabase(sql: string);
    class function userExists(email, password: string): boolean;
  public
    class function loginUser(email, password: string): boolean;
    class function registerUser(email, password, user_type: string): boolean;
  end;

implementation

uses Data_Module_U;

{ Utilities }

class function Utilities.registerUser(email, password, user_type: string)
  : boolean;
begin
  if userExists(email, password) then
  begin
    Showmessage('Email already in use.');
    result := false;
    Exit;
  end;

  try
    modifyDatabase
      ('INSERT INTO Users ([ID], Email, [Password], Type) VALUES (' +
      inttostr(randomrange(1000, 9999)) + ',' + quotedStr(email) + ',' + quotedStr(password) + ',' + quotedStr(user_type) +
      ')');

    // TODO: Add to teachers/students database
  except
    on E : Exception do
     begin
       ShowMessage('Exception class name = '+E.ClassName + #13 + 'Exception message = '+E.Message);
       result := false;
       Exit;
     end;

  end;

  result := true;

end;

class function Utilities.userExists(email, password: string): boolean;
begin
  result := not queryDatabase('SELECT * FROM Users WHERE email = ' + quotedStr
      (email) + ' AND password = ' + quotedStr(password)).Eof;
end;

class function Utilities.loginUser(email, password: string): boolean;
begin
  // TODO: return user object
  result := userExists(email, password);
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
