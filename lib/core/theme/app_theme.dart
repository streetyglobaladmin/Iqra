import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Builds the light and dark [ThemeData] for the whole IQRA ecosystem.
/// Both themes are fully readable — light mode uses the parchment/ink
/// tokens, dark mode uses the deep-emerald tokens from the handoff.
class IqraTheme {
  IqraTheme._();

  static ThemeData dark() => _build(IqraSurface.dark, Brightness.dark);
  static ThemeData light() => _build(IqraSurface.light, Brightness.light);

  static ThemeData _build(IqraSurface s, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = isDark
        ? const ColorScheme.dark(
            primary: IqraTokens.gold,
            onPrimary: IqraTokens.ink,
            secondary: IqraTokens.emeraldLt,
            onSecondary: Colors.white,
            surface: IqraTokens.appCardDark,
            onSurface: IqraTokens.appTextDark,
            error: IqraTokens.stateDanger,
            onError: Colors.white,
          )
        : const ColorScheme.light(
            primary: IqraTokens.emerald,
            onPrimary: Colors.white,
            secondary: IqraTokens.goldDk,
            onSecondary: Colors.white,
            surface: IqraTokens.appCardLight,
            onSurface: IqraTokens.appTextLight,
            error: IqraTokens.stateDanger,
            onError: Colors.white,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: s.appBg,
      colorScheme: colorScheme,
      fontFamily: IqraFonts.sans,
      extensions: [s],
      appBarTheme: AppBarTheme(
        backgroundColor: s.appBg,
        foregroundColor: s.appText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: IqraFonts.display,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: s.appText,
        ),
      ),
      cardTheme: CardThemeData(
        color: s.appCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: s.appBorder, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(color: s.appBorderSoft, thickness: 1),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: s.appText, fontFamily: IqraFonts.sans),
        bodyMedium: TextStyle(color: s.appText, fontFamily: IqraFonts.sans),
        bodySmall: TextStyle(color: s.appTextDim, fontFamily: IqraFonts.sans),
        titleLarge: TextStyle(
          color: s.appText,
          fontFamily: IqraFonts.display,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: s.appText,
          fontFamily: IqraFonts.display,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: IqraTokens.gold,
          foregroundColor: IqraTokens.ink,
          textStyle: const TextStyle(
            fontFamily: IqraFonts.sans,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.3,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: s.appText,
          side: BorderSide(color: s.appBorder),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: IqraTokens.gold,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: s.appCard2,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: s.appBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: s.appBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: IqraTokens.gold, width: 1.5),
        ),
        hintStyle: TextStyle(color: s.appTextMuted),
        labelStyle: TextStyle(color: s.appTextDim),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? IqraTokens.gold
                : s.appTextMuted),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? IqraTokens.gold.withValues(alpha: 0.35)
                : s.appBorder),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: s.appCard,
        selectedItemColor: IqraTokens.gold,
        unselectedItemColor: s.appTextMuted,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: s.appCard,
        indicatorColor: IqraTokens.gold.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? IqraTokens.gold
                : s.appTextMuted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? IqraTokens.gold
                : s.appTextMuted,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: s.appCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: s.appBorder),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: s.appCard3,
        contentTextStyle: TextStyle(color: s.appText),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: IqraTokens.gold,
        unselectedLabelColor: s.appTextMuted,
        indicatorColor: IqraTokens.gold,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: s.appCard2,
        labelStyle: TextStyle(color: s.appText, fontSize: 12),
        side: BorderSide(color: s.appBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
