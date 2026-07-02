class ReaderState {
  final int lastSurah;
  final int lastAyah;
  final String translation;
  final String reciter;
  final List<String> bookmarkedAyahKeys; // "surah:ayah"

  ReaderState({
    this.lastSurah = 1,
    this.lastAyah = 1,
    this.translation = 'Saheeh International',
    this.reciter = 'Mishary Alafasy',
    this.bookmarkedAyahKeys = const [],
  });

  ReaderState copyWith({
    int? lastSurah,
    int? lastAyah,
    String? translation,
    String? reciter,
    List<String>? bookmarkedAyahKeys,
  }) {
    return ReaderState(
      lastSurah: lastSurah ?? this.lastSurah,
      lastAyah: lastAyah ?? this.lastAyah,
      translation: translation ?? this.translation,
      reciter: reciter ?? this.reciter,
      bookmarkedAyahKeys: bookmarkedAyahKeys ?? this.bookmarkedAyahKeys,
    );
  }

  Map<String, dynamic> toMap() => {
        'lastSurah': lastSurah,
        'lastAyah': lastAyah,
        'translation': translation,
        'reciter': reciter,
        'bookmarkedAyahKeys': bookmarkedAyahKeys,
      };

  factory ReaderState.fromMap(Map map) => ReaderState(
        lastSurah: map['lastSurah'] as int? ?? 1,
        lastAyah: map['lastAyah'] as int? ?? 1,
        translation: map['translation'] as String? ?? 'Saheeh International',
        reciter: map['reciter'] as String? ?? 'Mishary Alafasy',
        bookmarkedAyahKeys:
            List<String>.from(map['bookmarkedAyahKeys'] as List? ?? []),
      );
}
