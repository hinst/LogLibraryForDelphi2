unit VCLLogPanel;

interface

uses
  Types,
  SysUtils,
  Classes,
  SyncObjs,

  Graphics,
  Controls,

  UAdditionalTypes,
  UAdditionalExceptions,
  UCustomThread,
  UMath,
  ULockThis,

  CustomLogMessage,
  CustomLogMessageList,
  VCLLogPanelItem,
  CustomVCLLogPanelAttachable;

type
  TLogViewPanel = class(TCustomLogViewPanel)
  public
    constructor Create(aOwner: TComponent); override;
  private
    const DefaultUpdateInterval = 200;
    const DefaultScrollSpeed = 300; //< pixels per second
  protected
    fLogMessages: TLogPanelItemList;
    fScrollTop: single;
    fDesiredScrollTop: single;
    fScrollSpeed: integer;
    fGap: integer;
    fLastMouseY: integer;
    fUpdateThread: TCustomThread;
    fUpdateInterval: integer;
    fNewMessageArrived: boolean;
    fTotalHeight: int64;
    procedure SetDesiredScrollTop(const aDesiredScrollTop: single);
    procedure CreateThis;
    procedure AssignDefaults;
    procedure Paint; override;
    procedure PaintMessages;
    procedure Resize; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure ScrollThis(const aDeltaY: integer);
    procedure RecalculateHeights;
    procedure ReleaseLogMessages;
    procedure UpdateRoutine(const aThread: TCustomThread);
    procedure DestroyThis;
  public
    property LogMessages: TLogPanelItemList read fLogMessages;
    property ScrollTop: single read fScrollTop;
    property DesiredScrollTop: single read fDesiredScrollTop write SetDesiredScrollTop;
    property ScrollSpeed: integer read fScrollSpeed;
    property Gap: integer read fGap write fGap;
    property LastMouseY: integer read fLastMouseY;
    property UpdateThread: TCustomThread read fUpdateThread;
    property UpdateInterval: integer read fUpdateInterval write fUpdateInterval;
    property NewMessageArrived: boolean read fNewMessageArrived;
    property TotalHeight: int64 read fTotalHeight;
    procedure AddMessage(const aMessage: TCustomLogMessage); override;
    procedure ScrollToBottom;
    destructor Destroy; override;
  end;


implementation

constructor TLogViewPanel.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  CreateThis;
end;

procedure TLogViewPanel.SetDesiredScrollTop(const aDesiredScrollTop: single);
begin
  fDesiredScrollTop := aDesiredScrollTop;
  if DesiredScrollTop < 0 then
    DesiredScrollTop := 0;
end;

procedure TLogViewPanel.CreateThis;
begin
  fLogMessages := TLogPanelItemList.Create(true);
  AssignDefaults;
  fUpdateThread := TCustomThread.Create;
  UpdateThread.OnExecute := UpdateRoutine;
  UpdateThread.Resume;
end;

procedure TLogViewPanel.AssignDefaults;
begin
  DoubleBuffered := true;
  fScrollTop := 0;
  DesiredScrollTop := 0;
  fScrollSpeed := DefaultScrollSpeed;
  Gap := 3;
  UpdateInterval := DefaultUpdateInterval;
  fTotalHeight := 0;
end;

procedure TLogViewPanel.AddMessage(const aMessage: TCustomLogMessage);
var
  item: TLogPanelItem;
begin
  {$REGION Assertions}
  AssertAssigned(self, 'self', TVariableType.Argument);
  AssertAssigned(aMessage, 'aMessage', TVariableType.Argument);
  LockPointer(LogMessages);
  AssertAssigned(LogMessages, 'LogMessages', TVariableType.Prop);
  UnlockPointer(LogMessages);
  {$ENDREGION}
  {$REGION Prepare}
  item := TLogPanelItem.Create(self, aMessage);
  item.Parent := self;
  {$ENDREGION}
  LockPointer(LogMessages);
  WriteLN('TLVP: Message arrived: "' + aMessage.Text + '" ' + IntToStr(LogMessages.Count));
  LogMessages.Add(item);
  fTotalHeight := fTotalHeight + item.Height + Gap;
  fNewMessageArrived := true;
  ScrollToBottom;
  UnlockPointer(LogMessages);
end;

procedure TLogViewPanel.ReleaseLogMessages;
begin
  LockPointer(LogMessages);
  LogMessages.Free;
  UnlockPointer(LogMessages);
  fLogMessages := nil;
end;

procedure TLogViewPanel.Paint;
begin
  inherited Paint;
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := clWhite;
  Canvas.Pen.Style := psClear;
  Canvas.Rectangle(ClientRect);
  PaintMessages;
end;

procedure TLogViewPanel.PaintMessages;
var
  i: integer;
  ActualY: int64;
  DrawY: integer;
  item: TLogPanelItem;
begin
  LockPointer(LogMessages);
  ActualY := Gap;
  WriteLN(LogMessages.Count);
  for i := 0 to LogMessages.Count - 1 do
  begin
    item := LogMessages[i];
    if item.Height = -1 then
      item.DirectRecalculateHeight(Canvas);
    AssertAssigned(item, 'item', TVariableType.Local);
    DrawY := ActualY - round(ScrollTop);
    if (0 < DrawY + item.Height) and (DrawY < ClientHeight) then
      item.Paint(Canvas, DrawY);
    ActualY := ActualY + item.Height + Gap;
  end;
  UnlockPointer(LogMessages);
end;

procedure TLogViewPanel.Resize;
begin
  inherited Resize;
  RecalculateHeights;
end;

procedure TLogViewPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  fLastMouseY := Y;
end;

procedure TLogViewPanel.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, y);
  if ssLeft in Shift then
  begin
    ScrollThis( - (Y - LastMouseY));
    fLastMouseY := Y;
  end;
end;

procedure TLogViewPanel.ScrollThis(const aDeltaY: integer);
begin
  fScrollTop := ScrollTop + aDeltaY;
  if ScrollTop < 0 then
    fScrollTop := 0;
  DesiredScrollTop := fScrollTop;
  Invalidate;
end;

procedure TLogViewPanel.RecalculateHeights;
var
  i: integer;
  item: TLogPanelItem;
begin
  LockPointer(LogMessages);
  fTotalHeight := 0;
  for i := 0 to LogMessages.Count - 1 do
  begin
    item := LogMessages[i];
    item.DirectRecalculateHeight(Canvas);
    fTotalHeight := fTotalHeight + item.Height + Gap;
  end;
  UnlockPointer(LogMessages);
end;

procedure TLogViewPanel.UpdateRoutine(const aThread: TCustomThread);
begin
  while not aThread.Stop do
  begin
    LockPointer(LogMessages);
    ApproachSingle(fScrollTop, DesiredScrollTop, ScrollSpeed / 1000 * UpdateInterval);
    UnlockPointer(LogMessages);
    if NewMessageArrived then
    begin
      aThread.Synchronize(Invalidate);
      fNewMessageArrived := false;
    end;
    Sleep(UpdateInterval);
  end;
end;

procedure TLogViewPanel.DestroyThis;
begin
  Detach;
  if UpdateThread <> nil then
  begin
    UpdateThread.Stop := true;
    UpdateThread.WaitFor;
    UpdateThread.Free;
    fUpdateThread := nil;
  end;
  ReleaseLogMessages;
end;

procedure TLogViewPanel.ScrollToBottom;
begin
  DesiredScrollTop := TotalHeight - ClientHeight - 1;
end;

destructor TLogViewPanel.Destroy;
begin
  DestroyThis;
  inherited Destroy;
end;

end.
