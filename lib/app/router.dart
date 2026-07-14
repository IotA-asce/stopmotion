import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/app_error_view.dart';
import '../core/widgets/app_scaffold.dart';
import '../features/audio/presentation/audio_page.dart';
import '../features/capture/presentation/capture_page.dart';
import '../features/editor/presentation/editor_page.dart';
import '../features/export/presentation/export_page.dart';
import '../features/onboarding/presentation/onboarding_page.dart';
import '../features/preview/presentation/preview_page.dart';
import '../features/projects/presentation/create_project_page.dart';
import '../features/projects/presentation/projects_page.dart';
import '../features/recovery/presentation/recovery_page.dart';
import '../features/settings/presentation/accessibility_settings_page.dart';
import '../features/settings/presentation/capture_defaults_page.dart';
import '../features/settings/presentation/export_defaults_page.dart';
import '../features/settings/presentation/information_pages.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/settings/presentation/storage_settings_page.dart';

abstract final class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String projects = '/projects';
  static const String settings = '/settings';
  static const String settingsCapture = '/settings/capture';
  static const String settingsExport = '/settings/export';
  static const String settingsAccessibility = '/settings/accessibility';
  static const String settingsStorage = '/settings/storage';
  static const String settingsPrivacy = '/settings/privacy';
  static const String settingsHelp = '/settings/help';
  static const String settingsAbout = '/settings/about';
  static const String recovery = '/recovery';

  static String capture(String projectId) => '/project/$projectId/capture';
  static String edit(String projectId) => '/project/$projectId/edit';
  static String audio(String projectId) => '/project/$projectId/audio';
  static String preview(String projectId) => '/project/$projectId/preview';
  static String export(String projectId) => '/project/$projectId/export';
}

GoRouter createAppRouter({String initialLocation = AppRoutes.projects}) {
  return GoRouter(
    initialLocation: initialLocation,
    restorationScopeId: 'app_router',
    errorBuilder: (BuildContext context, GoRouterState state) => AppErrorView(
      title: 'Page not found',
      message: 'This page is unavailable or may have moved.',
      actionLabel: 'Go to Projects',
      onAction: () => context.go(AppRoutes.projects),
    ),
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        restorationScopeId: 'top_level_shell',
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              return AppScaffold(navigationShell: navigationShell);
            },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            restorationScopeId: 'projects_branch',
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.projects,
                pageBuilder: (BuildContext context, GoRouterState state) {
                  return const NoTransitionPage<void>(child: ProjectsPage());
                },
              ),
            ],
          ),
          StatefulShellBranch(
            restorationScopeId: 'settings_branch',
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.settings,
                pageBuilder: (BuildContext context, GoRouterState state) {
                  return const NoTransitionPage<void>(child: SettingsPage());
                },
              ),
              GoRoute(
                path: AppRoutes.settingsCapture,
                builder: (BuildContext context, GoRouterState state) =>
                    const CaptureDefaultsPage(),
              ),
              GoRoute(
                path: AppRoutes.settingsExport,
                builder: (BuildContext context, GoRouterState state) =>
                    const ExportDefaultsPage(),
              ),
              GoRoute(
                path: AppRoutes.settingsAccessibility,
                builder: (BuildContext context, GoRouterState state) =>
                    const AccessibilitySettingsPage(),
              ),
              GoRoute(
                path: AppRoutes.settingsStorage,
                builder: (BuildContext context, GoRouterState state) =>
                    const StorageSettingsPage(),
              ),
              GoRoute(
                path: AppRoutes.settingsPrivacy,
                builder: (BuildContext context, GoRouterState state) =>
                    const PrivacyPage(),
              ),
              GoRoute(
                path: AppRoutes.settingsHelp,
                builder: (BuildContext context, GoRouterState state) =>
                    const HelpPage(),
              ),
              GoRoute(
                path: AppRoutes.settingsAbout,
                builder: (BuildContext context, GoRouterState state) =>
                    const AboutPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.recovery,
        builder: (BuildContext context, GoRouterState state) =>
            const RecoveryPage(),
      ),
      GoRoute(
        path: '/projects/new',
        builder: (BuildContext context, GoRouterState state) =>
            const CreateProjectPage(),
      ),
      GoRoute(
        path: '/project/:projectId/capture',
        builder: (BuildContext context, GoRouterState state) =>
            CapturePage(projectId: state.pathParameters['projectId']!),
      ),
      GoRoute(
        path: '/project/:projectId/edit',
        builder: (BuildContext context, GoRouterState state) =>
            EditorPage(projectId: state.pathParameters['projectId']!),
      ),
      GoRoute(
        path: '/project/:projectId/audio',
        builder: (BuildContext context, GoRouterState state) =>
            AudioPage(projectId: state.pathParameters['projectId']!),
      ),
      GoRoute(
        path: '/project/:projectId/preview',
        builder: (BuildContext context, GoRouterState state) => PreviewPage(
          projectId: state.pathParameters['projectId']!,
          initialFrame:
              int.tryParse(state.uri.queryParameters['frame'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
        path: '/project/:projectId/export',
        builder: (BuildContext context, GoRouterState state) =>
            ExportPage(projectId: state.pathParameters['projectId']!),
      ),
    ],
  );
}
