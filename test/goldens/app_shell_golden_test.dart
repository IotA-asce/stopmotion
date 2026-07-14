import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stop_motion/app/app.dart';
import 'package:stop_motion/app/router.dart';

void main() {
  const Key goldenKey = Key('app-shell-golden');

  Future<void> pumpGolden(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final GoRouter router = createAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        child: RepaintBoundary(
          key: goldenKey,
          child: StopMotionApp(router: router),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('phone Projects shell matches approved composition', (
    WidgetTester tester,
  ) async {
    await pumpGolden(tester, const Size(390, 844));
    await expectLater(
      find.byKey(goldenKey),
      matchesGoldenFile('files/app_shell_phone.png'),
    );
  }, skip: !Platform.isMacOS);

  testWidgets('tablet Projects shell matches approved composition', (
    WidgetTester tester,
  ) async {
    await pumpGolden(tester, const Size(900, 700));
    await expectLater(
      find.byKey(goldenKey),
      matchesGoldenFile('files/app_shell_tablet.png'),
    );
  }, skip: !Platform.isMacOS);
}
