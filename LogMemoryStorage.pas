unit LogMemoryStorage;

interface

uses
  CustomLogWriter,
  CustomLogMessageList;

type
  TLogMemoryStorage = class(TCustomLogWriter)
  private
    fList: TCustomLogMessageList;
    fFilteredList: TCustomLogMessageList;
  public
    property FilteredList: TCustomLogMessageList read fFilteredList;
  end;

implementation

end.
