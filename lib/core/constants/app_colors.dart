import 'package:flutter/material.dart';

/// Sacred Minimalist palette — use [ColorScheme] + [SacredThemeExtension] in UI.
abstract final class AppColors {
  // Brand (shared)
  static const Color primary = Color(0xFF003527);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF064E3B);
  static const Color onPrimaryContainer = Color(0xFF80BEA6);
  static const Color secondary = Color(0xFF775A19);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFED488);
  static const Color onSecondaryContainer = Color(0xFF785A1A);
  static const Color gold = Color(0xFFD4AF37);
  static const Color tertiary = Color(0xFF2D2E2C);
  static const Color onTertiary = Color(0xFFFFFFFF);

  // Light surfaces
  static const Color background = Color(0xFFFDFBF7);
  static const Color onBackground = Color(0xFF121C2A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF121C2A);
  static const Color onSurfaceVariant = Color(0xFF404944);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainerHighest = Color(0xFFD9E3F6);
  static const Color outline = Color(0xFF707974);
  static const Color outlineVariant = Color(0xFFBFC9C3);

  // Dark surfaces
  static const Color darkBackground = Color(0xFF0A1210);
  static const Color darkSurface = Color(0xFF161F1C);
  static const Color darkOnSurface = Color(0xFFE8F0EC);
  static const Color darkOnSurfaceVariant = Color(0xFFA8B8B0);
  static const Color darkSurfaceContainerLow = Color(0xFF1E2824);
  static const Color darkSurfaceContainerHighest = Color(0xFF2E3D36);
  static const Color darkPrimary = Color(0xFF95D3BA);
  static const Color darkOnPrimary = Color(0xFF002117);
  static const Color darkPrimaryContainer = Color(0xFF0D3D2E);
  static const Color darkOnPrimaryContainer = Color(0xFFB8E6D4);
  static const Color darkSecondary = Color(0xFFE8C878);
  static const Color darkOnSecondary = Color(0xFF3D2E0A);
  static const Color darkSecondaryContainer = Color(0xFF5C4A18);
  static const Color darkOnSecondaryContainer = Color(0xFFF5D9A0);
  static const Color darkOutline = Color(0xFF5C6B64);
  static const Color darkOutlineVariant = Color(0xFF3D4A44);

  // Semantic
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkOnError = Color(0xFF690005);

  // Legacy aliases
  static const Color lightBackground = background;
  static const Color cardLight = surface;
  static const Color cardDark = darkSurface;

  static ColorScheme get lightScheme => const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        error: error,
        onError: onError,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainerHighest: surfaceContainerHighest,
      );

  static ColorScheme get darkScheme => const ColorScheme(
        brightness: Brightness.dark,
        primary: darkPrimary,
        onPrimary: darkOnPrimary,
        primaryContainer: darkPrimaryContainer,
        onPrimaryContainer: darkOnPrimaryContainer,
        secondary: darkSecondary,
        onSecondary: darkOnSecondary,
        secondaryContainer: darkSecondaryContainer,
        onSecondaryContainer: darkOnSecondaryContainer,
        tertiary: Color(0xFF9CA89F),
        onTertiary: darkBackground,
        error: darkError,
        onError: darkOnError,
        surface: darkSurface,
        onSurface: darkOnSurface,
        onSurfaceVariant: darkOnSurfaceVariant,
        outline: darkOutline,
        outlineVariant: darkOutlineVariant,
        surfaceContainerLow: darkSurfaceContainerLow,
        surfaceContainerHighest: darkSurfaceContainerHighest,
      );
}
