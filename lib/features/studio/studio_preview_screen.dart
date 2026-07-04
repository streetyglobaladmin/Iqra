import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/iqra_logo.dart';
import '../../core/state/app_state.dart';
import '../../models/app_role.dart';
import '../auth/login_screen.dart';
import 'studio_apply_screen.dart';
import 'studio_shell.dart';

/// IQRA Studio — teacher/scholar workspace entry point reached from the
/// mobile app's Profile tab ("Teach on IQRA" → IQRA Studio). This is a
/// PREVIEW/marketing screen shown before any credentials are requested:
/// it explains what Studio does, then offers exactly three ways in —
/// Scholar Login, Apply as Scholar, and Existing teacher access.
///
/// There is intentionally NO Admin / Super Admin login option here. The
/// Nuerizo Control Center is a separate web-only surface reached from a
/// browser (control.nuerizo.com), never from inside the mobile app.
class StudioPreviewScreen extends StatelessWidget {
  const StudioPreviewScreen({super.key});

  static const _features = [
    (
      Icons.videocam_outlined,
      'Teach students online',
      'Run live classes with Zoom or Google Meet links.',
    ),
    (
      Icons.event_available_outlined,
      'Schedule classes',
      'Set up recurring class times students can join.',
    ),
    (
      Icons.group_add_outlined,
      'Add students',
      'Invite and enroll students into your classes.',
    ),
    (
      Icons.how_to_reg_outlined,
      'Accept student requests',
      'Review and approve incoming enrollment requests.',
    ),
    (
      Icons.assignment_outlined,
      'Assign homework',
      'Give tasks and track completion per student.',
    ),
    (
      Icons.trending_up_outlined,
      'Track progress',
      'Follow memorization, attendance, and performance.',
    ),
    (
      Icons.menu_book_outlined,
      'Use Digital Qur\u02beān',
      'Teach directly from the built-in digital muṣḥaf.',
    ),
    (
      Icons.abc_outlined,
      'Use Noorani Qaida',
      'Guide beginners through foundational Qur\u02beān reading.',
    ),
    (
      Icons.workspace_premium_outlined,
      'Issue certificates',
      'Award completion certificates to your students.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final text = IqraText(s);

    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(title: const Text('IQRA Studio')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(
            child: Column(
              children: [
                const IqraLogoMark(size: 56),
                const SizedBox(height: 14),
                Text(
                  'The teacher workspace for IQRA',
                  style: text.cardTitle(size: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Everything a scholar needs to teach online, in one place.',
                  style: text.metaDim(),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          ..._features.map((f) => _featureRow(s, text, f.$1, f.$2, f.$3)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _handleScholarLogin(context),
              icon: const Icon(Icons.login),
              label: const Text('Scholar Login'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StudioApplyScreen()),
              ),
              icon: const Icon(Icons.edit_document),
              label: const Text('Apply as Scholar'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _handleExistingTeacherAccess(context),
              icon: Icon(Icons.workspace_premium_outlined, color: s.appTextDim),
              label: Text(
                'Existing teacher access',
                style: TextStyle(color: s.appTextDim),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureRow(
    IqraSurface s,
    IqraText text,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: IqraTokens.saffron.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: IqraTokens.saffron, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: text.body(size: 14, weight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: text.metaDim()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleScholarLogin(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
    if (!context.mounted) return;
    final appState = context.read<AppState>();
    final user = appState.currentUser;
    if (user != null && user.hasRole(AppRole.teacher)) {
      if (!context.mounted) return;
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const StudioShell()));
    } else if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "This account isn't registered as a Scholar. Use \"Apply as Scholar\" to register.",
          ),
        ),
      );
    }
  }

  void _handleExistingTeacherAccess(BuildContext context) {
    // Teachers who already have a signed-in Scholar session jump straight
    // into Studio. If nobody is signed in yet, StudioShell's own guard
    // (GuestLockedScreen) will ask them to log in first.
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const StudioShell()));
  }
}
