import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../domain/app_settings.dart';
import 'settings_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: <Widget>[
          const _SectionLabel('App'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Appearance'),
            trailing: DropdownButton<AppAppearance>(
              value: settings.appearance,
              underline: const SizedBox.shrink(),
              onChanged: (AppAppearance? value) {
                if (value != null) {
                  ref
                      .read(appSettingsProvider.notifier)
                      .update(settings.copyWith(appearance: value));
                }
              },
              items: const <DropdownMenuItem<AppAppearance>>[
                DropdownMenuItem(
                  value: AppAppearance.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(
                  value: AppAppearance.light,
                  child: Text('Light'),
                ),
                DropdownMenuItem(
                  value: AppAppearance.dark,
                  child: Text('Dark'),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Capture defaults'),
            subtitle: const Text('New projects and capture workspace'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.settingsCapture),
          ),
          ListTile(
            leading: const Icon(Icons.ios_share_outlined),
            title: const Text('Export defaults'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.settingsExport),
          ),
          ListTile(
            leading: const Icon(Icons.accessibility_new),
            title: const Text('Accessibility'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.settingsAccessibility),
          ),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const Text('Storage'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.settingsStorage),
          ),
          const _SectionLabel('Support and privacy'),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Privacy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.settingsPrivacy),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help and troubleshooting'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.settingsHelp),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.settingsAbout),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 8),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}
