import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/numerals.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/state/app_state.dart';
import '../../data/repositories/student_repository.dart';
import '../../data/repositories/class_repository.dart';
import '../../data/repositories/payment_repository.dart';

/// Parent Dashboard: child progress, attendance, homework, invoices.
/// Reads real linked-student records — a parent with no linked children
/// sees a genuine empty state, not fake children.
class ParentShell extends StatelessWidget {
  const ParentShell({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;
    final s = context.surface;
    final text = IqraText(s);
    final useArabic = appState.prayerSettings.useArabicNumerals;

    final children = user != null ? StudentRepository.instance.getByParentId(user.id) : [];
    final payments = user != null ? PaymentRepository.instance.getByUser(user.id) : [];

    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(title: const Text('Parent Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('LINKED CHILDREN', style: text.sectionHeader),
          const SizedBox(height: 12),
          if (children.isEmpty)
            Container(
              decoration: BoxDecoration(color: s.appCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: s.appBorder)),
              child: const IqraEmptyState(
                icon: Icons.family_restroom_outlined,
                title: 'No children linked yet',
                subtitle: 'Ask your child to add your account as their parent, or contact their teacher to link accounts.',
              ),
            )
          else
            ...children.map((child) {
              final classes = ClassRepository.instance.getByStudent(child.id);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: s.appCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: s.appBorder)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: IqraTokens.rubyLt.withValues(alpha: 0.2),
                          child: Text(child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
                              style: const TextStyle(color: IqraTokens.rubyLt, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(child.name, style: text.cardTitle(size: 14)),
                              Text('${child.level} · ${Numerals.format(classes.length, useArabic: useArabic)} classes',
                                  style: text.metaDim()),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _miniStat('Streak', Numerals.format(child.streakDays, useArabic: useArabic), text)),
                        Expanded(child: _miniStat('Verses', Numerals.format(child.versesMemorized, useArabic: useArabic), text)),
                      ],
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 24),
          Text('INVOICES & PAYMENTS', style: text.sectionHeader),
          const SizedBox(height: 12),
          if (payments.isEmpty)
            Container(
              decoration: BoxDecoration(color: s.appCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: s.appBorder)),
              child: const IqraEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No invoices yet',
                subtitle: 'Payment history for class enrollments will appear here.',
              ),
            )
          else
            ...payments.map((p) => ListTile(
                  tileColor: s.appCard,
                  title: Text(p.description, style: text.body(size: 13)),
                  subtitle: Text(p.createdAt.toString().split('.').first, style: text.metaDim()),
                  trailing: Text('${(p.amountMinor / 100).toStringAsFixed(2)} ${p.currency}',
                      style: text.body(size: 13, weight: FontWeight.w700)),
                )),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, IqraText text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontFamily: IqraFonts.numeric, fontSize: 18, fontWeight: FontWeight.w600, color: IqraTokens.gold)),
        Text(label, style: text.metaDim()),
      ],
    );
  }
}
