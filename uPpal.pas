unit uPpal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, REST.Types,
  REST.Client, Data.Bind.Components, Data.Bind.ObjectScope, FMX.Edit,
  FMX.ComboEdit, FMX.Controls.Presentation, FMX.StdCtrls, FMX.EditBox,
  FMX.NumberBox, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, JSON, FMXTee.Engine,
  FMXTee.Series, FMXTee.Procs, System.DateUtils, Windows,
  IdGlobal, IdHashSHA, IdHMAC, IdHMACSHA1, IdSSLOpenSSL, System.Hash,
  System.Math, FMX.Layouts, uOrden, Generics.Collections, uTelegramAPI,
  uTelegramAPI.Interfaces,
  uExchangeInfo, uVelas, ScWebSocketClient, ScBridge, FMX.ListBox;

type
  TEstadoOperacion = (eoAnalisisCompra, eoAnalisisVenta, eoCompleto,
    eoEvaluaEntrada);

type
  TEMA = (emaPrice, emaOthers);

type
  TPpalFrm = class(TForm)
    lbResumen: TLabel;
    RESTClientCreate: TRESTClient;
    RESTReqCreate: TRESTRequest;
    RESTResCreate: TRESTResponse;
    Layout1: TLayout;
    Label1: TLabel;
    edLimit: TNumberBox;
    Label2: TLabel;
    edCantidadEnPrecio: TNumberBox;
    Label3: TLabel;
    btEjecutarAuto: TButton;
    btDetener: TButton;
    edGanancia: TNumberBox;
    edSL: TNumberBox;
    Label4: TLabel;
    Label5: TLabel;
    RESTClientOCO: TRESTClient;
    RESTReqOCO: TRESTRequest;
    RESTResOCO: TRESTResponse;
    RESTClientOrder: TRESTClient;
    RESTReqOrder: TRESTRequest;
    RESTResOrder: TRESTResponse;
    lbEstado: TLabel;
    btManual: TButton;
    edtickSize: TEdit;
    edstepSize: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    RESTClientExchange: TRESTClient;
    RESTReqExchange: TRESTRequest;
    RESTResExchange: TRESTResponse;
    btChangeCoin: TSpeedButton;
    RESTClientVelas: TRESTClient;
    RESTReqVelas: TRESTRequest;
    RESTResVelas: TRESTResponse;
    wsUltimaVela: TScWebSocketClient;
    lbConnection: TLabel;
    lbIDSubscribe: TLabel;
    edEmaRapida: TEdit;
    Label8: TLabel;
    Label9: TLabel;
    edEmaLenta: TEdit;
    memMessage: TMemo;
    btVentaManual: TButton;
    RESTClientMarket: TRESTClient;
    RESTResMarket: TRESTResponse;
    RESTReqMarket: TRESTRequest;
    cbBajista: TCheckBox;
    Label10: TLabel;
    edSMA: TEdit;
    Label11: TLabel;
    edSMAVenta: TEdit;
    btEvaluaCompra: TButton;
    btEvaluaVenta: TButton;
    edPares: TComboBox;
    procedure btEjecutarAutoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btDetenerClick(Sender: TObject);
    procedure btManualClick(Sender: TObject);
    procedure btChangeCoinClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure wsUltimaVelaMessage(Sender: TObject;
      const Data: TArray<System.Byte>; MessageType: TScWebSocketMessageType;
      EndOfMessage: Boolean);
    procedure wsUltimaVelaAsyncError(Sender: TObject; E: Exception);
    procedure wsUltimaVelaAfterConnect(Sender: TObject);
    procedure wsUltimaVelaAfterDisconnect(Sender: TObject);
    procedure btVentaManualClick(Sender: TObject);
    procedure cbBajistaChange(Sender: TObject);
    procedure btEvaluaCompraClick(Sender: TObject);
    procedure btEvaluaVentaClick(Sender: TObject);
  private

    // Stop Limit
    FSL: Extended;
    FManual: Boolean;
    FErrores: Integer;
    FDetener: Boolean;
    FVelaVenta: TVela;
    FCurrentPar: String;
    FConexionCaida: Boolean;
    FTelegram: iTelegramAPI;
    FVelasList: TListaVelas;
    FCantidadAVender: string;
    FCompraxMomentum: Boolean;
    FEstadoOP: TEstadoOperacion;
    FExcahngeInfo: TExchangeInfo;
    FCantidadVelasCambio: Integer;
    FConteoVelasEvaluadas: Integer;
    FPrecioDeCompra, FPrecioDeVenta: Extended;
    // FAcumuladoGanancias: Extended;

    procedure EnviarNotificaciones(pMessage: String);

    procedure serializeArray(MyJSONObject: TJSONObject);
    // procedure CrearOrdenCompra(vDepthList: TDepthList;
    // vPrecioMin, vPrecioMax: Extended);
    function UNIXTimeInMilliseconds: Int64;
    procedure CrearOrdenOCO(pOrden: TOrden);
    procedure ConsultarOrden(pOrden: TOrden);
    procedure SetSizeCoin(const ptickSize, pstepSize: String; out pQTY: Integer;
      out pPrice: String);

    procedure CalcularEMA(pNiveles, pNivelActual: Integer;
      pTipo: TEMA = emaPrice);
    function CalcularValorSuavizado(pNiveles: Integer): Extended;
    function CalcularSMA(pNiveles: Integer; pVelas: TListaVelas;
      pNivelActual: Integer; pTipo: TEMA = emaPrice): Extended;
    procedure AnalizaVelas(LEMAR, LEMAL, LMomentum, LSMA, LSMA_Venta: Extended);
    procedure CrearOrdenCompra(vPrecioCompra: Extended);
    function BytesToString(Data: TArray<System.Byte>): String;
    procedure AnalisisCompra(pEvaluar: Boolean; LEMAR, LEMAL, LMomentum, LSMA,
      LSMA_Venta: Extended);
    procedure AnalisisVenta(pEvaluar: Boolean; pEMAR, pEMAL, pMomentum, pSMA,
      pSMAVenta: Extended);
    procedure VentaMarket(pCantidadAVender: String);
    procedure OnAPIError(AExcept: Exception);

    // Devuelve True si ha cambiado la Vela
    function ActualizaUltimaVela(pData: String; var pEMAR, pEMAL, pMomentum,
      pSMA, pSMAVenta: Extended): Boolean;

    procedure MensajesDeError(pMensaje: String);
    procedure SetEstadoOP(const Value: TEstadoOperacion);

    property EstadoOP: TEstadoOperacion read FEstadoOP write SetEstadoOP;
  public
    { Public declarations }
  end;

var
  CNS_SECRET: String = '';
  CNS_API_KEY: String = '';
  CNS_QTY_SIZE: Integer = 0;
  CNS_PRICE_SIZE: String = '###,###,##0.#######';

const
  CNS_SMA = 50;
  CNS_SMA_VENTA = 13;
  CNS_EMA_RAPIDA = 8;
  CNS_EMA_LENTA = 21;
  CNS_TEMPORALIDAD = '5m';
  CNS_MOMENTUM_EVAL = 101.5;
  CNS_LOT_SIZE = 'LOT_SIZE';
  CNS_MAX_VELAS_EVALUAR = 2;
  CNS_PORC_MAX_GANANCIA = 11;
  CNS_PRICE_FILTER = 'PRICE_FILTER';
  CNS_URL = 'https://api3.binance.com/';

var
  PpalFrm: TPpalFrm;

implementation

{$R *.fmx}

procedure TPpalFrm.btChangeCoinClick(Sender: TObject);
begin
  FCurrentPar := edPares.Items[edPares.ItemIndex];
  edstepSize.Text := FExcahngeInfo.getSymbol(FCurrentPar)
    .getFilter(CNS_LOT_SIZE).StepSize;
  edtickSize.Text := FExcahngeInfo.getSymbol(FCurrentPar)
    .getFilter(CNS_PRICE_FILTER).TickSize;
end;

procedure TPpalFrm.btEjecutarAutoClick(Sender: TObject);
begin
  FCompraxMomentum := False;
  edPares.Enabled := False;
  FConteoVelasEvaluadas := 0;

  FCantidadVelasCambio := 0;
  FCurrentPar := edPares.Items[edPares.ItemIndex];

  if not FConexionCaida then
    EstadoOP := eoAnalisisCompra;

  btChangeCoinClick(Sender);
  SetSizeCoin(FExcahngeInfo.getSymbol(FCurrentPar).getFilter(CNS_PRICE_FILTER)
    .TickSize, FExcahngeInfo.getSymbol(FCurrentPar).getFilter(CNS_LOT_SIZE)
    .StepSize, CNS_QTY_SIZE, CNS_PRICE_SIZE);

  lbEstado.Text := 'Trayendo Velas';

  RESTClientVelas.BaseURL := CNS_URL + 'api/v3/klines?symbol=' + FCurrentPar +
    '&interval=' + CNS_TEMPORALIDAD + '&limit=500';

  RESTReqVelas.ExecuteAsync(
    procedure
    var
      vID: Integer;
      vJObject: TJSONObject;
    begin
      EnviarNotificaciones('Inició Proceso');

      vJObject := TJSONObject(TJSONObject.ParseJSONValue(RESTResVelas.Content));
      try
        serializeArray(vJObject);

        // wsUltimaVela.Close;

        vID := RandomRange(1, 1000);
        lbIDSubscribe.Text := 'ID de Suscripción: ' + vID.ToString;

        wsUltimaVela.RequestUri := 'wss://stream.binance.com:9443/ws/' +
          FCurrentPar.ToLower + '@kline_' + CNS_TEMPORALIDAD;
        wsUltimaVela.Connect;
        wsUltimaVela.Send('{"method": "SUBSCRIBE","params":["' +
          FCurrentPar.ToLower + '@kline_' + CNS_TEMPORALIDAD + '"],"id": ' +
          vID.ToString + '}');
      finally
        vJObject.Free;
      end;
    end, True, True,
    procedure (pError: TObject)
    var
      vError: Exception absolute pError;
    begin
      ShowMessage(vError.Message);
    end);
end;

procedure TPpalFrm.btEvaluaCompraClick(Sender: TObject);
begin
  EstadoOP := eoAnalisisCompra;
end;

procedure TPpalFrm.btEvaluaVentaClick(Sender: TObject);
begin
  FCantidadAVender := InputBox('Cantidad: ', '', FCantidadAVender);
  EstadoOP := eoAnalisisVenta;
end;

procedure TPpalFrm.CrearOrdenCompra(vPrecioCompra: Extended);
begin
  wsUltimaVela.OnMessage := nil;
  lbEstado.Text := 'Creando Orden de Compra';

  RESTReqCreate.Params.ParameterByName('newClientOrderId').Value :=
    TGUID.NewGuid.ToString.Replace('-', '').Replace('{', '').Replace('}', '');
  RESTReqCreate.Params.ParameterByName('symbol').Value := FCurrentPar;
  RESTReqCreate.Params.ParameterByName('quoteOrderQty').Value :=
    edCantidadEnPrecio.Text;

  RESTReqCreate.Params.ParameterByName('timestamp').Value :=
    UNIXTimeInMilliseconds.ToString;

  RESTReqCreate.Params.ParameterByName('signature').Value :=
    THashSHA2.GetHMAC('side=BUY&type=MARKET&recvWindow=5000&newClientOrderId=' +
    RESTReqCreate.Params.ParameterByName('newClientOrderId').Value + '&symbol='
    + edPares.Items[edPares.ItemIndex] + '&quoteOrderQty=' +
    RESTReqCreate.Params.ParameterByName('quoteOrderQty').Value + '&timestamp='
    + RESTReqCreate.Params.ParameterByName('timestamp').Value, CNS_SECRET);
  RESTReqCreate.ExecuteAsync(
    procedure
    var
      vOrden: TOrden;
    begin
      vOrden := TOrden.Create;
      try
        vOrden.AsJson := RESTResCreate.Content;

        if vOrden.Status = 'FILLED' then
        begin
          FCantidadAVender := vOrden.OrigQty;

          if vOrden.Fills.Count > 0 then
            FPrecioDeCompra := vOrden.Fills.Last.Price.ToExtended;

          FVelaVenta := FVelasList.Velas.Last;
          EstadoOP := eoAnalisisVenta;
          lbEstado.Text := 'Orden de Compra Ejecutada';

          wsUltimaVela.OnMessage := wsUltimaVelaMessage;

          EnviarNotificaciones(FCurrentPar +
            ': Orden de Compra Ejecutada; Precio: ' + FPrecioDeCompra.ToString +
            '; Cantidad: ' + vOrden.OrigQty + ';xMomentum: ' +
            FCompraxMomentum.ToString(TUseBoolStrs.True));
        end
        else if vOrden.Status = 'NEW' then
        begin
          ConsultarOrden(vOrden);
        end
        else
        begin
          MensajesDeError('Orden no ejecutada por el servidor: ' +
            RESTResCreate.Content);
          wsUltimaVela.OnMessage := wsUltimaVelaMessage;
        end;

      finally
      end;
    end);
end;

procedure TPpalFrm.ConsultarOrden(pOrden: TOrden);
begin
  // memMessage.Lines.Add('Orden: ' + pOrden.OrderId.ToString);
  // memMessage.Lines.Add('ClientOrden: ' + pOrden.ClientOrderId);

  lbEstado.Text := 'Consultando Estado de Orden';

  RESTReqOrder.Params.ParameterByName('symbol').Value := FCurrentPar;
  // RESTReqOrder.Params.ParameterByName('orderId').Value :=
  // pOrden.OrderId.ToString;
  // RESTReqOrder.Params.ParameterByName('origClientOrderId').Value :=
  // pOrden.ClientOrderId;
  RESTReqOrder.Params.ParameterByName('timestamp').Value :=
    UNIXTimeInMilliseconds.ToString;

  RESTReqOrder.Params.ParameterByName('signature').Value :=
    THashSHA2.GetHMAC('recvWindow=5000&symbol=' + FCurrentPar + '&timestamp=' +
    RESTReqOrder.Params.ParameterByName('timestamp').Value, CNS_SECRET);

  RESTReqOrder.ExecuteAsync(
    procedure
    var
      vOrden: TOrden;
    begin
      vOrden := TOrden.Create;
      try
        vOrden.AsJson := RESTResOrder.Content.Replace('[', '').Replace(']', '');

        if vOrden.Status = 'FILLED' then
        begin
          lbEstado.Text := 'Orden de Compra Ejecutada';

          case FEstadoOP of
            eoAnalisisCompra:
              begin
                FCantidadAVender := vOrden.OrigQty;
                FVelaVenta := FVelasList.Velas.Last;
                FPrecioDeCompra := vOrden.Price.ToExtended;
                lbEstado.Text := 'Orden de Compra Ejecutada';
                EstadoOP := eoAnalisisVenta;

                wsUltimaVela.OnMessage := wsUltimaVelaMessage;

                EnviarNotificaciones(FCurrentPar +
                  ': Orden de Compra Ejecutada; Precio: ' +
                  FPrecioDeCompra.ToString + '; Cantidad: ' + vOrden.OrigQty);
              end;
            eoAnalisisVenta:
              begin
                FCantidadVelasCambio := 0;

                EstadoOP := eoAnalisisCompra;

                lbEstado.Text := 'Orden de Venta Ejecutada';

                wsUltimaVela.OnMessage := wsUltimaVelaMessage;

                EnviarNotificaciones(FCurrentPar +
                  ': Orden de Venta Ejecutada');
              end;
          end;
        end
        else
        begin
          if vOrden.Status = 'NEW' then
          begin
            Sleep(1000);
            ConsultarOrden(vOrden);
          end
          else
          begin
            MensajesDeError(RESTResOrder.Content);
            Sleep(1000);
            ConsultarOrden(vOrden);
          end;
        end;

      finally
        // vOrden.Free;
      end;
    end);
end;

procedure TPpalFrm.CrearOrdenOCO(pOrden: TOrden);
begin
  // ShowMessage(pOrden.Price);
  lbEstado.Text := 'Creando OCO';

  RESTReqOCO.Params.ParameterByName('listClientOrderId').Value :=
    TGUID.NewGuid.ToString.Replace('-', '').Replace('{', '').Replace('}', '');
  RESTReqOCO.Params.ParameterByName('limitClientOrderId').Value :=
    TGUID.NewGuid.ToString.Replace('-', '').Replace('{', '').Replace('}', '');
  RESTReqOCO.Params.ParameterByName('stopClientOrderId').Value :=
    TGUID.NewGuid.ToString.Replace('-', '').Replace('{', '').Replace('}', '');
  RESTReqOCO.Params.ParameterByName('symbol').Value := FCurrentPar;
  RESTReqOCO.Params.ParameterByName('price').Value :=
    FormatFloat(CNS_PRICE_SIZE, pOrden.Price.ToExtended +
    (pOrden.Price.ToExtended * (edGanancia.Value / 100)));
  RESTReqOCO.Params.ParameterByName('quantity').Value :=
    Roundto(StrToFloat(pOrden.OrigQty), CNS_QTY_SIZE).ToString;
  // FormatFloat('###,###,##0.####', StrToFloat(pOrden.OrigQty));

  RESTReqOCO.Params.ParameterByName('stopLimitPrice').Value :=
    FormatFloat(CNS_PRICE_SIZE,
    (pOrden.Price.ToExtended - (pOrden.Price.ToExtended * (edSL.Value / 100))));
  RESTReqOCO.Params.ParameterByName('stopPrice').Value :=
    FormatFloat(CNS_PRICE_SIZE,
    (StrToFloat(RESTReqOCO.Params.ParameterByName('stopLimitPrice').Value) +
    (StrToFloat(RESTReqOCO.Params.ParameterByName('stopLimitPrice').Value) *
    (0.5 / 100))));

  RESTReqOCO.Params.ParameterByName('timestamp').Value :=
    UNIXTimeInMilliseconds.ToString;

  RESTReqOCO.Params.ParameterByName('signature').Value :=
    THashSHA2.GetHMAC
    ('side=SELL&recvWindow=5000&stopLimitTimeInForce=GTC&newOrderRespType=FULL'
    + '&listClientOrderId=' + RESTReqOCO.Params.ParameterByName
    ('listClientOrderId').Value + '&limitClientOrderId=' +
    RESTReqOCO.Params.ParameterByName('limitClientOrderId').Value +
    '&stopClientOrderId=' + RESTReqOCO.Params.ParameterByName
    ('stopClientOrderId').Value + '&symbol=' + FCurrentPar + '&price=' +
    RESTReqOCO.Params.ParameterByName('price').Value + '&quantity=' +
    RESTReqOCO.Params.ParameterByName('quantity').Value + '&stopPrice=' +
    RESTReqOCO.Params.ParameterByName('stopPrice').Value + '&stopLimitPrice=' +
    RESTReqOCO.Params.ParameterByName('stopLimitPrice').Value + '&timestamp=' +
    RESTReqOCO.Params.ParameterByName('timestamp').Value, CNS_SECRET);


  // ShowMessage(RESTReqOCO.Params.ParameterByName('quantity').Value);

  RESTReqOCO.ExecuteAsync(
    procedure
    var
      vEstado: String;
      vJValue: TJSONValue;
    begin
      vJValue := TJSONObject.ParseJSONValue(RESTResOCO.Content);

      vJValue.TryGetValue<string>('listStatusType', vEstado);


      // Memo1.Lines.Add(RESTResOCO.Content);
      //
      // Memo1.Lines.Add(RESTReqOCO.Params.ParameterByName('price').Value);
      // Memo1.Lines.Add(RESTReqOCO.Params.ParameterByName('quantity').Value);
      //
      // Memo1.Lines.Add(RESTReqOCO.Params.ParameterByName('stopPrice').Value);
      // Memo1.Lines.Add(RESTReqOCO.Params.ParameterByName('stopLimitPrice').Value);
      //
      //
      // Memo1.Lines.Add(pOrden.Price);


      // 40570.3919
      // 0.002539
      // 39189.8169135
      // 38994.8427

      // 39388.73000000

      if vEstado = 'EXEC_STARTED' then
        ShowMessage('Orden OCO Ejecutada')
      else
      begin
        // Memo1.Lines.Add(RESTResOCO.Content);
        Sleep(1000);
        CrearOrdenOCO(pOrden);
      end;
    end, True, True,
    procedure(vObject: TObject)
    begin
      if Pos('PRICE_FILTER', RESTResOCO.Content) > 0 then
      begin
        // Memo1.Lines.Add(RESTResOCO.Content);
        CrearOrdenOCO(pOrden);
      end
      else
        ShowMessage(RESTResOCO.Content);
    end);

end;

procedure TPpalFrm.EnviarNotificaciones(pMessage: String);
begin
  try
    FTelegram := TTelegramAPI.New();
    FTelegram.OnError(OnAPIError).SetUserID('IDUSer')
      .SetBotToken('TokenBot');

    FTelegram.SendMsg(pMessage);
  except
    on E: Exception do
      memMessage.Lines.Add(E.Message);
  end;
end;

procedure TPpalFrm.btManualClick(Sender: TObject);
begin
  FManual := True;
  btEjecutarAutoClick(Sender);
end;

procedure TPpalFrm.btDetenerClick(Sender: TObject);
begin
  wsUltimaVela.AfterDisconnect := nil;
  edPares.Enabled := True;
  wsUltimaVela.Close(TScWebSocketCloseStatus.csNormalClosure);
  wsUltimaVela.AfterDisconnect := wsUltimaVelaAfterDisconnect;
end;

function TPpalFrm.CalcularSMA(pNiveles: Integer; pVelas: TListaVelas;
pNivelActual: Integer; pTipo: TEMA = emaPrice): Extended;
var
  vI: Integer;
  vAcumulado: Extended;
begin
  vI := 0;
  vAcumulado := 0;

  case pTipo of
    emaPrice:
      for vI := (pNivelActual - (pNiveles + 1)) downto (pNivelActual) -
        ((pNiveles * 2)) do
        vAcumulado := vAcumulado + pVelas.Velas.Items[vI]
          .DatosVela.CPrice.ToExtended;

    emaOthers:
      for vI := pNivelActual downto (pNivelActual) - (pNiveles - 1) do
        vAcumulado := vAcumulado + pVelas.Velas.Items[vI]
          .DatosVela.CPrice.ToExtended;
  end;

  Result := vAcumulado / pNiveles;
end;

function TPpalFrm.CalcularValorSuavizado(pNiveles: Integer): Extended;
begin
  Result := (2 / (pNiveles + 1));
end;

procedure TPpalFrm.cbBajistaChange(Sender: TObject);
begin
  edEmaLenta.Text := '1';
end;

procedure TPpalFrm.CalcularEMA(pNiveles, pNivelActual: Integer;
pTipo: TEMA = emaPrice);
begin
  if ((FVelasList.Velas.Count - 1) - pNivelActual) = pNiveles - 1 then
  begin
    FVelasList.Velas[pNivelActual - 1].EMA := CalcularSMA(pNiveles, FVelasList,
      FVelasList.Velas.Count - 1, pTipo);
  end;

  case pTipo of
    emaPrice:
      FVelasList.Velas[pNivelActual].EMA :=
        (FVelasList.Velas.Items[pNivelActual].DatosVela.CPrice.ToExtended *
        CalcularValorSuavizado(pNiveles)) +
        (FVelasList.Velas[pNivelActual - 1].EMA *
        (1 - CalcularValorSuavizado(pNiveles)));

    { CalcularValorSuavizado(pNiveles) *
      FVelasList.Velas.Items[pNivelActual].DatosVela.CPrice.ToExtended +
      (1 - CalcularValorSuavizado(pNiveles)) * FVelasList.Velas
      [pNivelActual - 1].EMA; }

    emaOthers:
      FVelasList.Velas[pNivelActual].EMA := CalcularValorSuavizado(pNiveles) *
        FVelasList.Velas.Items[pNivelActual].DatosVela.Volume.ToExtended +
        (1 - CalcularValorSuavizado(pNiveles)) * FVelasList.Velas
        [pNivelActual - 1].EMA;
  end;

  if ((pNivelActual) < (FVelasList.Velas.Count - 1)) then
    CalcularEMA(pNiveles, pNivelActual + 1, pTipo);
end;

function TPpalFrm.UNIXTimeInMilliseconds: Int64;
var
  ST: SystemTime;
  DT: TDateTime;
begin
  Windows.GetSystemTime(ST);
  DT := EncodeDate(ST.wYear, ST.wMonth, ST.wDay) + EncodeTime(ST.wHour,
    ST.wMinute, ST.wSecond, ST.wMilliseconds);
  Result := MilliSecondsBetween(DT, UnixDateDelta);
end;

procedure TPpalFrm.wsUltimaVelaAfterConnect(Sender: TObject);
begin
  lbConnection.Text := 'Conectado';
  FConexionCaida := False;
end;

procedure TPpalFrm.wsUltimaVelaAfterDisconnect(Sender: TObject);
begin
  lbConnection.Text := 'Desconectado';
  FreeAndNil(FVelasList);

  // FConexionCaida := True;
  // btEjecutarAutoClick(Sender);
end;

procedure TPpalFrm.wsUltimaVelaAsyncError(Sender: TObject; E: Exception);
begin
  // Memo1.Lines.Add(E.Message);
end;

procedure TPpalFrm.btVentaManualClick(Sender: TObject);
begin
  FCantidadAVender := '0';
  btChangeCoinClick(Sender);
  SetSizeCoin(FExcahngeInfo.getSymbol(FCurrentPar).getFilter(CNS_PRICE_FILTER)
    .TickSize, FExcahngeInfo.getSymbol(FCurrentPar).getFilter(CNS_LOT_SIZE)
    .StepSize, CNS_QTY_SIZE, CNS_PRICE_SIZE);

  if (FCantidadAVender = '0') then
    FCantidadAVender := InputBox('Cantidad: ', '', '0');

  VentaMarket(FCantidadAVender);
  EstadoOP := eoCompleto;
end;

procedure TPpalFrm.OnAPIError(AExcept: Exception);
begin
  TThread.Synchronize(TThread.Current,
    procedure
    begin
      memMessage.Lines.Add(AExcept.Message);
    end);
end;

function TPpalFrm.BytesToString(Data: TArray<System.Byte>): String;
begin
  Result := TEncoding.ANSI.GetString(Data);
end;

function TPpalFrm.ActualizaUltimaVela(pData: String;
var pEMAR, pEMAL, pMomentum, pSMA, pSMAVenta: Extended): Boolean;
var
  vJSON: TJSONValue;
begin
  Result := False;
  vJSON := TJSONObject.ParseJSONValue(pData);
  try
    if Pos('result', pData) = 0 then
    begin
      if (vJSON.GetValue<Int64>('k.t') <> FVelasList.Velas.Last.DatosVela.
        StartTime) then
      begin
        // Eliminar...
        // FCantidadAVender := (FCantidadAVender.ToInteger + (1)).ToString;
        // memMessage.Lines.Add(FCantidadAVender);
        // Hasta Acá eliminar...

        Result := True;
        FVelasList.Velas.Add(TVela.Create);
      end;

      FVelasList.Velas.Last.DatosVela.StartTime := vJSON.GetValue<Int64>('k.t');
      FVelasList.Velas.Last.DatosVela.OPrice := vJSON.GetValue<string>('k.o');
      FVelasList.Velas.Last.DatosVela.CPrice := vJSON.GetValue<string>('k.c');
      FVelasList.Velas.Last.DatosVela.HPrice := vJSON.GetValue<string>('k.h');
      FVelasList.Velas.Last.DatosVela.LPrice := vJSON.GetValue<string>('k.l');
      FVelasList.Velas.Last.DatosVela.Volume := vJSON.GetValue<string>('k.v');

      CalcularEMA(CNS_EMA_RAPIDA, (FVelasList.Velas.Count - 1) -
        (CNS_EMA_RAPIDA - 1));
      pEMAR := FVelasList.Velas.Last.EMA;

      CalcularEMA(CNS_EMA_LENTA, (FVelasList.Velas.Count - 1) -
        (CNS_EMA_LENTA - 1));
      pEMAL := FVelasList.Velas.Last.EMA;

      pMomentum := ((FVelasList.Velas.Last.DatosVela.CPrice.ToExtended /
        FVelasList.Velas.Items[FVelasList.Velas.Count - 2]
        .DatosVela.CPrice.ToExtended) * 100);

      pSMA := CalcularSMA(CNS_SMA, FVelasList, FVelasList.Velas.Count - 1,
        emaOthers);

      pSMAVenta := CalcularSMA(CNS_SMA_VENTA, FVelasList,
        FVelasList.Velas.Count - 1, emaOthers);

      // memMessage.Lines.Add(CalcularSMA(CNS_SMA_VENTA, FVelasList,
      // FVelasList.Velas.Count - 2, emaOthers).ToString);

      edEmaLenta.BeginUpdate;
      edEmaRapida.BeginUpdate;
      edSMA.BeginUpdate;
      edSMAVenta.BeginUpdate;

      edEmaRapida.Text := pEMAR.ToString;
      edEmaLenta.Text := pEMAL.ToString;
      edSMA.Text := pSMA.ToString;
      edSMAVenta.Text := pSMAVenta.ToString;

      edSMAVenta.EndUpdate;
      edSMA.EndUpdate;
      edEmaRapida.EndUpdate;
      edEmaLenta.EndUpdate;
    end;
  finally
    FreeAndNil(vJSON);
  end;
end;

procedure TPpalFrm.AnalisisCompra(pEvaluar: Boolean;
LEMAR, LEMAL, LMomentum, LSMA, LSMA_Venta: Extended);
begin
  lbEstado.Text := 'Analizando Compra';
  try
    if ((pEvaluar) or (LMomentum >= CNS_MOMENTUM_EVAL)) then
    begin
      FCompraxMomentum := ((not pEvaluar) and (LMomentum >= CNS_MOMENTUM_EVAL));
      AnalizaVelas(LEMAR, LEMAL, LMomentum, LSMA, LSMA_Venta);
    end;
  except
    on E: Exception do
    begin
      Inc(FErrores);
      lbResumen.Text := E.Message + IntToStr(FErrores);
    end;
  end;
end;

procedure TPpalFrm.wsUltimaVelaMessage(Sender: TObject;
const Data: TArray<System.Byte>; MessageType: TScWebSocketMessageType;
EndOfMessage: Boolean);
var
  vEvaluar: Boolean;
  vEMAR, vEMAL, vMomentum, vSMA, vSMA_Venta: Extended;
begin
  vSMA := 0;
  vEMAR := 0;
  vEMAL := 0;
  vSMA_Venta := 0;
  vEvaluar := ActualizaUltimaVela(BytesToString(Data), vEMAR, vEMAL, vMomentum,
    vSMA, vSMA_Venta);

  if FManual then
  begin
    FManual := False;
    CrearOrdenCompra(FVelasList.Velas.Last.DatosVela.CPrice.ToExtended);
  end
  else
    case FEstadoOP of
      eoAnalisisCompra:
        AnalisisCompra(vEvaluar, vEMAR, vEMAL, vMomentum, vSMA, vSMA_Venta);
      eoAnalisisVenta:
        AnalisisVenta(vEvaluar, vEMAR, vEMAL, vMomentum, vSMA, vSMA_Venta);
      eoCompleto:
        begin
          btDetenerClick(Sender);
        end;
      eoEvaluaEntrada:
        if vEMAR < vEMAL then
          EstadoOP := eoAnalisisCompra;
    end;
end;

procedure TPpalFrm.AnalisisVenta(pEvaluar: Boolean;
pEMAR, pEMAL, pMomentum, pSMA, pSMAVenta: Extended);
var
  vPrecioActual: Extended;
  vMomentumAnterior: Extended;
begin
  lbEstado.Text := 'Analizando Venta';
  vPrecioActual := FVelasList.Velas.Last.DatosVela.CPrice.ToExtended;
  try
    if FCompraxMomentum then
    begin
      var
        vSLTemp: Extended := (vPrecioActual - (vPrecioActual * (0.01)));

      if vSLTemp > FSL then
        FSL := vSLTemp;

      if vPrecioActual <= FSL then
      begin
        VentaMarket(FCantidadAVender);
        FSL := 0;
        FCompraxMomentum := False;
      end;
    end
    else if pEvaluar then // if pEMAR <= pEMAL then
    begin
      vMomentumAnterior :=
        ((FVelasList.Velas.Items[FVelasList.Velas.Count - 2]
        .DatosVela.CPrice.ToExtended / FVelasList.Velas.Items
        [FVelasList.Velas.Count - 3].DatosVela.CPrice.ToExtended) * 100);

      // if ((vPrecioActual <= pSMAVenta) and (vMomentumAnterior < 100)) then
      if pEMAR < pSMAVenta then
        VentaMarket(FCantidadAVender);
    end;
  except
    on E: Exception do
    begin
      MensajesDeError(E.Message);
    end;
  end;
end;

procedure TPpalFrm.VentaMarket(pCantidadAVender: String);
begin
  // wsUltimaVela.Close;
  wsUltimaVela.OnMessage := nil;

  lbEstado.Text := 'Creando Orden de Venta';

  RESTReqMarket.Params.ParameterByName('newClientOrderId').Value :=
    TGUID.NewGuid.ToString.Replace('-', '').Replace('{', '').Replace('}', '');

  RESTReqMarket.Params.ParameterByName('symbol').Value := FCurrentPar; // *
  RESTReqMarket.Params.ParameterByName('side').Value := 'SELL';
  RESTReqMarket.Params.ParameterByName('type').Value := 'MARKET';
  RESTReqMarket.Params.ParameterByName('quantity').Value :=
    Roundto(StrToFloat(pCantidadAVender), CNS_QTY_SIZE).ToString;

  RESTReqMarket.Params.ParameterByName('timestamp').Value :=
    UNIXTimeInMilliseconds.ToString;

  RESTReqMarket.Params.ParameterByName('signature').Value :=
    THashSHA2.GetHMAC('side=SELL&type=MARKET&recvWindow=5000&newClientOrderId='
    + RESTReqMarket.Params.ParameterByName('newClientOrderId').Value +
    '&symbol=' + FCurrentPar + '&quantity=' +
    RESTReqMarket.Params.ParameterByName('quantity').Value + '&timestamp=' +
    RESTReqMarket.Params.ParameterByName('timestamp').Value, CNS_SECRET);

  RESTReqMarket.ExecuteAsync(
    procedure
    var
      vOrden: TOrden;
    begin
      vOrden := TOrden.Create;
      try
        vOrden.AsJson := RESTResMarket.Content;

        if vOrden.Status = 'FILLED' then
        begin
          if vOrden.Fills.Count > 0 then
            FPrecioDeVenta := vOrden.Fills.Last.Price.ToExtended;

          FCantidadVelasCambio := 0;

          EstadoOP := eoAnalisisCompra;

          lbEstado.Text := 'Orden de Venta Ejecutada';

          wsUltimaVela.OnMessage := wsUltimaVelaMessage;

          EnviarNotificaciones(FCurrentPar +
            ': Orden de Venta Ejecutada; Precio:' + FPrecioDeVenta.ToString);
        end
        else if vOrden.Status = 'NEW' then
        begin
          ConsultarOrden(vOrden);
        end
        else
        begin
          MensajesDeError('Orden de venta no ejecutada por el servidor: ' +
            RESTResMarket.Content);
          wsUltimaVela.OnMessage := wsUltimaVelaMessage;
        end;

      finally
      end;
    end);
end;

procedure TPpalFrm.AnalizaVelas(LEMAR, LEMAL, LMomentum, LSMA,
  LSMA_Venta: Extended);
var
  vVolume: Extended;
begin
  vVolume := FVelasList.Velas.Last.DatosVela.Volume.ToExtended;

  if cbBajista.IsChecked then
  begin
    if (vVolume > LSMA) then
    begin
      CrearOrdenCompra(FVelasList.Velas.Last.DatosVela.CPrice.ToExtended);
    end;
  end
  else
  begin
    if LEMAR > LEMAL then
    begin
      FConteoVelasEvaluadas := FConteoVelasEvaluadas + 1;

      if ((LEMAR > LSMA_Venta) and (LSMA_Venta > LEMAL) and (LEMAL > LSMA)) then
        // Linea Rapida por encima de la lenta
        CrearOrdenCompra(FVelasList.Velas.Last.DatosVela.CPrice.ToExtended)
      else if FConteoVelasEvaluadas >= CNS_MAX_VELAS_EVALUAR then
      begin
        FConteoVelasEvaluadas := 0;
        EstadoOP := eoEvaluaEntrada;
      end;
    end;
  end;
end;

procedure TPpalFrm.FormCreate(Sender: TObject);
// var

begin
  FSL := 0;
  FErrores := 0;
  FManual := False;
  FCompraxMomentum := False;
  FCantidadAVender := '0';
  // FAcumuladoGanancias := 0;
  FConexionCaida := False;
  FCurrentPar := 'OGNUSDT';

  RESTReqExchange.ExecuteAsync(
    procedure
    var
      vSymbol: TSymbolsDTO;
    begin
      FExcahngeInfo := TExchangeInfo.Create;
      FExcahngeInfo.AsJson := RESTResExchange.Content;

      edPares.BeginUpdate;
      try
        for vSymbol in FExcahngeInfo.Symbols do
          edPares.Items.Add(vSymbol.Symbol);
      finally
        edPares.EndUpdate;
      end;

      edPares.ItemIndex := 0;
      btChangeCoinClick(Sender);

      FDetener := False;

      RESTClientMarket.BaseURL := CNS_URL + 'api/v3/order';
      RESTClientCreate.BaseURL := CNS_URL + 'api/v3/order';
      RESTClientOCO.BaseURL := CNS_URL + 'api/v3/order/oco';
      RESTClientOrder.BaseURL := CNS_URL + 'api/v3/order';
      RESTClientExchange.BaseURL := CNS_URL + 'api/v3/exchangeInfo';

      RESTReqCreate.Params.ParameterByName('X-MBX-APIKEY').Value := CNS_API_KEY;
      RESTReqOrder.Params.ParameterByName('X-MBX-APIKEY').Value := CNS_API_KEY;
      RESTReqMarket.Params.ParameterByName('X-MBX-APIKEY').Value := CNS_API_KEY;
      RESTReqOCO.Params.ParameterByName('X-MBX-APIKEY').Value := CNS_API_KEY;
    end);
end;

procedure TPpalFrm.FormDestroy(Sender: TObject);
begin
  FExcahngeInfo.Free;
end;

procedure TPpalFrm.MensajesDeError(pMensaje: String);
begin
  try
    memMessage.Lines.Add(pMensaje);
    EnviarNotificaciones(pMensaje);
  except
    on E: Exception do
      memMessage.Lines.Add(E.Message);
  end;
end;

procedure TPpalFrm.serializeArray(MyJSONObject: TJSONObject);
var
  vJAux: TJSONValue;
  vEMAR, vEMAL: Extended;
  KeyFeatures: TJSONValue;
  FeatureItem: TJSONValue;
begin
  FVelasList := TListaVelas.Create;
  KeyFeatures := (MyJSONObject as TJSONObject);
  if KeyFeatures is TJSONArray then
  begin
    try
      for FeatureItem in TJSONArray(KeyFeatures) do
      begin
        vJAux := TJSONObject.ParseJSONValue(FeatureItem.ToString);
        try
          FVelasList.Velas.Add
            (TVela.Create(TJSONArray(vJAux).Items[1].ToString.Replace('"', ''),
            TJSONArray(vJAux).Items[4].ToString.Replace('"', ''),
            TJSONArray(vJAux).Items[2].ToString.Replace('"', ''),
            TJSONArray(vJAux).Items[3].ToString.Replace('"', ''),
            TJSONArray(vJAux).Items[5].ToString.Replace('"', ''),
            TJSONArray(vJAux).Items[0].ToString.Replace('"', '').ToInt64));
        finally
          FreeAndNil(vJAux);
        end;
      end;

      if not FManual then
      begin
        CalcularEMA(CNS_EMA_RAPIDA, (FVelasList.Velas.Count - 1) -
          (CNS_EMA_RAPIDA - 1));
        vEMAR := FVelasList.Velas.Last.EMA;

        CalcularEMA(CNS_EMA_LENTA, (FVelasList.Velas.Count - 1) -
          (CNS_EMA_LENTA - 1));
        vEMAL := FVelasList.Velas.Last.EMA;

        if vEMAR >= vEMAL then
          EstadoOP := eoEvaluaEntrada;
      end;
    finally
    end;
  end
  else
  begin
    // vDepthList := nil;
  end;
end;

procedure TPpalFrm.SetEstadoOP(const Value: TEstadoOperacion);
begin
  FEstadoOP := Value;

  case Value of
    eoCompleto:
      lbEstado.Text := 'Completo';
    eoEvaluaEntrada:
      lbEstado.Text := 'Evaluando el momento adecuado';
  end;
end;

procedure TPpalFrm.SetSizeCoin(

  const ptickSize, pstepSize: String; out pQTY: Integer; out pPrice: String);
begin
  pQTY := Pos('1', FloatToStr(Frac(StrToFloat(pstepSize))).Replace('0.', ''));

  if pQTY <> 0 then
    pQTY := Abs(pQTY) * -1;

  pPrice := '###,###,##0.' + StringOfChar('#', Pos('1', ptickSize) - 2);
end;

initialization

var
  vConfig: TStringList := TStringList.Create;
try
  vConfig.LoadFromFile(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))
    ) + 'Config.txt');

  CNS_SECRET := vConfig.Values['API_SECRET'];
  CNS_API_KEY := vConfig.Values['API_KEY'];
finally
  vConfig.Free;
end;

end.
