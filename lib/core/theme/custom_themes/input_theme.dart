import 'package:flutter/material.dart';
import 'package:book_store/core/constants/app_colors.dart';
import 'package:book_store/core/constants/app_sizes.dart';

abstract final class ForgeInputTheme {
  static InputDecorationTheme _base(ColorScheme scheme) => InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          borderSide: BorderSide.none,
        ),
      );

  static InputDecorationTheme get light =>
      _base(AppColors.lightScheme);

  static InputDecorationTheme get dark => _base(AppColors.darkScheme);
}
