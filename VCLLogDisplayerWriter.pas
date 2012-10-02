unit VCLLogDisplayerWriter;

interface

uses
  CustomLogMessage,
  CustomLogWriter,
  VCLLogDisplayer;

type
  TLogDisplayerWriter = class(TCustomLogWriter)
  public
    constructor Create(const aDisplayGrid: TLogDisplayer);
  protected
    fLogDisplayGrid: TLogDisplayer;
  public
    property LogDisplayGrid: TLogDisplayer read fLogDisplayGrid;
    procedure Write(const aMessage: TCustomLogMessage); override;
  end;

implementation

constructor TLogDisplayerWriter.Create(const aDisplayGrid: TLogDisplayer);
begin
  inherited Create;
  fLogDisplayGrid := aDisplayGrid;
end;

procedure TLogDisplayerWriter.Write(const aMessage: TCustomLogMessage);
begin
  LogDisplayGrid.AddMessage(aMessage);
end;

end.
