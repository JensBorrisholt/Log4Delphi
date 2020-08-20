unit Log4D.Targets.CustomTarget;

interface

uses
  Log4D.Types;

{$M+}

type
  TOnTargetNameChanged = reference to procedure(const aOldName, aNewName: string);

  TCustomTarget = class abstract
  private
    FMinimumLogLevel: TLogLevel;
    FTargetName: string;
    FOnTargetNameChanged: TOnTargetNameChanged;
    procedure SetTargetName(const Value: string);
    function GetLevelEnabled(const Index: TLogLevel): Boolean;
  public
    procedure LogToTarget(const aLogLevel: TLogLevel; const aSourceInfo: TSourceInfo; const aMessage: string); virtual; abstract;
    class function AddToManager(aMinimumLogLevel: TLogLevel): TCustomTarget;
    function Instance<T: TCustomTarget>: T;
  published
    property IsTraceEnabled: Boolean index llTrace read GetLevelEnabled;
    property IsDebugEnabled: Boolean index llDebug read GetLevelEnabled;
    property IsInfoEnabled: Boolean index llInfo read GetLevelEnabled;
    property IsWarnEnabled: Boolean index llWarn read GetLevelEnabled;
    property IsErrorEnabled: Boolean index llError read GetLevelEnabled;
    property IsFatalEnabled: Boolean index llFatal read GetLevelEnabled;

    property MinimumLogLevel: TLogLevel read FMinimumLogLevel write FMinimumLogLevel;
    property TargetName: string read FTargetName write SetTargetName;
    property OnTargetNameChanged: TOnTargetNameChanged read FOnTargetNameChanged write FOnTargetNameChanged;
  public
    constructor Create; virtual;
    function LogTarget: string; virtual;
    function ToString: string; override;
  end;

  TTargetClass = class of TCustomTarget;

implementation

uses
  System.SysUtils,

  Log4D.LogManager;
{ TCustomTarget }

class function TCustomTarget.AddToManager(aMinimumLogLevel: TLogLevel): TCustomTarget;
begin
  Result := LogManager.AddLogTarget(Self, aMinimumLogLevel);
end;

constructor TCustomTarget.Create;
var
  Uid: TGuid;
begin
  inherited;
  FMinimumLogLevel := TLogLevel.llInfo;
  if CreateGuid(Uid) = S_OK then
    FTargetName := GuidToString(Uid);
end;

function TCustomTarget.GetLevelEnabled(const Index: TLogLevel): Boolean;
begin
  Result := Index >= FMinimumLogLevel;
end;

function TCustomTarget.Instance<T>: T;
begin
  Result := Self as T;
end;

function TCustomTarget.LogTarget: string;
begin
  Result := ClassName;
end;

procedure TCustomTarget.SetTargetName(const Value: string);
var
  OldName: string;
begin
  OldName := FTargetName;
  FTargetName := Value;
  if Assigned(FOnTargetNameChanged) then
    FOnTargetNameChanged(OldName, FTargetName);
end;

function TCustomTarget.ToString: string;
begin
  Result := Format('[Log4Delphi] - [%s] - Name: %s', [ClassName, TargetName]);
end;

{ TAbstractTarget<T> }
end.
