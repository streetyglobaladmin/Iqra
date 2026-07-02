import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/iqra_logo.dart';
import '../../../core/state/app_state.dart';
import '../qibla/qibla_screen.dart';
import '../tasbih/tasbih_screen.dart';
import '../duas/duas_screen.dart';
import '../scholar/scholar_screen.dart';
import '../calendar/hijri_calendar_screen.dart';
import '../settings/settings_screen.dart';
import '../../hub/hub_shell.dart';
import '../../auth/login_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = context.surface;
    final text = IqraText(s);
    final user = appState.currentUser;

    final items = [
      (Icons.explore_outlined, 'Qibla', const QiblaScreen()),
      (Icons.circle_outlined, 'Tasbīḥ', const TasbihScreen()),
      (Icons.favorite_border, 'Duʿās', const DuasScreen()),
      (Icons.school_outlined, 'Scholars', const ScholarScreen()),
      (Icons.calendar_month_outlined, 'Hijri Calendar', const HijriCalendarScreen()),
      (Icons.settings_outlined, 'Settings', const SettingsScreen()),
    ];

    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: IqraTokens.gold.withValues(alpha: 0.2),
                child: Text(
                  user != null && user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: const TextStyle(color: IqraTokens.gold, fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? 'Guest', style: text.cardTitle(size: 16)),
                    Text(user?.email ?? '', style: text.metaDim()),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HubShell()),
                ),
                child: const Text('IQRA Hub'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...items.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: s.appCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: s.appBorder),
                ),
                child: ListTile(
                  leading: Icon(item.$1, color: IqraTokens.gold),
                  title: Text(item.$2, style: text.body(size: 14, weight: FontWeight.w600)),
                  trailing: Icon(Icons.chevron_right, color: s.appTextMuted),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => item.$3),
                  ),
                ),
              )),
          const SizedBox(height: 20),
          Center(
            child: TextButton.icon(
              onPressed: () async {
                await appState.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              icon: Icon(Icons.logout, size: 16, color: s.appTextDim),
              label: Text('Sign out', style: TextStyle(color: s.appTextDim)),
            ),
          ),
          const SizedBox(height: 20),
          Center(child: IqraWordmark(fontSize: 16, color: s.appTextMuted)),
        ],
      ),
    );
  }
}
