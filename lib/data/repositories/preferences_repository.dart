import 'package:hive/hive.dart';
import '../../models/prayer_settings.dart';
import '../../models/tasbih_state.dart';
import '../../models/reader_state.dart';
import '../local/db.dart';
import '../local/hive_boxes.dart';

/// Per-user local state: prayer settings, tasbih counter, Quran reader
/// position, and bookmarks. Keyed by userId so a shared device supports
/// multiple accounts without leaking state between them. Falls back to a
/// 'guest' key before login (onboarding flow).
class PreferencesRepository {
  static final PreferencesRepository instance = PreferencesRepository._();
  PreferencesRepository._();

  Box get _prayerBox => Db.box(HiveBoxes.prayerSettings);
  Box get _tasbihBox => Db.box(HiveBoxes.tasbihState);
  Box get _readerBox => Db.box(HiveBoxes.readerState);
  Box get _bookmarkBox => Db.box(HiveBoxes.bookmarks);
  Box get _appSettingsBox => Db.box(HiveBoxes.appSettings);

  PrayerSettings getPrayerSettings(String userKey) {
    final raw = _prayerBox.get(userKey);
    if (raw == null) return PrayerSettings.initial();
    return PrayerSettings.fromMap(Map<String, dynamic>.from(raw as Map));
  }

  Future<void> savePrayerSettings(String userKey, PrayerSettings s) async {
    await _prayerBox.put(userKey, s.toMap());
  }

  TasbihState getTasbihState(String userKey) {
    final raw = _tasbihBox.get(userKey);
    if (raw == null) return TasbihState();
    return TasbihState.fromMap(Map<String, dynamic>.from(raw as Map));
  }

  Future<void> saveTasbihState(String userKey, TasbihState s) async {
    await _tasbihBox.put(userKey, s.toMap());
  }

  ReaderState getReaderState(String userKey) {
    final raw = _readerBox.get(userKey);
    if (raw == null) return ReaderState();
    return ReaderState.fromMap(Map<String, dynamic>.from(raw as Map));
  }

  Future<void> saveReaderState(String userKey, ReaderState s) async {
    await _readerBox.put(userKey, s.toMap());
  }

  List<String> getBookmarks(String userKey) {
    final raw = _bookmarkBox.get(userKey) as List?;
    return raw?.cast<String>() ?? [];
  }

  Future<void> toggleBookmark(String userKey, String bookmarkKey) async {
    final current = getBookmarks(userKey);
    if (current.contains(bookmarkKey)) {
      current.remove(bookmarkKey);
    } else {
      current.add(bookmarkKey);
    }
    await _bookmarkBox.put(userKey, current);
  }

  bool get onboardingComplete =>
      _appSettingsBox.get('onboardingComplete', defaultValue: false) as bool;

  Future<void> setOnboardingComplete(bool value) async {
    await _appSettingsBox.put('onboardingComplete', value);
  }

  String get themeMode =>
      _appSettingsBox.get('themeMode', defaultValue: 'dark') as String;

  Future<void> setThemeMode(String mode) async {
    await _appSettingsBox.put('themeMode', mode);
  }
}
