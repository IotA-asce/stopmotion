import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../export/domain/export_job.dart';
import '../../export/domain/export_record.dart';
import '../domain/app_settings.dart';
import 'settings_providers.dart';

class ExportDefaultsPage extends ConsumerWidget {
  const ExportDefaultsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings appSettings = ref.watch(appSettingsProvider);
    final ExportSettings settings = appSettings.exportDefaults;
    Future<void> save(ExportSettings next) => ref
        .read(appSettingsProvider.notifier)
        .update(appSettings.copyWith(exportDefaults: next));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export defaults'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Reset export defaults',
            icon: const Icon(Icons.restart_alt),
            onPressed: () => save(const ExportSettings()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          DropdownButtonFormField<ExportFormat>(
            initialValue: settings.format,
            decoration: const InputDecoration(
              labelText: 'Format',
              border: OutlineInputBorder(),
            ),
            items: ExportFormat.values
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(_format(value)),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) save(settings.copyWith(format: value));
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ExportResolution>(
            initialValue: settings.resolution,
            decoration: const InputDecoration(
              labelText: 'Resolution',
              border: OutlineInputBorder(),
            ),
            items: ExportResolution.values
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(
                      value == ExportResolution.hd720 ? '720p' : '1080p',
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) save(settings.copyWith(resolution: value));
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ExportQuality>(
            initialValue: settings.quality,
            decoration: const InputDecoration(
              labelText: 'Quality',
              border: OutlineInputBorder(),
            ),
            items: ExportQuality.values
                .map(
                  (value) =>
                      DropdownMenuItem(value: value, child: Text(value.name)),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) save(settings.copyWith(quality: value));
            },
          ),
          if (settings.format == ExportFormat.gif) ...<Widget>[
            const SizedBox(height: 24),
            DropdownButtonFormField<GifLoopMode>(
              initialValue: settings.gifLoopMode,
              decoration: const InputDecoration(
                labelText: 'GIF loop',
                border: OutlineInputBorder(),
              ),
              items: GifLoopMode.values
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value.name)),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) save(settings.copyWith(gifLoopMode: value));
              },
            ),
          ],
          if (settings.format == ExportFormat.imageSequence) ...<Widget>[
            const SizedBox(height: 24),
            DropdownButtonFormField<ImageSequenceFormat>(
              initialValue: settings.imageSequenceFormat,
              decoration: const InputDecoration(
                labelText: 'Sequence images',
                border: OutlineInputBorder(),
              ),
              items: ImageSequenceFormat.values
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(value.name.toUpperCase()),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) {
                  save(settings.copyWith(imageSequenceFormat: value));
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  String _format(ExportFormat format) => switch (format) {
    ExportFormat.movie => 'MP4 movie',
    ExportFormat.gif => 'GIF',
    ExportFormat.imageSequence => 'Image sequence ZIP',
  };
}
