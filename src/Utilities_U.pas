unit Utilities_U;

interface

uses DB, ADODB, SysUtils, StrUtils;

type
  Utilities = Class
  private
    class function queryDatabase(query: string): TADOQuery;
  public
    class function userExists(email, password: string): boolean;
    class function registerUser(email, password, user_type: string): boolean;
  end;

implementation

uses Data_Module_U;

{ Utilities }

class function Utilities.registerUser(email, password, user_type: string): boolean;
begin
  if userExists(email, password) then
    result := false;

  result := not queryDatabase(
  'INSERT INTO Users (ID, Email, Password, Type) VALUES (' +
  '1,' + quotedStr(email) + ',' + quotedStr(password) + ',' + quotedStr(user_type) +
  ')').Eof;

end;

class function Utilities.userExists(email, password: string): boolean;
begin
  result := not queryDatabase('SELECT * FROM Users WHERE email = ' + QuotedStr(email) + ' AND password = ' + QuotedStr(password)).Eof;
end;

class function Utilities.queryDatabase(query: string): TADOQuery;
begin
  data_module.qry.Close;
  data_module.qry.SQL.Clear;
  data_module.qry.SQL.Add(query);

  try
    data_module.qry.Open;
  except
    data_module.qry.ExecSQL;
  end;

  result := data_module.qry;
end;



end.
