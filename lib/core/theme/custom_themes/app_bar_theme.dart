import 'package:book_store/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

abstract final class ForgeAppBarTheme {
  static AppBarTheme get light => const AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: AppColors.background,
    foregroundColor: AppColors.onSurface,
    iconTheme: IconThemeData(color: AppColors.onSurface),
  );

  static AppBarTheme get dark => const AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: AppColors.darkBackground,
    foregroundColor: AppColors.darkOnSurface,
    iconTheme: IconThemeData(color: AppColors.darkOnSurface),
  );
}
