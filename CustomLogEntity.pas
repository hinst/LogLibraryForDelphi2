unit CustomLogEntity;

interface

type
  TCustomLogEntity = class
  public
    procedure Write(const aText: string); virtual; abstract;
  end;

implementation

end.
