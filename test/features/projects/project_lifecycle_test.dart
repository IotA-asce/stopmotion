import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stop_motion/app/app.dart';
import 'package:stop_motion/app/router.dart';
import 'package:stop_motion/core/database/app_database.dart';
import 'package:stop_motion/core/filesystem/project_paths.dart';
import 'package:stop_motion/features/projects/presentation/project_providers.dart';

Future<void> waitForWidget(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
}

void main() {
  testWidgets('creates a project and opens its capture route', (
    WidgetTester tester,
  ) async {
    final Directory root = Directory.systemTemp.createTempSync(
      'project_widget_',
    );
    final AppDatabase database = AppDatabase.memory();
    final ProjectPaths paths = ProjectPaths(
      root: Directory('${root.path}/support'),
      cacheRoot: Directory('${root.path}/cache'),
    );
    final GoRouter router = createAppRouter(initialLocation: '/projects/new');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          projectPathsProvider.overrideWithValue(paths),
        ],
        child: StopMotionApp(router: router),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();

    expect(find.text('New project'), findsOneWidget);
    await tester.ensureVisible(find.text('Create'));
    await tester.tap(find.text('Create'));
    await waitForWidget(tester, find.text('Capture'));

    expect(find.text('Capture'), findsOneWidget);
    expect(find.textContaining('Project:'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pump();
    router.dispose();
    await tester.runAsync(database.close);
    root.deleteSync(recursive: true);
  });
}
