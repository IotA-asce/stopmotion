import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stop_motion/app/app.dart';
import 'package:stop_motion/app/router.dart';
import 'package:stop_motion/features/projects/domain/project.dart';
import 'package:stop_motion/features/projects/domain/project_library_health.dart';
import 'package:stop_motion/features/projects/presentation/project_providers.dart';

void main() {
  Project project({ProjectStatus status = ProjectStatus.draft}) => Project(
    id: 'project',
    title: 'Paper planets',
    aspectRatio: ProjectAspectRatio.widescreen,
    resolution: ProjectResolution.fullHd1080,
    framesPerSecond: 12,
    backgroundColorValue: 0,
    createdAt: DateTime.utc(2026, 7, 14),
    updatedAt: DateTime.utc(2026, 7, 14),
    status: status,
    frameCount: 0,
    durationFrames: 0,
    currentRevision: 0,
  );

  testWidgets('renders damaged-project and low-storage states', (
    WidgetTester tester,
  ) async {
    final GoRouter router = createAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectsProvider.overrideWith(
            (Ref ref) => Stream<List<Project>>.value(<Project>[
              project(status: ProjectStatus.needsRepair),
            ]),
          ),
          projectThumbnailProvider.overrideWith(
            (Ref ref, String projectId) async => null as File?,
          ),
          projectLibraryHealthProvider.overrideWithValue(
            const ProjectLibraryHealth(lowStorage: true),
          ),
        ],
        child: StopMotionApp(router: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Paper planets'), findsOneWidget);
    expect(find.text('Needs repair'), findsOneWidget);
    expect(
      find.text('Storage is running low. Capture and import may stop.'),
      findsOneWidget,
    );
    expect(find.text('Manage storage'), findsOneWidget);

    await tester.tap(find.byTooltip('Dismiss low storage warning'));
    await tester.pump();
    expect(find.text('Manage storage'), findsNothing);
  });
}
