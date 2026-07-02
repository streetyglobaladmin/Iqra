/// Real Gregorian <-> Hijri conversion using the well-known tabular
/// (Umm al-Qura approximation / Kuwaiti algorithm) civil calendar formula.
/// This gives correct results to within +/-1 day of local moon-sighting
/// announcements, exactly like the standard "civil Hijri" calculation
/// used by most calendar apps absent a moon-sighting service.
class HijriDate {
  final int year;
  final int month; // 1-12
  final int day;

  const HijriDate(this.year, this.month, this.day);

  static const monthNames = [
    'Muḥarram',
    'Ṣafar',
    'Rabīʿ al-Awwal',
    'Rabīʿ al-Thānī',
    'Jumādā al-Ūlā',
    'Jumādā al-Thāniyah',
    'Rajab',
    'Shaʿbān',
    'Ramaḍān',
    'Shawwāl',
    'Dhū al-Qaʿdah',
    'Dhū al-Ḥijjah',
  ];

  String get monthName => monthNames[month - 1];

  @override
  String toString() => '$day $monthName · $year AH';
}

class HijriCalendar {
  HijriCalendar._();

  /// Converts a Gregorian [date] to the civil Hijri calendar.
  static HijriDate fromGregorian(DateTime date) {
    final jd = _gregorianToJulianDay(date.year, date.month, date.day);
    return _julianDayToHijri(jd);
  }

  static DateTime toGregorian(HijriDate hijri) {
    final jd = _hijriToJulianDay(hijri.year, hijri.month, hijri.day);
    return _julianDayToGregorian(jd);
  }

  static int daysInHijriMonth(int year, int month) {
    final start = _hijriToJulianDay(year, month, 1);
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;
    final end = _hijriToJulianDay(nextYear, nextMonth, 1);
    return end - start;
  }

  static int _gregorianToJulianDay(int year, int month, int day) {
    final a = ((14 - month) / 12).floor();
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    return day +
        ((153 * m + 2) / 5).floor() +
        365 * y +
        (y / 4).floor() -
        (y / 100).floor() +
        (y / 400).floor() -
        32045;
  }

  static DateTime _julianDayToGregorian(int jd) {
    final a = jd + 32044;
    final b = ((4 * a + 3) / 146097).floor();
    final c = a - ((146097 * b) / 4).floor();
    final d = ((4 * c + 3) / 1461).floor();
    final e = c - ((1461 * d) / 4).floor();
    final m = ((5 * e + 2) / 153).floor();
    final day = e - ((153 * m + 2) / 5).floor() + 1;
    final month = m + 3 - 12 * (m / 10).floor();
    final year = 100 * b + d - 4800 + (m / 10).floor();
    return DateTime(year, month, day);
  }

  static HijriDate _julianDayToHijri(int jd) {
    final islamicEpoch = 1948440; // JD of 1 Muharram 1 AH (civil, Friday)
    final l = jd - islamicEpoch + 10632;
    final n = ((l - 1) / 10631).floor();
    final l2 = l - 10631 * n + 354;
    final j = (((10985 - l2) / 5316).floor() * ((50 * l2) / 17719).floor()) +
        ((l2 / 5670).floor() * ((43 * l2) / 15238).floor());
    final l3 = l2 -
        ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        (j / 16).floor() * ((15238 * j) / 43).floor() +
        29;
    final month = ((24 * l3) / 709).floor();
    final day = l3 - ((709 * month) / 24).floor();
    final year = 30 * n + j - 30;
    return HijriDate(year, month, day);
  }

  static int _hijriToJulianDay(int year, int month, int day) {
    final islamicEpoch = 1948440;
    return day +
        ((29.5001 * (month - 1)).ceil()) +
        (year - 1) * 354 +
        ((3 + 11 * year) / 30).floor() +
        islamicEpoch -
        385;
  }
}
