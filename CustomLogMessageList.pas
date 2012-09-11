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
    property Items[const i: integer]: TCustomLogMessage read GetItem;
  end;

implementation

{ TCustomLogMessageList }

function TCustomLogMessageList.GetItem(const aIndex: integer): TCustomLogMessage;
begin
  result := inherited GetItem(aIndex) as TCustomLogMessage;
end;

end.
