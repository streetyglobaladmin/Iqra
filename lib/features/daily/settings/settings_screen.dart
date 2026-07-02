import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/state/app_state.dart';
import '../../../models/prayer_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final settings = appState.prayerSettings;
    final s = context.surface;
    final text = IqraText(s);

    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionHeader('PRAYER SETTINGS', Icons.access_time_outlined, text),
          _settingsGroup(s, [
            _tapRow(
              context,
              'Calculation method',
              settings.calcMethod.label,
              () => _showMethodPicker(context, appState, settings),
            ),
            _tapRow(
              context,
              'Madhab (Asr calculation)',
              settings.madhab.label,
              () => _showMadhabPicker(context, appState, settings),
            ),
            _tapRow(
              context,
              'Location',
              settings.location.city,
              () {},
            ),
          ]),
          const SizedBox(height: 20),
          _sectionHeader('NOTIFICATIONS', Icons.notifications_outlined, text),
          _settingsGroup(s, [
            _switchRow(context, 'Prayer notifications', settings.notificationsEnabled, (v) {
              appState.updatePrayerSettings(settings.copyWith(notificationsEnabled: v));
            }),
            for (final entry in settings.perPrayerNotification.entries)
              _switchRow(
                context,
                '  ${entry.key[0].toUpperCase()}${entry.key.substring(1)} adhān',
                entry.value,
                (v) {
                  final updated = Map<String, bool>.from(settings.perPrayerNotification);
                  updated[entry.key] = v;
                  appState.updatePrayerSettings(settings.copyWith(perPrayerNotification: updated));
                },
              ),
          ]),
          const SizedBox(height: 20),
          _sectionHeader('NUMERALS', Icons.pin_outlined, text),
          _settingsGroup(s, [
            _switchRow(context, 'Use Arabic-Indic numerals (٠١٢...)', settings.useArabicNumerals, (v) {
              appState.updatePrayerSettings(settings.copyWith(useArabicNumerals: v));
            }),
          ]),
          const SizedBox(height: 20),
          _sectionHeader('APPEARANCE', Icons.dark_mode_outlined, text),
          _settingsGroup(s, [
            _switchRow(context, 'Dark mode', appState.themeMode == ThemeMode.dark, (v) {
              appState.setThemeMode(v ? ThemeMode.dark : ThemeMode.light);
            }),
          ]),
          const SizedBox(height: 20),
          _sectionHeader('LIVE CLASS PROVIDER', Icons.videocam_outlined, text),
          _settingsGroup(s, [
            _infoRow(
              'Zoom / Google Meet',
              'Currently active — teachers paste meeting links per class.',
              text,
            ),
            _infoRow(
              'LiveKit (native video)',
              'Architecture ready; hidden behind a feature flag until launch.',
              text,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, IqraText text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: IqraTokens.gold),
          const SizedBox(width: 8),
          Text(title, style: text.sectionHeader),
        ],
      ),
    );
  }

  Widget _settingsGroup(IqraSurface s, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: s.appCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: s.appBorder),
      ),
      child: Column(children: children),
    );
  }

  Widget _tapRow(BuildContext context, String label, String value, VoidCallback onTap) {
    final s = context.surface;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(child: Text(label, style: TextStyle(fontSize: 13.5, color: s.appText))),
            Text(value, style: TextStyle(fontSize: 12.5, color: s.appTextDim)),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, size: 18, color: s.appTextMuted),
          ],
        ),
      ),
    );
  }

  Widget _switchRow(BuildContext context, String label, bool value, ValueChanged<bool> onChanged) {
    final s = context.surface;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: s.appText))),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String subtitle, IqraText text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.body(size: 13, weight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(subtitle, style: text.metaDim()),
        ],
      ),
    );
  }

  void _showMethodPicker(BuildContext context, AppState appState, PrayerSettings settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surface.appCard,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: CalcMethod.values.map((m) {
            return ListTile(
              title: Text(m.label, style: TextStyle(color: context.surface.appText)),
              trailing: settings.calcMethod == m ? const Icon(Icons.check, color: IqraTokens.gold) : null,
              onTap: () {
                appState.updatePrayerSettings(settings.copyWith(calcMethod: m));
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showMadhabPicker(BuildContext context, AppState appState, PrayerSettings settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surface.appCard,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: Madhab.values.map((m) {
            return ListTile(
              title: Text(m.label, style: TextStyle(color: context.surface.appText)),
              trailing: settings.madhab == m ? const Icon(Icons.check, color: IqraTokens.gold) : null,
              onTap: () {
                appState.updatePrayerSettings(settings.copyWith(madhab: m));
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
