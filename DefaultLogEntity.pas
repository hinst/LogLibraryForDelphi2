unit DefaultLogEntity;

interface

uses
  CustomLogMessage,
  CustomLogEntity,
  CustomLogManager;

type
  TLog = class(TCustomLog)
  public
    constructor Create(const aManager: TCustomLogManager; const aName: string);
  protected
    fManager: TCustomLogManager;
    fName: string;
  public
    property Manager: TCustomLogManager read fManager;
    property Name: string read fName;
    procedure Write(const aText: string); overload; override;
    procedure Write(const aTag, aText: string); overload; override;
  end;

implementation

constructor TLog.Create(const aManager: TCustomLogManager; const aName: string);
begin
  inherited Create;
  fManager := aManager;
  fName := aName;
end;

procedure TLog.Write(const aText: string);
begin
  Write('', aText);
end;

procedure TLog.Write(const aTag, aText: string);
var
  m: TCustomLogMessage;
begin
  m := Manager.CreateMessage;
  if aTag <> '' then
    m.Tag := aTag;
  m.Name := Name;
  m.Text := aText;
  Manager.WriteMessage(m);
end;

end.
