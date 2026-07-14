import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';
import 'theme/app_theme.dart';

final appThemeModeProvider = NotifierProvider<AppThemeMode, ThemeMode>(
  AppThemeMode.new,
);

class AppThemeMode extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setThemeMode(ThemeMode mode) => state = mode;
}

class StopMotionApp extends ConsumerStatefulWidget {
  const StopMotionApp({this.router, super.key});

  final GoRouter? router;

  @override
  ConsumerState<StopMotionApp> createState() => _StopMotionAppState();
}

class _StopMotionAppState extends ConsumerState<StopMotionApp> {
  late final GoRouter _router = widget.router ?? createAppRouter();

  @override
  void dispose() {
    if (widget.router == null) {
      _router.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeMode themeMode = ref.watch(appThemeModeProvider);

    return MaterialApp.router(
      title: 'Stop Motion',
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'stop_motion_app',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
