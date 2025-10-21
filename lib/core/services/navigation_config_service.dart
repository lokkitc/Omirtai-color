import 'package:flutter/material.dart';
import 'package:app/core/constants/navigation_config.dart';
import 'package:app/core/constants/theme_mode.dart';
import 'package:app/core/services/persistence_service.dart';

class NavigationConfigService extends ChangeNotifier {
  bool _showBottomNavBar = NavigationConfig.showBottomNavBar;
  bool _showDrawer = NavigationConfig.showDrawer;
  AppThemeMode _themeMode = AppThemeMode.system;

  bool get showBottomNavBar => _showBottomNavBar;
  bool get showDrawer => _showDrawer;
  AppThemeMode get themeMode => _themeMode;

  // Initialize with saved preferences
  Future<void> init() async {
    final savedTheme = PersistenceService().loadTheme();
    switch (savedTheme) {
      case 'light':
        _themeMode = AppThemeMode.light;
        break;
      case 'dark':
        _themeMode = AppThemeMode.dark;
        break;
      case 'system':
      default:
        _themeMode = AppThemeMode.system;
        break;
    }
    notifyListeners();
  }

  void toggleBottomNavBar(bool value) {
    _showBottomNavBar = value;
    notifyListeners();
  }

  void toggleDrawer(bool value) {
    _showDrawer = value;
    notifyListeners();
  }

  void setThemeMode(AppThemeMode themeMode) {
    _themeMode = themeMode;
    
    // Save to persistence service
    String themeString;
    switch (themeMode) {
      case AppThemeMode.light:
        themeString = 'light';
        break;
      case AppThemeMode.dark:
        themeString = 'dark';
        break;
      case AppThemeMode.system:
        themeString = 'system';
        break;
    }
    PersistenceService().saveTheme(themeString);
    
    notifyListeners();
  }

  ThemeMode getFlutterThemeMode() {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  void updateNavigationPreferences({
    bool? showBottomNavBar,
    bool? showDrawer,
    AppThemeMode? themeMode,
  }) {
    if (showBottomNavBar != null) {
      _showBottomNavBar = showBottomNavBar;
    }
    if (showDrawer != null) {
      _showDrawer = showDrawer;
    }
    if (themeMode != null) {
      _themeMode = themeMode;
    }
    notifyListeners();
  }
}

// Singleton instance
final navigationConfigService = NavigationConfigService();