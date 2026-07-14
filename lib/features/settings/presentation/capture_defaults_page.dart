import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../capture/domain/capture_frame.dart';
import '../../projects/domain/project.dart';
import '../domain/app_settings.dart';
import 'settings_providers.dart';

class CaptureDefaultsPage extends ConsumerWidget {
  const CaptureDefaultsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings settings = ref.watch(appSettingsProvider);
    final CaptureDefaults defaults = settings.captureDefaults;
    Future<void> save(CaptureDefaults next) => ref
        .read(appSettingsProvider.notifier)
        .update(settings.copyWith(captureDefaults: next));
    return Scaffold(
      appBar: AppBar(title: const Text('Capture defaults')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            'These choices apply to new projects only.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<ProjectAspectRatio>(
            initialValue: defaults.aspectRatio,
            decoration: const InputDecoration(
              labelText: 'Aspect ratio',
              border: OutlineInputBorder(),
            ),
            items: ProjectAspectRatio.values
                .map(
                  (value) =>
                      DropdownMenuItem(value: value, child: Text(value.label)),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) save(defaults.copyWith(aspectRatio: value));
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ProjectResolution>(
            initialValue: defaults.resolution,
            decoration: const InputDecoration(
              labelText: 'Resolution intent',
              border: OutlineInputBorder(),
            ),
            items: ProjectResolution.values
                .map(
                  (value) =>
                      DropdownMenuItem(value: value, child: Text(value.label)),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) save(defaults.copyWith(resolution: value));
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: defaults.framesPerSecond,
            decoration: const InputDecoration(
              labelText: 'Frame rate',
              border: OutlineInputBorder(),
            ),
            items: const <int>[6, 8, 10, 12, 15, 24]
                .map(
                  (value) =>
                      DropdownMenuItem(value: value, child: Text('$value fps')),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) {
                save(defaults.copyWith(framesPerSecond: value));
              }
            },
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<CaptureGrid>(
            initialValue: defaults.grid,
            decoration: const InputDecoration(
              labelText: 'Composition grid',
              border: OutlineInputBorder(),
            ),
            items: CaptureGrid.values
                .map(
                  (value) =>
                      DropdownMenuItem(value: value, child: Text(value.name)),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) save(defaults.copyWith(grid: value));
            },
          ),
          const SizedBox(height: 16),
          Text('Onion opacity ${defaults.onionOpacity.toStringAsFixed(2)}'),
          Slider(
            value: defaults.onionOpacity,
            min: 0.1,
            max: 0.9,
            divisions: 8,
            onChanged: (value) {},
            onChangeEnd: (value) =>
                save(defaults.copyWith(onionOpacity: value)),
          ),
          DropdownButtonFormField<int>(
            initialValue: defaults.timerSeconds,
            decoration: const InputDecoration(
              labelText: 'Self timer',
              border: OutlineInputBorder(),
            ),
            items: const <int>[0, 3, 5, 10]
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(value == 0 ? 'Off' : '$value seconds'),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) save(defaults.copyWith(timerSeconds: value));
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Volume-button shutter'),
            value: defaults.volumeButtonShutter,
            onChanged: (value) =>
                save(defaults.copyWith(volumeButtonShutter: value)),
          ),
        ],
      ),
    );
  }
}
