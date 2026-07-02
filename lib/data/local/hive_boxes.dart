/// Central registry of Hive box names. "One database, many modules" —
/// every module reads/writes through this single local data layer so a
/// future Postgres/Supabase migration only needs to change the
/// repository implementations, not the UI.
class HiveBoxes {
  HiveBoxes._();

  static const users = 'users';
  static const session = 'session'; // current logged-in user id
  static const featureFlags = 'feature_flags';
  static const academies = 'academies';
  static const classes = 'classes';
  static const students = 'students';
  static const pricingPlans = 'pricing_plans';
  static const currencies = 'currencies';
  static const cmsPages = 'cms_pages';
  static const advertisements = 'advertisements';
  static const referrals = 'referrals';
  static const auditLog = 'audit_log';
  static const payments = 'payments';
  static const prayerSettings = 'prayer_settings'; // per-user key
  static const tasbihState = 'tasbih_state'; // per-user key
  static const readerState = 'reader_state'; // per-user key
  static const bookmarks = 'bookmarks'; // duas, ayahs, etc.
  static const appSettings = 'app_settings'; // theme mode, onboarding done
  static const teachers = 'teachers';
  static const lectures = 'lectures';
}
