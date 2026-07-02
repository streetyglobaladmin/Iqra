import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/state/app_state.dart';
import 'data/local/db.dart';
import 'data/repositories/pricing_repository.dart';
import 'features/splash/splash_screen.dart';

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
      home: const SplashScreen(),
    );
  }
}
