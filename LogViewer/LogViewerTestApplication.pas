unit LogViewerTestApplication;

interface

uses
  SysUtils,
  Forms,

  UFileNameCycler,

  PlainLogManager,
  FileLogWriter,
  ConsoleLogWriter,
  DefaultLogEntity,
  EmptyLogEntity,

  GlobalLogManagerUnit;

type
  TLVTApplication = class
  public const
    LogSubFolder = 'Log';
    LogFileCount = 10;
  protected
    fLog: TEmptyLog;
    procedure StartupLog;
    procedure StartupConsoleLog;
    procedure StartupFileLog;
    function GetLogDirectory: string;
    procedure ShutdownLog;
  public
    property Log: TEmptyLog read fLog;
    procedure Run;
  end;


implementation

procedure TLVTApplication.StartupLog;
begin
  GlobalLogManager := TPlainLogManager.Create;
  StartupConsoleLog;
  fLog := TLog.Create(GlobalLogManager, 'Application');
  StartupFileLog;
end;

procedure TLVTApplication.StartupConsoleLog;
var
  w: TConsoleLogWriter;
begin
  w := TConsoleLogWriter.Create;
  GlobalLogManager.AddWriter(w);
end;

procedure TLVTApplication.StartupFileLog;
var
  w: TFileLogWriter;
begin
  w := TFileLogWriter.Create;
  if not DirectoryExists(GetLogDirectory) then
    ForceDirectories(GetLogDirectory);
  w.FilePath := CycleFileName(IncludeTrailingPathDelimiter(GetLogDirectory) + 'logFile',
    LogFileCount, '.text');
  Log.Write('Log file: ' + w.FilePath);
  GlobalLogManager.AddWriter(w);
end;

function TLVTApplication.GetLogDirectory: string;
begin
  result := ExtractFilePath(Application.ExeName) + LogSubFolder;
end;

procedure TLVTApplication.ShutdownLog;
begin
  FreeAndNil(fLog);
  FreeAndNil(GlobalLogManager);
end;

procedure TLVTApplication.Run;
begin
  StartupLog;
  ShutdownLog;
end;

end.
