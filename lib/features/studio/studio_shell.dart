import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/numerals.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive.dart';
import '../../core/state/app_state.dart';
import '../../core/auth/guest_locked_screen.dart';
import '../../models/class_model.dart';
import '../../data/repositories/class_repository.dart';
import '../../data/repositories/payment_repository.dart';
import 'create_class_sheet.dart';

/// IQRA Studio — the teacher workspace. Real class CRUD backed by
/// [ClassRepository]. Starts empty: "0 students, 0 classes" until the
/// teacher actually creates something.
class StudioShell extends StatefulWidget {
  const StudioShell({super.key});

  @override
  State<StudioShell> createState() => _StudioShellState();
}

class _StudioShellState extends State<StudioShell> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;

    if (user == null) {
      return const GuestLockedScreen(
        surfaceName: 'IQRA Studio',
        icon: Icons.workspace_premium_outlined,
        message: 'Teachers sign in to manage classes, students, and earnings.',
      );
    }

    final s = context.surface;
    final text = IqraText(s);
    final useArabic = appState.prayerSettings.useArabicNumerals;

    final classes = ClassRepository.instance.getByTeacher(user.id);
    final totalStudents = classes.fold<int>(0, (sum, c) => sum + c.studentIds.length);
    final payments = PaymentRepository.instance.getByUser(user.id);
    final totalEarningsMinor = payments.fold<int>(0, (sum, p) => sum + p.amountMinor);

    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(title: const Text('IQRA Studio')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateClass(context, user.id),
        icon: const Icon(Icons.add),
        label: const Text('New class'),
        backgroundColor: IqraTokens.gold,
        foregroundColor: IqraTokens.ink,
      ),
      body: ResponsiveCenter(
        maxWidth: 900,
        child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(child: _statCard('Classes', Numerals.format(classes.length, useArabic: useArabic), s, text)),
              const SizedBox(width: 10),
              Expanded(child: _statCard('Students', Numerals.format(totalStudents, useArabic: useArabic), s, text)),
              const SizedBox(width: 10),
              Expanded(child: _statCard('Earnings', '\$${(totalEarningsMinor / 100).toStringAsFixed(0)}', s, text)),
            ],
          ),
          const SizedBox(height: 24),
          Text('MY CLASSES', style: text.sectionHeader),
          const SizedBox(height: 12),
          if (classes.isEmpty)
            Container(
              decoration: BoxDecoration(color: s.appCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: s.appBorder)),
              child: IqraEmptyState(
                icon: Icons.class_outlined,
                title: 'No classes yet',
                subtitle: 'Create your first class to start teaching. Add a Zoom or Google Meet link so students can join live.',
                action: ElevatedButton.icon(
                  onPressed: () => _openCreateClass(context, user.id),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Create a class'),
                ),
              ),
            )
          else
            ...classes.map((c) => _classCard(context, c, s, text, useArabic)),
        ],
        ),
      ),
    );
  }

  void _openCreateClass(BuildContext context, String? teacherId) {
    if (teacherId == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surface.appCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => CreateClassSheet(teacherId: teacherId, onCreated: () => setState(() {})),
    );
  }

  Widget _statCard(String label, String value, IqraSurface s, IqraText text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: s.appCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: s.appBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontFamily: IqraFonts.numeric, fontSize: 20, fontWeight: FontWeight.w600, color: IqraTokens.gold)),
          const SizedBox(height: 4),
          Text(label, style: text.metaDim()),
        ],
      ),
    );
  }

  Widget _classCard(BuildContext context, ClassSession c, IqraSurface s, IqraText text, bool useArabic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: s.appCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: s.appBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(c.title, style: text.cardTitle(size: 15))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: IqraTokens.emeraldLt.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                child: Text(c.level, style: const TextStyle(fontSize: 10, color: IqraTokens.emeraldLt, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(c.scheduleSummary, style: text.metaDim()),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.people_outline, size: 15, color: s.appTextDim),
              const SizedBox(width: 4),
              Text('${Numerals.format(c.studentIds.length, useArabic: useArabic)} enrolled', style: text.metaDim()),
              const SizedBox(width: 16),
              Icon(_providerIcon(c.provider), size: 15, color: s.appTextDim),
              const SizedBox(width: 4),
              Text(_providerLabel(c.provider), style: text.metaDim()),
              const Spacer(),
              if (c.priceAmountMinor > 0)
                Text('\$${(c.priceAmountMinor / 100).toStringAsFixed(0)}/mo', style: text.body(size: 12.5, weight: FontWeight.w700))
              else
                Text('Free', style: text.body(size: 12.5, weight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  IconData _providerIcon(LiveClassProvider p) {
    switch (p) {
      case LiveClassProvider.zoom:
        return Icons.videocam_outlined;
      case LiveClassProvider.googleMeet:
        return Icons.duo_outlined;
      case LiveClassProvider.liveKit:
        return Icons.live_tv_outlined;
      case LiveClassProvider.none:
        return Icons.link_off;
    }
  }

  String _providerLabel(LiveClassProvider p) {
    switch (p) {
      case LiveClassProvider.zoom:
        return 'Zoom';
      case LiveClassProvider.googleMeet:
        return 'Meet';
      case LiveClassProvider.liveKit:
        return 'LiveKit';
      case LiveClassProvider.none:
        return 'No link';
    }
  }
}
