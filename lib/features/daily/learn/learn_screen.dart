import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state.dart';
import '../scholar/scholar_screen.dart';

/// Learn modules screen. Categories are real navigational targets; actual
/// lesson content is authored by teachers/admin through IQRA Studio & the
/// CMS — starts with an honest "no modules yet" state rather than fake
/// courses.
class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  static const _categories = [
    ('Fiqh', Icons.balance_outlined, IqraTokens.emeraldLt),
    ('ʿAqīdah', Icons.auto_awesome_outlined, IqraTokens.lapisLt),
    ('Sīrah', Icons.timeline_outlined, IqraTokens.rubyLt),
    ('Tafsīr', Icons.menu_book_outlined, IqraTokens.saffron),
    ('Arabic', Icons.translate_outlined, IqraTokens.goldLt),
  ];

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final text = IqraText(s);

    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(title: const Text('Learn')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text('CATEGORIES', style: text.sectionHeader),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: _categories.map((c) {
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: s.appCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: s.appBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: (c.$3 as Color).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(c.$2 as IconData, color: c.$3 as Color, size: 18),
                    ),
                    const Spacer(),
                    Text(c.$1 as String, style: text.body(size: 13.5, weight: FontWeight.w700)),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('FEATURED MODULES', style: text.sectionHeader),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: s.appCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: s.appBorder),
            ),
            child: IqraEmptyState(
              icon: Icons.auto_stories_outlined,
              title: 'No learning modules yet',
              subtitle: 'Teachers publish structured lessons through IQRA Studio. Once published, they will appear here.',
              action: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ScholarScreen()),
                ),
                icon: const Icon(Icons.search, size: 16),
                label: const Text('Find a scholar'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
