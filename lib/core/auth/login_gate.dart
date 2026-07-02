import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/iqra_logo.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';

/// IQRA is guest-first: general Daily/Prayer/Qur'ān features never require
/// an account. Only identity-bound actions (enroll, join a live class,
/// book a teacher, save progress, homework, dashboards, payments,
/// certificates, private messages) are gated. When a guest taps one of
/// those, we show this non-blocking prompt instead of forcing login at
/// app open.
Future<void> showLoginPrompt(
  BuildContext context, {
  String title = 'Sign in required',
  String message = 'Create a free account or sign in to continue — browsing IQRA never requires one.',
}) {
  final s = context.surface;
  final text = IqraText(s);
  return showModalBottomSheet(
    context: context,
    backgroundColor: s.appCard,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IqraLogoMark(size: 48),
            const SizedBox(height: 16),
            Text(title, style: text.cardTitle(size: 18), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, style: text.bodyDim(size: 13), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
                child: const Text('Log In'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const SignupScreen()));
                },
                child: const Text('Create Account'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Not now', style: TextStyle(color: s.appTextDim)),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Gate helper for any protected action. If [isLoggedIn] is true, runs
/// [onAuthenticated] immediately (no interruption). Otherwise shows the
/// login/register prompt and leaves the guest exactly where they were —
/// nothing forces them to authenticate.
void requireLogin(
  BuildContext context, {
  required bool isLoggedIn,
  required VoidCallback onAuthenticated,
  String title = 'Sign in required',
  String message = 'Create a free account or sign in to continue — browsing IQRA never requires one.',
}) {
  if (isLoggedIn) {
    onAuthenticated();
    return;
  }
  showLoginPrompt(context, title: title, message: message);
}
