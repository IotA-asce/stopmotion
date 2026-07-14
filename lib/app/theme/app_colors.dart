import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color lightSurface = Color(0xFFF7F7F5);
  static const Color lightSurfaceRaised = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFECEDEA);
  static const Color lightTextPrimary = Color(0xFF17191A);
  static const Color lightTextSecondary = Color(0xFF5F6567);
  static const Color lightAccent = Color(0xFF087E6B);
  static const Color lightCapture = Color(0xFFD33C32);
  static const Color lightWarning = Color(0xFFA65B00);
  static const Color lightDanger = Color(0xFFB3261E);
  static const Color lightFocus = Color(0xFF315EFB);

  static const Color darkSurface = Color(0xFF151719);
  static const Color darkSurfaceRaised = Color(0xFF202326);
  static const Color darkSurfaceMuted = Color(0xFF2A2E31);
  static const Color darkTextPrimary = Color(0xFFF4F5F2);
  static const Color darkTextSecondary = Color(0xFFB8BDBE);
  static const Color darkAccent = Color(0xFF45C9AC);
  static const Color darkCapture = Color(0xFFF26055);
  static const Color darkWarning = Color(0xFFFFB65C);
  static const Color darkDanger = Color(0xFFFFB4AB);
  static const Color darkFocus = Color(0xFF8EA8FF);
}

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.surfaceRaised,
    required this.surfaceMuted,
    required this.textSecondary,
    required this.capture,
    required this.warning,
    required this.focus,
  });

  final Color surfaceRaised;
  final Color surfaceMuted;
  final Color textSecondary;
  final Color capture;
  final Color warning;
  final Color focus;

  @override
  AppSemanticColors copyWith({
    Color? surfaceRaised,
    Color? surfaceMuted,
    Color? textSecondary,
    Color? capture,
    Color? warning,
    Color? focus,
  }) {
    return AppSemanticColors(
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      textSecondary: textSecondary ?? this.textSecondary,
      capture: capture ?? this.capture,
      warning: warning ?? this.warning,
      focus: focus ?? this.focus,
    );
  }

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) {
      return this;
    }
    return AppSemanticColors(
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      capture: Color.lerp(capture, other.capture, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      focus: Color.lerp(focus, other.focus, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppSemanticColors get semanticColors =>
      Theme.of(this).extension<AppSemanticColors>()!;
}
