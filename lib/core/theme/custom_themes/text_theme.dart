import 'package:flutter/material.dart';
import 'package:book_store/core/constants/app_colors.dart';
import 'package:book_store/core/theme/app_typography.dart';

abstract final class ForgeTextTheme {
  static TextTheme get light => AppTypography.textTheme(AppColors.lightScheme);
  static TextTheme get dark => AppTypography.textTheme(AppColors.darkScheme);
}
