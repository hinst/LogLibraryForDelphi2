unit CustomVCLLogPanel;

interface

uses
  SysUtils,
  Classes,
  ExtCtrls,
  SyncObjs,
  Controls,

  UAdditionalTypes,
  UAdditionalExceptions,

  CustomLogMessage,
  EmptyLogEntity,
  CustomLogWriter;

type
  TCustomLogViewPanel = class(TPanel)
  public
    constructor Create(aOwner: TComponent); override;
  protected
    fLog: TEmptyLog;
    fLock: TCriticalSection;
    procedure SetLog(const aLog: TEmptyLog);
    procedure CreateThis;
    procedure AddMessageSynchronized(const aMessage: TCustomLogMessage);
    procedure AddMessageInternal(const aMessage: TCustomLogMessage); virtual; abstract;
    procedure DestroyThis;
  public
    property Log: TEmptyLog read fLog write SetLog;
    property Lock: TCriticalSection read fLock;
    procedure AddMessage(const aMessage: TCustomLogMessage);
    destructor Destroy; override;
  end;

implementation

type
  TAddMessage = class(TObject)
  public
    aMsg: TCustomLogMessage;
    aOwner: TCustomLogViewPanel;
    procedure Execute;
  end;

constructor TCustomLogViewPanel.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  CreateThis;
end;

procedure TCustomLogViewPanel.SetLog(const aLog: TEmptyLog);
begin
  ReplaceLog(fLog, aLog);
end;

procedure TCustomLogViewPanel.CreateThis;
begin
  Log := TEmptyLog.Create;
  fLock := TCriticalSection.Create;
end;

procedure TCustomLogViewPanel.AddMessageSynchronized(const aMessage: TCustomLogMessage);
var
  am: TAddMessage;
begin
  am := TAddMessage.Create;
  am.aMsg := aMessage;
  am.aOwner := self;
  Lock.Enter;
  TThread.Synchronize(nil, am.Execute);
  Lock.Leave;
  am.Free;
end;

procedure TCustomLogViewPanel.AddMessage(const aMessage: TCustomLogMessage);
begin
  AddMessageSynchronized(aMessage);
end;

procedure TAddMessage.Execute;
begin
  aOwner.AddMessageInternal(aMsg);
end;

procedure TCustomLogViewPanel.DestroyThis;
begin
  FreeAndNil(fLock);
  FreeAndNil(fLog);
end;

destructor TCustomLogViewPanel.Destroy;
begin
  DestroyThis;
  inherited Destroy;
end;

end.
