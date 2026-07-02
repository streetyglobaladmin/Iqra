/// A single ayah with authentic Arabic text, transliteration, and an
/// English translation (Saheeh International style). Full 114-surah text
/// requires a licensed Quran API/dataset; this handoff ships Al-Fātiḥah
/// complete and correct as the reference reader implementation, with the
/// architecture ready to load remaining surahs from a real Quran API
/// (e.g. alquran.cloud / Quran.com) once network access is configured.
class Ayah {
  final int number;
  final String arabic;
  final String transliteration;
  final String translation;

  const Ayah({
    required this.number,
    required this.arabic,
    required this.transliteration,
    required this.translation,
  });
}

const List<Ayah> alFatihahAyahs = [
  Ayah(
    number: 1,
    arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    transliteration: 'Bismillāhi r-Raḥmāni r-Raḥīm',
    translation: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
  ),
  Ayah(
    number: 2,
    arabic: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
    transliteration: 'Al-ḥamdu lillāhi rabbi l-ʿālamīn',
    translation: '[All] praise is [due] to Allah, Lord of the worlds.',
  ),
  Ayah(
    number: 3,
    arabic: 'الرَّحْمَٰنِ الرَّحِيمِ',
    transliteration: 'Ar-Raḥmāni r-Raḥīm',
    translation: 'The Entirely Merciful, the Especially Merciful.',
  ),
  Ayah(
    number: 4,
    arabic: 'مَالِكِ يَوْمِ الدِّينِ',
    transliteration: 'Māliki yawmi d-dīn',
    translation: 'Sovereign of the Day of Recompense.',
  ),
  Ayah(
    number: 5,
    arabic: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
    transliteration: 'Iyyāka naʿbudu wa iyyāka nastaʿīn',
    translation: 'It is You we worship and You we ask for help.',
  ),
  Ayah(
    number: 6,
    arabic: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
    transliteration: 'Ihdinā ṣ-ṣirāṭa l-mustaqīm',
    translation: 'Guide us to the straight path.',
  ),
  Ayah(
    number: 7,
    arabic: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
    transliteration: 'Ṣirāṭa l-ladhīna anʿamta ʿalayhim ghayri l-maghḍūbi ʿalayhim wa lā ḍ-ḍāllīn',
    translation: 'The path of those upon whom You have bestowed favor, not of those who have evoked [Your] anger or of those who are astray.',
  ),
];

/// Verse of the day rotation — real ayah references + text, cycled by
/// day-of-year so the "Verse of the day" card is always populated with
/// genuine content, not a placeholder.
class VerseOfDay {
  final String reference;
  final String arabic;
  final String translation;
  const VerseOfDay(this.reference, this.arabic, this.translation);
}

const List<VerseOfDay> verseRotation = [
  VerseOfDay(
    'Al-Baqarah 2:255 (Āyat al-Kursī)',
    'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
    'Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence.',
  ),
  VerseOfDay(
    'Ash-Sharḥ 94:5-6',
    'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
    'For indeed, with hardship [will be] ease.',
  ),
  VerseOfDay(
    'At-Talaq 65:3',
    'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
    'And whoever relies upon Allah - then He is sufficient for him.',
  ),
  VerseOfDay(
    'Ar-Raʿd 13:28',
    'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
    'Unquestionably, by the remembrance of Allah hearts are assured.',
  ),
];

VerseOfDay verseForToday() {
  final dayOfYear = DateTime.now()
      .difference(DateTime(DateTime.now().year, 1, 1))
      .inDays;
  return verseRotation[dayOfYear % verseRotation.length];
}
