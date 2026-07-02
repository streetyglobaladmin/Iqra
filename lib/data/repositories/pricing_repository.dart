import 'package:hive/hive.dart';
import '../../models/pricing_plan.dart';
import '../local/db.dart';
import '../local/hive_boxes.dart';

/// Pricing plans and currencies are seeded with real, sensible defaults
/// (not fake revenue numbers — these are prices the admin can edit, not
/// stats about actual sales). Admin can add/edit/deactivate at will.
class PricingRepository {
  static final PricingRepository instance = PricingRepository._();
  PricingRepository._();

  Box get _planBox => Db.box(HiveBoxes.pricingPlans);
  Box get _currencyBox => Db.box(HiveBoxes.currencies);

  Future<void> seedIfEmpty() async {
    if (_planBox.isEmpty) {
      final plans = [
        PricingPlan(
          id: 'free',
          code: 'free',
          name: 'Free',
          tier: 'free',
          pricesMinorByCurrency: const {'USD': 0, 'INR': 0, 'PKR': 0},
          features: const [
            'IQRA Daily companion',
            'Prayer times & Qibla',
            'Quran reader with 1 translation',
          ],
        ),
        PricingPlan(
          id: 'teacher_pro',
          code: 'teacher_pro',
          name: 'Teacher Pro',
          tier: 'pro',
          pricesMinorByCurrency: const {
            'USD': 900,
            'INR': 74900,
            'PKR': 250000
          },
          features: const [
            'Unlimited classes & students',
            'Studio workspace',
            'Earnings & payouts',
            'Live class links (Zoom/Meet)',
          ],
        ),
        PricingPlan(
          id: 'academy',
          code: 'academy',
          name: 'Academy',
          tier: 'academy',
          pricesMinorByCurrency: const {
            'USD': 4900,
            'INR': 399900,
            'PKR': 1350000
          },
          features: const [
            'Multi-teacher workspace',
            'Branded academy page',
            'Advanced analytics',
          ],
        ),
        PricingPlan(
          id: 'enterprise',
          code: 'enterprise',
          name: 'Enterprise',
          tier: 'enterprise',
          pricesMinorByCurrency: const {'USD': 0, 'INR': 0, 'PKR': 0},
          features: const [
            'Custom contract',
            'White-label',
            'SSO',
            'Dedicated support',
          ],
        ),
      ];
      for (final p in plans) {
        await _planBox.put(p.id, p.toMap());
      }
    }
    if (_currencyBox.isEmpty) {
      final currencies = [
        CurrencyDef(code: 'USD', symbol: '\$', name: 'US Dollar', rateToUsd: 1.0),
        CurrencyDef(code: 'INR', symbol: '₹', name: 'Indian Rupee', rateToUsd: 83.2),
        CurrencyDef(code: 'PKR', symbol: '₨', name: 'Pakistani Rupee', rateToUsd: 278.5),
        CurrencyDef(code: 'BDT', symbol: '৳', name: 'Bangladeshi Taka', rateToUsd: 117.0),
        CurrencyDef(code: 'GBP', symbol: '£', name: 'British Pound', rateToUsd: 0.79, active: false),
      ];
      for (final c in currencies) {
        await _currencyBox.put(c.code, c.toMap());
      }
    }
  }

  List<PricingPlan> getAllPlans() => _planBox.values
      .map((e) => PricingPlan.fromMap(Map<String, dynamic>.from(e as Map)))
      .toList();

  List<CurrencyDef> getAllCurrencies() => _currencyBox.values
      .map((e) => CurrencyDef.fromMap(Map<String, dynamic>.from(e as Map)))
      .toList();

  Future<void> upsertPlan(PricingPlan plan) async {
    await _planBox.put(plan.id, plan.toMap());
  }

  Future<void> upsertCurrency(CurrencyDef currency) async {
    await _currencyBox.put(currency.code, currency.toMap());
  }
}
