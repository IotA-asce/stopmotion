import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/app/theme/app_colors.dart';
import 'package:stop_motion/app/theme/app_spacing.dart';
import 'package:stop_motion/app/theme/app_theme.dart';

void main() {
  test('light theme uses release semantic colors', () {
    final ThemeData theme = AppTheme.light;

    expect(theme.colorScheme.primary, AppColors.lightAccent);
    expect(theme.scaffoldBackgroundColor, AppColors.lightSurface);
    expect(
      theme.extension<AppSemanticColors>()!.capture,
      AppColors.lightCapture,
    );
  });

  test('dark theme uses release semantic colors', () {
    final ThemeData theme = AppTheme.dark;

    expect(theme.colorScheme.primary, AppColors.darkAccent);
    expect(theme.scaffoldBackgroundColor, AppColors.darkSurface);
    expect(
      theme.extension<AppSemanticColors>()!.capture,
      AppColors.darkCapture,
    );
  });

  test('primary controls preserve minimum touch target', () {
    final ButtonStyle style = AppTheme.light.filledButtonTheme.style!;
    final Size minimum = style.minimumSize!.resolve(<WidgetState>{})!;

    expect(minimum.width, greaterThanOrEqualTo(AppSpacing.touchTarget));
    expect(minimum.height, greaterThanOrEqualTo(AppSpacing.touchTarget));
  });
}
