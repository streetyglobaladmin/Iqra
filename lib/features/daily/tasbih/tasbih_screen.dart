import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/numerals.dart';
import '../../../core/state/app_state.dart';

/// Real, working dhikr counter with persisted state (survives app
/// restarts via Hive). Long-press resets; tap increments.
class TasbihScreen extends StatelessWidget {
  const TasbihScreen({super.key});

  static const _dhikrOptions = ['SubḥānAllāh', 'Alḥamdulillāh', 'Allāhu Akbar'];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final state = appState.tasbihState;
    final useArabic = appState.prayerSettings.useArabicNumerals;
    final progress = (state.current % state.target) / state.target;

    void increment() {
      final newCurrent = state.current + 1;
      final counts = Map<String, int>.from(state.dhikrCounts);
      counts[state.dhikr] = (counts[state.dhikr] ?? 0) + 1;
      final completedSession = newCurrent % state.target == 0;
      appState.updateTasbih(state.copyWith(
        current: newCurrent,
        dhikrCounts: counts,
        sessionsToday: completedSession ? state.sessionsToday + 1 : state.sessionsToday,
      ));
    }

    void reset() {
      appState.updateTasbih(state.copyWith(current: 0));
    }

    void selectDhikr(String d) {
      appState.updateTasbih(state.copyWith(dhikr: d));
    }

    return Scaffold(
      backgroundColor: IqraTokens.appBgDark,
      appBar: AppBar(
        title: const Text('Tasbīḥ'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: reset),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: _dhikrOptions.map((d) {
                final selected = state.dhikr == d;
                final count = state.dhikrCounts[d] ?? 0;
                return ChoiceChip(
                  label: Text('$d (${Numerals.format(count, useArabic: useArabic)})'),
                  selected: selected,
                  onSelected: (_) => selectDhikr(d),
                );
              }).toList(),
            ),
            const Spacer(),
            GestureDetector(
              onTap: increment,
              onLongPress: reset,
              child: SizedBox(
                width: 260,
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 260,
                      height: 260,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 10,
                        backgroundColor: IqraTokens.appCardDark,
                        valueColor: const AlwaysStoppedAnimation(IqraTokens.gold),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${Numerals.format(state.current % state.target == 0 && state.current > 0 ? state.target : state.current % state.target, useArabic: useArabic)}',
                          style: const TextStyle(
                              fontFamily: IqraFonts.numeric, fontSize: 56, fontWeight: FontWeight.w200, color: IqraTokens.appTextDark),
                        ),
                        Text('/ ${Numerals.format(state.target, useArabic: useArabic)}',
                            style: TextStyle(fontSize: 16, color: IqraTokens.appTextDimDark)),
                        const SizedBox(height: 8),
                        Text(state.dhikr,
                            style: const TextStyle(fontFamily: IqraFonts.arabic, fontSize: 16, color: IqraTokens.goldLt)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('TAP TO COUNT · HOLD TO RESET',
                style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: IqraTokens.appTextMutedDark)),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Wrap(
                spacing: 8,
                children: [33, 100].map((t) {
                  final selected = state.target == t;
                  return ChoiceChip(
                    label: Text('Target: ${Numerals.format(t, useArabic: useArabic)}'),
                    selected: selected,
                    onSelected: (_) => appState.updateTasbih(state.copyWith(target: t)),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                'Sessions completed today: ${Numerals.format(state.sessionsToday, useArabic: useArabic)}',
                style: TextStyle(fontSize: 12, color: IqraTokens.appTextDimDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
