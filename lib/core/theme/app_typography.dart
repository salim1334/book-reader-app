import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography factories — always pass [ColorScheme] for correct light/dark text.
abstract final class AppTypography {
  static TextStyle ui(ColorScheme c) => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        height: 24 / 16,
        color: c.onSurface,
      );

  static TextStyle uiMedium(ColorScheme c) =>
      ui(c).copyWith(fontWeight: FontWeight.w500);

  static TextStyle labelSm(ColorScheme c) => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.05 * 12,
        color: c.onSurfaceVariant,
      );

  static TextStyle labelMd(ColorScheme c) => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w500,
        color: c.onSurface,
      );

  static TextStyle headlineLg(ColorScheme c) => GoogleFonts.notoSerif(
        fontSize: 28,
        height: 36 / 28,
        fontWeight: FontWeight.w600,
        color: c.primary,
      );

  static TextStyle headlineMd(ColorScheme c) => GoogleFonts.notoSerif(
        fontSize: 22,
        height: 30 / 22,
        fontWeight: FontWeight.w600,
        color: c.onSurface,
      );

  static TextStyle displayReading(ColorScheme c) => GoogleFonts.notoNaskhArabic(
        fontSize: 28,
        height: 1.6,
        fontWeight: FontWeight.w700,
        color: c.onSurface,
      );

  static TextStyle bodyReading(ColorScheme c) => GoogleFonts.sourceSerif4(
        fontSize: 20,
        height: 34 / 20,
        color: c.onSurface,
      );

  static TextStyle amharic(ColorScheme c) => GoogleFonts.notoSansEthiopic(
        fontSize: 16,
        height: 24 / 16,
        color: c.onSurface,
      );

  static TextTheme textTheme(ColorScheme c) => TextTheme(
        displayLarge: displayReading(c),
        headlineLarge: headlineLg(c),
        headlineMedium: headlineMd(c),
        titleLarge: headlineMd(c),
        titleMedium: labelMd(c).copyWith(fontWeight: FontWeight.w600),
        bodyLarge: ui(c),
        bodyMedium: ui(c),
        bodySmall: labelSm(c),
        labelLarge: labelMd(c),
        labelMedium: labelSm(c),
        labelSmall: labelSm(c),
      );
}

/// Convenient theme-aware text styles via [BuildContext.typo].
final class AppTypographyScope {
  const AppTypographyScope(this._c);

  final ColorScheme _c;

  TextStyle get ui => AppTypography.ui(_c);
  TextStyle get uiMedium => AppTypography.uiMedium(_c);
  TextStyle get labelSm => AppTypography.labelSm(_c);
  TextStyle get labelMd => AppTypography.labelMd(_c);
  TextStyle get headlineLg => AppTypography.headlineLg(_c);
  TextStyle get headlineMd => AppTypography.headlineMd(_c);
  TextStyle get displayReading => AppTypography.displayReading(_c);
  TextStyle get bodyReading => AppTypography.bodyReading(_c);
  TextStyle get amharic => AppTypography.amharic(_c);
}
