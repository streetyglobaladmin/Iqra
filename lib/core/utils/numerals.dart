/// Converts numbers to Western (0-9) or Arabic-Indic (٠-٩) numerals.
/// Per the build requirement: Western numerals are the default everywhere
/// unless the user explicitly opts into Arabic numerals in Settings.
class Numerals {
  Numerals._();

  static const _arabicIndic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  static String format(int number, {required bool useArabic}) {
    final s = number.toString();
    if (!useArabic) return s;
    return s.split('').map((c) {
      final d = int.tryParse(c);
      return d != null ? _arabicIndic[d] : c;
    }).join();
  }

  static String formatString(String numericString, {required bool useArabic}) {
    if (!useArabic) return numericString;
    return numericString.split('').map((c) {
      final d = int.tryParse(c);
      return d != null ? _arabicIndic[d] : c;
    }).join();
  }

  /// Formats a two-digit-padded time component, e.g. "05" or "٠٥".
  static String pad2(int number, {required bool useArabic}) {
    final s = number.toString().padLeft(2, '0');
    return formatString(s, useArabic: useArabic);
  }
}
