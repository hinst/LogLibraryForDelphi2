unit CustomLogWriter;

interface

uses
  CustomLogMessage;

type
  TCustomLogWriter = class
  public
    procedure Write(const aMessage: TCustomLogMessage); virtual; abstract;
  end;

implementation

end.
