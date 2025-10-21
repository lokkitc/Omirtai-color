import 'package:flutter/material.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_fonts.dart';
import 'package:app/core/constants/app_spacing.dart';

/// Centralized design tokens that combine all design constants
class AppDesignTokens {
  // Colors
  static const Color primaryColor = AppColors.primary;
  static const Color secondaryColor = AppColors.secondary;
  static const Color backgroundColor = AppColors.background;
  static const Color surfaceColor = AppColors.surface;
  static const Color errorColor = AppColors.error;
  static const Color textColorPrimary = AppColors.onBackground;
  static const Color textColorSecondary = AppColors.gray;

  // Typography
  static const TextStyle displayLarge = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.displayLarge,
    fontWeight: AppFonts.regular,
    color: AppColors.onBackground,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.displayMedium,
    fontWeight: AppFonts.regular,
    color: AppColors.onBackground,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.displaySmall,
    fontWeight: AppFonts.regular,
    color: AppColors.onBackground,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.headlineLarge,
    fontWeight: AppFonts.regular,
    color: AppColors.onBackground,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.headlineMedium,
    fontWeight: AppFonts.regular,
    color: AppColors.onBackground,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.headlineSmall,
    fontWeight: AppFonts.regular,
    color: AppColors.onBackground,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.titleLarge,
    fontWeight: AppFonts.regular,
    color: AppColors.onBackground,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.titleMedium,
    fontWeight: AppFonts.medium,
    color: AppColors.onBackground,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.titleSmall,
    fontWeight: AppFonts.medium,
    color: AppColors.onBackground,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.bodyLarge,
    fontWeight: AppFonts.regular,
    color: AppColors.onBackground,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.bodyMedium,
    fontWeight: AppFonts.regular,
    color: AppColors.onBackground,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.bodySmall,
    fontWeight: AppFonts.regular,
    color: AppColors.onBackground,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.labelLarge,
    fontWeight: AppFonts.medium,
    color: AppColors.onBackground,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.labelMedium,
    fontWeight: AppFonts.medium,
    color: AppColors.onBackground,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: AppFonts.labelSmall,
    fontWeight: AppFonts.medium,
    color: AppColors.onBackground,
  );

  // Spacing
  static const double spacingXs = AppSpacing.xs;
  static const double spacingS = AppSpacing.s;
  static const double spacingM = AppSpacing.m;
  static const double spacingL = AppSpacing.l;
  static const double spacingXl = AppSpacing.xl;
  static const double spacingXxl = AppSpacing.xxl;
  static const double spacingXxxl = AppSpacing.xxxl;

  // Border radius
  static const double borderRadiusXs = AppSpacing.radiusXs;
  static const double borderRadiusS = AppSpacing.radiusS;
  static const double borderRadiusM = AppSpacing.radiusM;
  static const double borderRadiusL = AppSpacing.radiusL;
  static const double borderRadiusXl = AppSpacing.radiusXl;
  static const double borderRadiusCircular = AppSpacing.radiusCircular;
}