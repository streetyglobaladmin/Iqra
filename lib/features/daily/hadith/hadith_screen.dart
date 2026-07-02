import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ornaments.dart';
import '../../../data/static/hadith_content.dart';

/// Daily Hadith — guest-accessible per the guest-first requirement.
/// No account needed to read; authentic text with source attribution.
class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final text = IqraText(s);
    final today = hadithForToday();

    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(title: const Text('Daily Hadith')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: IqraTokens.ink,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              children: [
                const Positioned(top: -8, right: -8, child: StarMotif(size: 56)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('HADITH OF THE DAY', style: text.sectionHeader),
                    const SizedBox(height: 12),
                    Text(
                      today.arabic,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontFamily: IqraFonts.arabic,
                        fontSize: 20,
                        color: IqraTokens.appTextDark,
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      today.translation,
                      style: const TextStyle(
                        fontFamily: IqraFonts.display,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: IqraTokens.appTextDimDark,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Narrated by ${today.narrator} · ${today.source}',
                        style: const TextStyle(fontSize: 11, color: IqraTokens.gold, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('MORE HADITH', style: text.sectionHeader),
          const SizedBox(height: 12),
          ...hadithContent.where((h) => h.id != today.id).map((h) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: s.appCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: s.appBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.arabic, textDirection: TextDirection.rtl, textAlign: TextAlign.right,
                        style: const TextStyle(fontFamily: IqraFonts.arabic, fontSize: 18, height: 1.8, color: IqraTokens.appTextDark)),
                    const SizedBox(height: 8),
                    Text(h.translation, style: text.body(size: 12.5)),
                    const SizedBox(height: 8),
                    Text('Narrated by ${h.narrator} · ${h.source}', style: text.metaDim()),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
