import 'package:flutter/material.dart';
import 'package:book_store/core/theme/app_typography.dart';
import 'package:book_store/core/theme/sacred_theme_extension.dart';

extension SacredThemeContext on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  SacredThemeExtension get sacred =>
      Theme.of(this).extension<SacredThemeExtension>()!;

  /// Theme-aware typography (correct text colors in light and dark).
  AppTypographyScope get typo => AppTypographyScope(colorScheme);
}
