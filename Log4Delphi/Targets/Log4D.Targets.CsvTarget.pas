unit Log4D.Targets.CsvTarget;

interface

uses
  System.Sysutils,

  Log4D.Types, Log4D.Targets.CustomTarget;

{$M+}

type
  TCsvTarget = class sealed(TCustomTarget)
  private
    FFileName: TFileName;
    procedure CreateFile;
    function LogLine(const aLogLevel: TLogLevel; const aSourceInfo: TSourceInfo; const aMessage: string): string;
  published
    property FileName: TFileName read FFileName write FFileName;
  public
    procedure LogToTarget(const aLogLevel: TLogLevel; const aSourceInfo: TSourceInfo; const aMessage: string); override;
    function LogTarget: string; override;
    constructor Create; override;
  end;

implementation

uses
  System.IoUtils, System.Classes;

{ TCsvTarget }

constructor TCsvTarget.Create;
begin
  inherited;
  FFileName := IncludeTrailingPathDelimiter(TPath.GetDocumentsPath) + TargetName + '.csv'
end;

procedure TCsvTarget.CreateFile;
var
  FileStream: TFileStream;
begin
  if TFile.Exists(FFileName) then
    exit;

  FileStream := TFile.Create(FFileName);
  with TStringlist.Create do
    try
      Add('LogTime,Log Level,Unit Name,Line Number,Procedure Name,Binary FileName,Log Message');
      SaveToStream(FileStream);
    finally
      Free;
      FreeAndNil(FileStream);
    end;
end;

function TCsvTarget.LogLine(const aLogLevel: TLogLevel; const aSourceInfo: TSourceInfo; const aMessage: string): string;
begin
  with TStringlist.Create do
    try
      Add(DateTimeToStr(aSourceInfo.LogTime));
      Add(sLogLevel[aLogLevel]);
      Add(aSourceInfo.UnitName);
      Add(aSourceInfo.LineNumber.ToString);
      Add(aSourceInfo.ProcedureName);
      Add(aSourceInfo.BinaryFileName);
      Add(aMessage);
      Result := CommaText;
    finally
      Free;
    end;
end;

function TCsvTarget.LogTarget: string;
begin
  Result := 'CSV File: ' + FFileName;
end;

procedure TCsvTarget.LogToTarget(const aLogLevel: TLogLevel; const aSourceInfo: TSourceInfo; const aMessage: string);
begin
  CreateFile;
  TFile.AppendAllText(FFileName, LogLine(aLogLevel, aSourceInfo, aMessage) + sLineBreak);
end;

end.
