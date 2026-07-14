import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('opens Projects by default with phone navigation', (
    WidgetTester tester,
  ) async {
    await pumpStopMotionApp(tester);

    expect(find.text('Projects'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('uses navigation rail on tablet constraints', (
    WidgetTester tester,
  ) async {
    await pumpStopMotionApp(tester, size: const Size(900, 700));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('switches top-level branches', (WidgetTester tester) async {
    await pumpStopMotionApp(tester);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Settings'), findsOneWidget);
  });

  testWidgets('resolves workspace path parameters', (
    WidgetTester tester,
  ) async {
    await pumpStopMotionApp(
      tester,
      initialLocation: '/project/project-123/edit',
    );

    expect(find.text('Editor unavailable'), findsOneWidget);
    expect(find.textContaining('Editor could not open'), findsOneWidget);
  });

  testWidgets('shows explicit page for unknown routes', (
    WidgetTester tester,
  ) async {
    await pumpStopMotionApp(tester, initialLocation: '/missing');

    expect(find.text('Page not found'), findsOneWidget);
    expect(find.text('Go to Projects'), findsOneWidget);
  });
}
