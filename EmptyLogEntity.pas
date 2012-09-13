unit EmptyLogEntity;

interface

uses
  CustomLogEntity;

type
  TEmptyLog = class(TCustomLog)
  public
    procedure Write(const aText: string); overload; override;
    procedure Write(const aTag, aText: string); overload; override;
  end; 

implementation

{ TEmptyLog }

procedure TEmptyLog.Write(const aText: string);
begin
end;

procedure TEmptyLog.Write(const aTag, aText: string);
begin
end;

end.
