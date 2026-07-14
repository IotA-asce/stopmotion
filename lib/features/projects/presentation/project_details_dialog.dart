import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../domain/project.dart';
import 'project_providers.dart';

class ProjectDetailsDialog extends ConsumerWidget {
  const ProjectDetailsDialog({
    required this.project,
    required this.onRename,
    required this.onDuplicate,
    required this.onDelete,
    super.key,
  });

  final Project project;
  final VoidCallback onRename;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<File?> thumbnail = ref.watch(
      projectThumbnailProvider(project.id),
    );
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.82,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Project details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Close project details',
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.x6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: project.aspectRatio.value,
                      child: ColoredBox(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: thumbnail.when(
                          data: (File? file) => file == null
                              ? const Icon(Icons.movie_outlined, size: 56)
                              : Image.file(file, fit: BoxFit.cover),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (_, _) =>
                              const Icon(Icons.broken_image_outlined, size: 56),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x4),
                    Text(
                      project.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.x4),
                    _Detail(
                      label: 'Status',
                      value: project.status == ProjectStatus.needsRepair
                          ? 'Needs repair'
                          : project.status == ProjectStatus.exported
                          ? 'Exported'
                          : 'Draft',
                    ),
                    _Detail(label: 'Frames', value: '${project.frameCount}'),
                    _Detail(
                      label: 'Duration',
                      value: _formatDuration(project.duration),
                    ),
                    _Detail(
                      label: 'Frame rate',
                      value: '${project.framesPerSecond} fps',
                    ),
                    _Detail(label: 'Canvas', value: project.resolution.label),
                    _Detail(
                      label: 'Aspect ratio',
                      value: project.aspectRatio.label,
                    ),
                    FutureBuilder<int>(
                      future: ref
                          .read(projectRepositoryProvider)
                          .projectSize(project.id),
                      builder:
                          (BuildContext context, AsyncSnapshot<int> snapshot) {
                            final String size = snapshot.hasData
                                ? _formatBytes(snapshot.data!)
                                : 'Measuring';
                            return _Detail(label: 'Project size', value: size);
                          },
                    ),
                    _Detail(
                      label: 'Created',
                      value: project.createdAt
                          .toLocal()
                          .toString()
                          .split(' ')
                          .first,
                    ),
                    _Detail(
                      label: 'Last edited',
                      value: project.updatedAt
                          .toLocal()
                          .toString()
                          .split(' ')
                          .first,
                    ),
                    _Detail(
                      label: 'Last export',
                      value: project.lastExportedRevision == null
                          ? 'None'
                          : 'Revision ${project.lastExportedRevision}',
                    ),
                    const SizedBox(height: AppSpacing.x4),
                    Wrap(
                      spacing: AppSpacing.x2,
                      runSpacing: AppSpacing.x2,
                      children: <Widget>[
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            onRename();
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Rename'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            onDuplicate();
                          },
                          icon: const Icon(Icons.copy_outlined),
                          label: const Text('Duplicate'),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            onDelete();
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Move to trash'),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.x4),
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final int seconds = duration.inSeconds;
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.x1),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          Text(value, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  }
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
