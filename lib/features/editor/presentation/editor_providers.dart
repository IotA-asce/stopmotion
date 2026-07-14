import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/media/frame_renderer.dart';
import '../../projects/presentation/project_providers.dart';
import '../data/editor_repository.dart';
import 'editor_controller.dart';

final Provider<EditorRepository> editorRepositoryProvider =
    Provider<EditorRepository>((Ref ref) {
      return EditorRepository(database: ref.watch(appDatabaseProvider));
    });

final Provider<FramePreviewCache> framePreviewCacheProvider =
    Provider<FramePreviewCache>((Ref ref) => FramePreviewCache());

final editorControllerProvider = Provider.autoDispose
    .family<EditorController, String>((Ref ref, String projectId) {
      final EditorController controller = EditorController(
        projectId: projectId,
        repository: ref.watch(editorRepositoryProvider),
        projects: ref.watch(projectRepositoryProvider),
      );
      ref.onDispose(controller.dispose);
      unawaited(controller.initialize());
      return controller;
    });
