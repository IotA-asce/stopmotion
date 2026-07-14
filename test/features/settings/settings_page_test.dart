import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('settings exposes persistent configuration sections', (
    WidgetTester tester,
  ) async {
    await pumpStopMotionApp(tester, initialLocation: '/settings');

    expect(find.text('Capture defaults'), findsOneWidget);
    expect(find.text('Export defaults'), findsOneWidget);
    expect(find.text('Accessibility'), findsOneWidget);
    expect(find.text('Storage'), findsOneWidget);
    expect(find.text('Privacy'), findsOneWidget);
  });

  testWidgets('settings subroutes render stable pages', (
    WidgetTester tester,
  ) async {
    await pumpStopMotionApp(tester, initialLocation: '/settings/capture');

    expect(find.widgetWithText(AppBar, 'Capture defaults'), findsOneWidget);
    expect(find.text('Volume-button shutter'), findsOneWidget);
  });
}
