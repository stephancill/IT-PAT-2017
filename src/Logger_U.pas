unit Logger_U;

interface

uses SysUtils, Dialogs, DateUtils;

type
  TLogType = (Error = 1, Debug);

  TLogger = class (TObject)
    private
      const
        destination: string = 'SESSION_LOG.txt';
    public
      class procedure log(tag: string; logtype: TLogType; msg: string);
      class procedure logException(tag, func: string; ex: Exception);
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

class procedure TLogger.logException(tag, func: string; ex: Exception);
begin
  TLogger.log(TAG, TLogType.Error,
        '@' + func + ' Exception class name = ' + ex.ClassName + #13 +
          'Exception message = ' + ex.Message);
end;

end.
