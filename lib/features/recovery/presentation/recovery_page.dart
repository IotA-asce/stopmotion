import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/widgets/app_state_views.dart';
import '../domain/recovery_report.dart';
import 'recovery_controller.dart';
import 'recovery_providers.dart';

class RecoveryPage extends ConsumerStatefulWidget {
  const RecoveryPage({super.key});

  @override
  ConsumerState<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends ConsumerState<RecoveryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recoveryControllerProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final RecoveryViewState state = ref.watch(recoveryControllerProvider);
    final RecoveryController controller = ref.read(
      recoveryControllerProvider.notifier,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Recovery')),
      body: state.loading
          ? const AppLoadingView(label: 'Checking project consistency')
          : state.report.items.isEmpty
          ? AppEmptyView(
              icon: Icons.check_circle_outline,
              title: 'No recovery needed',
              message: 'Your projects are consistent and ready to open.',
              action: FilledButton(
                onPressed: () => context.go(AppRoutes.projects),
                child: const Text('Continue to Projects'),
              ),
            )
          : Column(
              children: <Widget>[
                if (state.message != null)
                  Semantics(
                    liveRegion: true,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(state.message!),
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    itemCount: state.report.items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (BuildContext context, int index) {
                      final RecoveryItem item = state.report.items[index];
                      return ListTile(
                        leading: Icon(_iconFor(item.kind)),
                        title: Text(_titleFor(item.kind)),
                        subtitle: Text(item.message),
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: <Widget>[
                        if (state.report.items.any(
                          (RecoveryItem item) => item.canRepair,
                        ))
                          FilledButton.icon(
                            onPressed: controller.repair,
                            icon: const Icon(Icons.build_outlined),
                            label: const Text('Repair'),
                          ),
                        if (state.report.hasMissingItems)
                          OutlinedButton.icon(
                            onPressed: controller.removeMissingItems,
                            icon: const Icon(Icons.remove_circle_outline),
                            label: const Text('Remove missing items'),
                          ),
                        OutlinedButton.icon(
                          onPressed: controller.exportDiagnostics,
                          icon: const Icon(Icons.bug_report_outlined),
                          label: const Text('Export diagnostics'),
                        ),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.projects),
                          child: const Text('Keep for later'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  IconData _iconFor(RecoveryIssueKind kind) => switch (kind) {
    RecoveryIssueKind.migration => Icons.storage_outlined,
    RecoveryIssueKind.orphanedMedia => Icons.inventory_2_outlined,
    RecoveryIssueKind.missingMedia => Icons.broken_image_outlined,
    RecoveryIssueKind.interruptedDuplicate => Icons.copy_outlined,
    RecoveryIssueKind.interruptedDelete => Icons.delete_outline,
    RecoveryIssueKind.missingProjectDirectory => Icons.folder_off_outlined,
  };

  String _titleFor(RecoveryIssueKind kind) => switch (kind) {
    RecoveryIssueKind.migration => 'Database recovery needed',
    RecoveryIssueKind.orphanedMedia => 'Media retained for review',
    RecoveryIssueKind.missingMedia => 'Missing source media',
    RecoveryIssueKind.interruptedDuplicate => 'Interrupted project copy',
    RecoveryIssueKind.interruptedDelete => 'Interrupted permanent deletion',
    RecoveryIssueKind.missingProjectDirectory => 'Project directory missing',
  };
}
