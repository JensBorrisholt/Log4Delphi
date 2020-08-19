unit Log4D.LogManager;

interface

uses
  Log4D.Types, Log4D.Targets.CustomTarget, Log4D.LogTargets;

{$M+}

type
  TLogManager = class
  private
    class var FInstance: TLogManager;

  var
    FLogTargets: TLogTargets;
    procedure OnTargetNameChanged(const aOldName, aNewName: string);
  public
    constructor Create;
    destructor Destroy; override;
    function AddLogTarget(aLogTargetClass: TTargetClass; aMinLogLevel: TLogLevel = llInfo): TCustomTarget; overload;
    function AddLogTarget(aLogTarget: TCustomTarget; aMinLogLevel: TLogLevel = llInfo): TCustomTarget; overload;
    function RemoveTarget(aLogTargetClass: TTargetClass; aFreeTarget: Boolean = True): TCustomTarget;
    function RemoveTargetByName(aTargetName: string; aFreeTarget: Boolean = True): TCustomTarget;
  published
    property LogTargets: TLogTargets read FLogTargets;
  end;

function LogManager: TLogManager; inline;

implementation

uses
  System.Sysutils;

function LogManager: TLogManager;
begin
  Result := TLogManager.FInstance;
end;

{ TLogManager }

function TLogManager.AddLogTarget(aLogTargetClass: TTargetClass; aMinLogLevel: TLogLevel): TCustomTarget;
begin
  Result := AddLogTarget(aLogTargetClass.Create, aMinLogLevel);
end;

function TLogManager.AddLogTarget(aLogTarget: TCustomTarget; aMinLogLevel: TLogLevel): TCustomTarget;
begin
  if FLogTargets.TryGetValue(aLogTarget.TargetName, Result) then
    raise EDuplicateLoggerNameException.Create('LogManager allready contains a Dev');

  Result := aLogTarget;
  Result.MinimumLogLevel := aMinLogLevel;
  Result.OnTargetNameChanged := OnTargetNameChanged;
  FLogTargets.Add(Result.TargetName, Result);
end;

constructor TLogManager.Create;
begin
  inherited;
  FLogTargets := TLogTargets.Create;
end;

destructor TLogManager.Destroy;
begin
  FLogTargets.Free;
  inherited;
end;

procedure TLogManager.OnTargetNameChanged(const aOldName, aNewName: string);
var
  Target: TCustomTarget;
begin
  Target := RemoveTargetByName(aOldName, False);
  AddLogTarget(Target, Target.MinimumLogLevel);
end;

function TLogManager.RemoveTarget(aLogTargetClass: TTargetClass; aFreeTarget: Boolean): TCustomTarget;
begin
  Result := RemoveTargetByName(aLogTargetClass.ClassName, aFreeTarget)
end;

function TLogManager.RemoveTargetByName(aTargetName: string; aFreeTarget: Boolean): TCustomTarget;
begin
  if not FLogTargets.TryGetValue(aTargetName, Result) then
    raise ELoggerNotFoundExtection.CreateFmt('LogTarget %s not found', [aTargetName]);

  if aFreeTarget then
    FreeAndNil(Result);
end;

initialization

TLogManager.FInstance := TLogManager.Create;

finalization

TLogManager.FInstance.Free;

end.
