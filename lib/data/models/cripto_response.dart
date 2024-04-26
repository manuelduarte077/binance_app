import 'dart:convert';

CriptoModel criptoModelFromJson(String str) =>
    CriptoModel.fromJson(json.decode(str));

String criptoModelToJson(CriptoModel data) => json.encode(data.toJson());

class CriptoModel {
  final String? timezone;
  final int? serverTime;
  final List<RateLimit>? rateLimits;
  final List<dynamic>? exchangeFilters;
  final List<Symbol>? symbols;

  CriptoModel({
    this.timezone,
    this.serverTime,
    this.rateLimits,
    this.exchangeFilters,
    this.symbols,
  });

  factory CriptoModel.fromJson(Map<String, dynamic> json) => CriptoModel(
        timezone: json["timezone"],
        serverTime: json["serverTime"],
        rateLimits: json["rateLimits"] == null
            ? []
            : List<RateLimit>.from(
                json["rateLimits"]!.map((x) => RateLimit.fromJson(x))),
        exchangeFilters: json["exchangeFilters"] == null
            ? []
            : List<dynamic>.from(json["exchangeFilters"]!.map((x) => x)),
        symbols: json["symbols"] == null
            ? []
            : List<Symbol>.from(
                json["symbols"]!.map((x) => Symbol.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "timezone": timezone,
        "serverTime": serverTime,
        "rateLimits": rateLimits == null
            ? []
            : List<dynamic>.from(rateLimits!.map((x) => x.toJson())),
        "exchangeFilters": exchangeFilters == null
            ? []
            : List<dynamic>.from(exchangeFilters!.map((x) => x)),
        "symbols": symbols == null
            ? []
            : List<dynamic>.from(symbols!.map((x) => x.toJson())),
      };
}

class RateLimit {
  final String? rateLimitType;
  final String? interval;
  final int? intervalNum;
  final int? limit;

  RateLimit({
    this.rateLimitType,
    this.interval,
    this.intervalNum,
    this.limit,
  });

  factory RateLimit.fromJson(Map<String, dynamic> json) => RateLimit(
        rateLimitType: json["rateLimitType"],
        interval: json["interval"],
        intervalNum: json["intervalNum"],
        limit: json["limit"],
      );

  Map<String, dynamic> toJson() => {
        "rateLimitType": rateLimitType,
        "interval": interval,
        "intervalNum": intervalNum,
        "limit": limit,
      };
}

class Symbol {
  final String? symbol;
  final String? status;
  final String? baseAsset;
  final int? baseAssetPrecision;
  final String? quoteAsset;
  final int? quotePrecision;
  final int? quoteAssetPrecision;
  final int? baseCommissionPrecision;
  final int? quoteCommissionPrecision;
  final List<String>? orderTypes;
  final bool? icebergAllowed;
  final bool? ocoAllowed;
  final bool? otoAllowed;
  final bool? quoteOrderQtyMarketAllowed;
  final bool? allowTrailingStop;
  final bool? cancelReplaceAllowed;
  final bool? isSpotTradingAllowed;
  final bool? isMarginTradingAllowed;
  final List<Filter>? filters;
  final List<dynamic>? permissions;
  final List<List<String>>? permissionSets;
  final String? defaultSelfTradePreventionMode;
  final List<String>? allowedSelfTradePreventionModes;

  Symbol({
    this.symbol,
    this.status,
    this.baseAsset,
    this.baseAssetPrecision,
    this.quoteAsset,
    this.quotePrecision,
    this.quoteAssetPrecision,
    this.baseCommissionPrecision,
    this.quoteCommissionPrecision,
    this.orderTypes,
    this.icebergAllowed,
    this.ocoAllowed,
    this.otoAllowed,
    this.quoteOrderQtyMarketAllowed,
    this.allowTrailingStop,
    this.cancelReplaceAllowed,
    this.isSpotTradingAllowed,
    this.isMarginTradingAllowed,
    this.filters,
    this.permissions,
    this.permissionSets,
    this.defaultSelfTradePreventionMode,
    this.allowedSelfTradePreventionModes,
  });

  factory Symbol.fromJson(Map<String, dynamic> json) => Symbol(
        symbol: json["symbol"],
        status: json["status"],
        baseAsset: json["baseAsset"],
        baseAssetPrecision: json["baseAssetPrecision"],
        quoteAsset: json["quoteAsset"],
        quotePrecision: json["quotePrecision"],
        quoteAssetPrecision: json["quoteAssetPrecision"],
        baseCommissionPrecision: json["baseCommissionPrecision"],
        quoteCommissionPrecision: json["quoteCommissionPrecision"],
        orderTypes: json["orderTypes"] == null
            ? []
            : List<String>.from(json["orderTypes"]!.map((x) => x)),
        icebergAllowed: json["icebergAllowed"],
        ocoAllowed: json["ocoAllowed"],
        otoAllowed: json["otoAllowed"],
        quoteOrderQtyMarketAllowed: json["quoteOrderQtyMarketAllowed"],
        allowTrailingStop: json["allowTrailingStop"],
        cancelReplaceAllowed: json["cancelReplaceAllowed"],
        isSpotTradingAllowed: json["isSpotTradingAllowed"],
        isMarginTradingAllowed: json["isMarginTradingAllowed"],
        filters: json["filters"] == null
            ? []
            : List<Filter>.from(
                json["filters"]!.map((x) => Filter.fromJson(x))),
        permissions: json["permissions"] == null
            ? []
            : List<dynamic>.from(json["permissions"]!.map((x) => x)),
        permissionSets: json["permissionSets"] == null
            ? []
            : List<List<String>>.from(json["permissionSets"]!
                .map((x) => List<String>.from(x.map((x) => x)))),
        defaultSelfTradePreventionMode: json["defaultSelfTradePreventionMode"],
        allowedSelfTradePreventionModes:
            json["allowedSelfTradePreventionModes"] == null
                ? []
                : List<String>.from(
                    json["allowedSelfTradePreventionModes"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "symbol": symbol,
        "status": status,
        "baseAsset": baseAsset,
        "baseAssetPrecision": baseAssetPrecision,
        "quoteAsset": quoteAsset,
        "quotePrecision": quotePrecision,
        "quoteAssetPrecision": quoteAssetPrecision,
        "baseCommissionPrecision": baseCommissionPrecision,
        "quoteCommissionPrecision": quoteCommissionPrecision,
        "orderTypes": orderTypes == null
            ? []
            : List<dynamic>.from(orderTypes!.map((x) => x)),
        "icebergAllowed": icebergAllowed,
        "ocoAllowed": ocoAllowed,
        "otoAllowed": otoAllowed,
        "quoteOrderQtyMarketAllowed": quoteOrderQtyMarketAllowed,
        "allowTrailingStop": allowTrailingStop,
        "cancelReplaceAllowed": cancelReplaceAllowed,
        "isSpotTradingAllowed": isSpotTradingAllowed,
        "isMarginTradingAllowed": isMarginTradingAllowed,
        "filters": filters == null
            ? []
            : List<dynamic>.from(filters!.map((x) => x.toJson())),
        "permissions": permissions == null
            ? []
            : List<dynamic>.from(permissions!.map((x) => x)),
        "permissionSets": permissionSets == null
            ? []
            : List<dynamic>.from(permissionSets!
                .map((x) => List<dynamic>.from(x.map((x) => x)))),
        "defaultSelfTradePreventionMode": defaultSelfTradePreventionMode,
        "allowedSelfTradePreventionModes":
            allowedSelfTradePreventionModes == null
                ? []
                : List<dynamic>.from(
                    allowedSelfTradePreventionModes!.map((x) => x)),
      };
}

class Filter {
  final String? filterType;
  final String? minPrice;
  final String? maxPrice;
  final String? tickSize;
  final String? minQty;
  final String? maxQty;
  final String? stepSize;
  final int? limit;
  final int? minTrailingAboveDelta;
  final int? maxTrailingAboveDelta;
  final int? minTrailingBelowDelta;
  final int? maxTrailingBelowDelta;
  final String? bidMultiplierUp;
  final String? bidMultiplierDown;
  final String? askMultiplierUp;
  final String? askMultiplierDown;
  final int? avgPriceMins;
  final String? minNotional;
  final bool? applyMinToMarket;
  final String? maxNotional;
  final bool? applyMaxToMarket;
  final int? maxNumOrders;
  final int? maxNumAlgoOrders;
  final String? maxPosition;

  Filter({
    this.filterType,
    this.minPrice,
    this.maxPrice,
    this.tickSize,
    this.minQty,
    this.maxQty,
    this.stepSize,
    this.limit,
    this.minTrailingAboveDelta,
    this.maxTrailingAboveDelta,
    this.minTrailingBelowDelta,
    this.maxTrailingBelowDelta,
    this.bidMultiplierUp,
    this.bidMultiplierDown,
    this.askMultiplierUp,
    this.askMultiplierDown,
    this.avgPriceMins,
    this.minNotional,
    this.applyMinToMarket,
    this.maxNotional,
    this.applyMaxToMarket,
    this.maxNumOrders,
    this.maxNumAlgoOrders,
    this.maxPosition,
  });

  factory Filter.fromJson(Map<String, dynamic> json) => Filter(
        filterType: json["filterType"],
        minPrice: json["minPrice"],
        maxPrice: json["maxPrice"],
        tickSize: json["tickSize"],
        minQty: json["minQty"],
        maxQty: json["maxQty"],
        stepSize: json["stepSize"],
        limit: json["limit"],
        minTrailingAboveDelta: json["minTrailingAboveDelta"],
        maxTrailingAboveDelta: json["maxTrailingAboveDelta"],
        minTrailingBelowDelta: json["minTrailingBelowDelta"],
        maxTrailingBelowDelta: json["maxTrailingBelowDelta"],
        bidMultiplierUp: json["bidMultiplierUp"],
        bidMultiplierDown: json["bidMultiplierDown"],
        askMultiplierUp: json["askMultiplierUp"],
        askMultiplierDown: json["askMultiplierDown"],
        avgPriceMins: json["avgPriceMins"],
        minNotional: json["minNotional"],
        applyMinToMarket: json["applyMinToMarket"],
        maxNotional: json["maxNotional"],
        applyMaxToMarket: json["applyMaxToMarket"],
        maxNumOrders: json["maxNumOrders"],
        maxNumAlgoOrders: json["maxNumAlgoOrders"],
        maxPosition: json["maxPosition"],
      );

  Map<String, dynamic> toJson() => {
        "filterType": filterType,
        "minPrice": minPrice,
        "maxPrice": maxPrice,
        "tickSize": tickSize,
        "minQty": minQty,
        "maxQty": maxQty,
        "stepSize": stepSize,
        "limit": limit,
        "minTrailingAboveDelta": minTrailingAboveDelta,
        "maxTrailingAboveDelta": maxTrailingAboveDelta,
        "minTrailingBelowDelta": minTrailingBelowDelta,
        "maxTrailingBelowDelta": maxTrailingBelowDelta,
        "bidMultiplierUp": bidMultiplierUp,
        "bidMultiplierDown": bidMultiplierDown,
        "askMultiplierUp": askMultiplierUp,
        "askMultiplierDown": askMultiplierDown,
        "avgPriceMins": avgPriceMins,
        "minNotional": minNotional,
        "applyMinToMarket": applyMinToMarket,
        "maxNotional": maxNotional,
        "applyMaxToMarket": applyMaxToMarket,
        "maxNumOrders": maxNumOrders,
        "maxNumAlgoOrders": maxNumAlgoOrders,
        "maxPosition": maxPosition,
      };
}
