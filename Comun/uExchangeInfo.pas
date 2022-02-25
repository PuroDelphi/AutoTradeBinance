unit uExchangeInfo;

interface

uses
  Pkg.Json.DTO, System.Generics.Collections, REST.Json.Types;

{$M+}

type
  TFiltersDTO = class
  private
    FFilterType: string;
    FMaxPrice: string;
    FMinPrice: string;
    FTickSize: string;
    FStepSize: string;
  published
    property FilterType: string read FFilterType write FFilterType;
    property MaxPrice: string read FMaxPrice write FMaxPrice;
    property MinPrice: string read FMinPrice write FMinPrice;
    property TickSize: string read FTickSize write FTickSize;
    property StepSize: string read FStepSize write FStepSize;
  end;
  
  TSymbolsDTO = class
  private
    FBaseAsset: string;
    FBaseAssetPrecision: Integer;
    FBaseCommissionPrecision: Integer;
    [JSONName('filters')]
    FFiltersArray: TArray<TFiltersDTO>;
    [GenericListReflect]
    FFilters: TObjectList<TFiltersDTO>;
    FIcebergAllowed: Boolean;
    FIsMarginTradingAllowed: Boolean;
    FIsSpotTradingAllowed: Boolean;
    FOcoAllowed: Boolean;
    FOrderTypes: TArray<string>;
    FPermissions: TArray<string>;
    FQuoteAsset: string;
    FQuoteAssetPrecision: Integer;
    FQuoteCommissionPrecision: Integer;
    FQuoteOrderQtyMarketAllowed: Boolean;
    FQuotePrecision: Integer;
    FStatus: string;
    FSymbol: string;
    function GetFilters: TObjectList<TFiltersDTO>;
  published
    property BaseAsset: string read FBaseAsset write FBaseAsset;
    property BaseAssetPrecision: Integer read FBaseAssetPrecision write FBaseAssetPrecision;
    property BaseCommissionPrecision: Integer read FBaseCommissionPrecision write FBaseCommissionPrecision;
    property Filters: TObjectList<TFiltersDTO> read GetFilters;
    property IcebergAllowed: Boolean read FIcebergAllowed write FIcebergAllowed;
    property IsMarginTradingAllowed: Boolean read FIsMarginTradingAllowed write FIsMarginTradingAllowed;
    property IsSpotTradingAllowed: Boolean read FIsSpotTradingAllowed write FIsSpotTradingAllowed;
    property OcoAllowed: Boolean read FOcoAllowed write FOcoAllowed;
    property OrderTypes: TArray<string> read FOrderTypes write FOrderTypes;
    property Permissions: TArray<string> read FPermissions write FPermissions;
    property QuoteAsset: string read FQuoteAsset write FQuoteAsset;
    property QuoteAssetPrecision: Integer read FQuoteAssetPrecision write FQuoteAssetPrecision;
    property QuoteCommissionPrecision: Integer read FQuoteCommissionPrecision write FQuoteCommissionPrecision;
    property QuoteOrderQtyMarketAllowed: Boolean read FQuoteOrderQtyMarketAllowed write FQuoteOrderQtyMarketAllowed;
    property QuotePrecision: Integer read FQuotePrecision write FQuotePrecision;
    property Status: string read FStatus write FStatus;
    property Symbol: string read FSymbol write FSymbol;

    function getFilter(pFilter: string):TFiltersDTO;
    destructor Destroy; override;
  end;
  
  TExchangeFiltersDTO = class
  end;
  
  TRateLimitsDTO = class
  private
    FInterval: string;
    FIntervalNum: Integer;
    FLimit: Integer;
    FRateLimitType: string;
  published
    property Interval: string read FInterval write FInterval;
    property IntervalNum: Integer read FIntervalNum write FIntervalNum;
    property Limit: Integer read FLimit write FLimit;
    property RateLimitType: string read FRateLimitType write FRateLimitType;
  end;
  
  TExchangeInfo = class(TJsonDTO)
  private
    [JSONName('exchangeFilters')]
    FExchangeFiltersArray: TArray<TExchangeFiltersDTO>;
    [GenericListReflect]
    FExchangeFilters: TObjectList<TExchangeFiltersDTO>;
    [JSONName('rateLimits')]
    FRateLimitsArray: TArray<TRateLimitsDTO>;
    [GenericListReflect]
    FRateLimits: TObjectList<TRateLimitsDTO>;
    FServerTime: Int64;
    [JSONName('symbols')]
    FSymbolsArray: TArray<TSymbolsDTO>;
    [GenericListReflect]
    FSymbols: TObjectList<TSymbolsDTO>;
    FTimezone: string;
    function GetRateLimits: TObjectList<TRateLimitsDTO>;
    function GetExchangeFilters: TObjectList<TExchangeFiltersDTO>;
    function GetSymbols: TObjectList<TSymbolsDTO>;
  published
    property ExchangeFilters: TObjectList<TExchangeFiltersDTO> read GetExchangeFilters;
    property RateLimits: TObjectList<TRateLimitsDTO> read GetRateLimits;
    property ServerTime: Int64 read FServerTime write FServerTime;
    property Symbols: TObjectList<TSymbolsDTO> read GetSymbols;
    property Timezone: string read FTimezone write FTimezone;

    function getSymbol(pSymbol: String): TSymbolsDTO;

    destructor Destroy; override;
  end;
  
implementation

{ TSymbolsDTO }

destructor TSymbolsDTO.Destroy;
begin
  GetFilters.Free;
  inherited;
end;

function TSymbolsDTO.getFilter(pFilter: string): TFiltersDTO;
begin
  for Result in GetFilters do
    if Result.FilterType = pFilter then
      break;
end;

function TSymbolsDTO.GetFilters: TObjectList<TFiltersDTO>;
begin
  if not Assigned(FFilters) then
  begin
    FFilters := TObjectList<TFiltersDTO>.Create;
    FFilters.AddRange(FFiltersArray);
  end;
  Result := FFilters;
end;

{ TRootDTO }

destructor TExchangeInfo.Destroy;
begin
  GetRateLimits.Free;
  GetExchangeFilters.Free;
  GetSymbols.Free;
  inherited;
end;

function TExchangeInfo.GetRateLimits: TObjectList<TRateLimitsDTO>;
begin
  if not Assigned(FRateLimits) then
  begin
    FRateLimits := TObjectList<TRateLimitsDTO>.Create;
    FRateLimits.AddRange(FRateLimitsArray);
  end;
  Result := FRateLimits;
end;

function TExchangeInfo.getSymbol(pSymbol: String): TSymbolsDTO;
begin
  for Result in GetSymbols do
    if Result.Symbol = pSymbol then
      break;
end;

function TExchangeInfo.GetExchangeFilters: TObjectList<TExchangeFiltersDTO>;
begin
  if not Assigned(FExchangeFilters) then
  begin
    FExchangeFilters := TObjectList<TExchangeFiltersDTO>.Create;
    FExchangeFilters.AddRange(FExchangeFiltersArray);
  end;
  Result := FExchangeFilters;
end;

function TExchangeInfo.GetSymbols: TObjectList<TSymbolsDTO>;
begin
  if not Assigned(FSymbols) then
  begin
    FSymbols := TObjectList<TSymbolsDTO>.Create;
    FSymbols.AddRange(FSymbolsArray);
  end;
  Result := FSymbols;
end;

end.
