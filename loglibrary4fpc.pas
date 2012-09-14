{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit LogLibrary4FPC;

interface

uses
  ConsoleLogWriter, CustomLogEntity, CustomLogManager, CustomLogMessage, 
  CustomLogMessageList, CustomLogWriter, CustomLogWriterList, 
  DefaultLogEntity, DefaultLogMessage, EmptyLogEntity, PlainLogManager, 
  PlainTextWriter, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('LogLibrary4FPC', @Register);
end.
