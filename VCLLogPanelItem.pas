unit VCLLogPanelItem;

interface

uses
  Windows,
  SysUtils,
  Classes,
  Graphics,
  Contnrs,
  Forms,

  Controls,
  ExtCtrls,
  StdCtrls,

  UEnhancedObject,

  CustomLogMessage;

type
  TLogPanelItem = class
  public
    constructor Create(const aOwner: TComponent; const aMessage: TCustomLogMessage); reintroduce;
  protected
    fLogMessage: TCustomLogMessage;
    fTagHeight: integer;
    fTextHeight: integer;
    fHeight: integer;
    fParent: TPanel;
    fGap: integer;
    fInnerTextGap: integer;
    fBorderColor: TColor;
    procedure CreateThis;
    procedure AssignDefaults;
    function CalculateTextHeight(const aCanvas: TCanvas; const aText: string): integer;
    procedure DestroyThis;
  public
    property LogMessage: TCustomLogMessage read fLogMessage;
    property TagHeight: integer read fTagHeight;
    property TextHeight: integer read fTextHeight;
    property Height: integer read fHeight;
      // external assign required
    property Parent: TPanel read fParent write fParent;
    property Gap: integer read fGap write fGap;
    property InnerTextGap: integer read fInnerTextGap write fInnerTextGap;
    property BorderColor: TColor read fBorderColor write fBorderColor;
    procedure RecalculateHeight(const aCanvas: TCanvas);
    procedure Paint(const aCanvas: TCanvas; const aTop: integer);
    destructor Destroy; override;
  end;

  TLogPanelItemList = class(TObjectList)
  protected
    function GetItem(const aIndex: integer): TLogPanelItem;
  public
    property Items[const aIndex: integer]: TLogPanelItem read GetItem; default;
  end;


implementation

constructor TLogPanelItem.Create(const aOwner: TComponent; const aMessage: TCustomLogMessage);
begin
  inherited Create;
  fLogMessage := aMessage;
  CreateThis;
end;

procedure TLogPanelItem.CreateThis;
begin
  LogMessage.Refererence;
  AssignDefaults;
end;

procedure TLogPanelItem.AssignDefaults;
begin
  Gap := 3;
  BorderColor := clGray;
  InnerTextGap := 3;
end;

function TLogPanelItem.CalculateTextHeight(const aCanvas: TCanvas; const aText: string): integer;
var
  r: TRect;
  text: string;
begin
  text := aText;
  r := Rect(
    Gap + InnerTextGap,
    InnerTextGap,
    Parent.ClientWidth - Gap - InnerTextGap, 0);
  DrawText(aCanvas.Handle,
    PChar(PChar(text)),
    Length(text),
    r,
    DT_LEFT or DT_TOP or DT_WORDBREAK or DT_CALCRECT
  );
  result := r.Bottom - r.Top;
end;

procedure TLogPanelItem.DestroyThis;
begin
  DereferenceAndNil(fLogMessage);
end;

procedure TLogPanelItem.RecalculateHeight(const aCanvas: TCanvas);
begin
  fHeight := 0;
  if LogMessage.Tag <> '' then
  begin
    fTagHeight := CalculateTextHeight(aCanvas, LogMessage.Tag);
    fHeight := Height + InnerTextGap + TagHeight;
  end;
  fTextHeight := CalculateTextHeight(aCanvas, LogMessage.Text);
  fHeight := Height + InnerTextGap + TextHeight;

  fHeight := Height + InnerTextGap;
  //WriteLN('Height recalculated: ' + IntToStr(Height));
end;

procedure TLogPanelItem.Paint(const aCanvas: TCanvas; const aTop: integer);
var
  currentOffset: integer;

  function NextRect(const aHeight: integer): TRect;
  begin
    result.Left := Parent.ClientRect.Left + Gap + InnerTextGap;
    result.Top := aTop + currentOffset + InnerTextGap;
    result.Right := Parent.ClientRect.Right - Gap - InnerTextGap;
    result.Bottom := aTop + currentOffset + InnerTextGap + aHeight;
    currentOffset := currentOffset + InnerTextGap + aHeight;
  end;

  procedure NextDraw(const aText: string; const aHeight: integer);
  var
    textRect: TRect;
    text: string;
  begin
    textRect := NextRect(aHeight);
    text := aText;
    aCanvas.TextRect(
      textRect,
      text,
      [tfWordBreak]
    );
    //aCanvas.Rectangle(textRect);
  end;

begin
  aCanvas.Pen.Color := BorderColor;
  aCanvas.Pen.Width := 1;
  aCanvas.Pen.Style := psSolid;
  aCanvas.Rectangle(
    Parent.ClientRect.Left + Gap,
    aTop,
    Parent.ClientRect.Right - Gap * 2,
    aTop + Height
  );

  currentOffset := 0;
  if LogMessage.Tag <> '' then
  begin
    aCanvas.Font.Color := clBlue;
    NextDraw(LogMessage.Tag, TagHeight);
  end;
  aCanvas.Font.Color := clBlack;
  NextDraw(LogMessage.Text, TextHeight);
end;

destructor TLogPanelItem.Destroy;
begin
  DestroyThis;
  inherited Destroy;
end;


function TLogPanelItemList.GetItem(const aIndex: integer): TLogPanelItem;
begin
  result := inherited GetItem(aIndex) as TLogPanelItem;
end;

end.
