unit uOrden;

interface

uses
  Pkg.Json.DTO, System.Generics.Collections, REST.Json.Types;

{$M+}

type
  TFills = class
  private
    FCommission: string;
    FCommissionAsset: string;
    FPrice: string;
    FQty: string;
    FTradeId: Integer;
  published
    property Commission: string read FCommission write FCommission;
    property CommissionAsset: string read FCommissionAsset write FCommissionAsset;
    property Price: string read FPrice write FPrice;
    property Qty: string read FQty write FQty;
    property TradeId: Integer read FTradeId write FTradeId;
  end;
  
  TOrden = class(TJsonDTO)
  private
    FClientOrderId: string;
    FCummulativeQuoteQty: string;
    FExecutedQty: string;
    [JSONName('fills')]
    FFillsArray: TArray<TFills>;
    [GenericListReflect]
    FFills: TObjectList<TFills>;
    FOrderId: Integer;
    FOrderListId: Integer;
    FOrigQty: string;
    FPrice: string;
    FSide: string;
    FStatus: string;
    FSymbol: string;
    FTimeInForce: string;
    FTransactTime: Int64;
    FType: string;
    function GetFills: TObjectList<TFills>;
  published
    property ClientOrderId: string read FClientOrderId write FClientOrderId;
    property CummulativeQuoteQty: string read FCummulativeQuoteQty write FCummulativeQuoteQty;
    property ExecutedQty: string read FExecutedQty write FExecutedQty;
    property Fills: TObjectList<TFills> read GetFills;
    property OrderId: Integer read FOrderId write FOrderId;
    property OrderListId: Integer read FOrderListId write FOrderListId;
    property OrigQty: string read FOrigQty write FOrigQty;
    property Price: string read FPrice write FPrice;
    property Side: string read FSide write FSide;
    property Status: string read FStatus write FStatus;
    property Symbol: string read FSymbol write FSymbol;
    property TimeInForce: string read FTimeInForce write FTimeInForce;
    property TransactTime: Int64 read FTransactTime write FTransactTime;
    property &Type: string read FType write FType;
    destructor Destroy; override;
  end;
  
implementation

{ TOrden }

destructor TOrden.Destroy;
begin
  GetFills.Free;
  inherited;
end;

function TOrden.GetFills: TObjectList<TFills>;
begin
  if not Assigned(FFills) then
  begin
    FFills := TObjectList<TFills>.Create;
    FFills.AddRange(FFillsArray);
  end;
  Result := FFills;
end;

end.
