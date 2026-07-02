/// A subscription plan definition, editable from the admin panel.
/// Prices are stored in "minor units" (cents/paise) per currency code so
/// multiple currencies can be attached without float rounding issues.
class PricingPlan {
  final String id;
  final String code; // free, teacher_pro, academy, enterprise
  final String name;
  final String tier;
  final Map<String, int> pricesMinorByCurrency; // {"USD": 900, "INR": 74900}
  final List<String> features;
  final bool active;

  PricingPlan({
    required this.id,
    required this.code,
    required this.name,
    required this.tier,
    required this.pricesMinorByCurrency,
    required this.features,
    this.active = true,
  });

  PricingPlan copyWith({
    String? name,
    Map<String, int>? pricesMinorByCurrency,
    List<String>? features,
    bool? active,
  }) {
    return PricingPlan(
      id: id,
      code: code,
      name: name ?? this.name,
      tier: tier,
      pricesMinorByCurrency:
          pricesMinorByCurrency ?? this.pricesMinorByCurrency,
      features: features ?? this.features,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'code': code,
        'name': name,
        'tier': tier,
        'prices': pricesMinorByCurrency,
        'features': features,
        'active': active,
      };

  factory PricingPlan.fromMap(Map map) => PricingPlan(
        id: map['id'] as String,
        code: map['code'] as String,
        name: map['name'] as String,
        tier: map['tier'] as String? ?? 'free',
        pricesMinorByCurrency:
            Map<String, int>.from(map['prices'] as Map? ?? {}),
        features: List<String>.from(map['features'] as List? ?? []),
        active: map['active'] as bool? ?? true,
      );
}

class CurrencyDef {
  final String code; // ISO 4217
  final String symbol;
  final String name;
  final double rateToUsd; // manual FX rate, admin-editable
  final bool active;

  CurrencyDef({
    required this.code,
    required this.symbol,
    required this.name,
    required this.rateToUsd,
    this.active = true,
  });

  CurrencyDef copyWith({double? rateToUsd, bool? active}) => CurrencyDef(
        code: code,
        symbol: symbol,
        name: name,
        rateToUsd: rateToUsd ?? this.rateToUsd,
        active: active ?? this.active,
      );

  Map<String, dynamic> toMap() => {
        'code': code,
        'symbol': symbol,
        'name': name,
        'rateToUsd': rateToUsd,
        'active': active,
      };

  factory CurrencyDef.fromMap(Map map) => CurrencyDef(
        code: map['code'] as String,
        symbol: map['symbol'] as String,
        name: map['name'] as String,
        rateToUsd: (map['rateToUsd'] as num?)?.toDouble() ?? 1.0,
        active: map['active'] as bool? ?? true,
      );
}
