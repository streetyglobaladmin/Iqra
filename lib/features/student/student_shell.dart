import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/numerals.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/state/app_state.dart';
import '../../core/auth/guest_locked_screen.dart';
import '../../models/class_model.dart';
import '../../data/repositories/student_repository.dart';
import '../../data/repositories/class_repository.dart';
import 'live_class_view.dart';

/// Student experience: enrolled classes, memorization tracker, homework,
/// and one-tap live class join. Reads real data from repositories — a
/// brand-new student sees genuine empty states, not fake progress.
class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;

    // Guest-first: Student dashboard is login-required. If someone reaches
    // this route without a session (deep link, back-stack edge case),
    // show the gate instead of a broken/empty personal dashboard.
    if (user == null) {
      return const GuestLockedScreen(
        surfaceName: 'Student',
        icon: Icons.school_outlined,
        message: 'Your classes, memorization tracker, and homework are tied to your account.',
      );
    }

    final s = context.surface;
    final text = IqraText(s);
    final useArabic = appState.prayerSettings.useArabicNumerals;

    final profile = StudentRepository.instance.getByUserId(user.id);
    final classes = profile != null ? ClassRepository.instance.getByStudent(profile.id) : <ClassSession>[];

    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(title: const Text('Student')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [IqraTokens.emerald, IqraTokens.emeraldDeep]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome, ${user.name}',
                          style: const TextStyle(fontFamily: IqraFonts.display, fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(
                        profile != null
                            ? 'Level: ${profile.level} · ${Numerals.format(profile.streakDays, useArabic: useArabic)} day streak'
                            : 'Complete your profile to get started',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.75)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.school, color: Colors.white.withValues(alpha: 0.85), size: 32),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _statsRow(profile, s, text, useArabic),
          const SizedBox(height: 24),
          Text('MY CLASSES', style: text.sectionHeader),
          const SizedBox(height: 12),
          if (classes.isEmpty)
            Container(
              decoration: BoxDecoration(color: s.appCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: s.appBorder)),
              child: const IqraEmptyState(
                icon: Icons.video_call_outlined,
                title: 'No classes yet',
                subtitle: 'Once a teacher enrolls you in a class, it will appear here with the live session link.',
              ),
            )
          else
            ...classes.map((c) => _classCard(context, c, s, text)),
          const SizedBox(height: 24),
          Text('HOMEWORK', style: text.sectionHeader),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: s.appCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: s.appBorder)),
            child: const IqraEmptyState(
              icon: Icons.assignment_outlined,
              title: 'No homework assigned',
              subtitle: 'Waiting for first activity from your teacher.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow(dynamic profile, IqraSurface s, IqraText text, bool useArabic) {
    final versesMemorized = profile?.versesMemorized ?? 0;
    final enrolled = (profile?.enrolledClassIds as List?)?.length ?? 0;
    return Row(
      children: [
        Expanded(child: _statCard('Verses memorized', Numerals.format(versesMemorized, useArabic: useArabic), s, text)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('Enrolled classes', Numerals.format(enrolled, useArabic: useArabic), s, text)),
      ],
    );
  }

  Widget _statCard(String label, String value, IqraSurface s, IqraText text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: s.appCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: s.appBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontFamily: IqraFonts.numeric, fontSize: 24, fontWeight: FontWeight.w600, color: IqraTokens.gold)),
          const SizedBox(height: 4),
          Text(label, style: text.metaDim()),
        ],
      ),
    );
  }

  Widget _classCard(BuildContext context, ClassSession c, IqraSurface s, IqraText text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: s.appCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: s.appBorder)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: IqraTokens.lapisLt.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.menu_book_outlined, color: IqraTokens.lapisLt),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title, style: text.body(size: 13.5, weight: FontWeight.w700)),
                Text(c.scheduleSummary, style: text.metaDim()),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => LiveClassView(session: c)),
            ),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}
