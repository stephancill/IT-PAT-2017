unit Logger_U;

interface

uses SysUtils, Dialogs, DateUtils;

type
  TLogType = (Error = 1, Debug);

  TLogger = class (TObject)
    private
      const
        destination: string = 'SESSION-LOG.txt';
    public
      class procedure log(tag: string; logtype: TLogType; msg: string);

  end;
implementation



{ TLogger }

class procedure TLogger.log(tag: string; logtype: TLogType; msg: string);
var
  f: TextFile;
  t: string;
begin

  case logtype of
    Error: t := 'ERROR';
    Debug: t := 'DEBUG';
  end;

  msg := Format('%s %s (%s) - %s: %s', [datetostr(DateUtils.Today), timetostr(Time), tag, t, msg]);

  AssignFile(f,destination);
  try
    if fileExists(destination) then
    begin
      Append(f);
    end else
    begin
      ReWrite(f);
    end;

    writeLn(f, msg);

    CloseFile(f);
  except
     on E: Exception do
    begin
      Showmessage('Exception class name = ' + E.ClassName + #13 +
          'Exception message = ' + E.Message);
      Exit;
    end;
  end;
end;

end.
