import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode mode = ref.watch(appThemeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: <Widget>[
          const _SectionLabel('App'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Appearance'),
            trailing: DropdownButton<ThemeMode>(
              value: mode,
              underline: const SizedBox.shrink(),
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  ref.read(appThemeModeProvider.notifier).setThemeMode(value);
                }
              },
              items: const <DropdownMenuItem<ThemeMode>>[
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
            ),
          ),
          const ListTile(
            leading: Icon(Icons.accessibility_new),
            title: Text('Accessibility'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            leading: Icon(Icons.storage_outlined),
            title: Text('Storage'),
            trailing: Icon(Icons.chevron_right),
          ),
          const _SectionLabel('Support and privacy'),
          const ListTile(
            leading: Icon(Icons.shield_outlined),
            title: Text('Privacy'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('Help and troubleshooting'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About'),
            trailing: Icon(Icons.chevron_right),
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
