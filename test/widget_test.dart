// Basic smoke test for the IQRA app shell.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/core/state/app_state.dart';

void main() {
  testWidgets('IqraApp builds without crashing', (WidgetTester tester) async {
    final appState = AppState();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const IqraApp(),
      ),
    );
    await tester.pump();
    // Smoke test only — full bootstrap requires Hive init which happens in main().
  });
}
