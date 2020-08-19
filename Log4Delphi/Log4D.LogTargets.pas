unit Log4D.LogTargets;

interface

uses
  System.SysUtils, System.Generics.Collections, System.Generics.Defaults,

  Log4D.Targets.CustomTarget;

type
  TLogTargets = class(TObjectDictionary<string, TCustomTarget>)
  strict private
    FDestructorCalled: Boolean;
  protected
    procedure ValueNotify(const Value: TCustomTarget; Action: TCollectionNotification); override;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

implementation

{ TLogTargets }

constructor TLogTargets.Create;
begin
  inherited Create([]);
  FDestructorCalled := false;
end;

destructor TLogTargets.Destroy;
begin
  FDestructorCalled := True;
  inherited;
end;

procedure TLogTargets.ValueNotify(const Value: TCustomTarget; Action: TCollectionNotification);
begin
  if (FDestructorCalled) and (Action = cnRemoved) then
    PObject(@Value)^.DisposeOf;

  inherited;
end;

end.
