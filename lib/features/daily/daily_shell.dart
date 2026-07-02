import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'home/home_screen.dart';
import 'prayer/prayer_screen.dart';
import 'quran/quran_list_screen.dart';
import 'learn/learn_screen.dart';
import 'more/more_screen.dart';

/// IQRA Daily — the consumer companion app. Bottom tab bar drives
/// Today / Prayer / Qur'an / Learn / More, exactly per the handoff.
class DailyShell extends StatefulWidget {
  const DailyShell({super.key});

  @override
  State<DailyShell> createState() => _DailyShellState();
}

class _DailyShellState extends State<DailyShell> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    PrayerScreen(),
    QuranListScreen(),
    LearnScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final s = IqraSurface.dark;
    return Scaffold(
      backgroundColor: s.appBg,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: s.appCard,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today_outlined), selectedIcon: Icon(Icons.today), label: 'Today'),
          NavigationDestination(icon: Icon(Icons.access_time_outlined), selectedIcon: Icon(Icons.access_time), label: 'Prayer'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: "Qur'an"),
          NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school), label: 'Learn'),
          NavigationDestination(icon: Icon(Icons.more_horiz), selectedIcon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}
