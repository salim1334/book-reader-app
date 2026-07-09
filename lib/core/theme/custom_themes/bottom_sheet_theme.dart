import 'package:flutter/material.dart';
import 'package:book_store/core/constants/app_colors.dart';
import 'package:book_store/core/constants/app_sizes.dart';

abstract final class ForgeBottomSheetTheme {
  static BottomSheetThemeData _base(Color surface) => BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.lg),
          ),
        ),
      );

  static BottomSheetThemeData get light =>
      _base(AppColors.surface);

  static BottomSheetThemeData get dark =>
      _base(AppColors.darkSurface);
}
