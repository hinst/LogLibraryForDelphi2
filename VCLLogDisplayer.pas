unit VCLLogDisplayer;

interface

uses
  SysUtils,
  Classes,
  SyncObjs,
  Controls,
  Grids,

  CustomLogMessage,
  CustomLogWriter;

type
  TLogDisplayer = class(TStringGrid)
  public
    constructor Create(aOwner: TComponent); override;
  protected
    fLock: TCriticalSection;
    procedure CreateThis;
    procedure SetColumnTitles;
    procedure AddMessageThreadSafe(const aMessage: TCustomLogMessage);
    procedure AddMessageInternal(const aMessage: TCustomLogMessage);
    procedure Resize; override;
    procedure AdjustColumnWidths;
    procedure DestroyThis;
  public
    property Lock: TCriticalSection read fLock;
    procedure AddMessage(const aMessage: TCustomLogMessage);
    destructor Destroy; override;
  end;

implementation

type
  TAddMessage = class(TObject)
  public
    aMsg: TCustomLogMessage;
    aOwner: TLogDisplayer;
    procedure Execute;
  end;

constructor TLogDisplayer.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  CreateThis;
end;

procedure TLogDisplayer.CreateThis;
begin
  fLock := TCriticalSection.Create;
  RowCount := 1;
  ColCount := 4;
  SetColumnTitles;
end;

procedure TLogDisplayer.SetColumnTitles;
begin
  Rows[0].Add('#');
  Rows[0].Add('TAG');
  Rows[0].Add('Name');
  Rows[0].Add('Text');
end;

procedure TLogDisplayer.AddMessageThreadSafe(const aMessage: TCustomLogMessage);
var
  am: TAddMessage;
begin
  am := TAddMessage.Create;
  am.aMsg := aMessage;
  am.aOwner := self;
  TThread.Synchronize(nil, am.Execute);
  am.Free;
end;

procedure TLogDisplayer.AddMessageInternal(const aMessage: TCustomLogMessage);
var
  i: integer;
begin
  Lock.Enter;
  RowCount := RowCount + 1;
  i := RowCount - 1;
  Rows[i].Add(IntToStr(aMessage.Number));
  Rows[i].Add(aMessage.Tag);
  Rows[i].Add(aMessage.Name);
  Rows[i].Add(aMessage.Text);
  Lock.Leave;
end;

procedure TLogDisplayer.AddMessage(const aMessage: TCustomLogMessage);
begin
  AddMessageThreadSafe(aMessage);
end;

procedure TAddMessage.Execute;
begin
  aOwner.AddMessageInternal(aMsg);
end;

procedure TLogDisplayer.AdjustColumnWidths;
begin
  ColWidths[0] := ClientWidth * 10 div 100 - 1;
  ColWidths[1] := ClientWidth * 10 div 100 - 1;
  ColWidths[2] := ClientWidth * 10 div 100 - 1;
  ColWidths[3] := ClientWidth * 70 div 100 - 1;
    // -1 = magic width decrease
end;

procedure TLogDisplayer.Resize;
begin
  AdjustColumnWidths;
  inherited Resize;
end;

procedure TLogDisplayer.DestroyThis;
begin
  FreeAndNil(fLock);
end;

destructor TLogDisplayer.Destroy;
begin
  DestroyThis;
  inherited Destroy;
end;

end.
