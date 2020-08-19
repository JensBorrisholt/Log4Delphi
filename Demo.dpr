// JCL_DEBUG_EXPERT_INSERTJDBG ON
program Demo;

uses
  Vcl.Forms,
  MainU in 'MainU.pas' {FormMain},
  Log4D.Logger in 'Log4Delphi\Log4D.Logger.pas',
  Log4D.Types in 'Log4Delphi\Log4D.Types.pas',
  Log4D.Targets.CustomTarget in 'Log4Delphi\Targets\Log4D.Targets.CustomTarget.pas',
  Log4D.LogTargets in 'Log4Delphi\Log4D.LogTargets.pas',
  Log4D.LogManager in 'Log4Delphi\Log4D.LogManager.pas',
  Log4D.Targets.ConsoleTarget in 'Log4Delphi\Targets\Log4D.Targets.ConsoleTarget.pas',
  System.Console in 'Log4Delphi\System.Console.pas',
  Log4D.Targets.CsvTarget in 'Log4Delphi\Targets\Log4D.Targets.CsvTarget.pas',
  Log4D.Targets.DatabaseTarget in 'Log4Delphi\Targets\Log4D.Targets.DatabaseTarget.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  TDatabaseTarget.AddToManager(llTrace);
  TConsoleTarget.AddToManager(llTrace);
  TCsvTarget.AddToManager(llWarn);
  Application.Run;

end.
