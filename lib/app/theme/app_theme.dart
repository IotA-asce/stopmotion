import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;
    final Color surface = isLight
        ? AppColors.lightSurface
        : AppColors.darkSurface;
    final Color raised = isLight
        ? AppColors.lightSurfaceRaised
        : AppColors.darkSurfaceRaised;
    final Color muted = isLight
        ? AppColors.lightSurfaceMuted
        : AppColors.darkSurfaceMuted;
    final Color primary = isLight
        ? AppColors.lightAccent
        : AppColors.darkAccent;
    final Color onSurface = isLight
        ? AppColors.lightTextPrimary
        : AppColors.darkTextPrimary;
    final Color secondaryText = isLight
        ? AppColors.lightTextSecondary
        : AppColors.darkTextSecondary;
    final Color danger = isLight ? AppColors.lightDanger : AppColors.darkDanger;
    final Color focus = isLight ? AppColors.lightFocus : AppColors.darkFocus;

    final ColorScheme colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: isLight ? Colors.white : AppColors.darkSurface,
      secondary: focus,
      onSecondary: Colors.white,
      error: danger,
      onError: isLight ? Colors.white : AppColors.darkSurface,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: muted,
      outline: secondaryText,
      outlineVariant: muted,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: onSurface,
      onInverseSurface: surface,
      inversePrimary: primary,
    );

    final ThemeData base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      focusColor: focus,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: raised,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: BorderSide(color: muted),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: raised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: raised,
        modalBackgroundColor: raised,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.cardRadius),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(
            AppSpacing.touchTarget,
            AppSpacing.touchTarget,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(
            AppSpacing.touchTarget,
            AppSpacing.touchTarget,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: raised,
        indicatorColor: primary.withValues(alpha: 0.18),
        height: 72,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: raised,
        indicatorColor: primary.withValues(alpha: 0.18),
        minWidth: 80,
        minExtendedWidth: 200,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
      extensions: <ThemeExtension<dynamic>>[
        AppSemanticColors(
          surfaceRaised: raised,
          surfaceMuted: muted,
          textSecondary: secondaryText,
          capture: isLight ? AppColors.lightCapture : AppColors.darkCapture,
          warning: isLight ? AppColors.lightWarning : AppColors.darkWarning,
          focus: focus,
        ),
      ],
    );
  }
}
