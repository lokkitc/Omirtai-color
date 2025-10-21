import 'package:flutter/foundation.dart';

class NavigationService extends ChangeNotifier {
  bool _showBottomNavBar = true;
  bool _showDrawer = true;

  bool get showBottomNavBar => _showBottomNavBar;
  bool get showDrawer => _showDrawer;

  void toggleBottomNavBar(bool value) {
    _showBottomNavBar = value;
    notifyListeners();
  }

  void toggleDrawer(bool value) {
    _showDrawer = value;
    notifyListeners();
  }

  void updateNavigationPreferences({
    bool? showBottomNavBar,
    bool? showDrawer,
  }) {
    if (showBottomNavBar != null) {
      _showBottomNavBar = showBottomNavBar;
    }
    if (showDrawer != null) {
      _showDrawer = showDrawer;
    }
    notifyListeners();
  }
}