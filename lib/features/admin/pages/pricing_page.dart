import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/repositories/pricing_repository.dart';

/// Manage Pricing & Currencies. Real editable plans + FX rates — admin
/// can adjust prices per currency without a code deploy.
class PricingPage extends StatefulWidget {
  const PricingPage({super.key});

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  @override
  void initState() {
    super.initState();
    PricingRepository.instance.seedIfEmpty();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final text = IqraText(s);
    final plans = PricingRepository.instance.getAllPlans();
    final currencies = PricingRepository.instance.getAllCurrencies();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Pricing Plans', style: text.cardTitle(size: 20)),
        const SizedBox(height: 12),
        ...plans.map((p) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: s.appCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: s.appBorder)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(p.name, style: text.body(size: 14, weight: FontWeight.w700))),
                      Switch(
                        value: p.active,
                        onChanged: (v) async {
                          await PricingRepository.instance.upsertPlan(p.copyWith(active: v));
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 12,
                    children: p.pricesMinorByCurrency.entries
                        .map((e) => Text('${e.key} ${(e.value / 100).toStringAsFixed(0)}', style: text.metaDim()))
                        .toList(),
                  ),
                  const SizedBox(height: 6),
                  Text(p.features.join(' · '), style: text.metaDim(size: 10.5)),
                ],
              ),
            )),
        const SizedBox(height: 24),
        Text('Currencies', style: text.cardTitle(size: 18)),
        const SizedBox(height: 12),
        ...currencies.map((c) => ListTile(
              tileColor: s.appCard,
              title: Text('${c.code} (${c.symbol}) — ${c.name}', style: text.body(size: 13)),
              subtitle: Text('Rate to USD: ${c.rateToUsd}', style: text.metaDim()),
              trailing: Switch(
                value: c.active,
                onChanged: (v) async {
                  await PricingRepository.instance.upsertCurrency(c.copyWith(active: v));
                  setState(() {});
                },
              ),
            )),
      ],
    );
  }
}
