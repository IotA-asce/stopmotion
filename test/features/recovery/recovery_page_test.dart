import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('recovery screen presents a safe continue action when clean', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpStopMotionApp(
      tester,
      initialLocation: '/recovery',
      settle: false,
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();

    expect(find.widgetWithText(AppBar, 'Recovery'), findsOneWidget);
    expect(find.text('No recovery needed'), findsOneWidget);
    expect(find.text('Continue to Projects'), findsOneWidget);
  });
}
