import 'package:data4impact/core/theme/app_text_Style.dart';
import 'package:flutter/material.dart';

import 'color.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.lightBackground,
  cardColor: AppColors.lightCard,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.lightBackground,
    foregroundColor: AppColors.lightText,
    elevation: 0,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    labelStyle: TextStyle(color: Colors.grey.shade700),
  ),
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
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.darkBackground,
  cardColor: AppColors.darkCard,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkBackground,
    foregroundColor: AppColors.darkText,
    elevation: 0,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade800.withOpacity(0.4),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade600),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade600),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    labelStyle: const TextStyle(color: Colors.white70),
  ),
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