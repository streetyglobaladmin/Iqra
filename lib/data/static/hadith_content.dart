/// Authentic hadith with correct source attribution — sourced from
/// standard collections (Bukhari, Muslim, Tirmidhi), not invented text.
/// Mirrors the pattern used for [duasContent]. Guest-accessible per the
/// guest-first requirement — "Daily Hadith" needs no account to read.
class HadithEntry {
  final String id;
  final String arabic;
  final String translation;
  final String narrator;
  final String source;

  const HadithEntry({
    required this.id,
    required this.arabic,
    required this.translation,
    required this.narrator,
    required this.source,
  });
}

const List<HadithEntry> hadithContent = [
  HadithEntry(
    id: 'hadith_1',
    arabic: 'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ',
    translation: 'Actions are but by intentions, and every man shall have only that which he intended.',
    narrator: 'Umar ibn al-Khattab',
    source: 'Sahih al-Bukhari & Sahih Muslim',
  ),
  HadithEntry(
    id: 'hadith_2',
    arabic: 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ',
    translation: 'Whoever believes in Allah and the Last Day should speak good or remain silent.',
    narrator: 'Abu Hurairah',
    source: 'Sahih al-Bukhari & Sahih Muslim',
  ),
  HadithEntry(
    id: 'hadith_3',
    arabic: 'الطُّهُورُ شَطْرُ الْإِيمَانِ',
    translation: 'Cleanliness is half of faith.',
    narrator: 'Abu Malik al-Ashari',
    source: 'Sahih Muslim',
  ),
  HadithEntry(
    id: 'hadith_4',
    arabic: 'لَا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لِأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
    translation: 'None of you truly believes until he loves for his brother what he loves for himself.',
    narrator: 'Anas ibn Malik',
    source: 'Sahih al-Bukhari & Sahih Muslim',
  ),
  HadithEntry(
    id: 'hadith_5',
    arabic: 'مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ فِيهِ عِلْمًا سَهَّلَ اللَّهُ لَهُ بِهِ طَرِيقًا إِلَى الْجَنَّةِ',
    translation: 'Whoever travels a path in search of knowledge, Allah will make easy for him a path to Paradise.',
    narrator: 'Abu Hurairah',
    source: 'Sahih Muslim',
  ),
  HadithEntry(
    id: 'hadith_6',
    arabic: 'الْكَلِمَةُ الطَّيِّبَةُ صَدَقَةٌ',
    translation: 'A good word is charity.',
    narrator: 'Abu Hurairah',
    source: 'Sahih al-Bukhari & Sahih Muslim',
  ),
  HadithEntry(
    id: 'hadith_7',
    arabic: 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
    translation: 'The best among you are those who learn the Qur\'ān and teach it.',
    narrator: 'Uthman ibn Affan',
    source: 'Sahih al-Bukhari',
  ),
];

HadithEntry hadithForToday() {
  final dayOfYear = DateTime.now()
      .difference(DateTime(DateTime.now().year, 1, 1))
      .inDays;
  return hadithContent[dayOfYear % hadithContent.length];
}
