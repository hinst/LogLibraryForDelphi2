program LLTestApplication;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  CustomLogEntity,
  CustomLogManager,
  CustomLogWriter,
  ConsoleLogWriter,
  PlainLogManager,
  DefaultLogEntity,
  PLainTextWriter;

var
  LogMan: TCustomLogManager;
  ConsoleLW: TCustomLogWriter;
  log: TLog;


begin
  LogMan := TPlainLogManager.Create;
  ConsoleLW := TConsoleLogWriter.Create;
  LogMan.AddWriter(ConsoleLW);
  LogMan.AddWriter(TPlainTextWriter.Create('Test.log'));
  log := TLog.Create(LogMan, 'GLOBAL');
  log.Write('START', 'The the log is functioning now...');
  log.Write('Some debug message');
  log.Write('END', 'Releasing log...');
  log.Free;
  LogMan.Free;
end.
