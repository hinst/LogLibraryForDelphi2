unit CustomLogWriter;

interface

uses
  Classes,
  UEnhancedObject,
  CustomLogMessage;

type
  TCustomLogWriter = class(TEnhancedObject)
  public
    procedure Write(const aMessage: TCustomLogMessage); virtual; abstract;
  end;

implementation

end.
