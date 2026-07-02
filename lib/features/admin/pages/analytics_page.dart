import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/class_repository.dart';
import '../../../data/repositories/academy_repository.dart';
import '../../../data/repositories/payment_repository.dart';

/// Real analytics computed from the live local database — genuinely 0
/// until real activity happens. No fake user counts, no fake revenue.
class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final text = IqraText(s);
    final users = UserRepository.instance.getAll();
    final classes = ClassRepository.instance.getAll();
    final academies = AcademyRepository.instance.getAll();
    final payments = PaymentRepository.instance.getAll();
    final totalRevenueMinor = payments.fold<int>(0, (sum, p) => sum + p.amountMinor);

    final stats = [
      ('Total users', users.length.toString(), Icons.people_outline),
      ('Total classes', classes.length.toString(), Icons.class_outlined),
      ('Total academies', academies.length.toString(), Icons.apartment_outlined),
      ('Simulated revenue', '\$${(totalRevenueMinor / 100).toStringAsFixed(2)}', Icons.attach_money),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Analytics', style: text.cardTitle(size: 20)),
        const SizedBox(height: 4),
        Text('Live figures from the platform database — zero until real activity happens.', style: text.metaDim()),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: stats.map((s2) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: s.appCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: s.appBorder)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(s2.$3, color: IqraTokens.gold, size: 20),
                  const Spacer(),
                  Text(s2.$2, style: const TextStyle(fontFamily: IqraFonts.numeric, fontSize: 22, fontWeight: FontWeight.w600, color: IqraTokens.gold)),
                  Text(s2.$1, style: text.metaDim()),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
