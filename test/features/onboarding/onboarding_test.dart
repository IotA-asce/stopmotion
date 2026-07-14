import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stop_motion/app/app.dart';
import 'package:stop_motion/app/router.dart';
import 'package:stop_motion/features/onboarding/data/onboarding_repository.dart';
import 'package:stop_motion/features/projects/presentation/project_providers.dart';

void main() {
  testWidgets('onboarding explains permissions without requesting them', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final MemoryOnboardingRepository onboarding = MemoryOnboardingRepository(
      complete: false,
    );
    final GoRouter router = createAppRouter(
      initialLocation: AppRoutes.onboarding,
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [onboardingRepositoryProvider.overrideWithValue(onboarding)],
        child: StopMotionApp(router: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Start creating'));
    await tester.tap(find.text('Start creating'));
    await tester.pumpAndSettle();

    expect(find.text('Camera access'), findsOneWidget);
    expect(find.text('Microphone access'), findsOneWidget);
    expect(await onboarding.isComplete(), isFalse);

    await tester.ensureVisible(find.text('Not now'));
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    expect(await onboarding.isComplete(), isTrue);
    expect(find.text('Projects'), findsWidgets);
  });
}
