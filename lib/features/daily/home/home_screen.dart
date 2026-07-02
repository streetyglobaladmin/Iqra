import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/numerals.dart';
import '../../../core/widgets/ornaments.dart';
import '../../../core/state/app_state.dart';
import '../../../services/prayer_times_calculator.dart';
import '../../../services/hijri_calendar.dart';
import '../../../data/static/quran_content.dart';
import '../qibla/qibla_screen.dart';
import '../tasbih/tasbih_screen.dart';
import '../duas/duas_screen.dart';
import '../hadith/hadith_screen.dart';
import '../scholar/scholar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  static const _prayerLabels = {
    'fajr': 'Fajr',
    'dhuhr': 'Dhuhr',
    'asr': 'Asr',
    'maghrib': 'Maghrib',
    'isha': 'Isha',
  };
  static const _prayerArabic = {
    'fajr': 'الفجر',
    'dhuhr': 'الظهر',
    'asr': 'العصر',
    'maghrib': 'المغرب',
    'isha': 'العشاء',
  };

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final settings = appState.prayerSettings;
    final s = context.surface;
    final text = IqraText(s);
    final useArabic = settings.useArabicNumerals;

    final times = PrayerTimesCalculator.calculate(
      date: _now,
      location: settings.location,
      method: settings.calcMethod,
      madhab: settings.madhab,
    );
    final (activeKey, nextKey, nextTime) = times.currentWindow(_now);
    var remaining = nextTime.difference(_now);
    if (remaining.isNegative) {
      remaining = remaining + const Duration(days: 1);
    }
    final hh = remaining.inHours;
    final mm = remaining.inMinutes % 60;
    final ss = remaining.inSeconds % 60;

    final hijri = HijriCalendar.fromGregorian(_now);
    final verse = verseForToday();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildHero(context, s, text, nextKey, hh, mm, ss, useArabic, settings.location.city),
        ),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -28),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildDateCard(context, s, text, hijri, useArabic),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: _buildPrayerRail(context, s, text, times, activeKey, useArabic),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: _buildVerseCard(context, s, text, verse),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: _buildQuickActions(context, s, text),
          ),
        ),
      ],
    );
  }

  Widget _buildHero(BuildContext context, IqraSurface s, IqraText text, String nextKey,
      int hh, int mm, int ss, bool useArabic, String city) {
    final sky = IqraTokens.skyFor(nextKey);
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: sky,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: GeoPatternBackground(opacity: 0.05)),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: Colors.white.withValues(alpha: 0.85), size: 16),
                      const SizedBox(width: 4),
                      Text(city.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5)),
                      const Spacer(),
                      Icon(Icons.notifications_outlined, color: Colors.white.withValues(alpha: 0.85), size: 20),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text('NEXT PRAYER',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3)),
                  const SizedBox(height: 6),
                  const Flourish(width: 60, color: Colors.white),
                  const SizedBox(height: 6),
                  Text(
                    _prayerLabels[nextKey] ?? '',
                    style: const TextStyle(
                      fontFamily: IqraFonts.display,
                      fontSize: 34,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${Numerals.pad2(hh, useArabic: useArabic)}:${Numerals.pad2(mm, useArabic: useArabic)}:${Numerals.pad2(ss, useArabic: useArabic)}',
                    style: const TextStyle(
                      fontFamily: IqraFonts.numeric,
                      fontSize: 42,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text('UNTIL ADHĀN',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(BuildContext context, IqraSurface s, IqraText text, HijriDate hijri, bool useArabic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: s.appCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: s.appBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${Numerals.format(hijri.day, useArabic: useArabic)} ${hijri.monthName} · ${Numerals.format(hijri.year, useArabic: useArabic)} AH',
                  style: text.cardTitle(size: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_weekdayName(DateTime.now())}, ${_now.day} ${_monthName(_now.month)}',
                  style: text.metaDim(),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 32, color: IqraTokens.gold.withValues(alpha: 0.3)),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QiblaScreen())),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: IqraTokens.gold, width: 1.5),
              ),
              child: const Icon(Icons.explore_outlined, color: IqraTokens.gold, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerRail(BuildContext context, IqraSurface s, IqraText text, DailyPrayerTimes times,
      String activeKey, bool useArabic) {
    final order = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: order.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final key = order[i];
          final time = times.asMap[key]!;
          final isActive = key == activeKey;
          final isDone = time.isBefore(_now) && !isActive;
          return Container(
            width: 68,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? IqraTokens.gold : (isDone ? s.appCard2 : s.appCard),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isActive ? IqraTokens.gold : s.appBorder),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isDone)
                  Icon(Icons.check, size: 14, color: s.appTextDim)
                else
                  Text(_prayerArabic[key]!,
                      style: TextStyle(
                          fontFamily: IqraFonts.arabic,
                          fontSize: 13,
                          color: isActive ? IqraTokens.ink : s.appText)),
                const SizedBox(height: 4),
                Text(_prayerLabels[key]!,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isActive ? IqraTokens.ink : s.appText)),
                Text(
                  '${Numerals.pad2(time.hour % 12 == 0 ? 12 : time.hour % 12, useArabic: useArabic)}:${Numerals.pad2(time.minute, useArabic: useArabic)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive ? IqraTokens.ink.withValues(alpha: 0.7) : s.appTextDim,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerseCard(BuildContext context, IqraSurface s, IqraText text, VerseOfDay verse) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: IqraTokens.ink,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          const Positioned(top: -8, right: -8, child: StarMotif(size: 56)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('VERSE OF THE DAY', style: text.sectionHeader),
              const SizedBox(height: 12),
              Text(
                verse.arabic,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: IqraFonts.arabic,
                  fontSize: 22,
                  color: IqraTokens.appTextDark,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                verse.translation,
                style: const TextStyle(
                  fontFamily: IqraFonts.display,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: IqraTokens.appTextDimDark,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(verse.reference,
                        style: const TextStyle(fontSize: 11, color: IqraTokens.gold, fontWeight: FontWeight.w600)),
                  ),
                  Icon(Icons.bookmark_border, color: IqraTokens.appTextMutedDark, size: 18),
                  const SizedBox(width: 12),
                  Icon(Icons.volume_up_outlined, color: IqraTokens.appTextMutedDark, size: 18),
                  const SizedBox(width: 12),
                  Icon(Icons.share_outlined, color: IqraTokens.appTextMutedDark, size: 18),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, IqraSurface s, IqraText text) {
    final actions = [
      (_QuickAction('Qibla', 'Find direction', Icons.explore_outlined, IqraTokens.emeraldLt,
          () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QiblaScreen())))),
      (_QuickAction('Tasbīḥ', 'Count dhikr', Icons.circle_outlined, IqraTokens.lapisLt,
          () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TasbihScreen())))),
      (_QuickAction('Duʿās', 'Daily supplications', Icons.favorite_border, IqraTokens.rubyLt,
          () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DuasScreen())))),
      (_QuickAction('Hadith', 'Daily narration', Icons.menu_book_outlined, IqraTokens.goldLt,
          () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HadithScreen())))),
      (_QuickAction('Ask Scholar', 'Find a teacher', Icons.school_outlined, IqraTokens.saffron,
          () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ScholarScreen())))),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.6,
      children: actions.map((a) {
        return InkWell(
          onTap: a.onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: s.appCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: s.appBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: a.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(a.icon, color: a.color, size: 19),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(a.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: s.appText)),
                      Text(a.sublabel, style: text.metaDim(size: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _weekdayName(DateTime d) =>
      const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][d.weekday - 1];
  String _monthName(int m) => const [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ][m - 1];
}

class _QuickAction {
  final String label;
  final String sublabel;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _QuickAction(this.label, this.sublabel, this.icon, this.color, this.onTap);
}
