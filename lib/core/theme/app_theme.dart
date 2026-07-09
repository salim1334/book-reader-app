import 'package:flutter/material.dart';
import 'package:book_store/core/constants/app_colors.dart';
import 'package:book_store/core/constants/app_sizes.dart';
import 'package:book_store/core/theme/app_typography.dart';
import 'package:book_store/core/theme/custom_themes/app_bar_theme.dart';
import 'package:book_store/core/theme/custom_themes/bottom_sheet_theme.dart';
import 'package:book_store/core/theme/custom_themes/button_theme.dart';
import 'package:book_store/core/theme/custom_themes/chip_theme.dart';
import 'package:book_store/core/theme/custom_themes/input_theme.dart';
import 'package:book_store/core/theme/custom_themes/text_theme.dart';
import 'package:book_store/core/theme/sacred_theme_extension.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme => _build(
        scheme: AppColors.lightScheme,
        sacred: SacredThemeExtension.light,
        scaffoldBg: AppColors.background,
        textTheme: ForgeTextTheme.light,
        appBar: ForgeAppBarTheme.light,
        buttons: ForgeButtonTheme.light,
        inputs: ForgeInputTheme.light,
        chips: ForgeChipTheme.light,
        sheets: ForgeBottomSheetTheme.light,
      );

  static ThemeData get darkTheme => _build(
        scheme: AppColors.darkScheme,
        sacred: SacredThemeExtension.dark,
        scaffoldBg: AppColors.darkBackground,
        textTheme: ForgeTextTheme.dark,
        appBar: ForgeAppBarTheme.dark,
        buttons: ForgeButtonTheme.dark,
        inputs: ForgeInputTheme.dark,
        chips: ForgeChipTheme.dark,
        sheets: ForgeBottomSheetTheme.dark,
      );

  static ThemeData _build({
    required ColorScheme scheme,
    required SacredThemeExtension sacred,
    required Color scaffoldBg,
    required TextTheme textTheme,
    required AppBarTheme appBar,
    required ElevatedButtonThemeData buttons,
    required InputDecorationTheme inputs,
    required ChipThemeData chips,
    required BottomSheetThemeData sheets,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme.copyWith(surfaceTint: Colors.transparent),
      scaffoldBackgroundColor: scaffoldBg,
      canvasColor: scaffoldBg,
      textTheme: textTheme,
      appBarTheme: appBar,
      elevatedButtonTheme: buttons,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: scheme.primary),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurface,
        ),
      ),
      inputDecorationTheme: inputs,
      chipTheme: chips,
      bottomSheetTheme: sheets,
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.5),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        titleTextStyle: AppTypography.headlineMd(scheme),
        contentTextStyle: AppTypography.ui(scheme).copyWith(
          color: scheme.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        textStyle: AppTypography.labelMd(scheme),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
      ),
      extensions: [sacred],
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface.withValues(
          alpha: sacred.navBarFillAlpha,
        ),
        indicatorColor: scheme.primaryContainer.withValues(alpha: 0.35),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppTypography.labelSm(scheme).copyWith(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
