import 'package:flutter/material.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_fonts.dart';
import 'package:app/core/constants/app_spacing.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.black,
      elevation: 0,
      shadowColor: Color(0x1A000000), // Мягкая черная с прозрачностью (10%)
      surfaceTintColor: Colors.transparent,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      error: AppColors.error,
      onError: AppColors.onError,
      surface: AppColors.background,
      onSurface: AppColors.onBackground,
    ),
    scaffoldBackgroundColor: AppColors.lightscaffoldBackgroundColor,
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.displayLarge,
        fontWeight: AppFonts.regular,
        color: AppColors.onBackground,
      ),
      displayMedium: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.displayMedium,
        fontWeight: AppFonts.regular,
        color: AppColors.onBackground,
      ),
      displaySmall: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.displaySmall,
        fontWeight: AppFonts.regular,
        color: AppColors.onBackground,
      ),
      headlineLarge: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.headlineLarge,
        fontWeight: AppFonts.regular,
        color: AppColors.onBackground,
      ),
      headlineMedium: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.headlineMedium,
        fontWeight: AppFonts.regular,
        color: AppColors.onBackground,
      ),
      headlineSmall: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.headlineSmall,
        fontWeight: AppFonts.regular,
        color: AppColors.onBackground,
      ),
      titleLarge: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.titleLarge,
        fontWeight: AppFonts.regular,
        color: AppColors.onBackground,
      ),
      titleMedium: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.titleMedium,
        fontWeight: AppFonts.medium,
        color: AppColors.onBackground,
      ),
      titleSmall: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.titleSmall,
        fontWeight: AppFonts.medium,
        color: AppColors.onBackground,
      ),
      bodyLarge: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.bodyLarge,
        fontWeight: AppFonts.regular,
        color: AppColors.onBackground,
      ),
      bodyMedium: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.bodyMedium,
        fontWeight: AppFonts.regular,
        color: AppColors.onBackground,
      ),
      bodySmall: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.bodySmall,
        fontWeight: AppFonts.regular,
        color: AppColors.onBackground,
      ),
      labelLarge: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.labelLarge,
        fontWeight: AppFonts.medium,
        color: AppColors.onBackground,
      ),
      labelMedium: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.labelMedium,
        fontWeight: AppFonts.medium,
        color: AppColors.onBackground,
      ),
      labelSmall: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.labelSmall,
        fontWeight: AppFonts.medium,
        color: AppColors.onBackground,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        textStyle: TextStyle(
          fontFamily: AppFonts.primaryFont,
          fontSize: AppFonts.labelLarge,
          fontWeight: AppFonts.medium,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusS),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
        borderSide: const BorderSide(
          color: AppColors.gray,
          width: AppSpacing.inputBorderWidth,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: AppSpacing.inputBorderWidth,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
        borderSide: const BorderSide(
          color: AppColors.lightGray,
          width: AppSpacing.inputBorderWidth,
        ),
      ),
      labelStyle: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.bodySmall,
        color: AppColors.gray,
      ),
      floatingLabelStyle: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.bodySmall,
        color: AppColors.primary,
      ),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.black,
      foregroundColor: AppColors.white,
      elevation: 0,
      shadowColor: Color(0x1A000000), // Мягкая черная с прозрачностью (10%)
      surfaceTintColor: Colors.transparent,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      error: AppColors.error,
      onError: AppColors.onError,
      surface: AppColors.black,
      onSurface: AppColors.white,
    ),
    scaffoldBackgroundColor: AppColors.darkscaffoldBackgroundColor,
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.displayLarge,
        fontWeight: AppFonts.regular,
        color: AppColors.white,
      ),
      displayMedium: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.displayMedium,
        fontWeight: AppFonts.regular,
        color: AppColors.white,
      ),
      displaySmall: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.displaySmall,
        fontWeight: AppFonts.regular,
        color: AppColors.white,
      ),
      headlineLarge: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.headlineLarge,
        fontWeight: AppFonts.regular,
        color: AppColors.white,
      ),
      headlineMedium: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.headlineMedium,
        fontWeight: AppFonts.regular,
        color: AppColors.white,
      ),
      headlineSmall: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.headlineSmall,
        fontWeight: AppFonts.regular,
        color: AppColors.white,
      ),
      titleLarge: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.titleLarge,
        fontWeight: AppFonts.regular,
        color: AppColors.white,
      ),
      titleMedium: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.titleMedium,
        fontWeight: AppFonts.medium,
        color: AppColors.white,
      ),
      titleSmall: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.titleSmall,
        fontWeight: AppFonts.medium,
        color: AppColors.white,
      ),
      bodyLarge: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.bodyLarge,
        fontWeight: AppFonts.regular,
        color: AppColors.white,
      ),
      bodyMedium: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.bodyMedium,
        fontWeight: AppFonts.regular,
        color: AppColors.white,
      ),
      bodySmall: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.bodySmall,
        fontWeight: AppFonts.regular,
        color: AppColors.white,
      ),
      labelLarge: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.labelLarge,
        fontWeight: AppFonts.medium,
        color: AppColors.white,
      ),
      labelMedium: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.labelMedium,
        fontWeight: AppFonts.medium,
        color: AppColors.white,
      ),
      labelSmall: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.labelSmall,
        fontWeight: AppFonts.medium,
        color: AppColors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        textStyle: TextStyle(
          fontFamily: AppFonts.primaryFont,
          fontSize: AppFonts.labelLarge,
          fontWeight: AppFonts.medium,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusS),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
        borderSide: const BorderSide(
          color: AppColors.gray,
          width: AppSpacing.inputBorderWidth,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: AppSpacing.inputBorderWidth,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
        borderSide: const BorderSide(
          color: AppColors.lightGray,
          width: AppSpacing.inputBorderWidth,
        ),
      ),
      labelStyle: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.bodySmall,
        color: AppColors.gray,
      ),
      floatingLabelStyle: TextStyle(
        fontFamily: AppFonts.primaryFont,
        fontSize: AppFonts.bodySmall,
        color: AppColors.primary,
      ),
    ),
  );
}