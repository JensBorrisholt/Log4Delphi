unit Log4D.Targets.DatabaseTarget;

interface

uses
  System.Sysutils, Data.DB, Data.Win.ADODB,

  Log4D.Types, Log4D.Targets.CustomTarget;

{$M+}

type
  TDatabaseTarget = class sealed(TCustomTarget)
  strict private
    FADOConnection: TADOConnection;
    FPreparedQuery: TADOQuery;
    function UDLFile: string;
    function ADOConnection: TADOConnection;
    function PreparedQuery: TADOQuery;
  private
    FConnectionString: string;
    procedure SetConnectionString(const Value: string);
  published
    property ConnectionString: string read FConnectionString write SetConnectionString;
  public
    procedure LogToTarget(const aLogLevel: TLogLevel; const aSourceInfo: TSourceInfo; const aMessage: string); override;
    constructor Create; override;
    destructor Destroy; override;
    function LogTarget: string; override;
  end;

implementation

uses
  System.IoUtils, System.Classes;

(*
  /****** Object:  Table [dbo].[ApplicationLog] ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[ApplicationLog](
    [ID] [int] IDENTITY(1,1) NOT NULL,
    [LogTime] [datetime] NOT NULL,
    [LogLevel] [int] NOT NULL,
    [sLogLevel] [nvarchar](10) NOT NULL,
    [UnitName] [nvarchar](255) NOT NULL,
    [LineNmber] [int] NOT NULL,
    [ProcedureName] [nvarchar](500) NOT NULL,
    [BinaryFileName] [nvarchar](255) NOT NULL,
    [LogMessage] [nvarchar](max) NOT NULL,
    CONSTRAINT [PK_ApplicationLog] PRIMARY KEY CLUSTERED
  (
    [ID] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
*)

type
  TADOQueryHelper = class helper for TADOQuery
  public
    function ParamByName(aName: string; aDataType: TDataType = TDataType.ftUnknown): TParameter;
  end;
  { TDatabaseTarget }

function TDatabaseTarget.ADOConnection: TADOConnection;
begin
  if not Assigned(FADOConnection) then
  begin
    FADOConnection := TADOConnection.Create(nil);
    FADOConnection.LoginPrompt := False;
    FADOConnection.ConnectionString := FConnectionString;
  end;

  FADOConnection.Open;
  Result := FADOConnection;
end;

constructor TDatabaseTarget.Create;
begin
  inherited;
  FConnectionString := 'FILE NAME=' + UDLFile;
end;

destructor TDatabaseTarget.Destroy;
begin
  FreeAndNil(FADOConnection);
  FreeAndNil(FPreparedQuery);
  inherited;
end;

function TDatabaseTarget.LogTarget: string;
begin
  Result := ADOConnection.Properties['Data Source'].Value;
end;

procedure TDatabaseTarget.LogToTarget(const aLogLevel: TLogLevel; const aSourceInfo: TSourceInfo; const aMessage: string);
var
  Query: TADOQuery;
begin
  Query := PreparedQuery;
  Query.ParamCheck := True;
  Query.ParamByName('LogTime').Value := aSourceInfo.LogTime;
  Query.ParamByName('LogLevel').Value := aLogLevel;
  Query.ParamByName('sLogLevel').Value := sLogLevel[aLogLevel];
  Query.ParamByName('UnitName').Value := aSourceInfo.UnitName;
  Query.ParamByName('LineNmber').Value := aSourceInfo.LineNumber;
  Query.ParamByName('ProcedureName').Value := aSourceInfo.ProcedureName;
  Query.ParamByName('BinaryFileName').Value := aSourceInfo.BinaryFileName;
  Query.ParamByName('LogMessage').Value := aMessage;
  Query.ExecSQL;
end;

function TDatabaseTarget.PreparedQuery: TADOQuery;
begin
  if FPreparedQuery = nil then
  begin
    FPreparedQuery := TADOQuery.Create(nil);
    FPreparedQuery.SQL.Add('insert into');
    FPreparedQuery.SQL.Add('	[ApplicationLog] (LogTime, LogLevel, sLogLevel, UnitName, LineNmber, ProcedureName, BinaryFileName, LogMessage)');
    FPreparedQuery.SQL.Add('values');
    FPreparedQuery.SQL.Add('	(:LogTime, :LogLevel, :sLogLevel, :UnitName, :LineNmber, :ProcedureName, :BinaryFileName, :LogMessage)');
    FPreparedQuery.Connection := ADOConnection;
    FPreparedQuery.Prepared := True;
  end;

  Result := FPreparedQuery;
end;

procedure TDatabaseTarget.SetConnectionString(const Value: string);
begin
  if FConnectionString = Value then
    exit;

  FConnectionString := Value;
  FreeAndNil(FADOConnection);
end;

function TDatabaseTarget.UDLFile: string;
begin
  Result := TPath.ChangeExtension(TPath.GetFileName(System.ParamStr(0)), '.udl');
end;

{ TADOQueryHelper }

function TADOQueryHelper.ParamByName(aName: string; aDataType: TDataType): TParameter;
begin
  Result := Parameters.FindParam(aName);

  if Assigned(Result) then
    exit;

  Result := Parameters.AddParameter;
  Result.Name := aName;

  if aDataType <> TDataType.ftUnknown then
    Result.DataType := aDataType;
end;

end.
