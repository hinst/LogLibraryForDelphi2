unit CustomLogManager;

interface

uses
  CustomLogMessage;

type
  TCustomLogManager = class
    procedure WriteMessage(const aMessage: TCustomLogMessage); virtual; abstract;
  end;

implementation

end.
