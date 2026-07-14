import 'package:flutter_test/flutter_test.dart';

Future<void> expectAccessibilityGuidelines(
  WidgetTester tester, {
  bool checkTextContrast = false,
}) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  if (checkTextContrast) {
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }
}

void expectNoLayoutException(WidgetTester tester) {
  expect(tester.takeException(), isNull);
}
