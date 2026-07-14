import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/settings/domain/app_settings.dart';
import '../features/settings/presentation/settings_providers.dart';
import 'router.dart';
import 'theme/app_theme.dart';

final appThemeModeProvider = NotifierProvider<AppThemeMode, ThemeMode>(
  AppThemeMode.new,
);

class AppThemeMode extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => themeModeFor(ref.watch(appSettingsProvider).appearance);

  void setThemeMode(ThemeMode mode) {
    state = mode;
    unawaited(
      ref
          .read(appSettingsProvider.notifier)
          .update(
            ref
                .read(appSettingsProvider)
                .copyWith(
                  appearance: switch (mode) {
                    ThemeMode.system => AppAppearance.system,
                    ThemeMode.light => AppAppearance.light,
                    ThemeMode.dark => AppAppearance.dark,
                  },
                ),
          ),
    );
  }
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
    final AppSettings settings = ref.watch(appSettingsProvider);

    return MaterialApp.router(
      title: 'Stop Motion',
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'stop_motion_app',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: _router,
      builder: (BuildContext context, Widget? child) {
        final MediaQueryData media = MediaQuery.of(context);
        final bool disableAnimations = switch (settings.reducedMotion) {
          ReducedMotionPreference.on => true,
          ReducedMotionPreference.off => false,
          ReducedMotionPreference.system => media.disableAnimations,
        };
        return MediaQuery(
          data: media.copyWith(disableAnimations: disableAnimations),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
