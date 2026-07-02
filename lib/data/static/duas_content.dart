enum DuaCategory { morning, evening, travel, home, distress }

class DuaEntry {
  final String id;
  final DuaCategory category;
  final String arabic;
  final String transliteration;
  final String translation;
  final String source;

  const DuaEntry({
    required this.id,
    required this.category,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.source,
  });
}

/// Authentic duas with correct source attribution — sourced from standard
/// hadith collections, not invented text.
const List<DuaEntry> duasContent = [
  DuaEntry(
    id: 'morning_1',
    category: DuaCategory.morning,
    arabic: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ',
    transliteration: 'Aṣbaḥnā wa aṣbaḥa l-mulku lillāh, wal-ḥamdu lillāh',
    translation: 'We have entered the morning and the dominion belongs to Allah, and all praise is to Allah.',
    source: 'Sahih Muslim',
  ),
  DuaEntry(
    id: 'evening_1',
    category: DuaCategory.evening,
    arabic: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ',
    transliteration: 'Amsaynā wa amsā l-mulku lillāh, wal-ḥamdu lillāh',
    translation: 'We have entered the evening and the dominion belongs to Allah, and all praise is to Allah.',
    source: 'Sahih Muslim',
  ),
  DuaEntry(
    id: 'travel_1',
    category: DuaCategory.travel,
    arabic: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ',
    transliteration: 'Subḥāna l-ladhī sakhkhara lanā hādhā wa mā kunnā lahu muqrinīn',
    translation: 'Glory be to Him who has subjected this to us, and we could never have accomplished it by ourselves.',
    source: 'Quran 43:13',
  ),
  DuaEntry(
    id: 'home_1',
    category: DuaCategory.home,
    arabic: 'بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى رَبِّنَا تَوَكَّلْنَا',
    transliteration: 'Bismillāhi walajnā, wa bismillāhi kharajnā, wa ʿalā rabbinā tawakkalnā',
    translation: 'In the name of Allah we enter, in the name of Allah we leave, and upon our Lord we place our trust.',
    source: 'Abu Dawud',
  ),
  DuaEntry(
    id: 'distress_1',
    category: DuaCategory.distress,
    arabic: 'لَا إِلَٰهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
    transliteration: 'Lā ilāha illā anta subḥānaka innī kuntu mina ẓ-ẓālimīn',
    translation: 'There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers.',
    source: 'Quran 21:87 (Dua of Yunus)',
  ),
  DuaEntry(
    id: 'morning_2',
    category: DuaCategory.morning,
    arabic: 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ',
    transliteration: 'Allāhumma bika aṣbaḥnā, wa bika amsaynā, wa bika naḥyā, wa bika namūtu wa ilayka n-nushūr',
    translation: 'O Allah, by You we enter the morning, by You we enter the evening, by You we live and by You we die, and to You is the resurrection.',
    source: 'Tirmidhi',
  ),
];
