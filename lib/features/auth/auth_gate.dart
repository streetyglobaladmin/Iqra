import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import 'login_screen.dart';
import '../hub/hub_shell.dart';

/// Routes to the Hub if a session exists, otherwise the login screen.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (appState.currentUser != null) {
      return const HubShell();
    }
    return const LoginScreen();
  }
}
