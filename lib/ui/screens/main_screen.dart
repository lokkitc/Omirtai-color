import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/constants/app_constants.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_spacing.dart';
import 'package:app/core/constants/app_fonts.dart';
import 'package:app/core/services/navigation_config_service.dart';
import 'package:app/localization/app_localizations.dart';
import 'package:app/features/home/view/home_screen.dart';
import 'package:app/features/colors/view/colors_screen.dart';
import 'package:app/features/calculators/view/calculators_screen.dart';
import 'package:app/features/settings/view/settings_screen.dart';
import 'package:app/features/modeling/view/modeling_screen.dart';
import 'package:app/core/services/locale_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const HomeScreen(),
    const ColorsScreen(),
    const CalculatorsScreen(),
    const ModelingScreen(),
    const SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Используем Consumer для отслеживания изменений локализации
    return Consumer<LocaleService>(
      builder: (context, localeService, child) {
        final localizations = AppLocalizations.of(context);
        
        final screenTitles = [
          localizations.translate('home'),
          localizations.translate('colors'),
          localizations.translate('calculators'),
          localizations.translate('modelingScreen'),
          localizations.translate('settings'),
        ];

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: AppBar(
              title: Text(
                screenTitles[_currentIndex],
                style: const TextStyle(
                  fontWeight: FontWeight.w600, // SemiBold
                ),
              ),
              centerTitle: true,
              // Removed the menu button from actions since we want to remove the duplicate drawer navigation
            ),
          ),
          body: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const NeverScrollableScrollPhysics(), // Disable swipe to maintain tab control
            children: _screens,
          ),
          bottomNavigationBar: navigationConfigService.showBottomNavBar
              ? BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: _onTabTapped,
                  selectedItemColor: Theme.of(context).primaryColor,
                  unselectedItemColor: AppColors.gray,
                  selectedFontSize: AppFonts.titleMedium, // AppFonts.titleSmall
                  unselectedFontSize: AppFonts.bodySmall, // AppFonts.bodySmall
                  type: BottomNavigationBarType.fixed,
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  elevation: 0,
                  items: [
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.home_outlined),
                      activeIcon: const Icon(Icons.home),
                      label: localizations.translate('home'),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.color_lens_outlined),
                      activeIcon: const Icon(Icons.color_lens),
                      label: localizations.translate('colors'),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.calculate_outlined),
                      activeIcon: const Icon(Icons.calculate),
                      label: localizations.translate('calculators'),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.view_in_ar_outlined),
                      activeIcon: const Icon(Icons.view_in_ar),
                      label: localizations.translate('modelingScreen'),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.settings_outlined),
                      activeIcon: const Icon(Icons.settings),
                      label: localizations.translate('settings'),
                    ),
                  ],
                )
              : null,
          drawer: navigationConfigService.showDrawer ? _buildDrawer(localizations, context) : null,
        );
      },
    );
  }

  Widget _buildDrawer(AppLocalizations localizations, BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              border: Border(), // Remove the default bottom border
            ),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).appBarTheme.foregroundColor?.withAlpha(51), // 20% opacity
                  child: Icon(
                    Icons.app_registration,
                    color: Theme.of(context).appBarTheme.foregroundColor,
                    size: 24,
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  localizations.translate('appTitle'), // Используем локализованный заголовок
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  localizations.translate('navigation'),
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor?.withAlpha(204), // 80% opacity
                    fontSize: AppFonts.bodySmall
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s), // Add horizontal padding
              children: [
                const SizedBox(height: AppSpacing.s),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: Text(localizations.translate('home')),
                  selected: _currentIndex == 0,
                  selectedTileColor: Theme.of(context).primaryColor.withAlpha(25), // 10% opacity
                  onTap: () {
                    Navigator.pop(context);
                    _onTabTapped(0);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(AppSpacing.s),
                      left: Radius.circular(AppSpacing.s),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: Text(localizations.translate('colors')),
                  selected: _currentIndex == 1,
                  selectedTileColor: Theme.of(context).primaryColor.withAlpha(25), // 10% opacity
                  onTap: () {
                    Navigator.pop(context);
                    _onTabTapped(1);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(AppSpacing.s),
                      left: Radius.circular(AppSpacing.s),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                ListTile(
                  leading: const Icon(Icons.calculate),
                  title: Text(localizations.translate('calculators')),
                  selected: _currentIndex == 2,
                  selectedTileColor: Theme.of(context).primaryColor.withAlpha(25), // 10% opacity
                  onTap: () {
                    Navigator.pop(context);
                    _onTabTapped(2);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(AppSpacing.s),
                      left: Radius.circular(AppSpacing.s),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                ListTile(
                  leading: const Icon(Icons.view_in_ar),
                  title: Text(localizations.translate('modelingScreen')),
                  selected: _currentIndex == 3,
                  selectedTileColor: Theme.of(context).primaryColor.withAlpha(25), // 10% opacity
                  onTap: () {
                    Navigator.pop(context);
                    _onTabTapped(3);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(AppSpacing.s),
                      left: Radius.circular(AppSpacing.s),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(localizations.translate('settings')),
                  selected: _currentIndex == 4,
                  selectedTileColor: Theme.of(context).primaryColor.withAlpha(25), // 10% opacity
                  onTap: () {
                    Navigator.pop(context);
                    _onTabTapped(4);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(AppSpacing.s),
                      left: Radius.circular(AppSpacing.s),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                const Divider(),
                AboutListTile(
                  icon: const Icon(Icons.info),
                  applicationName: localizations.translate('appTitle'), // Используем локализованный заголовок
                  applicationVersion: AppConstants.appVersion,
                  aboutBoxChildren: [
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      localizations.translate('settingsNote'),
                      style: const TextStyle(fontSize: AppFonts.bodySmall),
                    ),
                  ],
                  child: Text(localizations.translate('appTitle')), // Используем локализованный заголовок
                ),
                const SizedBox(height: AppSpacing.s),
              ],
            ),
          ),
        ],
      ),
    );
  }
}