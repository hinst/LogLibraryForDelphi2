unit CustomLogMessage;

interface

type
  TCustomLogMessage = class
  protected
    function GetNumber: integer; virtual; abstract;
    function GetTag: string; virtual; abstract;
    function GetTime: TDateTime; virtual; abstract;
    function GetName: string; virtual; abstract;
    function GetText: string; virtual; abstract;
  public
    property Number: integer read GetNumber;
    property Time: TDateTime read GetTime;
    property Tag: string read GetTag;
    property Name: string read GetName;
    property Text: string read GetText;
  end;

implementation

end.
