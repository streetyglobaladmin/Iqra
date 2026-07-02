import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// The IQRA logo mark rendered from the bundled brand asset. Falls back
/// to a typographic wordmark if the asset is unavailable.
class IqraLogoMark extends StatelessWidget {
  final double size;
  const IqraLogoMark({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/iqra-logo-mark.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: IqraTokens.gold, width: 1.5),
        ),
        child: Center(
          child: Text(
            'ق',
            style: TextStyle(
              fontFamily: IqraFonts.arabic,
              fontSize: size * 0.5,
              color: IqraTokens.gold,
            ),
          ),
        ),
      ),
    );
  }
}

class IqraWordmark extends StatelessWidget {
  final double fontSize;
  final Color? color;
  const IqraWordmark({super.key, this.fontSize = 22, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      'IQRA',
      style: TextStyle(
        fontFamily: IqraFonts.display,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
        color: color ?? IqraTokens.gold,
      ),
    );
  }
}
