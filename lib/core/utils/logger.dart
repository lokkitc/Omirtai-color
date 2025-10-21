import 'package:flutter/foundation.dart';

class Logger {
  static void debug(String message) {
    // In a real app, you might want to use a proper logging package
    // For now, we'll just print to the console in debug mode
    if (kDebugMode) {
      print('DEBUG: $message');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      print('INFO: $message');
    }
  }

  static void error(String message) {
    if (kDebugMode) {
      print('ERROR: $message');
    }
  }
}