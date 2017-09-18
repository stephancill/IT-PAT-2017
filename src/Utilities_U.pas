unit Utilities_U;

interface

uses DB, ADODB, SysUtils;

type
  Utilities = Class
  private
    class function queryDatabase(query: string): TADOQuery;
  public
    class function userExists(email: string; password: string): boolean;
  end;

implementation

uses Data_Module_U;

{ Utilities }

class function Utilities.userExists(email: string; password: string): boolean;
begin
  result := queryDatabase('SELECT * FROM Users WHERE email = ' + QuotedStr(email) + ' AND password = ' + QuotedStr(password)).Eof;
end;

class function Utilities.queryDatabase(query: string): TADOQuery;
begin
  data_module.qry.Close;
  data_module.qry.SQL.Clear;
  data_module.qry.SQL.Add(query);
  data_module.qry.Open;

  result := data_module.qry;
end;



end.