unit VCLLogPanel;

interface

uses
  Types,
  SysUtils,
  Classes,

  Graphics,
  Controls,

  UAdditionalTypes,
  UAdditionalExceptions,

  CustomLogMessage,
  CustomLogMessageList,
  VCLLogPanelItem,
  CustomVCLLogPanelAttachable;

type
  TLogViewPanel = class(TCustomLogViewPanel)
  public
    constructor Create(aOwner: TComponent); override;
  protected
    fLogMessages: TLogPanelItemList;
    fScrollTop: int64;
    fGap: integer;
    fLastMouseY: integer;
    procedure CreateThis;
    procedure AssignDefaults;
    procedure AddMessageInternal(const aMessage: TCustomLogMessage); override;
    procedure Paint; override;
    procedure PaintMessages;
    procedure Resize; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure ScrollThis(const aDeltaY: integer);
    procedure RecalculateMessageHeights;
    procedure ReleaseLogMessages;
    procedure DestroyThis;
  public
    property LogMessages: TLogPanelItemList read fLogMessages;
    property ScrollTop: int64 read fScrollTop write fScrollTop;
    property Gap: integer read fGap write fGap;
    property LastMouseY: integer read fLastMouseY;
    destructor Destroy; override;
  end;


implementation

constructor TLogViewPanel.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  CreateThis;
  DoubleBuffered := true;
end;

procedure TLogViewPanel.CreateThis;
begin
  fLogMessages := TLogPanelItemList.Create(true);
  AssignDefaults;
end;

procedure TLogViewPanel.AssignDefaults;
begin
  ScrollTop := 0;
  Gap := 3;
end;

procedure TLogViewPanel.AddMessageInternal(const aMessage: TCustomLogMessage);
var
  item: TLogPanelItem;
begin
  {$REGION Assertions}
  AssertAssigned(aMessage, 'aMessage', TVariableType.Argument);
  AssertAssigned(LogMessages, 'LogMessages', TVariableType.Prop);
  {$ENDREGION}
  item := TLogPanelItem.Create(self, aMessage);
  item.Parent := self;
  item.RecalculateHeight(Canvas);
  LogMessages.Add(item);
  Invalidate;
end;

procedure TLogViewPanel.ReleaseLogMessages;
begin
  FreeAndNil(fLogMessages);
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
  ActualY := Gap;
  for i := 0 to LogMessages.Count - 1 do
  begin
    item := LogMessages[i];
    AssertAssigned(item, 'item', TVariableType.Local);
    DrawY := ActualY - ScrollTop;
    if (0 < DrawY + item.Height) and (DrawY < ClientHeight) then
      item.Paint(Canvas, DrawY);
    ActualY := ActualY + item.Height + Gap;
  end;
end;

procedure TLogViewPanel.Resize;
begin
  inherited Resize;
  RecalculateMessageHeights;
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
  ScrollTop := ScrollTop + aDeltaY;
  Invalidate;
end;

procedure TLogViewPanel.RecalculateMessageHeights;
var
  i: integer;
begin
  for i := 0 to LogMessages.Count - 1 do
    LogMessages[i].RecalculateHeight(self.Canvas);
end;

procedure TLogViewPanel.DestroyThis;
begin
  ReleaseLogMessages;
end;

destructor TLogViewPanel.Destroy;
begin
  DestroyThis;
  inherited Destroy;
end;

end.
