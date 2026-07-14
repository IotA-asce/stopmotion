import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/filesystem/storage_monitor.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/confirm_action_dialog.dart';
import '../../projects/domain/project.dart';
import '../../projects/presentation/project_providers.dart';
import 'settings_providers.dart';

class StorageSettingsPage extends ConsumerStatefulWidget {
  const StorageSettingsPage({super.key});

  @override
  ConsumerState<StorageSettingsPage> createState() =>
      _StorageSettingsPageState();
}

class _StorageSettingsPageState extends ConsumerState<StorageSettingsPage> {
  late Future<StorageSummary> _summary;

  @override
  void initState() {
    super.initState();
    _summary = _load();
  }

  Future<StorageSummary> _load() => ref.read(storageMonitorProvider).inspect();

  void _refresh() => setState(() => _summary = _load());

  Future<void> _clearCache() async {
    await ref.read(storageMonitorProvider).clearCache();
    _refresh();
  }

  Future<void> _emptyTrash() async {
    final bool confirmed = await showConfirmActionDialog(
      context,
      title: 'Permanently empty trash?',
      message: 'Projects and their source media in trash cannot be restored.',
      confirmLabel: 'Empty trash',
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(storageMonitorProvider).emptyTrash();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Project>> trashed = ref.watch(
      trashedProjectsProvider,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh storage',
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<StorageSummary>(
        future: _summary,
        builder: (BuildContext context, AsyncSnapshot<StorageSummary> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const AppLoadingView(label: 'Measuring storage');
          }
          if (snapshot.hasError) {
            return AppEmptyView(
              icon: Icons.error_outline,
              title: 'Storage is unavailable',
              message: 'Try again before removing files.',
              action: FilledButton(
                onPressed: _refresh,
                child: const Text('Retry'),
              ),
            );
          }
          final StorageSummary summary = snapshot.requireData;
          return ListView(
            children: <Widget>[
              if (summary.lowSpace)
                const MaterialBanner(
                  content: Text(
                    'Storage is running low. Capture and export may be blocked.',
                  ),
                  leading: Icon(Icons.warning_amber_outlined),
                  actions: <Widget>[],
                ),
              _SizeTile('Project media', summary.projectMediaBytes),
              _SizeTile('Exports', summary.exportBytes),
              _SizeTile('Cache', summary.cacheBytes),
              _SizeTile('Trash', summary.trashBytes),
              ListTile(
                title: const Text('Available device storage'),
                trailing: Text(
                  summary.availableBytes == null
                      ? 'Unknown'
                      : _bytes(summary.availableBytes!),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.cleaning_services_outlined),
                title: const Text('Clear cache'),
                subtitle: const Text(
                  'Removes thumbnails and temporary render data only.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _clearCache,
              ),
              const Divider(),
              ListTile(
                title: const Text('Trash'),
                subtitle: Text(
                  '${summary.expiredTrashCount} project(s) have reached the 7-day retention limit.',
                ),
                trailing: TextButton(
                  onPressed: _emptyTrash,
                  child: const Text('Empty trash'),
                ),
              ),
              ...trashed.when(
                loading: () => const <Widget>[LinearProgressIndicator()],
                error: (_, _) => const <Widget>[],
                data: (List<Project> projects) => projects
                    .map(
                      (Project project) => ListTile(
                        leading: const Icon(Icons.delete_outline),
                        title: Text(project.title),
                        subtitle: Text(
                          'Deleted ${project.deletedAt?.toLocal().toString().split(' ').first ?? ''}',
                        ),
                        trailing: TextButton(
                          onPressed: () async {
                            await ref
                                .read(projectActionsProvider)
                                .restore(project.id);
                            _refresh();
                          },
                          child: const Text('Restore'),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SizeTile extends StatelessWidget {
  const _SizeTile(this.label, this.bytes);

  final String label;
  final int bytes;

  @override
  Widget build(BuildContext context) =>
      ListTile(title: Text(label), trailing: Text(_bytes(bytes)));
}

String _bytes(int value) {
  if (value < 1024 * 1024) {
    return '${(value / 1024).toStringAsFixed(1)} KB';
  }
  if (value < 1024 * 1024 * 1024) {
    return '${(value / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(value / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}
