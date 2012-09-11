unit ConsoleLogWriter;

interface

uses
  CustomLogMessage,
  CustomLogWriter;

type
  TConsoleLogWriter = class(TCustomLogWriter)
  public
    procedure Write(const aMessage: TCustomLogMessage); override;
  end;

implementation

{ TConsoleLogWriter }

procedure TConsoleLogWriter.Write(const aMessage: TCustomLogMessage);
var
  text: string;
begin
  if not IsConsole then 
    exit;
  text := '[' + aMessage.Tag + ']';
  text := text + aMessage.Name + ': ';
  text := text + aMessage.Text;
  WriteLN(text);
end;

end.
