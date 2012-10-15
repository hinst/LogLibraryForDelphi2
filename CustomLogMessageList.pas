unit CustomLogMessageList;

interface

uses
  Contnrs,
  CustomLogMessage;

type
  TCustomLogMessageList = class(TObjectList)
  protected
    function GetItem(const aIndex: integer): TCustomLogMessage;
  public
    property Items[const i: integer]: TCustomLogMessage read GetItem; default;
  end;

implementation

function TCustomLogMessageList.GetItem(const aIndex: integer): TCustomLogMessage;
begin
  result := inherited GetItem(aIndex) as TCustomLogMessage;
end;

end.
