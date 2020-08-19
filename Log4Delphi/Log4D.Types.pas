unit Log4D.Types;

interface

uses
  System.SysUtils;
{$M+}

type
  (*
    Trace - very detailed logs, which may include high-volume information such as protocol payloads. This log level is typically only enabled during development
    Debug - debugging information, less detailed than trace, typically not enabled in production environment.
    Info - information messages, which are normally enabled in production environment
    Warn - warning messages, typically for non-critical issues, which can be recovered or which are temporary failures
    Error - error messages - most of the time these are Exceptions
    Fatal - very serious errors!
  *)

  /// <summary>
  /// The Logger can write messages with different LogLevels, so only relevant messages are logged.
  /// The LogLevel identifies how important/detailed the message is.
  /// </summary>
  /// <param>Tllrace - Very detailed logs</param>
  /// <param>Dllebug - Debugging information</param>
  /// <param>llInfo - Information messages</param>
  /// <param>llWarn - Warning messages</param>
  /// <param>llError - Error messages</param>
  /// <param>llFatal - Very serious errors!</param>
  TLogLevel = (llTrace, llDebug, llInfo, llWarn, llError, llFatal);

  TSourceInfo = record
    LogTime: TDateTime;
    UnitName: string;
    ProcedureName: string;
    LineNumber: Integer;
    BinaryFileName: string;
  end;

  ELoggerNotFoundExtection = Exception;
  EDuplicateLoggerNameException = Exception;

const
  sLogLevel: array [TLogLevel] of string = ('Trace', 'Debug', 'Info', 'Warn', 'Error', 'Fatal');

implementation

end.
