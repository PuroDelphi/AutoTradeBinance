unit uProfundidad;

interface

uses System.JSON.Serializers, System.JSON.Converters, Generics.Collections;

type
  //Compradores, ¿Cuánto está dispuesto alguien a pagar por mis BTC?... Zona Roja de la gráfica
  TBids = class
  private
    FPrice: Double;
    FQty: Double;
  public
    property Price: Double read FPrice write FPrice;
    property Qty: Double read FQty write FQty;

    constructor Create(pPrice, pCantidad: Double);
  end;


  //Vendedores, ¿En cuánto está dispuesto alguien a venderme BTC? ... Zona Verde de la gráfica
  TAsks = class
  private
    FPrice: Double;
    FQty: Double;
  public
    property Price: Double read FPrice write FPrice;
    property Qty: Double read FQty write FQty;

    constructor Create(pPrice, pCantidad: Double);
  end;

  TDepthList = class
  private
    FBidsList: TObjectList<TBids>;
    FAsksList: TObjectList<TAsks>;
    FTotalQtyBids: Double;
    FTotalQtyAsks: Double;
  public
    property BidsList: TObjectList<TBids> read FBidsList write FBidsList;
    property AsksList: TObjectList<TAsks> read FAsksList write FAsksList;

    property TotalQtyBids: Double read FTotalQtyBids write FTotalQtyBids;
    property TotalQtyAsks: Double read FTotalQtyAsks write FTotalQtyAsks;


    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TDepthList }

constructor TDepthList.Create;
begin
  TotalQtyBids := 0;
  TotalQtyAsks := 0;
  FBidsList := TObjectList<TBids>.Create;
  FAsksList := TObjectList<TAsks>.Create;
end;

destructor TDepthList.Destroy;
begin
  FBidsList.Free;
  FAsksList.Free;
  inherited;
end;

{ TAsks }

constructor TAsks.Create(pPrice, pCantidad: Double);
begin
  FPrice := pPrice;
  FQty := pCantidad;
end;

{ TBids }

constructor TBids.Create(pPrice, pCantidad: Double);
begin
  FPrice := pPrice;
  FQty := pCantidad;
end;

end.
