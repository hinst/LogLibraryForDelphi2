unit LogManager;

interface

uses
  SysUtils,
  Contnrs,
  SyncObjs,

  UCustomThread,
  
  CustomLogMessage,
  CustomLogMessageList,
  DefaultLogMessage,
  CustomLogManager,
  CustomLogWriter,
  CustomLogWriterList;

type

  TLogManager = class(TCustomLogManager)
  public
    constructor Create;
  private
    fMessageNumber: integer;
    fMessages: TCustomLogMessageList;
    fWriters: TCustomLogWriterList;
    fWritersLock: TCriticalSection;
    fDeferred: TCustomThread;
  public
    property MessageNumber: integer read fMessageNumber;
    property Writers: TCustomLogWriterList read fWriters;
      // TLogManager owns writers.
      // It meas that it releases them on destruction
    function CreateMessage: TCustomLogMessage; override;
    procedure WriteMessage(const aMessage: TCustomLogMessage); override;
    procedure AddWriter(const aWriter: TCustomLogWriter); override;
    destructor Destroy; override;
  end;

implementation

constructor TLogManager.Create;
begin
  inherited Create;
  fMessageNumber := 0;
  fWritersLock := TCriticalSection.Create;
  fWriters := TCustomLogWriterList.Create(true);
end;

function TLogManager.CreateMessage: TCustomLogMessage;
begin
  result := TDefaultLogMessage.Create(MessageNumber);
end;

procedure TLogManager.AddWriter(const aWriter: TCustomLogWriter);
begin
  Writers.Add(aWriter);
end;

destructor TLogManager.Destroy;
begin
  FreeAndNil(fDeferred);
  FreeAndNil(fWriters);
  FreeAndNil(fWritersLock);
  inherited Destroy;
end;

procedure TLogManager.WriteMessage(const aMessage: TCustomLogMessage);
var
  i: integer;
begin
  for i := 0 to Writers.Count - 1 do
    Writers[i].Write(aMessage);
end;

end.
