unit VCLLogPanel;

interface

uses
  Classes,

  CustomLogMessage,
  CustomVCLLogPanelAttachable;

type
  TLogViewPanel = class(TCustomLogViewPanel)
  protected
    procedure CreateThis;
  public
    constructor Create(aOwner: TComponent); override;
  end;


implementation

constructor TLogViewPanel.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  CreateThis;
end;

end.
