import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/repositories/ad_repository.dart';
import '../../../data/repositories/referral_repository.dart';

/// Manage Advertisements + Referrals. Real records, real impression/click
/// counters (start at 0, no fake stats).
class AdsPage extends StatefulWidget {
  const AdsPage({super.key});

  @override
  State<AdsPage> createState() => _AdsPageState();
}

class _AdsPageState extends State<AdsPage> {
  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final text = IqraText(s);
    final ads = AdRepository.instance.getAll();
    final referrals = ReferralRepository.instance.getAll();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Advertisements', style: text.cardTitle(size: 20)),
        const SizedBox(height: 12),
        if (ads.isEmpty)
          const IqraEmptyState(
            icon: Icons.campaign_outlined,
            title: 'No advertisements yet',
            subtitle: 'This module is currently Hidden by feature flag. Create a campaign to test it internally.',
          )
        else
          ...ads.map((a) => ListTile(
                tileColor: s.appCard,
                title: Text(a.title, style: text.body(size: 13.5, weight: FontWeight.w700)),
                subtitle: Text('${a.impressions} impressions · ${a.clicks} clicks', style: text.metaDim()),
                trailing: Switch(value: a.active, onChanged: (v) async {
                  await AdRepository.instance.upsert(a.copyWith(active: v));
                  setState(() {});
                }),
              )),
        const SizedBox(height: 24),
        Text('Referrals', style: text.cardTitle(size: 18)),
        const SizedBox(height: 12),
        if (referrals.isEmpty)
          const IqraEmptyState(
            icon: Icons.card_giftcard_outlined,
            title: 'No referrals yet',
            subtitle: 'Waiting for first activity — referrals appear here once a user signs up with a code.',
          )
        else
          ...referrals.map((r) => ListTile(
                tileColor: s.appCard,
                title: Text(r.code, style: text.body(size: 13)),
                subtitle: Text(r.status.name, style: text.metaDim()),
              )),
      ],
    );
  }
}
