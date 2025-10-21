import 'package:flutter/material.dart';

/// Centralized color definitions for the application
class AppColors {
  // Primary colors
  // static const Color primary = Color.fromARGB(255, 255, 255, 255);
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryVariant = Color.fromRGBO(239, 239, 239, 1);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);

  static const Color lightscaffoldBackgroundColor = Color.fromRGBO(239, 239, 239, 1);
  static const Color darkscaffoldBackgroundColor = Color.fromARGB(255, 23, 23, 23);

  // Background colors
  static const Color background = Color.fromRGBO(239, 239, 239, 1);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color scaffoldBackground = Color(0xFFFAFAFA);

  // Text colors
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF000000);
  static const Color onBackground = Color(0xFF000000);
  static const Color onSurface = Color(0xFF000000);

  // Error colors
  static const Color error = Color(0xFFB00020);
  static const Color onError = Color(0xFFFFFFFF);

  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color gray = Color(0xFF9E9E9E);
  static const Color lightGray = Color(0xFFE0E0E0);
  static const Color darkGray = Color(0xFF424242);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);
}