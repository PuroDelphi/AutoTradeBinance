unit uVelas;

interface

uses Generics.Collections, System.JSON.Serializers, System.JSON.Converters, SysUtils;

{
  "e": "kline",     // Event type
  "E": 123456789,   // Event time
  "s": "BNBBTC",    // Symbol
  "k": {
  "t": 123400000, // Kline start time
  "T": 123460000, // Kline close time
  "s": "BNBBTC",  // Symbol
  "i": "1m",      // Interval
  "f": 100,       // First trade ID
  "L": 200,       // Last trade ID
  "o": "0.0010",  // Open price
  "c": "0.0020",  // Close price
  "h": "0.0025",  // High price
  "l": "0.0015",  // Low price
  "v": "1000",    // Base asset volume
  "n": 100,       // Number of trades
  "x": false,     // Is this kline closed?
  "q": "1.0000",  // Quote asset volume
  "V": "500",     // Taker buy base asset volume
  "Q": "0.500",   // Taker buy quote asset volume
  "B": "123456"   // Ignore
}

type

  [JsonSerialize(TJsonMemberSerialization.&Public)]
  TDatosVela = class
  private
    [JsonName('t')]
    FStartTime: Int64;
    [JsonName('T')]
    FCloseTime: Int64;
    [JsonName('s')]
    FSymbol: String;
    [JsonName('i')]
    FInterval: String;
    [JsonName('o')]
    FOPrice: String;
    [JsonName('c')]
    FCPrice: String;
    [JsonName('h')]
    FHPrice: String;
    [JsonName('l')]
    FLPrice: String;
    [JsonName('v')]
    FBaseAssetVolume: String;
    [JsonName('n')]
    FNumberOfTrades: Integer;
    [JsonName('x')]
    FIsClosed: Boolean;
    [JsonName('q')]
    FQuoteVolume: String;
    [JsonName('V')]
    FTakerBuyBaseVolume: String;
    [JsonName('Q')]
    FTakerBuyQuoteVolume: String;
    FVolume: String;
  public
    property StartTime: Int64 read FStartTime write FStartTime;
    property CloseTime: Int64 read FCloseTime write FCloseTime;
    property Symbol: String read FSymbol write FSymbol;
    property Interval: String read FInterval write FInterval;
    property OPrice: String read FOPrice write FOPrice;
    property CPrice: String read FCPrice write FCPrice;
    property HPrice: String read FHPrice write FHPrice;
    property LPrice: String read FLPrice write FLPrice;
    property BaseAssetVolume: String read FBaseAssetVolume
      write FBaseAssetVolume;
    property NumberOfTrades: Integer read FNumberOfTrades write FNumberOfTrades;
    property IsClosed: Boolean read FIsClosed write FIsClosed;
    property QuoteVolume: String read FQuoteVolume write FQuoteVolume;
    property TakerBuyBaseVolume: String read FTakerBuyBaseVolume
      write FTakerBuyBaseVolume;
    property TakerBuyQuoteVolume: String read FTakerBuyQuoteVolume
      write FTakerBuyQuoteVolume;
    property Volume: String read FVolume write FVolume;
  end;

type

  [JsonSerialize(TJsonMemberSerialization.&Public)]
  TVela = class
  private
    [JsonName('e')]
    FEventType: String;
    [JsonName('E')]
    FEventTime: Int64;
    [JsonName('s')]
    FSymbol: String;
    [JsonName('k')]
    FDatosVela: TDatosVela;
    FEMA: Double;
  public
    property EventType: String read FEventType write FEventType;
    property EventTime: Int64 read FEventTime write FEventTime;
    property Symbol: String read FSymbol write FSymbol;
    property DatosVela: TDatosVela read FDatosVela write FDatosVela;

    property EMA: Double read FEMA write FEMA;

    constructor Create;overload;
    constructor Create(pOPrice, pCPrice, pHPrice, pLPrice, pVolume: String; pStartTime: Int64);overload;
    destructor Destroy; override;
  end;

type
  TListaVelas = class
  private
    FVelas: TObjectList<TVela>;
  public
    property Velas: TObjectList<TVela> read FVelas write FVelas;

    constructor Create; overload;
    constructor Create(pJson: String); overload;

    destructor Destroy; override;
  end;

implementation

{ TListaVelas }

constructor TListaVelas.Create(pJson: String);
var
  Serializer: TJsonSerializer;
begin
  inherited Create;
  Serializer := TJsonSerializer.Create;
  try
    Self := Serializer.Deserialize<TListaVelas>('');
  finally
    Serializer.Free;
  end;
end;

destructor TListaVelas.Destroy;
begin
  FVelas.Free;
  inherited;
end;

constructor TListaVelas.Create;
begin
  FVelas := TObjectList<TVela>.Create;
  inherited;
end;

{ TVela }

constructor TVela.Create(pOPrice, pCPrice, pHPrice, pLPrice, pVolume: String; pStartTime: Int64);
begin
  FDatosVela := TDatosVela.Create;
  FDatosVela.OPrice := pOPrice;
  FDatosVela.CPrice := pCPrice;
  FDatosVela.HPrice := pHPrice;
  FDatosVela.LPrice := pLPrice;
  FDatosVela.Volume  := pVolume;
  FDatosVela.StartTime := pStartTime;

end;

constructor TVela.Create;
begin
  inherited;
  FDatosVela := TDatosVela.Create;
end;

destructor TVela.Destroy;
begin
  FDatosVela.Free;
  inherited;
end;

end.
