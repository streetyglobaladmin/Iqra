import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/numerals.dart';
import '../../../core/widgets/ornaments.dart';
import '../../../core/state/app_state.dart';
import '../../../services/prayer_times_calculator.dart';
import '../../../models/prayer_settings.dart';
import '../settings/settings_screen.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final settings = appState.prayerSettings;
    final s = context.surface;
    final text = IqraText(s);
    final useArabic = settings.useArabicNumerals;

    final weekStart = _selectedDay.subtract(Duration(days: _selectedDay.weekday - 1));
    final weekDays = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    final todayTimes = PrayerTimesCalculator.calculate(
      date: _selectedDay,
      location: settings.location,
      method: settings.calcMethod,
      madhab: settings.madhab,
    );
    final (activeKey, _, __) = todayTimes.currentWindow(DateTime.now());

    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(
        title: const Text('Prayer Times'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Text(
            '${settings.location.city} · ${settings.madhab.label} · ${settings.calcMethod.name.toUpperCase()}',
            style: text.metaDim(),
          ),
          const SizedBox(height: 16),
          _weekSelector(weekDays, s, text, useArabic),
          const SizedBox(height: 20),
          _todayCard(todayTimes, activeKey, s, text, useArabic),
          const SizedBox(height: 20),
          _weeklyTable(weekDays, settings, s, text, useArabic),
          const SizedBox(height: 20),
          _methodFooter(settings, s, text),
        ],
      ),
    );
  }

  Widget _weekSelector(List<DateTime> days, IqraSurface s, IqraText text, bool useArabic) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return SizedBox(
      height: 68,
      child: Row(
        children: days.asMap().entries.map((e) {
          final i = e.key;
          final d = e.value;
          final isToday = _isSameDay(d, _selectedDay);
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedDay = d),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isToday ? IqraTokens.emerald : s.appCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isToday ? IqraTokens.emerald : s.appBorder),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(labels[i], style: TextStyle(fontSize: 11, color: isToday ? Colors.white70 : s.appTextDim)),
                    const SizedBox(height: 4),
                    Text(Numerals.format(d.day, useArabic: useArabic),
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isToday ? Colors.white : s.appText)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _todayCard(DailyPrayerTimes times, String activeKey, IqraSurface s, IqraText text, bool useArabic) {
    final entries = [
      ('Fajr', times.fajr, 'fajr'),
      ('Sunrise', times.sunrise, 'sunrise'),
      ('Dhuhr', times.dhuhr, 'dhuhr'),
      ('Asr', times.asr, 'asr'),
      ('Maghrib', times.maghrib, 'maghrib'),
      ('Isha', times.isha, 'isha'),
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: IqraTokens.ink,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          const Positioned(top: -4, right: -4, child: StarMotif(size: 48, opacity: 0.18)),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 8,
            childAspectRatio: 1.6,
            children: entries.map((e) {
              final isActive = e.$3 == activeKey;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.$1.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w700,
                        color: isActive ? IqraTokens.gold : IqraTokens.appTextMutedDark,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    '${Numerals.pad2(e.$2.hour % 12 == 0 ? 12 : e.$2.hour % 12, useArabic: useArabic)}:${Numerals.pad2(e.$2.minute, useArabic: useArabic)}',
                    style: TextStyle(
                      fontFamily: IqraFonts.numeric,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isActive ? IqraTokens.gold : IqraTokens.appTextDark,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _weeklyTable(List<DateTime> days, dynamic settings, IqraSurface s, IqraText text, bool useArabic) {
    return Container(
      decoration: BoxDecoration(
        color: s.appCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: s.appBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: IqraTokens.gold.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                _headerCell(''),
                _headerCell('FAJR'),
                _headerCell('DHUHR'),
                _headerCell('ASR'),
                _headerCell('MAG'),
                _headerCell('ISHA'),
              ],
            ),
          ),
          ...days.map((d) {
            final isToday = _isSameDay(d, DateTime.now());
            final t = PrayerTimesCalculator.calculate(
              date: d,
              location: settings.location,
              method: settings.calcMethod,
              madhab: settings.madhab,
            );
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                color: isToday ? IqraTokens.gold.withValues(alpha: 0.1) : null,
                border: Border(top: BorderSide(color: s.appBorderSoft)),
              ),
              child: Row(
                children: [
                  _dataCell(Numerals.format(d.day, useArabic: useArabic), s, bold: isToday),
                  _timeCell(t.fajr, s, useArabic),
                  _timeCell(t.dhuhr, s, useArabic),
                  _timeCell(t.asr, s, useArabic),
                  _timeCell(t.maghrib, s, useArabic),
                  _timeCell(t.isha, s, useArabic),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _headerCell(String s) => Expanded(
        child: Text(s,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: IqraTokens.gold, letterSpacing: 0.5)),
      );

  Widget _dataCell(String s2, IqraSurface s, {bool bold = false}) => Expanded(
        child: Text(s2,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.w700 : FontWeight.w500, color: s.appText)),
      );

  Widget _timeCell(DateTime t, IqraSurface s, bool useArabic) => Expanded(
        child: Text(
          '${Numerals.pad2(t.hour % 12 == 0 ? 12 : t.hour % 12, useArabic: useArabic)}:${Numerals.pad2(t.minute, useArabic: useArabic)}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: s.appTextDim, fontFamily: IqraFonts.numeric),
        ),
      );

  Widget _methodFooter(dynamic settings, IqraSurface s, IqraText text) {
    final angles = settings.calcMethod.angles as (double, double);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: s.appCard2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: IqraTokens.gold.withValues(alpha: 0.3), style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${settings.madhab.label} · ${settings.calcMethod.label}', style: text.body(size: 12.5, weight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text('Fajr ${angles.$1}° · Isha ${angles.$2}°', style: text.metaDim()),
              ],
            ),
          ),
          Icon(Icons.settings_outlined, color: s.appTextDim, size: 18),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
