import 'package:data4impact/core/theme/app_text_Style.dart';
import 'package:flutter/material.dart';

import 'color.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.accent,
    onSecondary: Colors.white,
    surface: AppColors.lightBackground,
    onSurface: AppColors.lightText,
    background: AppColors.lightBackground,
    onBackground: AppColors.lightText,
    error: AppColors.error,
  ),
  textTheme: TextTheme(
    displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.lightText),
    displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.lightText),
    displaySmall: AppTextStyles.displaySmall.copyWith(color: AppColors.lightText),
    headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.lightText),
    headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.lightText),
    headlineSmall: AppTextStyles.headlineSmall.copyWith(color: AppColors.lightText),
    titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.lightText),
    titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.lightText),
    titleSmall: AppTextStyles.titleSmall.copyWith(color: AppColors.lightText),
    bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.lightText),
    bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightText),
    bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.lightText),
    labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.lightText),
    labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.lightText),
    labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.lightText),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.accent,
    onSecondary: Colors.white,
    surface: AppColors.darkBackground,
    onSurface: AppColors.darkText,
    background: AppColors.darkBackground,
    onBackground: AppColors.darkText,
    error: AppColors.error,
  ),
  textTheme: TextTheme(
    displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.darkText),
    displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.darkText),
    displaySmall: AppTextStyles.displaySmall.copyWith(color: AppColors.darkText),
    headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.darkText),
    headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.darkText),
    headlineSmall: AppTextStyles.headlineSmall.copyWith(color: AppColors.darkText),
    titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.darkText),
    titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.darkText),
    titleSmall: AppTextStyles.titleSmall.copyWith(color: AppColors.darkText),
    bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.darkText),
    bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkText),
    bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.darkText),
    labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.darkText),
    labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.darkText),
    labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.darkText),
  ),
);