unit VCLLogDisplayerAttachable;

interface

uses
  SysUtils,
  Classes,

  UAdditionalTypes,
  UAdditionalExceptions,
  
  CustomLogManager,
  VCLLogDisplayer,
  VCLLogDisplayerWriter;

type
  TLogDisplayerParentClass = TLogDisplayer;

  TLogDisplayer = class(TLogDisplayerParentClass)
  public
    constructor Create(aOwner: TComponent); override;
  public type
    EAlreadyAttached = class(Exception);
    ENotAttached = class(Exception);
  protected
    fWriter: TLogDisplayerWriter;
    fLogManager: TCustomLogManager;
    procedure CreateThis;
    procedure DestroyThis;
  public
    property Writer: TLogDisplayerWriter read fWriter;
    property LogManager: TCustomLogManager read fLogManager;
    procedure AttachTo(const aLogManager: TCustomLogManager);
    procedure DetachFrom(const aLogManager: TCustomLogManager);
    procedure Detach(const aForSure: boolean);
    destructor Destroy; override;
  end;


implementation

constructor TLogDisplayer.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  CreateThis;
end;

procedure TLogDisplayer.CreateThis;
begin
  fWriter := TLogDisplayerWriter.Create(self);
end;

procedure TLogDisplayer.DestroyThis;
begin
  Detach(false);
  FreeAndNil(fWriter);
end;

procedure TLogDisplayer.AttachTo(const aLogManager: TCustomLogManager);
begin
  if LogManager <> nil then
    raise EAlreadyAttached.Create('');
  aLogManager.AddWriter(Writer);
  fLogManager := aLogManager;
end;

procedure TLogDisplayer.DetachFrom(const aLogManager: TCustomLogManager);
begin
  AssertAssigned(aLogManager, 'aLogManager', TVariableType.Argument);
  aLogManager.RemoveWriter(Writer);
end;

procedure TLogDisplayer.Detach(const aForSure: boolean);
begin
  if aForSure then
    if LogManager = nil then
      raise ENotAttached.Create('');
  DetachFrom(LogManager);
end;

destructor TLogDisplayer.Destroy;
begin
  DestroyThis;
  inherited Destroy;
end;

end.
