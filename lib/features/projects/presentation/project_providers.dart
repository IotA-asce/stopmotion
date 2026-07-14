import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/filesystem/project_paths.dart';
import '../../../core/recovery/operation_journal.dart';
import '../../onboarding/data/onboarding_repository.dart';
import '../data/project_repository.dart';
import '../data/project_thumbnail_repository.dart';
import '../domain/project.dart';
import '../domain/project_library_health.dart';

final appDatabaseProvider = Provider<AppDatabase>((Ref ref) {
  final AppDatabase database = AppDatabase.memory();
  ref.onDispose(() => unawaited(database.close()));
  return database;
});

final projectPathsProvider = Provider<ProjectPaths>((Ref ref) {
  final String root = '${Directory.systemTemp.path}/stop_motion_test';
  return ProjectPaths(
    root: Directory(root),
    cacheRoot: Directory('${root}_cache'),
  );
});

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (Ref ref) => MemoryOnboardingRepository(),
);

final operationJournalProvider = Provider<OperationJournalRepository>(
  (Ref ref) => OperationJournalRepository(ref.watch(appDatabaseProvider)),
);

final projectRepositoryProvider = Provider<ProjectRepository>((Ref ref) {
  return ProjectRepository(
    database: ref.watch(appDatabaseProvider),
    paths: ref.watch(projectPathsProvider),
    journal: ref.watch(operationJournalProvider),
  );
});

final projectThumbnailRepositoryProvider = Provider<ProjectThumbnailRepository>(
  (Ref ref) => ProjectThumbnailRepository(ref.watch(projectPathsProvider)),
);

final projectThumbnailProvider = FutureProvider.autoDispose
    .family<File?, String>(
      (Ref ref, String projectId) =>
          ref.watch(projectThumbnailRepositoryProvider).read(projectId),
    );

final projectLibraryHealthProvider = Provider<ProjectLibraryHealth>(
  (Ref ref) => const ProjectLibraryHealth(),
);

class ProjectLibraryQuery {
  const ProjectLibraryQuery({
    this.search = '',
    this.sort = ProjectSort.lastEdited,
    this.filter = ProjectFilter.all,
    this.grid = true,
  });

  final String search;
  final ProjectSort sort;
  final ProjectFilter filter;
  final bool grid;

  ProjectLibraryQuery copyWith({
    String? search,
    ProjectSort? sort,
    ProjectFilter? filter,
    bool? grid,
  }) {
    return ProjectLibraryQuery(
      search: search ?? this.search,
      sort: sort ?? this.sort,
      filter: filter ?? this.filter,
      grid: grid ?? this.grid,
    );
  }
}

class ProjectLibraryQueryNotifier extends Notifier<ProjectLibraryQuery> {
  @override
  ProjectLibraryQuery build() => const ProjectLibraryQuery();

  void setSearch(String value) => state = state.copyWith(search: value);
  void setSort(ProjectSort value) => state = state.copyWith(sort: value);
  void setFilter(ProjectFilter value) => state = state.copyWith(filter: value);
  void toggleGrid() => state = state.copyWith(grid: !state.grid);
}

final projectLibraryQueryProvider =
    NotifierProvider<ProjectLibraryQueryNotifier, ProjectLibraryQuery>(
      ProjectLibraryQueryNotifier.new,
    );

final projectsProvider = StreamProvider.autoDispose<List<Project>>((Ref ref) {
  final ProjectLibraryQuery query = ref.watch(projectLibraryQueryProvider);
  return ref
      .watch(projectRepositoryProvider)
      .watchProjects(
        sort: query.sort,
        filter: query.filter,
        queryText: query.search,
      );
});

final trashedProjectsProvider = StreamProvider.autoDispose<List<Project>>(
  (Ref ref) => ref.watch(projectRepositoryProvider).watchTrashedProjects(),
);

class ProjectActions {
  const ProjectActions(this._repository);

  final ProjectRepository _repository;

  Future<Project> create(ProjectDraft draft) =>
      _repository.createProject(draft);
  Future<void> rename(String id, String title) =>
      _repository.renameProject(id, title);
  Future<Project> duplicate(String id) => _repository.duplicateProject(id);
  Future<void> moveToTrash(String id) => _repository.moveToTrash(id);
  Future<void> restore(String id) => _repository.restoreFromTrash(id);
  Future<void> permanentlyDelete(String id) =>
      _repository.permanentlyDelete(id);
}

final projectActionsProvider = Provider<ProjectActions>(
  (Ref ref) => ProjectActions(ref.watch(projectRepositoryProvider)),
);
