import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/state/app_state.dart';
import 'data/local/db.dart';
import 'data/repositories/pricing_repository.dart';
import 'features/splash/splash_screen.dart';
import 'features/studio/studio_shell.dart';
import 'features/admin/admin_shell.dart';
import 'features/website/public_website_screen.dart';

/// Build-time deployment target — lets ONE codebase produce four separate
/// web builds for the four IQRA subdomains without any code branching at
/// runtime and without maintaining separate projects:
///
///   flutter build web --dart-define=IQRA_TARGET=app      -> iqra.nuerizo.com (default)
///   flutter build web --dart-define=IQRA_TARGET=studio   -> studio.iqra.nuerizo.com
///   flutter build web --dart-define=IQRA_TARGET=control  -> control.nuerizo.com
///   flutter build web --dart-define=IQRA_TARGET=website  -> public marketing site
///
/// Guest-first rule still applies on every target: Studio/Control targets
/// show their own GuestLockedScreen guard (already built into
/// StudioShell/AdminShell) instead of a forced login screen.
const String iqraTarget = String.fromEnvironment('IQRA_TARGET', defaultValue: 'app');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Db.init();
  await PricingRepository.instance.seedIfEmpty();

  final appState = AppState();
  await appState.bootstrap();

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const IqraApp(),
    ),
  );
}

class IqraApp extends StatelessWidget {
  const IqraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return MaterialApp(
      title: 'IQRA',
      debugShowCheckedModeBanner: false,
      theme: IqraTheme.light(),
      darkTheme: IqraTheme.dark(),
      themeMode: appState.themeMode,
      // Guest-first launch flow: Splash -> (onboarding if first run) ->
      // guest-accessible IQRA Hub. Login is never forced here; it is only
      // requested when a guest taps a protected feature (see
      // core/auth/login_gate.dart and core/auth/guest_locked_screen.dart).
      //
      // For the studio/control/website subdomain builds, skip splash and
      // land directly on that surface (each already self-guards guests
      // via GuestLockedScreen where required).
      home: switch (iqraTarget) {
        'studio' => const StudioShell(),
        'control' => const AdminShell(),
        'website' => const PublicWebsiteScreen(),
        _ => const SplashScreen(),
      },
    );
  }
}
