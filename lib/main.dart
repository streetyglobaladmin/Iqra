import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/state/app_state.dart';
import 'data/local/db.dart';
import 'data/repositories/pricing_repository.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/auth_gate.dart';

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
      home: appState.onboardingComplete
          ? const AuthGate()
          : const OnboardingScreen(),
    );
  }
}
