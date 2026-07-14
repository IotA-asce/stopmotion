import 'package:flutter_test/flutter_test.dart';

import '../helpers/accessibility_checks.dart';
import '../helpers/pump_app.dart';

void main() {
  testWidgets('top-level navigation meets Flutter accessibility guidelines', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await pumpStopMotionApp(tester);

    expect(find.text('Projects'), findsWidgets);
    expect(find.text('Settings'), findsOneWidget);
    await expectAccessibilityGuidelines(tester, checkTextContrast: true);
    expectNoLayoutException(tester);

    semantics.dispose();
  });

  testWidgets('settings remains operable at 200 percent text scale', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpStopMotionApp(tester, initialLocation: '/settings');

    expect(find.text('Capture defaults'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Help and troubleshooting'), 200);
    expect(find.text('Help and troubleshooting'), findsOneWidget);
    expectNoLayoutException(tester);
  });

  testWidgets('recovery announces a clear safe continuation state', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await pumpStopMotionApp(
      tester,
      initialLocation: '/recovery',
      settle: false,
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();

    expect(find.text('Continue to Projects'), findsOneWidget);
    expectNoLayoutException(tester);
    semantics.dispose();
  });
}
