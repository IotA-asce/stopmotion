import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import '../../../core/widgets/app_state_views.dart';
import '../domain/export_job.dart';
import '../domain/export_record.dart';
import 'export_controller.dart';
import 'export_providers.dart';

class ExportPage extends ConsumerWidget {
  const ExportPage({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ExportController controller = ref.watch(
      exportControllerProvider(projectId),
    );
    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? child) {
        final ExportViewState state = controller.state;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Back',
              onPressed: state.status == ExportViewStatus.exporting
                  ? null
                  : () => context.pop(),
              icon: const Icon(Icons.arrow_back),
            ),
            title: const Text('Export'),
          ),
          body: SafeArea(
            child: switch (state.status) {
              ExportViewStatus.loading => const AppLoadingView(
                label: 'Checking export settings',
              ),
              ExportViewStatus.exporting => _ExportProgressView(
                state: state,
                onCancel: controller.cancel,
              ),
              ExportViewStatus.complete => _ExportCompleteView(
                state: state,
                onShare: controller.share,
                onSave: controller.save,
                onOpen: controller.open,
                onDone: () => context.pop(),
              ),
              ExportViewStatus.failed => _ExportFailureView(
                message: state.errorMessage ?? 'Export failed.',
                onRetry: controller.retry,
                onSettings: () => controller.setSettings(state.settings),
              ),
              ExportViewStatus.cancelled || ExportViewStatus.ready =>
                _ExportSetupView(controller: controller, state: state),
            },
          ),
        );
      },
    );
  }
}

class _ExportSetupView extends ConsumerWidget {
  const _ExportSetupView({required this.controller, required this.state});

  final ExportController controller;
  final ExportViewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ExportPreflight? preflight = state.preflight;
    final AsyncValue<List<ProjectExportRecord>> history = ref.watch(
      exportHistoryProvider(controller.projectId),
    );
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth > 720
            ? 680
            : constraints.maxWidth;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Align(
              child: SizedBox(
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: preflight == null
                          ? 16 / 9
                          : preflight.dimensions.width /
                                preflight.dimensions.height,
                      child: ColoredBox(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: const Center(
                          child: Icon(Icons.movie_creation_outlined, size: 56),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SegmentedButton<ExportFormat>(
                      showSelectedIcon: false,
                      segments: const <ButtonSegment<ExportFormat>>[
                        ButtonSegment(
                          value: ExportFormat.movie,
                          icon: Icon(Icons.movie_outlined),
                          label: Text('Movie'),
                        ),
                        ButtonSegment(
                          value: ExportFormat.gif,
                          icon: Icon(Icons.gif_box_outlined),
                          label: Text('GIF'),
                        ),
                        ButtonSegment(
                          value: ExportFormat.imageSequence,
                          icon: Icon(Icons.photo_library_outlined),
                          label: Text('Images'),
                        ),
                      ],
                      selected: <ExportFormat>{state.settings.format},
                      onSelectionChanged: (Set<ExportFormat> selected) {
                        controller.setSettings(
                          state.settings.copyWith(format: selected.first),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    if (state.settings.format == ExportFormat.movie)
                      _MovieSettings(controller: controller, state: state),
                    if (state.settings.format == ExportFormat.gif)
                      _GifSettings(controller: controller, state: state),
                    if (state.settings.format == ExportFormat.imageSequence)
                      _ImageSettings(controller: controller, state: state),
                    const SizedBox(height: 12),
                    if (preflight != null)
                      Text(
                        '${preflight.dimensions.width} x ${preflight.dimensions.height}  |  '
                        '${_duration(preflight.duration)}  |  '
                        '${_bytes(preflight.estimatedBytes)} estimated',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    if (state.settings.format == ExportFormat.gif)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('Audio is not included in GIF files.'),
                      ),
                    if (state.status == ExportViewStatus.cancelled)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            'Export cancelled. No partial file was kept.',
                          ),
                        ),
                      ),
                    for (final ExportIssue issue
                        in preflight?.issues ?? const <ExportIssue>[])
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Material(
                          color: Theme.of(context).colorScheme.errorContainer,
                          child: ListTile(
                            leading: const Icon(Icons.warning_amber),
                            title: Text(issue.message),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: preflight?.canExport == true
                          ? controller.export
                          : null,
                      icon: const Icon(Icons.ios_share),
                      label: const Text('Export'),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Export history',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    history.when(
                      data: (List<ProjectExportRecord> records) =>
                          records.isEmpty
                          ? const Text('No exports yet.')
                          : Column(
                              children: records.take(5).map((record) {
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(_formatIcon(record.format)),
                                  title: Text(_formatLabel(record.format)),
                                  subtitle: Text(record.status.name),
                                  trailing: record.outputBytes == null
                                      ? null
                                      : Text(_bytes(record.outputBytes!)),
                                );
                              }).toList(),
                            ),
                      loading: () => const LinearProgressIndicator(),
                      error: (Object error, StackTrace stack) =>
                          const Text('Export history is unavailable.'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MovieSettings extends StatelessWidget {
  const _MovieSettings({required this.controller, required this.state});
  final ExportController controller;
  final ExportViewState state;

  @override
  Widget build(BuildContext context) => _responsivePair(
    DropdownButtonFormField<ExportResolution>(
      initialValue: state.settings.resolution,
      decoration: const InputDecoration(labelText: 'Resolution'),
      items: const <DropdownMenuItem<ExportResolution>>[
        DropdownMenuItem(value: ExportResolution.hd720, child: Text('720p')),
        DropdownMenuItem(
          value: ExportResolution.fullHd1080,
          child: Text('1080p'),
        ),
      ],
      onChanged: (ExportResolution? value) {
        if (value != null) {
          controller.setSettings(state.settings.copyWith(resolution: value));
        }
      },
    ),
    DropdownButtonFormField<ExportQuality>(
      initialValue: state.settings.quality,
      decoration: const InputDecoration(labelText: 'Quality'),
      items: <DropdownMenuItem<ExportQuality>>[
        for (final ExportQuality quality in ExportQuality.values)
          DropdownMenuItem(value: quality, child: Text(quality.name)),
      ],
      onChanged: (ExportQuality? value) {
        if (value != null) {
          controller.setSettings(state.settings.copyWith(quality: value));
        }
      },
    ),
  );
}

class _GifSettings extends StatelessWidget {
  const _GifSettings({required this.controller, required this.state});
  final ExportController controller;
  final ExportViewState state;

  @override
  Widget build(BuildContext context) => _responsivePair(
    DropdownButtonFormField<int>(
      initialValue: state.settings.gifMaximumDimension,
      decoration: const InputDecoration(labelText: 'Maximum size'),
      items: const <DropdownMenuItem<int>>[
        DropdownMenuItem(value: 320, child: Text('320 px')),
        DropdownMenuItem(value: 640, child: Text('640 px')),
        DropdownMenuItem(value: 960, child: Text('960 px')),
      ],
      onChanged: (int? value) {
        if (value != null) {
          controller.setSettings(
            state.settings.copyWith(gifMaximumDimension: value),
          );
        }
      },
    ),
    DropdownButtonFormField<GifLoopMode>(
      initialValue: state.settings.gifLoopMode,
      decoration: const InputDecoration(labelText: 'Loop'),
      items: const <DropdownMenuItem<GifLoopMode>>[
        DropdownMenuItem(value: GifLoopMode.forever, child: Text('Forever')),
        DropdownMenuItem(value: GifLoopMode.count, child: Text('2 times')),
        DropdownMenuItem(value: GifLoopMode.once, child: Text('Play once')),
      ],
      onChanged: (GifLoopMode? value) {
        if (value != null) {
          controller.setSettings(state.settings.copyWith(gifLoopMode: value));
        }
      },
    ),
  );
}

class _ImageSettings extends StatelessWidget {
  const _ImageSettings({required this.controller, required this.state});
  final ExportController controller;
  final ExportViewState state;

  @override
  Widget build(BuildContext context) =>
      DropdownButtonFormField<ImageSequenceFormat>(
        initialValue: state.settings.imageSequenceFormat,
        decoration: const InputDecoration(labelText: 'Image format'),
        items: const <DropdownMenuItem<ImageSequenceFormat>>[
          DropdownMenuItem(value: ImageSequenceFormat.png, child: Text('PNG')),
          DropdownMenuItem(
            value: ImageSequenceFormat.jpeg,
            child: Text('JPEG'),
          ),
        ],
        onChanged: (ImageSequenceFormat? value) {
          if (value != null) {
            controller.setSettings(
              state.settings.copyWith(imageSequenceFormat: value),
            );
          }
        },
      );
}

class _ExportProgressView extends StatelessWidget {
  const _ExportProgressView({required this.state, required this.onCancel});
  final ExportViewState state;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final ExportProgress progress = state.progress!;
    return Center(
      child: SizedBox(
        width: 520,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Semantics(
            liveRegion: true,
            label: 'Export ${progress.stage.name}',
            value: '${(progress.fraction * 100).round()} percent',
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  _stage(progress.stage),
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(value: progress.fraction),
                const SizedBox(height: 12),
                Text(
                  '${(progress.fraction * 100).round()}%  |  ${_duration(progress.elapsed)} elapsed',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExportCompleteView extends StatelessWidget {
  const _ExportCompleteView({
    required this.state,
    required this.onShare,
    required this.onSave,
    required this.onOpen,
    required this.onDone,
  });
  final ExportViewState state;
  final Future<void> Function({Rect? origin}) onShare;
  final Future<void> Function({Rect? origin}) onSave;
  final Future<void> Function() onOpen;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 520,
        child: Semantics(
          liveRegion: true,
          child: Column(
            children: <Widget>[
              Icon(
                Icons.check_circle,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Export complete',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(p.basename(state.output!.path)),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  Builder(
                    builder: (BuildContext buttonContext) => FilledButton.icon(
                      onPressed: () => onShare(origin: _origin(buttonContext)),
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ),
                  Builder(
                    builder: (BuildContext buttonContext) =>
                        OutlinedButton.icon(
                          onPressed: () =>
                              onSave(origin: _origin(buttonContext)),
                          icon: const Icon(Icons.save_alt),
                          label: const Text('Save'),
                        ),
                  ),
                  OutlinedButton.icon(
                    onPressed: onOpen,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open'),
                  ),
                ],
              ),
              if (state.handoffMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(state.handoffMessage!),
                ),
              const SizedBox(height: 24),
              TextButton(onPressed: onDone, child: const Text('Done')),
            ],
          ),
        ),
      ),
    ),
  );

  static Rect? _origin(BuildContext context) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    return box == null ? null : box.localToGlobal(Offset.zero) & box.size;
  }
}

class _ExportFailureView extends StatelessWidget {
  const _ExportFailureView({
    required this.message,
    required this.onRetry,
    required this.onSettings,
  });
  final String message;
  final Future<void> Function() onRetry;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 440,
        child: Column(
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Export failed',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
            TextButton(
              onPressed: onSettings,
              child: const Text('Change settings'),
            ),
          ],
        ),
      ),
    ),
  );
}

String _duration(Duration duration) {
  final int minutes = duration.inMinutes;
  final int seconds = duration.inSeconds.remainder(60);
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

String _bytes(int value) {
  if (value >= 1024 * 1024) {
    return '${(value / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  if (value >= 1024) return '${(value / 1024).toStringAsFixed(0)} KB';
  return '$value B';
}

String _stage(ExportStage stage) => switch (stage) {
  ExportStage.preflight => 'Preparing export',
  ExportStage.rendering => 'Rendering frames',
  ExportStage.mixingAudio => 'Encoding movie and audio',
  ExportStage.packaging => 'Packaging export',
  ExportStage.validating => 'Validating output',
};

String _formatLabel(ExportFormat format) => switch (format) {
  ExportFormat.movie => 'Movie',
  ExportFormat.gif => 'GIF',
  ExportFormat.imageSequence => 'Image sequence',
};

IconData _formatIcon(ExportFormat format) => switch (format) {
  ExportFormat.movie => Icons.movie_outlined,
  ExportFormat.gif => Icons.gif_box_outlined,
  ExportFormat.imageSequence => Icons.photo_library_outlined,
};

Widget _responsivePair(Widget first, Widget second) => LayoutBuilder(
  builder: (BuildContext context, BoxConstraints constraints) {
    if (constraints.maxWidth < 480) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[first, const SizedBox(height: 12), second],
      );
    }
    return Row(
      children: <Widget>[
        Expanded(child: first),
        const SizedBox(width: 12),
        Expanded(child: second),
      ],
    );
  },
);
