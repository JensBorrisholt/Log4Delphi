unit MainU;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Data.DB,
  Data.Win.ADODB;

type
  TFormMain = class(TForm)
    Timer1: TTimer;
    Memo1: TMemo;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

uses
  System.Threading,
  Log4D.Targets.CustomTarget, Log4D.LogManager, Log4D.Logger, Log4D.Types;

{$R *.dfm}

procedure TFormMain.FormCreate(Sender: TObject);
begin
  TTask.Run(
      procedure
    begin
      Sleep(500);

      TThread.Synchronize(nil,
          procedure
        var
          LogTarget: TCustomTarget;
        begin
          for LogTarget in LogManager.LogTargets.Values do
            Memo1.Lines.Add(Format('[%s] Logging to %s. Minimum Log Level: %s', [LogTarget.ClassName, LogTarget.LogTarget, sLogLevel[LogTarget.MinimumLogLevel]]));
        end)
    end);
end;

procedure TFormMain.Timer1Timer(Sender: TObject);
begin
  with Log do
  begin
    Trace('Trace');
    Debug('Debug');
    Info('Info');
    Warn('Warn');
    Error('Error');
    Fatal('Fatal');
  end;
end;

end.
