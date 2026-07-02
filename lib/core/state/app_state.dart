import 'package:flutter/material.dart';
import '../../models/user_account.dart';
import '../../models/app_role.dart';
import '../../models/prayer_settings.dart';
import '../../models/tasbih_state.dart';
import '../../models/reader_state.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/preferences_repository.dart';
import '../../data/repositories/feature_flag_repository.dart';

/// Root application state: current session, theme mode, active role
/// context (a user with multiple roles can switch between Student /
/// Parent / Teacher / Admin surfaces), and cached per-user preferences.
class AppState extends ChangeNotifier {
  UserAccount? currentUser;
  AppRole activeRole = AppRole.student;
  ThemeMode themeMode = ThemeMode.dark;
  bool onboardingComplete = false;

  late PrayerSettings prayerSettings;
  late TasbihState tasbihState;
  late ReaderState readerState;

  final _userRepo = UserRepository.instance;
  final _prefsRepo = PreferencesRepository.instance;
  final _flagRepo = FeatureFlagRepository.instance;

  String get _userKey => currentUser?.id ?? 'guest';

  Future<void> bootstrap() async {
    await _flagRepo.seedIfEmpty();
    onboardingComplete = _prefsRepo.onboardingComplete;
    themeMode = _prefsRepo.themeMode == 'light' ? ThemeMode.light : ThemeMode.dark;
    currentUser = _userRepo.currentUser;
    if (currentUser != null && currentUser!.roles.isNotEmpty) {
      activeRole = currentUser!.roles.first;
    }
    _loadUserPrefs();
    notifyListeners();
  }

  void _loadUserPrefs() {
    prayerSettings = _prefsRepo.getPrayerSettings(_userKey);
    tasbihState = _prefsRepo.getTasbihState(_userKey);
    readerState = _prefsRepo.getReaderState(_userKey);
  }

  Future<void> completeOnboarding(PrayerSettings settings) async {
    prayerSettings = settings;
    await _prefsRepo.savePrayerSettings(_userKey, settings);
    onboardingComplete = true;
    await _prefsRepo.setOnboardingComplete(true);
    notifyListeners();
  }

  Future<void> login(UserAccount user) async {
    currentUser = user;
    if (user.roles.isNotEmpty) activeRole = user.roles.first;
    _loadUserPrefs();
    notifyListeners();
  }

  Future<void> logout() async {
    await _userRepo.logout();
    currentUser = null;
    activeRole = AppRole.student;
    _loadUserPrefs();
    notifyListeners();
  }

  void switchActiveRole(AppRole role) {
    if (currentUser == null) return;
    if (!currentUser!.roles.contains(role)) return;
    activeRole = role;
    notifyListeners();
  }

  bool get isStaff =>
      currentUser?.hasRole(AppRole.admin) == true ||
      currentUser?.hasRole(AppRole.superAdmin) == true;

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    await _prefsRepo.setThemeMode(mode == ThemeMode.light ? 'light' : 'dark');
    notifyListeners();
  }

  Future<void> updatePrayerSettings(PrayerSettings settings) async {
    prayerSettings = settings;
    await _prefsRepo.savePrayerSettings(_userKey, settings);
    notifyListeners();
  }

  Future<void> updateTasbih(TasbihState state) async {
    tasbihState = state;
    await _prefsRepo.saveTasbihState(_userKey, state);
    notifyListeners();
  }

  Future<void> updateReaderState(ReaderState state) async {
    readerState = state;
    await _prefsRepo.saveReaderState(_userKey, state);
    notifyListeners();
  }

  bool isFeatureEnabled(String key) => _flagRepo.isEnabled(
        key,
        isStaff: isStaff,
        isPremiumUser: false,
      );
}
