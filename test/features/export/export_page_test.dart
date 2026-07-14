import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/features/export/data/export_handoff.dart';
import 'package:stop_motion/features/export/data/export_repository.dart';
import 'package:stop_motion/features/export/domain/export_job.dart';
import 'package:stop_motion/features/export/domain/export_record.dart';
import 'package:stop_motion/features/export/presentation/export_controller.dart';
import 'package:stop_motion/features/export/presentation/export_page.dart';
import 'package:stop_motion/features/export/presentation/export_providers.dart';

import '../../helpers/export_fixtures.dart';

class _PageGateway implements ExportGateway {
  _PageGateway(this.request);
  final ExportRequest request;

  @override
  Future<ExportRequest> createRequest(
    String projectId,
    ExportSettings settings, {
    String? id,
  }) async => request;

  @override
  Future<ExportSettings?> previousSuccessfulSettings(String projectId) async =>
      null;

  @override
  Future<ExportPreflight> preflight(
    String projectId,
    ExportSettings settings,
  ) async => ExportPreflight(
    issues: const <ExportIssue>[],
    estimatedBytes: 2 * 1024 * 1024,
    dimensions: const ExportDimensions(1280, 720),
    duration: const Duration(seconds: 2),
  );

  @override
  Future<ExportResult> run(
    ExportRequest request, {
    required ExportCancellationToken cancellation,
    required void Function(ExportProgress progress) onProgress,
  }) async => ExportResult(
    output: request.output,
    bytes: 4,
    duration: const Duration(seconds: 2),
  );
}

class _PageHandoff implements ExportHandoff {
  @override
  Future<ExportHandoffResult> open(File file) async =>
      ExportHandoffResult.complete;

  @override
  Future<ExportHandoffResult> save(
    File file,
    ExportFormat format, {
    Rect? origin,
  }) async => ExportHandoffResult.complete;

  @override
  Future<ExportHandoffResult> share(File file, {Rect? origin}) async =>
      ExportHandoffResult.complete;
}

void main() {
  testWidgets('export setup exposes formats, estimates, and GIF disclosure', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    late Directory root;
    late ExportRequest request;
    await tester.runAsync(() async {
      root = await Directory.systemTemp.createTemp('export_page_');
      request = await exportRequest(root);
    });
    final ExportController controller = ExportController(
      projectId: 'project-1',
      repository: _PageGateway(request),
      handoff: _PageHandoff(),
    );
    addTearDown(() {
      controller.dispose();
      if (root.existsSync()) root.deleteSync(recursive: true);
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await controller.initialize();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          exportControllerProvider('project-1').overrideWithValue(controller),
          exportHistoryProvider(
            'project-1',
          ).overrideWith((Ref ref) => Stream.value(<ProjectExportRecord>[])),
        ],
        child: const MaterialApp(home: ExportPage(projectId: 'project-1')),
      ),
    );
    await tester.pump();

    expect(find.text('Movie'), findsOneWidget);
    expect(find.text('GIF'), findsOneWidget);
    expect(find.text('Images'), findsOneWidget);
    expect(find.textContaining('1280 x 720'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Export'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('GIF'));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();

    expect(find.text('Audio is not included in GIF files.'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
