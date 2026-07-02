import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/numerals.dart';
import '../../../core/state/app_state.dart';
import '../../../data/static/surah_index.dart';
import 'quran_reader_screen.dart';

class QuranListScreen extends StatefulWidget {
  const QuranListScreen({super.key});

  @override
  State<QuranListScreen> createState() => _QuranListScreenState();
}

class _QuranListScreenState extends State<QuranListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = context.surface;
    final text = IqraText(s);
    final useArabic = appState.prayerSettings.useArabicNumerals;
    final reader = appState.readerState;

    final filtered = surahIndex.where((surah) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return surah.nameLatin.toLowerCase().contains(q) ||
          surah.nameTranslation.toLowerCase().contains(q) ||
          surah.number.toString() == q;
    }).toList();

    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(
        title: const Text("Qur'ān"),
        actions: [
          IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: TextStyle(color: s.appText),
              decoration: const InputDecoration(
                hintText: 'Search surah...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => QuranReaderScreen(surahNumber: reader.lastSurah),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: s.appCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: s.appBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: IqraTokens.gold.withValues(alpha: 0.15), shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow, color: IqraTokens.gold, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Last read', style: text.metaDim()),
                          Text(
                            '${surahIndex[reader.lastSurah - 1].nameLatin} · ${Numerals.format(reader.lastAyah, useArabic: useArabic)}',
                            style: text.body(size: 12.5, weight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => Divider(color: s.appBorderSoft, height: 1),
              itemBuilder: (context, i) {
                final surah = filtered[i];
                return ListTile(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => QuranReaderScreen(surahNumber: surah.number)),
                  ),
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: IqraTokens.gold, width: 1.2),
                    ),
                    child: Center(
                      child: Text(
                        Numerals.format(surah.number, useArabic: true),
                        style: const TextStyle(fontFamily: IqraFonts.arabic, color: IqraTokens.gold, fontSize: 14),
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(surah.nameLatin, style: text.body(size: 14, weight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      Text(surah.nameArabic, style: const TextStyle(fontFamily: IqraFonts.arabic, fontSize: 15, color: IqraTokens.goldLt)),
                    ],
                  ),
                  subtitle: Text(
                    '${surah.place == RevelationPlace.meccan ? "Meccan" : "Medinan"} · ${Numerals.format(surah.ayahCount, useArabic: useArabic)} verses',
                    style: text.metaDim(),
                  ),
                  trailing: Icon(Icons.chevron_right, color: s.appTextMuted),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
