import 'package:flutter/material.dart';

/// IQRA design tokens — ported 1:1 from the design handoff `tokens.js`
/// (window.IQRA). Source of truth for all colour usage in the app.
class IqraTokens {
  IqraTokens._();

  // ── Surface / ink ─────────────────────────────────────────────
  static const ink = Color(0xFF0A1F18);
  static const inkSoft = Color(0xFF0F2A20);
  static const emeraldDeep = Color(0xFF0A2A1F);
  static const emeraldDp2 = Color(0xFF0E3527);
  static const emerald = Color(0xFF0E5C4A);
  static const emeraldLt = Color(0xFF1B8A6E);

  // ── Cream / parchment (light surface) ───────────────────────────
  static const parchment = Color(0xFFF6EEDD);
  static const parchment2 = Color(0xFFEEE4CE);
  static const cream = Color(0xFFFFF8E8);

  // ── Gold ─────────────────────────────────────────────────────
  static const goldLt = Color(0xFFEBC97A);
  static const gold = Color(0xFFD4A94A);
  static const goldDk = Color(0xFFA8822E);

  // ── Jewel accents ────────────────────────────────────────────
  static const ruby = Color(0xFF8E2D3A);
  static const rubyLt = Color(0xFFC26B7A);
  static const lapis = Color(0xFF2A4A8A);
  static const lapisLt = Color(0xFF4A6FB5);
  static const saffron = Color(0xFFD98E2B);
  static const rose = Color(0xFFC26B7A);

  // ── Dark app-surface tokens ─────────────────────────────────
  static const appBgDark = Color(0xFF062018);
  static const appCardDark = Color(0xFF0E3527);
  static const appCard2Dark = Color(0xFF0A2A1F);
  static const appCard3Dark = Color(0xFF103E2E);
  static const appBorderDark = Color(0x38D4A94A); // 22%
  static const appBorderSoftDark = Color(0x1FD4A94A); // 12%
  static const appTextDark = Color(0xFFF4E9C9);
  static const appTextDimDark = Color(0x9EF4E9C9); // 62%
  static const appTextMutedDark = Color(0x6BF4E9C9); // 42%

  // ── Light app-surface tokens (parchment alternative, WCAG-checked) ─
  static const appBgLight = Color(0xFFF7F4EC);
  static const appCardLight = Color(0xFFFFFFFF);
  static const appCard2Light = Color(0xFFF1E9D6);
  static const appCard3Light = Color(0xFFFBF7EC);
  static const appBorderLight = Color(0x3DA8822E); // 24%
  static const appBorderSoftLight = Color(0x1FA8822E); // 12%
  static const appTextLight = Color(0xFF14201B);
  static const appTextDimLight = Color(0xB314201B); // 70%
  static const appTextMutedLight = Color(0x8014201B); // 50%

  // ── Release-state badge colours (feature flags) ───────────────
  static const releaseHidden = Color(0xFF8A8A8A);
  static const releaseInternal = Color(0xFF4A6FB5);
  static const releaseBeta = Color(0xFFD98E2B);
  static const releasePublic = Color(0xFF1B8A6E);
  static const releasePremium = Color(0xFFD4A94A);
  static const releaseEnterprise = Color(0xFF8E2D3A);

  // ── Semantic states ────────────────────────────────────────
  static const stateSuccess = Color(0xFF1B8A6E);
  static const stateWarn = Color(0xFFD98E2B);
  static const stateDanger = Color(0xFFB3423B);
  static const stateInfo = Color(0xFF4A6FB5);

  /// Time-of-day sky gradients used on Home hero panels.
  static const skyFajr = [
    Color(0xFF2B2541),
    Color(0xFF5C3E5E),
    Color(0xFFC26B7A),
    Color(0xFFE8C892),
  ];
  static const skyDhuhr = [
    Color(0xFF1B8A6E),
    Color(0xFF4FB39A),
    Color(0xFFE8C892),
  ];
  static const skyAsr = [
    Color(0xFFB66A1F),
    Color(0xFFD98E2B),
    Color(0xFFF0CE8E),
  ];
  static const skyMaghrib = [
    Color(0xFF2A1530),
    Color(0xFF6B2845),
    Color(0xFFC75B4A),
    Color(0xFFE8945C),
  ];
  static const skyIsha = [
    Color(0xFF06101F),
    Color(0xFF122844),
    Color(0xFF2A4A8A),
  ];

  static const _jewelCycle = [ruby, lapis, saffron, emeraldLt, rubyLt, lapisLt];
  static Color jewelForIndex(int i) => _jewelCycle[i % _jewelCycle.length];

  static List<Color> skyFor(String prayerKey) {
    switch (prayerKey) {
      case 'fajr':
        return skyFajr;
      case 'dhuhr':
        return skyDhuhr;
      case 'asr':
        return skyAsr;
      case 'maghrib':
        return skyMaghrib;
      case 'isha':
        return skyIsha;
      default:
        return skyDhuhr;
    }
  }
}

/// A [ThemeExtension] exposing the IQRA "app surface" tokens so any
/// widget can read the correct light/dark values via `Theme.of(context)`.
@immutable
class IqraSurface extends ThemeExtension<IqraSurface> {
  final Color appBg;
  final Color appCard;
  final Color appCard2;
  final Color appCard3;
  final Color appBorder;
  final Color appBorderSoft;
  final Color appText;
  final Color appTextDim;
  final Color appTextMuted;
  final bool isDark;

  const IqraSurface({
    required this.appBg,
    required this.appCard,
    required this.appCard2,
    required this.appCard3,
    required this.appBorder,
    required this.appBorderSoft,
    required this.appText,
    required this.appTextDim,
    required this.appTextMuted,
    required this.isDark,
  });

  static const dark = IqraSurface(
    appBg: IqraTokens.appBgDark,
    appCard: IqraTokens.appCardDark,
    appCard2: IqraTokens.appCard2Dark,
    appCard3: IqraTokens.appCard3Dark,
    appBorder: IqraTokens.appBorderDark,
    appBorderSoft: IqraTokens.appBorderSoftDark,
    appText: IqraTokens.appTextDark,
    appTextDim: IqraTokens.appTextDimDark,
    appTextMuted: IqraTokens.appTextMutedDark,
    isDark: true,
  );

  static const light = IqraSurface(
    appBg: IqraTokens.appBgLight,
    appCard: IqraTokens.appCardLight,
    appCard2: IqraTokens.appCard2Light,
    appCard3: IqraTokens.appCard3Light,
    appBorder: IqraTokens.appBorderLight,
    appBorderSoft: IqraTokens.appBorderSoftLight,
    appText: IqraTokens.appTextLight,
    appTextDim: IqraTokens.appTextDimLight,
    appTextMuted: IqraTokens.appTextMutedLight,
    isDark: false,
  );

  @override
  IqraSurface copyWith({
    Color? appBg,
    Color? appCard,
    Color? appCard2,
    Color? appCard3,
    Color? appBorder,
    Color? appBorderSoft,
    Color? appText,
    Color? appTextDim,
    Color? appTextMuted,
    bool? isDark,
  }) {
    return IqraSurface(
      appBg: appBg ?? this.appBg,
      appCard: appCard ?? this.appCard,
      appCard2: appCard2 ?? this.appCard2,
      appCard3: appCard3 ?? this.appCard3,
      appBorder: appBorder ?? this.appBorder,
      appBorderSoft: appBorderSoft ?? this.appBorderSoft,
      appText: appText ?? this.appText,
      appTextDim: appTextDim ?? this.appTextDim,
      appTextMuted: appTextMuted ?? this.appTextMuted,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  IqraSurface lerp(ThemeExtension<IqraSurface>? other, double t) {
    if (other is! IqraSurface) return this;
    return IqraSurface(
      appBg: Color.lerp(appBg, other.appBg, t)!,
      appCard: Color.lerp(appCard, other.appCard, t)!,
      appCard2: Color.lerp(appCard2, other.appCard2, t)!,
      appCard3: Color.lerp(appCard3, other.appCard3, t)!,
      appBorder: Color.lerp(appBorder, other.appBorder, t)!,
      appBorderSoft: Color.lerp(appBorderSoft, other.appBorderSoft, t)!,
      appText: Color.lerp(appText, other.appText, t)!,
      appTextDim: Color.lerp(appTextDim, other.appTextDim, t)!,
      appTextMuted: Color.lerp(appTextMuted, other.appTextMuted, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

extension IqraSurfaceX on BuildContext {
  IqraSurface get surface =>
      Theme.of(this).extension<IqraSurface>() ?? IqraSurface.dark;
}
