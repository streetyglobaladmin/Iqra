import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/state/app_state.dart';
import '../../core/auth/guest_locked_screen.dart';
import 'pages/flags_page.dart';
import 'pages/users_page.dart';
import 'pages/pricing_page.dart';
import 'pages/cms_page_admin.dart';
import 'pages/ads_page.dart';
import 'pages/analytics_page.dart';
import 'pages/audit_log_page.dart';

/// Nuerizo Control Center — the internal operator console. Real
/// working admin CRUD over the same local database every other surface
/// reads from. Every mutation writes to the audit log automatically.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  final _pages = const [
    FeatureFlagsPage(),
    UsersPage(),
    PricingPage(),
    CmsAdminPage(),
    AdsPage(),
    AnalyticsPage(),
    AuditLogPage(),
  ];

  final _labels = const [
    'Flags', 'Users', 'Pricing', 'CMS', 'Ads', 'Analytics', 'Audit',
  ];

  final _icons = const [
    Icons.flag_outlined, Icons.people_outline, Icons.attach_money,
    Icons.article_outlined, Icons.campaign_outlined, Icons.insights_outlined,
    Icons.history_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    // Guest-first + admin-only: the Control Center is never reachable
    // without an authenticated Academy Admin / Super Admin session.
    if (!appState.isStaff) {
      return const GuestLockedScreen(
        surfaceName: 'Nuerizo Control Center',
        icon: Icons.admin_panel_settings_outlined,
        message: 'Restricted to Academy Admin and Super Admin accounts.',
      );
    }

    final s = context.surface;
    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(title: const Text('Nuerizo Control Center')),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            backgroundColor: s.appCard,
            labelType: NavigationRailLabelType.all,
            destinations: List.generate(
              _labels.length,
              (i) => NavigationRailDestination(
                icon: Icon(_icons[i]),
                label: Text(_labels[i], style: const TextStyle(fontSize: 10)),
              ),
            ),
          ),
          VerticalDivider(width: 1, color: s.appBorder),
          Expanded(child: _pages[_index]),
        ],
      ),
    );
  }
}
