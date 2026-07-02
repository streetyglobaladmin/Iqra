import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/iqra_logo.dart';
import '../../core/widgets/ornaments.dart';
import '../../core/state/app_state.dart';
import '../onboarding/onboarding_screen.dart';
import '../hub/hub_shell.dart';

/// Launch flow step 1: a brief brand splash, then guests and signed-in
/// users alike land straight on the guest-accessible IQRA Hub — nobody
/// is forced through login before this point.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1100), _proceed);
  }

  void _proceed() {
    if (!mounted) return;
    final appState = context.read<AppState>();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => appState.onboardingComplete
            ? const HubShell()
            : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IqraTokens.emeraldDeep,
      body: Stack(
        children: [
          const Positioned.fill(child: GeoPatternBackground(opacity: 0.06)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const IqraLogoMark(size: 88),
                const SizedBox(height: 18),
                const IqraWordmark(fontSize: 30),
                const SizedBox(height: 10),
                Text(
                  'Guest-first. Everywhere you are.',
                  style: TextStyle(
                    fontFamily: IqraFonts.sans,
                    fontSize: 12.5,
                    color: IqraTokens.appTextDimDark,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: IqraTokens.gold.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
