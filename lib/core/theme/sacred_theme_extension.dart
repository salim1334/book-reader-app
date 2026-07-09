import 'package:flutter/material.dart';
import 'package:book_store/core/constants/app_colors.dart';

/// Semantic colors beyond [ColorScheme] (gold accent, chip surfaces, shadows).
@immutable
class SacredThemeExtension extends ThemeExtension<SacredThemeExtension> {
  const SacredThemeExtension({
    required this.gold,
    required this.surfaceContainerLow,
    required this.surfaceContainerHighest,
    required this.chipEmphasizedFill,
    required this.chipMutedFill,
    required this.patternDotAlpha,
    required this.cardShadowAlpha,
    required this.navBarFillAlpha,
  });

  final Color gold;
  final Color surfaceContainerLow;
  final Color surfaceContainerHighest;
  final Color chipEmphasizedFill;
  final Color chipMutedFill;
  final double patternDotAlpha;
  final double cardShadowAlpha;
  final double navBarFillAlpha;

  static const light = SacredThemeExtension(
    gold: AppColors.gold,
    surfaceContainerLow: AppColors.surfaceContainerLow,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
    chipEmphasizedFill: Color(0x59FED488),
    chipMutedFill: AppColors.surfaceContainerLow,
    patternDotAlpha: 0.04,
    cardShadowAlpha: 0.05,
    navBarFillAlpha: 0.88,
  );

  static const dark = SacredThemeExtension(
    gold: AppColors.gold,
    surfaceContainerLow: AppColors.darkSurfaceContainerLow,
    surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,
    chipEmphasizedFill: Color(0x335C4A18),
    chipMutedFill: AppColors.darkSurfaceContainerLow,
    patternDotAlpha: 0.08,
    cardShadowAlpha: 0.25,
    navBarFillAlpha: 0.92,
  );

  @override
  SacredThemeExtension copyWith({
    Color? gold,
    Color? surfaceContainerLow,
    Color? surfaceContainerHighest,
    Color? chipEmphasizedFill,
    Color? chipMutedFill,
    double? patternDotAlpha,
    double? cardShadowAlpha,
    double? navBarFillAlpha,
  }) {
    return SacredThemeExtension(
      gold: gold ?? this.gold,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainerHighest:
          surfaceContainerHighest ?? this.surfaceContainerHighest,
      chipEmphasizedFill: chipEmphasizedFill ?? this.chipEmphasizedFill,
      chipMutedFill: chipMutedFill ?? this.chipMutedFill,
      patternDotAlpha: patternDotAlpha ?? this.patternDotAlpha,
      cardShadowAlpha: cardShadowAlpha ?? this.cardShadowAlpha,
      navBarFillAlpha: navBarFillAlpha ?? this.navBarFillAlpha,
    );
  }

  @override
  SacredThemeExtension lerp(
    covariant ThemeExtension<SacredThemeExtension>? other,
    double t,
  ) {
    if (other is! SacredThemeExtension) return this;
    return SacredThemeExtension(
      gold: Color.lerp(gold, other.gold, t)!,
      surfaceContainerLow:
          Color.lerp(surfaceContainerLow, other.surfaceContainerLow, t)!,
      surfaceContainerHighest: Color.lerp(
        surfaceContainerHighest,
        other.surfaceContainerHighest,
        t,
      )!,
      chipEmphasizedFill:
          Color.lerp(chipEmphasizedFill, other.chipEmphasizedFill, t)!,
      chipMutedFill: Color.lerp(chipMutedFill, other.chipMutedFill, t)!,
      patternDotAlpha:
          patternDotAlpha + (other.patternDotAlpha - patternDotAlpha) * t,
      cardShadowAlpha:
          cardShadowAlpha + (other.cardShadowAlpha - cardShadowAlpha) * t,
      navBarFillAlpha:
          navBarFillAlpha + (other.navBarFillAlpha - navBarFillAlpha) * t,
    );
  }
}
