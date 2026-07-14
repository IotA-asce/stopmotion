import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('primary destinations expose readable labels', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpStopMotionApp(tester);

    expect(find.text('Projects'), findsWidgets);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.byTooltip('Search projects'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('shell remains usable at 200 percent text scale', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpStopMotionApp(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('New project'), findsOneWidget);
  });
}
