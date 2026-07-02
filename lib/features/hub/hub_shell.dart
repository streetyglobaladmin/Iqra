import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/iqra_logo.dart';
import '../../core/widgets/release_badge.dart';
import '../../core/state/app_state.dart';
import '../../models/app_role.dart';
import '../../models/release_state.dart';
import '../../data/repositories/feature_flag_repository.dart';
import '../daily/daily_shell.dart';
import '../student/student_shell.dart';
import '../parent/parent_shell.dart';
import '../studio/studio_shell.dart';
import '../admin/admin_shell.dart';
import '../auth/login_screen.dart';

/// IQRA Hub: the ecosystem launcher. Shows every module the signed-in
/// user's roles unlock, gated by real feature flags — not a static list.
class HubShell extends StatelessWidget {
  const HubShell({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;
    final s = IqraSurface.dark;
    final text = IqraText(s);
    final flags = FeatureFlagRepository.instance;

    final modules = <_ModuleCard>[
      _ModuleCard(
        title: 'IQRA Daily',
        subtitle: 'Prayer times, Qibla, Qur\'ān, dhikr & duas',
        icon: Icons.wb_twilight_outlined,
        color: IqraTokens.emeraldLt,
        flagKey: 'daily.app',
        visible: true,
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DailyShell())),
      ),
      if (user?.hasRole(AppRole.student) == true)
        _ModuleCard(
          title: 'Student',
          subtitle: 'Your classes, memorization & homework',
          icon: Icons.school_outlined,
          color: IqraTokens.lapisLt,
          flagKey: 'student.portal',
          visible: true,
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StudentShell())),
        ),
      if (user?.hasRole(AppRole.parent) == true)
        _ModuleCard(
          title: 'Parent Dashboard',
          subtitle: "Track your child's progress",
          icon: Icons.family_restroom_outlined,
          color: IqraTokens.rubyLt,
          flagKey: 'parent.portal',
          visible: true,
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ParentShell())),
        ),
      if (user?.hasRole(AppRole.teacher) == true)
        _ModuleCard(
          title: 'IQRA Studio',
          subtitle: 'Teach classes, manage students, earnings',
          icon: Icons.workspace_premium_outlined,
          color: IqraTokens.saffron,
          flagKey: 'studio.app',
          visible: true,
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StudioShell())),
        ),
      if (appState.isStaff)
        _ModuleCard(
          title: 'Nuerizo Control Center',
          subtitle: 'Admin: flags, users, pricing, CMS, analytics',
          icon: Icons.admin_panel_settings_outlined,
          color: IqraTokens.gold,
          flagKey: 'admin.control_center',
          visible: true,
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminShell())),
        ),
    ];

    return Scaffold(
      backgroundColor: s.appBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    const IqraLogoMark(size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('IQRA Hub', style: text.cardTitle(size: 18)),
                          Text(
                            user != null ? 'Welcome, ${user.name}' : 'Ecosystem launcher',
                            style: text.metaDim(),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.logout, color: s.appTextDim, size: 20),
                      tooltip: 'Sign out',
                      onPressed: () async {
                        await context.read<AppState>().logout();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildModuleTile(context, modules[index], flags),
                  ),
                  childCount: modules.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: _websiteFooterCard(context, text, s),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleTile(BuildContext context, _ModuleCard m, FeatureFlagRepository flags) {
    final s = IqraSurface.dark;
    final text = IqraText(s);
    final flag = flags.getByKey(m.flagKey);
    return InkWell(
      onTap: m.onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: s.appCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: s.appBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: m.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(m.icon, color: m.color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(m.title, style: text.cardTitle(size: 15)),
                      if (flag != null && flag.releaseState != ReleaseState.public) ...[
                        const SizedBox(width: 8),
                        ReleaseBadge(state: flag.releaseState, fontSize: 8.5),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(m.subtitle, style: text.metaDim()),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: s.appTextMuted),
          ],
        ),
      ),
    );
  }

  Widget _websiteFooterCard(BuildContext context, IqraText text, IqraSurface s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: s.appCard2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: s.appBorderSoft, style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          Icon(Icons.public, color: s.appTextDim, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Public website & Nuerizo Control Center are also part of this build — see the web/admin surfaces.',
              style: text.metaDim(size: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String flagKey;
  final bool visible;
  final VoidCallback onTap;

  _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.flagKey,
    required this.visible,
    required this.onTap,
  });
}
