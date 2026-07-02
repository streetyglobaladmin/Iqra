import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/iqra_logo.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';

/// Full-screen gate shown in place of an entire protected surface
/// (Student dashboard, Parent dashboard, IQRA Studio, Nuerizo Control
/// Center) when the visitor is a guest. This is what makes those
/// dashboards "login required" while everything else in the app stays
/// open — the guest can always back out, nothing traps them.
class GuestLockedScreen extends StatelessWidget {
  final String surfaceName;
  final String message;
  final IconData icon;

  const GuestLockedScreen({
    super.key,
    required this.surfaceName,
    required this.message,
    this.icon = Icons.lock_outline,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final text = IqraText(s);
    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(title: Text(surfaceName)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const IqraLogoMark(size: 56),
                const SizedBox(height: 20),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: s.appCard2,
                    shape: BoxShape.circle,
                    border: Border.all(color: s.appBorder),
                  ),
                  child: Icon(icon, color: IqraTokens.gold, size: 30),
                ),
                const SizedBox(height: 20),
                Text('$surfaceName requires an account',
                    style: text.cardTitle(size: 18), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(message, style: text.bodyDim(size: 13), textAlign: TextAlign.center),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: const Text('Log In'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    ),
                    child: const Text('Create Account'),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Back', style: TextStyle(color: s.appTextDim)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
