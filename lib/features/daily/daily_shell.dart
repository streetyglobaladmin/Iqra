import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'home/home_screen.dart';
import 'prayer/prayer_screen.dart';
import 'quran/quran_list_screen.dart';
import 'learn/learn_screen.dart';
import 'scholar/scholar_screen.dart';
import 'profile/profile_screen.dart';

/// IQRA Daily — the real consumer mobile app home. This is the ONLY
/// screen the mobile APK opens into after splash/onboarding (see
/// features/splash/splash_screen.dart). It is guest-first: every tab
/// here is reachable without signing in.
///
/// Navigation: Today / Prayer / Qur'ān / Learn / Scholars / Profile, all
/// visible at once in a single scrollable bottom bar (so the list can
/// grow — e.g. a future "Kids" tab — without needing an overflow menu).
/// The body is a swipeable [PageView] so moving between sections feels
/// continuous, whether by tapping a tab or swiping the content.
///
/// Do NOT wire this shell to the ecosystem "IQRA Hub" launcher
/// (features/hub/hub_shell.dart) or the Nuerizo Control Center
/// (features/admin/admin_shell.dart) — those are web-only surfaces for
/// the public website / control.nuerizo.com builds, never part of the
/// mobile app's navigation.
class DailyShell extends StatefulWidget {
  const DailyShell({super.key});

  @override
  State<DailyShell> createState() => _DailyShellState();
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  const _NavItem(this.label, this.icon, this.selectedIcon);
}

class _DailyShellState extends State<DailyShell> {
  late final PageController _pageController;
  int _index = 0;

  static const _items = [
    _NavItem('Today', Icons.today_outlined, Icons.today),
    _NavItem('Prayer', Icons.access_time_outlined, Icons.access_time),
    _NavItem("Qur'ān", Icons.menu_book_outlined, Icons.menu_book),
    _NavItem('Learn', Icons.school_outlined, Icons.school),
    _NavItem('Scholars', Icons.groups_outlined, Icons.groups),
    _NavItem('Profile', Icons.person_outline, Icons.person),
  ];

  final _pages = const [
    HomeScreen(),
    PrayerScreen(),
    QuranListScreen(),
    LearnScreen(),
    ScholarScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int i) {
    if (i == _index) return;
    setState(() => _index = i);
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    return Scaffold(
      backgroundColor: s.appBg,
      body: PageView(
        controller: _pageController,
        // Fluid swipe navigation between Today -> Prayer -> Qur'ān ->
        // Learn -> Scholars -> Profile, matching the tab order.
        onPageChanged: (i) => setState(() => _index = i),
        children: _pages,
      ),
      bottomNavigationBar: _ScrollableBottomBar(
        items: _items,
        index: _index,
        onTap: _goTo,
      ),
    );
  }
}

/// A horizontally scrollable bottom navigation bar. Unlike a fixed
/// [NavigationBar], this can hold more destinations than comfortably fit
/// on one screen — the row simply scrolls to reveal the rest — so future
/// additions (Kids, Academy Enterprise, etc.) don't require redesigning
/// the navigation shell.
class _ScrollableBottomBar extends StatelessWidget {
  final List<_NavItem> items;
  final int index;
  final ValueChanged<int> onTap;

  const _ScrollableBottomBar({
    required this.items,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    return Container(
      decoration: BoxDecoration(
        color: s.appCard,
        border: Border(top: BorderSide(color: s.appBorderSoft)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              final selected = i == index;
              return _BottomBarButton(
                label: item.label,
                icon: selected ? item.selectedIcon : item.icon,
                selected: selected,
                onTap: () => onTap(i),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BottomBarButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _BottomBarButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final color = selected ? IqraTokens.gold : s.appTextMuted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: IqraFonts.sans,
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
