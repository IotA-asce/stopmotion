import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/confirm_action_dialog.dart';
import '../domain/project.dart';
import 'create_project_page.dart';
import 'project_details_dialog.dart';
import 'project_providers.dart';

enum _ProjectMenuAction { rename, duplicate, details, delete }

class ProjectsPage extends ConsumerStatefulWidget {
  const ProjectsPage({super.key});

  @override
  ConsumerState<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends ConsumerState<ProjectsPage> {
  bool _searching = false;
  bool _lowStorageDismissed = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() => _searching = !_searching);
    if (!_searching) {
      _searchController.clear();
      ref.read(projectLibraryQueryProvider.notifier).setSearch('');
    }
  }

  Future<void> _handleAction(Project project, _ProjectMenuAction action) async {
    switch (action) {
      case _ProjectMenuAction.rename:
        await _rename(project);
      case _ProjectMenuAction.duplicate:
        await _runWithMessage(
          () => ref.read(projectActionsProvider).duplicate(project.id),
          success: 'Project duplicated.',
        );
      case _ProjectMenuAction.details:
        await showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          isScrollControlled: true,
          builder: (BuildContext context) => ProjectDetailsDialog(
            project: project,
            onRename: () => _rename(project),
            onDuplicate: () => _runWithMessage(
              () => ref.read(projectActionsProvider).duplicate(project.id),
              success: 'Project duplicated.',
            ),
            onDelete: () => _delete(project),
          ),
        );
      case _ProjectMenuAction.delete:
        await _delete(project);
    }
  }

  Future<void> _rename(Project project) async {
    final TextEditingController controller = TextEditingController(
      text: project.title,
    );
    final String? title = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Rename project'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 120,
          decoration: const InputDecoration(labelText: 'Title'),
          onSubmitted: (String value) => Navigator.pop(context, value),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (title != null && title.trim().isNotEmpty) {
      await _runWithMessage(
        () => ref.read(projectActionsProvider).rename(project.id, title),
        success: 'Project renamed.',
      );
    }
  }

  Future<void> _delete(Project project) async {
    final bool confirmed = await showConfirmActionDialog(
      context,
      title: 'Move ${project.title} to trash?',
      message: 'You can restore this project for seven days.',
      confirmLabel: 'Move to trash',
      destructive: true,
    );
    if (!confirmed) {
      return;
    }
    await ref.read(projectActionsProvider).moveToTrash(project.id);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${project.title} moved to trash.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            ref.read(projectActionsProvider).restore(project.id);
          },
        ),
      ),
    );
  }

  Future<void> _runWithMessage(
    Future<Object?> Function() action, {
    required String success,
  }) async {
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(success)));
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Action failed: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProjectLibraryQuery query = ref.watch(projectLibraryQueryProvider);
    final AsyncValue<List<Project>> projects = ref.watch(projectsProvider);
    final bool showLowStorage =
        ref.watch(projectLibraryHealthProvider).lowStorage &&
        !_lowStorageDismissed;

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search projects',
                  border: InputBorder.none,
                ),
                onChanged: ref
                    .read(projectLibraryQueryProvider.notifier)
                    .setSearch,
              )
            : const Text('Projects'),
        leading: _searching
            ? IconButton(
                onPressed: _toggleSearch,
                tooltip: 'Close search',
                icon: const Icon(Icons.arrow_back),
              )
            : null,
        actions: <Widget>[
          IconButton(
            onPressed: _toggleSearch,
            tooltip: _searching ? 'Clear search' : 'Search projects',
            icon: Icon(_searching ? Icons.close : Icons.search),
          ),
          IconButton(
            onPressed: ref
                .read(projectLibraryQueryProvider.notifier)
                .toggleGrid,
            tooltip: query.grid ? 'Use list view' : 'Use grid view',
            icon: Icon(query.grid ? Icons.view_list : Icons.grid_view),
          ),
          IconButton(
            onPressed: _showTrash,
            tooltip: 'Review trash',
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          if (showLowStorage)
            MaterialBanner(
              content: const Text(
                'Storage is running low. Capture and import may stop.',
              ),
              leading: const Icon(Icons.sd_storage_outlined),
              actions: <Widget>[
                TextButton(
                  onPressed: () => context.go(AppRoutes.settings),
                  child: const Text('Manage storage'),
                ),
                IconButton(
                  onPressed: () => setState(() => _lowStorageDismissed = true),
                  tooltip: 'Dismiss low storage warning',
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          _ProjectToolbar(query: query),
          const Divider(height: 1),
          Expanded(
            child: projects.when(
              loading: () => const AppLoadingView(label: 'Loading projects'),
              error: (Object error, StackTrace stackTrace) => AppEmptyView(
                icon: Icons.error_outline,
                title: 'Could not load projects',
                message: error.toString(),
                action: FilledButton(
                  onPressed: () => ref.invalidate(projectsProvider),
                  child: const Text('Try again'),
                ),
              ),
              data: (List<Project> items) {
                if (items.isEmpty) {
                  final bool filtered =
                      query.search.isNotEmpty ||
                      query.filter != ProjectFilter.all;
                  return AppEmptyView(
                    icon: filtered
                        ? Icons.search_off
                        : Icons.movie_creation_outlined,
                    title: filtered
                        ? 'No matching projects'
                        : 'Create your first film',
                    message: filtered
                        ? 'Try a different search or filter.'
                        : 'Start a project to capture or import your first frames.',
                    action: filtered
                        ? OutlinedButton(
                            onPressed: () {
                              _searchController.clear();
                              final ProjectLibraryQueryNotifier notifier = ref
                                  .read(projectLibraryQueryProvider.notifier);
                              notifier.setSearch('');
                              notifier.setFilter(ProjectFilter.all);
                            },
                            child: const Text('Clear filters'),
                          )
                        : FilledButton.icon(
                            onPressed: _showCreateProject,
                            icon: const Icon(Icons.add),
                            label: const Text('New project'),
                          ),
                  );
                }
                return _ProjectCollection(
                  projects: items,
                  grid: query.grid,
                  onOpen: (Project project) => context.push(
                    project.status == ProjectStatus.needsRepair
                        ? AppRoutes.recovery
                        : project.frameCount == 0
                        ? AppRoutes.capture(project.id)
                        : AppRoutes.edit(project.id),
                  ),
                  onAction: _handleAction,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateProject,
        icon: const Icon(Icons.add),
        label: const Text('New project'),
      ),
    );
  }

  Future<void> _showTrash() => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (BuildContext context) => const _TrashSheet(),
  );

  Future<void> _showCreateProject() async {
    final Project? project = await showModalBottomSheet<Project>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext sheetContext) => FractionallySizedBox(
        heightFactor: 0.92,
        child: CreateProjectPage(
          onCreated: (Project project) => Navigator.pop(sheetContext, project),
        ),
      ),
    );
    if (project != null && mounted) {
      await context.push<void>(AppRoutes.capture(project.id));
    }
  }
}

class _TrashSheet extends ConsumerWidget {
  const _TrashSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Project>> projects = ref.watch(
      trashedProjectsProvider,
    );
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.65,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Trash',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Close trash',
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: projects.when(
                loading: () => const AppLoadingView(label: 'Loading trash'),
                error: (Object error, StackTrace stackTrace) => AppEmptyView(
                  icon: Icons.error_outline,
                  title: 'Could not load trash',
                  message: error.toString(),
                ),
                data: (List<Project> items) => items.isEmpty
                    ? const AppEmptyView(
                        icon: Icons.delete_outline,
                        title: 'Trash is empty',
                        message: 'Deleted projects remain here for seven days.',
                      )
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Project project = items[index];
                          return ListTile(
                            title: Text(project.title),
                            subtitle: const Text('Deleted project'),
                            trailing: PopupMenuButton<String>(
                              tooltip: 'Trash options for ${project.title}',
                              onSelected: (String action) async {
                                if (action == 'restore') {
                                  await ref
                                      .read(projectActionsProvider)
                                      .restore(project.id);
                                  return;
                                }
                                final bool
                                confirmed = await showConfirmActionDialog(
                                  context,
                                  title: 'Delete ${project.title} forever?',
                                  message:
                                      'This removes the project and its media permanently.',
                                  confirmLabel: 'Delete forever',
                                  destructive: true,
                                );
                                if (confirmed) {
                                  await ref
                                      .read(projectActionsProvider)
                                      .permanentlyDelete(project.id);
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  const <PopupMenuEntry<String>>[
                                    PopupMenuItem(
                                      value: 'restore',
                                      child: Text('Restore'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete forever'),
                                    ),
                                  ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectToolbar extends ConsumerWidget {
  const _ProjectToolbar({required this.query});

  final ProjectLibraryQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3),
      child: Row(
        children: <Widget>[
          DropdownButton<ProjectFilter>(
            value: query.filter,
            underline: const SizedBox.shrink(),
            onChanged: (ProjectFilter? value) {
              if (value != null) {
                ref.read(projectLibraryQueryProvider.notifier).setFilter(value);
              }
            },
            items: const <DropdownMenuItem<ProjectFilter>>[
              DropdownMenuItem(value: ProjectFilter.all, child: Text('All')),
              DropdownMenuItem(
                value: ProjectFilter.draft,
                child: Text('Draft'),
              ),
              DropdownMenuItem(
                value: ProjectFilter.exported,
                child: Text('Exported'),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.x4),
          DropdownButton<ProjectSort>(
            value: query.sort,
            underline: const SizedBox.shrink(),
            onChanged: (ProjectSort? value) {
              if (value != null) {
                ref.read(projectLibraryQueryProvider.notifier).setSort(value);
              }
            },
            items: const <DropdownMenuItem<ProjectSort>>[
              DropdownMenuItem(
                value: ProjectSort.lastEdited,
                child: Text('Last edited'),
              ),
              DropdownMenuItem(
                value: ProjectSort.dateCreated,
                child: Text('Date created'),
              ),
              DropdownMenuItem(value: ProjectSort.title, child: Text('Title')),
              DropdownMenuItem(
                value: ProjectSort.duration,
                child: Text('Duration'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProjectCollection extends StatelessWidget {
  const _ProjectCollection({
    required this.projects,
    required this.grid,
    required this.onOpen,
    required this.onAction,
  });

  final List<Project> projects;
  final bool grid;
  final ValueChanged<Project> onOpen;
  final Future<void> Function(Project, _ProjectMenuAction) onAction;

  @override
  Widget build(BuildContext context) {
    if (!grid) {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
        itemCount: projects.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(height: AppSpacing.x2),
        itemBuilder: (BuildContext context, int index) => _ProjectListTile(
          project: projects[index],
          onOpen: onOpen,
          onAction: onAction,
        ),
      );
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int count = (constraints.maxWidth / 220).floor().clamp(1, 4);
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            crossAxisSpacing: AppSpacing.x3,
            mainAxisSpacing: AppSpacing.x3,
            childAspectRatio: 0.95,
          ),
          itemCount: projects.length,
          itemBuilder: (BuildContext context, int index) => _ProjectGridTile(
            project: projects[index],
            onOpen: onOpen,
            onAction: onAction,
          ),
        );
      },
    );
  }
}

class _ProjectGridTile extends StatelessWidget {
  const _ProjectGridTile({
    required this.project,
    required this.onOpen,
    required this.onAction,
  });

  final Project project;
  final ValueChanged<Project> onOpen;
  final Future<void> Function(Project, _ProjectMenuAction) onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onOpen(project),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: _ProjectThumbnail(project: project)),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 4, 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          project.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppSpacing.x1),
                        Text(_projectMetadata(project)),
                        if (project.status == ProjectStatus.needsRepair)
                          const _RepairBadge(),
                      ],
                    ),
                  ),
                  _ProjectMenu(project: project, onAction: onAction),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectListTile extends StatelessWidget {
  const _ProjectListTile({
    required this.project,
    required this.onOpen,
    required this.onAction,
  });

  final Project project;
  final ValueChanged<Project> onOpen;
  final Future<void> Function(Project, _ProjectMenuAction) onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => onOpen(project),
        leading: SizedBox(
          width: 64,
          height: 48,
          child: _ProjectThumbnail(project: project),
        ),
        title: Text(project.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(_projectMetadata(project)),
            if (project.status == ProjectStatus.needsRepair)
              const _RepairBadge(),
          ],
        ),
        trailing: _ProjectMenu(project: project, onAction: onAction),
      ),
    );
  }
}

class _ProjectThumbnail extends ConsumerWidget {
  const _ProjectThumbnail({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<File?> thumbnail = ref.watch(
      projectThumbnailProvider(project.id),
    );
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: thumbnail.when(
        data: (File? file) => file == null
            ? const Center(child: Icon(Icons.movie_outlined, size: 40))
            : Image.file(
                file,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, _, _) =>
                    const Center(child: Icon(Icons.broken_image_outlined)),
              ),
        loading: () => const Center(
          child: SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (_, _) => const Center(child: Icon(Icons.broken_image_outlined)),
      ),
    );
  }
}

class _RepairBadge extends StatelessWidget {
  const _RepairBadge();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.x1),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: AppSpacing.x1),
          Flexible(
            child: Text(
              'Needs repair',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectMenu extends StatelessWidget {
  const _ProjectMenu({required this.project, required this.onAction});

  final Project project;
  final Future<void> Function(Project, _ProjectMenuAction) onAction;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ProjectMenuAction>(
      tooltip: 'Project options for ${project.title}',
      onSelected: (_ProjectMenuAction action) => onAction(project, action),
      itemBuilder: (BuildContext context) =>
          const <PopupMenuEntry<_ProjectMenuAction>>[
            PopupMenuItem(
              value: _ProjectMenuAction.rename,
              child: Text('Rename'),
            ),
            PopupMenuItem(
              value: _ProjectMenuAction.duplicate,
              child: Text('Duplicate'),
            ),
            PopupMenuItem(
              value: _ProjectMenuAction.details,
              child: Text('Details'),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: _ProjectMenuAction.delete,
              child: Text('Delete'),
            ),
          ],
    );
  }
}

String _projectMetadata(Project project) {
  final int seconds = project.duration.inSeconds;
  final String duration =
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  final String exported = project.isCurrentRevisionExported
      ? ' - Exported'
      : '';
  return '${project.frameCount} fr - $duration$exported';
}
