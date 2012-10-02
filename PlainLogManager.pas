unit PlainLogManager;

interface

uses
  SysUtils,
  Contnrs,
  SyncObjs,

  CustomLogMessage,
  CustomLogMessageList,
  DefaultLogMessage,
  CustomLogManager,
  CustomLogWriter,
  CustomLogWriterList;

type

  TPlainLogManager = class(TCustomLogManager)
  public
    constructor Create;
  protected
    fMessageNumber: integer;
    fWriters: TCustomLogWriterList;
    fWriteMessageLock: TCriticalSection;
    procedure WriteMessageInternal(const aMessage: TCustomLogMessage);
    procedure WriteMessageThreadSafe(const aMessage: TCustomLogMessage);
  public
    property MessageNumber: integer read fMessageNumber;
    property Writers: TCustomLogWriterList read fWriters;
    property WriteMessageLock: TCriticalSection read fWriteMessageLock;
      // TLogManager owns writers.
      // It meas that it releases them on destruction
    function CreateMessage: TCustomLogMessage; override;
      // Releases aMessage after execution
    procedure WriteMessage(const aMessage: TCustomLogMessage); override;
    procedure AddWriter(const aWriter: TCustomLogWriter); override;
    function RemoveWriter(const aWriter: TCustomLogWriter): boolean; override;
    destructor Destroy; override;
  end;

implementation

constructor TPlainLogManager.Create;
begin
  inherited Create;
  fMessageNumber := 0;
  fWriters := TCustomLogWriterList.Create(true);
  fWriteMessageLock := TCriticalSection.Create;
end;

procedure TPlainLogManager.WriteMessageInternal(const aMessage: TCustomLogMessage);
var
  i: integer;
begin
  for i := 0 to Writers.Count - 1 do
    Writers[i].Write(aMessage);
  aMessage.Free;
end;

procedure TPlainLogManager.WriteMessageThreadSafe(const aMessage: TCustomLogMessage);
begin
  WriteMessageLock.Enter;
  WriteMessageInternal(aMessage);
  WriteMessageLock.Leave;
end;

function TPlainLogManager.CreateMessage: TCustomLogMessage;
begin
  result := TDefaultLogMessage.Create(MessageNumber);
  result.Time := Now;
end;

procedure TPlainLogManager.AddWriter(const aWriter: TCustomLogWriter);
begin
  Writers.Add(aWriter);
end;

function TPlainLogManager.RemoveWriter(const aWriter: TCustomLogWriter): boolean;
begin
  result := Writers.IndexOf(aWriter) >= 0;
  if result then
    Writers.Remove(aWriter);
end;

procedure TPlainLogManager.WriteMessage(const aMessage: TCustomLogMessage);
begin
  WriteMessageThreadSafe(aMessage);
end;

destructor TPlainLogManager.Destroy;
begin
  FreeAndNil(fWriteMessageLock);
  FreeAndNil(fWriters);
  inherited Destroy;
end;

end.
