unit Log4D.Targets.ConsoleTarget;

interface

uses
  Log4D.Types, Log4D.Targets.CustomTarget;

type
  TConsoleTarget = class sealed(TCustomTarget)
  public
    procedure LogToTarget(const aLogLevel: TLogLevel; const aSourceInfo: TSourceInfo; const aMessage: string); override;
    function LogTarget: string; override;
  end;

implementation

uses
  System.Classes, System.Sysutils,

  System.Console;

const
  LogLevelColor: array [TLogLevel] of TConsoleColor = (TConsoleColor.Gray, TConsoleColor.Blue, TConsoleColor.Yellow, TConsoleColor.DarkMagenta, TConsoleColor.Red, TConsoleColor.DarkRed);

  { TConsoleTarget }

function TConsoleTarget.LogTarget: string;
begin
  Result := 'Console';
end;

procedure TConsoleTarget.LogToTarget(const aLogLevel: TLogLevel; const aSourceInfo: TSourceInfo; const aMessage: string);
begin
  TThread.Queue(nil,
      procedure
    var
      LogLine: string;
    begin
      LogLine := DateTimeToStr(aSourceInfo.LogTime) + '|' + sLogLevel[aLogLevel] + '|' + aSourceInfo.UnitName + '|' + aSourceInfo.LineNumber.ToString + '|' + aSourceInfo.ProcedureName + '|' +
        aMessage;

      Console.AllocateConsole;
      Console.Title := ToString;
      Console.ForegroundColor := LogLevelColor[aLogLevel];
      Console.WriteLine(LogLine);
    end);
end;

end.
