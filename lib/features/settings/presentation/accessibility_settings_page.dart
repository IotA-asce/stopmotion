import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/app_settings.dart';
import 'settings_providers.dart';

class AccessibilitySettingsPage extends ConsumerWidget {
  const AccessibilitySettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings settings = ref.watch(appSettingsProvider);
    Future<void> save(AppSettings next) =>
        ref.read(appSettingsProvider.notifier).update(next);
    return Scaffold(
      appBar: AppBar(title: const Text('Accessibility')),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Reduced motion'),
            trailing: DropdownButton<ReducedMotionPreference>(
              value: settings.reducedMotion,
              underline: const SizedBox.shrink(),
              items: const <DropdownMenuItem<ReducedMotionPreference>>[
                DropdownMenuItem(
                  value: ReducedMotionPreference.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(
                  value: ReducedMotionPreference.on,
                  child: Text('On'),
                ),
                DropdownMenuItem(
                  value: ReducedMotionPreference.off,
                  child: Text('Off'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  save(settings.copyWith(reducedMotion: value));
                }
              },
            ),
          ),
          SwitchListTile(
            title: const Text('High-contrast timeline'),
            subtitle: const Text(
              'Increase selected-frame and playhead contrast.',
            ),
            value: settings.highContrastTimeline,
            onChanged: (value) =>
                save(settings.copyWith(highContrastTimeline: value)),
          ),
          SwitchListTile(
            title: const Text('Haptics'),
            subtitle: const Text('Confirm a frame after it is saved.'),
            value: settings.hapticsEnabled,
            onChanged: (value) =>
                save(settings.copyWith(hapticsEnabled: value)),
          ),
          SwitchListTile(
            title: const Text('Keep screen awake during capture'),
            value: settings.keepAwakeDuringCapture,
            onChanged: (value) =>
                save(settings.copyWith(keepAwakeDuringCapture: value)),
          ),
        ],
      ),
    );
  }
}
