program AutoTrader;

uses
  System.StartUpCopy,
  FMX.Forms,
  uPpal in 'uPpal.pas' {PpalFrm},
  uProfundidad in 'uProfundidad.pas',
  Pkg.Json.DTO in 'Comun\Pkg.Json.DTO.pas',
  uOrden in 'Comun\uOrden.pas',
  uExchangeInfo in 'Comun\uExchangeInfo.pas',
  uVelas in 'uVelas.pas',
  uClassMessageDTO in 'Comun\Telegram\uClassMessageDTO.pas',
  uConsts in 'Comun\Telegram\uConsts.pas',
  uTelegramAPI.Interfaces in 'Comun\Telegram\uTelegramAPI.Interfaces.pas',
  uTelegramAPI in 'Comun\Telegram\uTelegramAPI.pas';

{$R *.res}

begin
//  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.CreateForm(TPpalFrm, PpalFrm);
  Application.Run;
end.
