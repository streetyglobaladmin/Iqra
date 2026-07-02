import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/numerals.dart';
import '../../../core/state/app_state.dart';
import '../../../services/hijri_calendar.dart';

/// Real Hijri month grid, computed via [HijriCalendar] — not a static
/// image. Highlights today and Fridays (Jumuʿah).
class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  late HijriDate _viewedMonth;

  @override
  void initState() {
    super.initState();
    _viewedMonth = HijriCalendar.fromGregorian(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final useArabic = appState.prayerSettings.useArabicNumerals;
    final s = context.surface;
    final text = IqraText(s);

    final daysInMonth = HijriCalendar.daysInHijriMonth(_viewedMonth.year, _viewedMonth.month);
    final firstOfMonthGregorian = HijriCalendar.toGregorian(HijriDate(_viewedMonth.year, _viewedMonth.month, 1));
    final leadingBlank = (firstOfMonthGregorian.weekday - 1) % 7; // Monday = 0

    final todayHijri = HijriCalendar.fromGregorian(DateTime.now());

    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(title: const Text('Hijri Calendar')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() => _viewedMonth = _shiftMonth(-1)),
                ),
                Expanded(
                  child: Text(
                    '${_viewedMonth.monthName} · ${Numerals.format(_viewedMonth.year, useArabic: useArabic)}',
                    textAlign: TextAlign.center,
                    style: text.cardTitle(size: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() => _viewedMonth = _shiftMonth(1)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final d in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                  Center(child: Text(d, style: text.metaDim())),
                for (int i = 0; i < leadingBlank; i++) const SizedBox(),
                for (int day = 1; day <= daysInMonth; day++)
                  _buildDayCell(day, todayHijri, s, text, useArabic),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(int day, HijriDate today, IqraSurface s, IqraText text, bool useArabic) {
    final isToday = today.year == _viewedMonth.year && today.month == _viewedMonth.month && today.day == day;
    final gregorian = HijriCalendar.toGregorian(HijriDate(_viewedMonth.year, _viewedMonth.month, day));
    final isFriday = gregorian.weekday == DateTime.friday;

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isToday ? IqraTokens.gold : (isFriday ? IqraTokens.emerald.withValues(alpha: 0.15) : s.appCard),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isToday ? IqraTokens.gold : s.appBorderSoft),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(Numerals.format(day, useArabic: useArabic),
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: isToday ? IqraTokens.ink : s.appText)),
          Text('${gregorian.day}',
              style: TextStyle(fontSize: 9, color: isToday ? IqraTokens.ink.withValues(alpha: 0.7) : s.appTextMuted)),
        ],
      ),
    );
  }

  HijriDate _shiftMonth(int delta) {
    var month = _viewedMonth.month + delta;
    var year = _viewedMonth.year;
    if (month > 12) {
      month = 1;
      year++;
    } else if (month < 1) {
      month = 12;
      year--;
    }
    return HijriDate(year, month, 1);
  }
}
