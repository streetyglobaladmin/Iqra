import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/numerals.dart';
import '../../../core/widgets/ornaments.dart';
import '../../../core/state/app_state.dart';
import '../../../data/static/surah_index.dart';
import '../../../data/static/quran_content.dart';

class QuranReaderScreen extends StatefulWidget {
  final int surahNumber;
  const QuranReaderScreen({super.key, required this.surahNumber});

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  bool _isPlaying = false;
  int? _selectedAyah;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = context.surface;
    final text = IqraText(s);
    final useArabic = appState.prayerSettings.useArabicNumerals;
    final surah = surahIndex[widget.surahNumber - 1];
    final hasFullText = widget.surahNumber == 1; // Al-Fātiḥah ships complete

    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(
        title: Text('${surah.nameLatin} · ${surah.number}'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              children: [
                Center(
                  child: Column(
                    children: [
                      const Flourish(width: 100),
                      const SizedBox(height: 10),
                      const Text(
                        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(fontFamily: IqraFonts.arabic, fontSize: 28, color: IqraTokens.goldLt),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'In the name of Allah, the Entirely Merciful, the Especially Merciful',
                        textAlign: TextAlign.center,
                        style: text.metaDim(size: 12),
                      ),
                      const SizedBox(height: 10),
                      const Flourish(width: 100),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (hasFullText)
                  ...alFatihahAyahs.map((ayah) => _buildAyahBlock(ayah, s, text, useArabic))
                else
                  _buildComingSoonNotice(s, text, surah),
              ],
            ),
          ),
          _buildAudioDock(s, text),
        ],
      ),
    );
  }

  Widget _buildAyahBlock(Ayah ayah, IqraSurface s, IqraText text, bool useArabic) {
    final isSelected = _selectedAyah == ayah.number;
    return GestureDetector(
      onTap: () => setState(() => _selectedAyah = isSelected ? null : ayah.number),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? IqraTokens.gold.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isSelected ? Border.all(color: IqraTokens.gold.withValues(alpha: 0.4)) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: IqraTokens.gold, width: 1.2),
                  ),
                  child: Center(
                    child: Text(
                      Numerals.format(ayah.number, useArabic: true),
                      style: const TextStyle(fontFamily: IqraFonts.arabic, fontSize: 11, color: IqraTokens.gold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              ayah.arabic,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: const TextStyle(fontFamily: IqraFonts.arabic, fontSize: 25, height: 2.0, color: IqraTokens.appTextDark),
            ),
            const SizedBox(height: 8),
            Text(
              ayah.transliteration,
              style: const TextStyle(fontFamily: IqraFonts.display, fontStyle: FontStyle.italic, fontSize: 13.5, color: IqraTokens.appTextDimDark),
            ),
            const SizedBox(height: 6),
            Text(
              ayah.translation,
              style: const TextStyle(fontFamily: IqraFonts.sans, fontSize: 13, color: IqraTokens.appTextDark, height: 1.4),
            ),
            if (isSelected) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  _iconBtn(Icons.play_arrow),
                  const SizedBox(width: 16),
                  _iconBtn(Icons.bookmark_border),
                  const SizedBox(width: 16),
                  _iconBtn(Icons.share_outlined),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon) => Icon(icon, size: 18, color: IqraTokens.appTextMutedDark);

  Widget _buildComingSoonNotice(IqraSurface s, IqraText text, SurahMeta surah) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: s.appCard2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: s.appBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.menu_book_outlined, color: IqraTokens.gold, size: 28),
          const SizedBox(height: 12),
          Text('Full text loads from the Quran API', style: text.cardTitle(size: 15), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
            '${surah.nameLatin} (${Numerals.format(surah.ayahCount, useArabic: false)} verses) will stream from a licensed Quran text/audio API once network access is configured. Al-Fātiḥah ships fully offline as the reference implementation.',
            textAlign: TextAlign.center,
            style: text.bodyDim(size: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioDock(IqraSurface s, IqraText text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: s.appCard,
        border: Border(top: BorderSide(color: s.appBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            CircleAvatar(radius: 18, backgroundColor: IqraTokens.gold.withValues(alpha: 0.2), child: const Icon(Icons.person, color: IqraTokens.gold, size: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mishary Alafasy', style: text.body(size: 12.5, weight: FontWeight.w700)),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    height: 3,
                    decoration: BoxDecoration(color: s.appBorder, borderRadius: BorderRadius.circular(2)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () => setState(() => _isPlaying = !_isPlaying),
              child: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(color: IqraTokens.gold, shape: BoxShape.circle),
                child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: IqraTokens.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
