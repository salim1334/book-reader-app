import 'package:flutter/material.dart';
import 'package:book_store/core/constants/app_colors.dart';

abstract final class ForgeChipTheme {
  static ChipThemeData _base(ColorScheme scheme) => ChipThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        labelStyle: TextStyle(color: scheme.onSurface),
        side: BorderSide(color: scheme.outlineVariant),
      );

  static ChipThemeData get light => _base(AppColors.lightScheme);
  static ChipThemeData get dark => _base(AppColors.darkScheme);
}
