import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/state/app_state.dart';
import '../../../models/app_role.dart';
import '../../../models/user_account.dart';
import '../../../services/iqra_api_service.dart';
import '../../../data/repositories/user_repository.dart';
import '../qibla/qibla_screen.dart';
import '../tasbih/tasbih_screen.dart';
import '../duas/duas_screen.dart';
import '../hadith/hadith_screen.dart';
import '../calendar/hijri_calendar_screen.dart';
import '../settings/settings_screen.dart';
import '../articles/articles_screen.dart';
import '../lectures/lectures_screen.dart';
import '../../auth/login_screen.dart';
import '../../auth/signup_screen.dart';
import '../../student/student_shell.dart';
import '../../parent/parent_shell.dart';
import '../../studio/studio_preview_screen.dart';

/// Profile tab — the mobile app's account & settings surface.
/// Refreshes the signed-in profile from `/me` on each visit.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _refreshing = false;
  String? _refreshError;

  @override
  void initState() {
    super.initState();
    _refreshProfile();
  }

  Future<void> _refreshProfile() async {
    final appState = context.read<AppState>();
    if (appState.isGuest) return;
    setState(() => _refreshing = true);
    try {
      final user = await UserRepository.instance.refreshCurrentUser();
      if (user != null && mounted) {
        await appState.login(user);
      }
    } on IqraApiException catch (e) {
      if (mounted) setState(() => _refreshError = e.message);
    } catch (e) {
      if (mounted) setState(() => _refreshError = e.toString());
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = context.surface;
    final text = IqraText(s);
    final user = appState.currentUser;

    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(title: const Text('Profile')),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        color: IqraTokens.gold,
        backgroundColor: s.appCard,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _accountCard(context, s, text, user),
            if (_refreshing)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Center(child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )),
              ),
            if (_refreshError != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Could not refresh profile: $_refreshError',
                  style: TextStyle(color: IqraTokens.stateDanger, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 20),
            if (user == null) ...[
              Text('GET STARTED', style: text.sectionHeader),
              const SizedBox(height: 10),
              _actionTile(
                context,
                s,
                text,
                icon: Icons.login,
                title: 'Customer / User Login',
                subtitle: 'Sign in to an existing account',
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
              ),
              _actionTile(
                context,
                s,
                text,
                icon: Icons.person_add_alt_outlined,
                title: 'Student / Parent Sign Up',
                subtitle: 'Create a free account to save progress',
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const SignupScreen())),
              ),
              const SizedBox(height: 20),
            ] else ...[
              Text('MY ACCOUNT', style: text.sectionHeader),
              const SizedBox(height: 10),
              if (user.hasRole(AppRole.student))
                _actionTile(
                  context,
                  s,
                  text,
                  icon: Icons.school_outlined,
                  title: 'Student Dashboard',
                  subtitle: 'Classes, memorization & homework',
                  color: IqraTokens.lapisLt,
                  onTap: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const StudentShell())),
                ),
              if (user.hasRole(AppRole.parent))
                _actionTile(
                  context,
                  s,
                  text,
                  icon: Icons.family_restroom_outlined,
                  title: 'Parent Dashboard',
                  subtitle: "Track your child's progress",
                  color: IqraTokens.rubyLt,
                  onTap: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const ParentShell())),
                ),
              const SizedBox(height: 20),
            ],
            Text('TEACH ON IQRA', style: text.sectionHeader),
            const SizedBox(height: 10),
            _actionTile(
              context,
              s,
              text,
              icon: Icons.workspace_premium_outlined,
              title: 'IQRA Studio',
              subtitle: 'Teach classes, manage students, earnings',
              color: IqraTokens.saffron,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StudioPreviewScreen()),
              ),
            ),
            const SizedBox(height: 20),
            Text('EXPLORE', style: text.sectionHeader),
            const SizedBox(height: 10),
            _actionTile(
              context,
              s,
              text,
              icon: Icons.explore_outlined,
              title: 'Qibla',
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const QiblaScreen())),
            ),
            _actionTile(
              context,
              s,
              text,
              icon: Icons.circle_outlined,
              title: 'Tasbīḥ',
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const TasbihScreen())),
            ),
            _actionTile(
              context,
              s,
              text,
              icon: Icons.favorite_border,
              title: 'Duʿās',
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const DuasScreen())),
            ),
            _actionTile(
              context,
              s,
              text,
              icon: Icons.menu_book_outlined,
              title: 'Daily Hadith',
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const HadithScreen())),
            ),
            _actionTile(
              context,
              s,
              text,
              icon: Icons.play_circle_outline,
              title: 'Public Lectures',
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const LecturesScreen())),
            ),
            _actionTile(
              context,
              s,
              text,
              icon: Icons.calendar_month_outlined,
              title: 'Hijri Calendar',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HijriCalendarScreen()),
              ),
            ),
            _actionTile(
              context,
              s,
              text,
              icon: Icons.article_outlined,
              title: 'Articles & Blog',
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ArticlesScreen())),
            ),
            _actionTile(
              context,
              s,
              text,
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
            const SizedBox(height: 24),
            if (user != null)
              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    await appState.logout();
                  },
                  icon: Icon(Icons.logout, size: 16, color: s.appTextDim),
                  label: Text('Sign out', style: TextStyle(color: s.appTextDim)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _accountCard(
    BuildContext context,
    IqraSurface s,
    IqraText text,
    UserAccount? user,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: s.appCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: s.appBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: IqraTokens.gold.withValues(alpha: 0.2),
            child: Text(
              user != null && user.name.isNotEmpty
                  ? user.name[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: IqraTokens.gold,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.name ?? 'Guest', style: text.cardTitle(size: 16)),
                Text(
                  user?.email ?? 'Browsing without an account',
                  style: text.metaDim(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTile(
    BuildContext context,
    IqraSurface s,
    IqraText text, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: s.appCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: s.appBorder),
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? IqraTokens.gold),
        title: Text(title, style: text.body(size: 14, weight: FontWeight.w600)),
        subtitle: subtitle != null
            ? Text(subtitle, style: text.metaDim())
            : null,
        trailing: Icon(Icons.chevron_right, color: s.appTextMuted),
        onTap: onTap,
      ),
    );
  }
}
