import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/app_error_view.dart';
import '../core/widgets/app_scaffold.dart';
import '../core/widgets/feature_boundary_page.dart';
import '../features/audio/presentation/audio_page.dart';
import '../features/capture/presentation/capture_page.dart';
import '../features/editor/presentation/editor_page.dart';
import '../features/onboarding/presentation/onboarding_page.dart';
import '../features/preview/presentation/preview_page.dart';
import '../features/projects/presentation/create_project_page.dart';
import '../features/projects/presentation/projects_page.dart';
import '../features/recovery/presentation/recovery_page.dart';
import '../features/settings/presentation/settings_page.dart';

abstract final class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String projects = '/projects';
  static const String settings = '/settings';
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
      _workspaceRoute('export', 'Export', 7),
    ],
  );
}

GoRoute _workspaceRoute(String path, String title, int phase) {
  return GoRoute(
    path: '/project/:projectId/$path',
    builder: (BuildContext context, GoRouterState state) {
      return FeatureBoundaryPage(
        title: title,
        projectId: state.pathParameters['projectId'],
        phase: phase,
      );
    },
  );
}
