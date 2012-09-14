unit PlainTextWriter;
{$IFDEF FPC}
  {$mode delphi}
{$ENDIF}
interface

uses
  Classes,
  sysutils,
  CustomLogMessage,
  CustomLogWriter;

type

  { TPlainTextWriter }

  TPlainTextWriter = class(TCustomLogWriter)
  private
    fLogFileStream:TFileStream;
  public
    constructor Create(const aLogFileName:string);
    destructor Destroy; override;
    procedure Write(const aMessage: TCustomLogMessage); override;
  end;

implementation

{ TPlainTextWriter }

constructor TPlainTextWriter.Create(const aLogFileName: string);
begin
  if FileExists(aLogFileName) then
    fLogFileStream := TFileStream.Create(aLogFileName, fmOpenReadWrite or fmShareDenyNone)
  else
    fLogFileStream := TFileStream.Create(aLogFileName, fmCreate or fmShareDenyNone)
  fLogFileStream.Position := fLogFileStream.Size;
end;

destructor TPlainTextWriter.Destroy;
begin
  FreeAndNil(fLogFileStream);
  inherited Destroy;
end;

procedure TPlainTextWriter.Write(const aMessage: TCustomLogMessage);
var
  s:String;
begin
  s := Format('%s : [%s] %s'#13#10, [DateTimeToStr(aMessage.Time), aMessage.Tag, aMessage.Text]);
  fLogFileStream.WriteBuffer(s[1], Length(s));
end;

end.

