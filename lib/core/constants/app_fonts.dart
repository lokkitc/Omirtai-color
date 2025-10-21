import 'package:flutter/material.dart';

/// Centralized typography definitions for the application
class AppFonts {
  // Font families
  static const String primaryFont = 'Roboto';
  static const String secondaryFont = 'OpenSans';

  // Font sizes
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 28.0;
  static const double headlineSmall = 24.0;
  static const double titleLarge = 22.0;
  static const double titleMedium = 16.0;
  static const double titleSmall = 14.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 11.0;

  // Font weights
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // Text styles
  static TextStyle displayLargeStyle({Color color = Colors.black}) => TextStyle(
        fontFamily: primaryFont,
        fontSize: displayLarge,
        fontWeight: regular,
        color: color,
      );

  static TextStyle displayMediumStyle({Color color = Colors.black}) => TextStyle(
        fontFamily: primaryFont,
        fontSize: displayMedium,
        fontWeight: regular,
        color: color,
      );

  static TextStyle displaySmallStyle({Color color = Colors.black}) => TextStyle(
        fontFamily: primaryFont,
        fontSize: displaySmall,
        fontWeight: regular,
        color: color,
      );

  static TextStyle headlineLargeStyle({Color color = Colors.black}) => TextStyle(
        fontFamily: primaryFont,
        fontSize: headlineLarge,
        fontWeight: regular,
        color: color,
      );

  static TextStyle headlineMediumStyle({Color color = Colors.black}) => TextStyle(
        fontFamily: primaryFont,
        fontSize: headlineMedium,
        fontWeight: regular,
        color: color,
      );

  static TextStyle headlineSmallStyle({Color color = Colors.black}) => TextStyle(
        fontFamily: primaryFont,
        fontSize: headlineSmall,
        fontWeight: regular,
        color: color,
      );

  static TextStyle titleLargeStyle({Color color = Colors.black}) => TextStyle(
        fontFamily: primaryFont,
        fontSize: titleLarge,
        fontWeight: regular,
        color: color,
      );

  static TextStyle titleMediumStyle({Color color = Colors.black}) => TextStyle(
        fontFamily: primaryFont,
        fontSize: titleMedium,
        fontWeight: medium,
        color: color,
      );

  static TextStyle titleSmallStyle({Color color = Colors.black}) => TextStyle(
        fontFamily: primaryFont,
        fontSize: titleSmall,
        fontWeight: medium,
        color: color,
      );

  static TextStyle bodyLargeStyle({Color color = Colors.black}) => TextStyle(
        fontFamily: primaryFont,
        fontSize: bodyLarge,
        fontWeight: regular,
        color: color,
      );

  static TextStyle bodyMediumStyle({Color color = Colors.black}) => TextStyle(
        fontFamily: primaryFont,
        fontSize: bodyMedium,
        fontWeight: regular,
        color: color,
      );

  static TextStyle bodySmallStyle({Color color = Colors.black}) => TextStyle(
        fontFamily: primaryFont,
        fontSize: bodySmall,
        fontWeight: regular,
        color: color,
      );

  static TextStyle labelLargeStyle({Color color = Colors.black}) => TextStyle(
        fontFamily: primaryFont,
        fontSize: labelLarge,
        fontWeight: medium,
        color: color,
      );

  static TextStyle labelMediumStyle({Color color = Colors.black}) => TextStyle(
        fontFamily: primaryFont,
        fontSize: labelMedium,
        fontWeight: medium,
        color: color,
      );

  static TextStyle labelSmallStyle({Color color = Colors.black}) => TextStyle(
        fontFamily: primaryFont,
        fontSize: labelSmall,
        fontWeight: medium,
        color: color,
      );
}