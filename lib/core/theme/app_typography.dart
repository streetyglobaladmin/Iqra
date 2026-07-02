import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Font family names, matching the fonts bundled in pubspec.yaml.
/// Mirrors the handoff's Amiri / Manrope / Cormorant Garamond / Inter Tight.
class IqraFonts {
  IqraFonts._();
  static const arabic = 'Amiri';
  static const sans = 'Manrope';
  static const display = 'CormorantGaramond';
  static const numeric = 'InterTight';
  static const mono = 'JetBrainsMono';
}

/// Recurring type presets from the handoff, parameterised by the current
/// [IqraSurface] so they always read correctly in light or dark mode.
class IqraText {
  final IqraSurface surface;
  const IqraText(this.surface);

  TextStyle get eyebrow => TextStyle(
        fontFamily: IqraFonts.sans,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.6,
        color: IqraTokens.gold,
      );

  TextStyle get sectionHeader => TextStyle(
        fontFamily: IqraFonts.sans,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.5,
        color: IqraTokens.gold,
      );

  TextStyle cardTitle({double size = 18}) => TextStyle(
        fontFamily: IqraFonts.display,
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: surface.appText,
      );

  TextStyle body({double size = 13, FontWeight weight = FontWeight.w500}) =>
      TextStyle(
        fontFamily: IqraFonts.sans,
        fontSize: size,
        fontWeight: weight,
        color: surface.appText,
      );

  TextStyle bodyDim({double size = 12}) => TextStyle(
        fontFamily: IqraFonts.sans,
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: surface.appTextDim,
      );

  TextStyle metaDim({double size = 11}) => TextStyle(
        fontFamily: IqraFonts.sans,
        fontSize: size,
        color: surface.appTextDim,
      );

  TextStyle arabic({double size = 26, FontWeight weight = FontWeight.w400}) =>
      TextStyle(
        fontFamily: IqraFonts.arabic,
        fontSize: size,
        fontWeight: weight,
        color: surface.appText,
        height: 2.0,
      );

  TextStyle numeric({double size = 44, FontWeight weight = FontWeight.w200}) =>
      TextStyle(
        fontFamily: IqraFonts.numeric,
        fontSize: size,
        fontWeight: weight,
        color: surface.appText,
        letterSpacing: -0.4,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  TextStyle displayHeadline({double size = 32}) => TextStyle(
        fontFamily: IqraFonts.display,
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: surface.appText,
        height: 1.15,
      );
}
