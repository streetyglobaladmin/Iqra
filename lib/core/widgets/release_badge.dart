import 'package:flutter/material.dart';
import '../../models/release_state.dart';
import '../theme/app_colors.dart';

Color releaseStateColor(ReleaseState state) {
  switch (state) {
    case ReleaseState.hidden:
      return IqraTokens.releaseHidden;
    case ReleaseState.internal:
      return IqraTokens.releaseInternal;
    case ReleaseState.beta:
      return IqraTokens.releaseBeta;
    case ReleaseState.public:
      return IqraTokens.releasePublic;
    case ReleaseState.premium:
      return IqraTokens.releasePremium;
    case ReleaseState.enterprise:
      return IqraTokens.releaseEnterprise;
  }
}

/// Small pill badge showing a feature's release state — used in the
/// admin panel and, where relevant, as a "Beta" label in end-user UI.
class ReleaseBadge extends StatelessWidget {
  final ReleaseState state;
  final double fontSize;

  const ReleaseBadge({super.key, required this.state, this.fontSize = 10});

  @override
  Widget build(BuildContext context) {
    final color = releaseStateColor(state);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        state.label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
