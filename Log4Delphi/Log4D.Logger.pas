unit Log4D.Logger;

interface

uses
  Log4D.Types;

type
  TLogger = class
  private
    class var Instance: TLogger;
  strict private
    function GetSourceInfo: TSourceInfo;
    procedure DoLog(const aLogLevel: TLogLevel; const aMessage: string);
  public
    procedure Trace(aMessage: string); overload;
    procedure Trace(aMessage: string; const Args: array of const); overload;
    procedure Debug(aMessage: string); overload;
    procedure Debug(aMessage: string; const Args: array of const); overload;
    procedure Info(aMessage: string); overload;
    procedure Info(aMessage: string; const Args: array of const); overload;
    procedure Warn(aMessage: string); overload;
    procedure Warn(aMessage: string; const Args: array of const); overload;
    procedure Error(aMessage: string); overload;
    procedure Error(aMessage: string; const Args: array of const); overload;
    procedure Fatal(aMessage: string); overload;
    procedure Fatal(aMessage: string; const Args: array of const); overload;
    class function VariableString<T>(aVariableName: string; aValue: T): string;
    class function GenericToString<T>(aValue: T): string;
  end;

function Log: TLogger; inline;

implementation

uses
  System.Sysutils, System.Rtti, System.TypInfo, System.Threading, System.Classes, JCLDebug,
  Log4D.LogManager, Log4D.Targets.CustomTarget;

function Log: TLogger;
begin
  Result := TLogger.Instance.Instance;
end;
{ TLogger }

procedure TLogger.Debug(aMessage: string);
begin
  DoLog(TLogLevel.llDebug, aMessage);
end;

procedure TLogger.Debug(aMessage: string; const Args: array of const);
begin
  DoLog(TLogLevel.llDebug, Format(aMessage, Args));
end;

procedure TLogger.DoLog(const aLogLevel: TLogLevel; const aMessage: string);
var
  Target: TCustomTarget;
  SourceInfo: TSourceInfo;
  Manager: TLogManager;
begin
  Manager := LogManager;
  SourceInfo := GetSourceInfo;

  for Target in Manager.LogTargets.Values do
    if Target.MinimumLogLevel <= aLogLevel then
      try
        Target.LogToTarget(aLogLevel, SourceInfo, aMessage);
      except

      end
end;

procedure TLogger.Error(aMessage: string; const Args: array of const);
begin
  DoLog(TLogLevel.llError, Format(aMessage, Args));
end;

procedure TLogger.Error(aMessage: string);
begin
  DoLog(TLogLevel.llError, aMessage);
end;

procedure TLogger.Fatal(aMessage: string; const Args: array of const);
begin
  DoLog(TLogLevel.llFatal, Format(aMessage, Args));
end;

procedure TLogger.Fatal(aMessage: string);
begin
  DoLog(TLogLevel.llFatal, aMessage);
end;

class function TLogger.GenericToString<T>(aValue: T): string;
var
  ElementValue, Value: TValue;
  Data: PTypeData;
  I: Integer;
  RttiRecordType: TRttiRecordType;
begin
  TValue.Make(@aValue, System.TypeInfo(T), Value);

  if Value.IsArray then
  begin
    if Value.GetArrayLength = 0 then
      Exit('[ø]');

    Result := '[';

    for I := 0 to Value.GetArrayLength - 1 do
    begin
      ElementValue := Value.GetArrayElement(I);
      Result := Result + ElementValue.ToString + ',';
    end;

    Result[Length(Result)] := ']';
    Exit;
  end;

  Data := GetTypeData(Value.TypeInfo);

  if (Value.IsObject) and (Value.TypeInfo^.Kind <> tkInterface) then
    Exit(Format('0x%p %s', [pointer(Value.AsObject), Data.ClassType.ClassName]));

  if Value.TypeInfo^.Kind = tkRecord then
  begin
    RttiRecordType := TRttiContext.Create.GetType(Value.TypeInfo).AsRecord;
    Exit(Format('0x%p (Record ''%s'' @ %p)', [Value.GetReferenceToRawData, RttiRecordType.Name, Data]));
  end;

  Result := Value.ToString;
end;

function TLogger.GetSourceInfo: TSourceInfo;
const
  Level = 3;
var
  Info: TJclLocationInfo;
begin
  Info := GetLocationInfo(Caller(Level));
  Result.LogTime := now;
  Result.UnitName := Info.UnitName;
  Result.ProcedureName := Info.ProcedureName;
  Result.LineNumber := Info.LineNumber;
  Result.BinaryFileName := Info.BinaryFileName
end;

procedure TLogger.Info(aMessage: string);
begin
  DoLog(TLogLevel.llInfo, aMessage);
end;

procedure TLogger.Info(aMessage: string; const Args: array of const);
begin
  DoLog(TLogLevel.llInfo, Format(aMessage, Args));
end;

procedure TLogger.Trace(aMessage: string);
begin
  DoLog(TLogLevel.llTrace, aMessage);
end;

procedure TLogger.Trace(aMessage: string; const Args: array of const);
begin
  DoLog(TLogLevel.llTrace, Format(aMessage, Args));
end;

class function TLogger.VariableString<T>(aVariableName: string; aValue: T): string;
begin
  Result := Format('[%s] = [%s]', [aVariableName, GenericToString(aValue)]);
end;

procedure TLogger.Warn(aMessage: string);
begin
  DoLog(TLogLevel.llWarn, aMessage);
end;

procedure TLogger.Warn(aMessage: string; const Args: array of const);
begin
  DoLog(TLogLevel.llWarn, Format(aMessage, Args));
end;

initialization

TLogger.Instance := TLogger.Create;

finalization

Log.Free;

end.
