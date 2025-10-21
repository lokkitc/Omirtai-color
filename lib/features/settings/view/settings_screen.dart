
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/constants/theme_mode.dart';
import 'package:app/core/constants/app_fonts.dart';
import 'package:app/core/constants/app_spacing.dart';
import 'package:app/core/services/navigation_config_service.dart';
import 'package:app/core/services/locale_service.dart';
import 'package:app/localization/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _showBottomNavBar;
  late bool _showDrawer;
  late AppThemeMode _themeMode;
  late Locale _selectedLocale;

  @override
  void initState() {
    super.initState();
    _showBottomNavBar = navigationConfigService.showBottomNavBar;
    _showDrawer = navigationConfigService.showDrawer;
    _themeMode = navigationConfigService.themeMode;
    _selectedLocale = context.read<LocaleService>().locale;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final localeService = context.read<LocaleService>();
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.translate('settings'),
                style: TextStyle(
                  fontSize: AppFonts.headlineSmall,
                  fontWeight: AppFonts.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                localizations.translate('settings_note'),
                style: TextStyle(
                  fontSize: AppFonts.bodySmall,
                  color: Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              Card(
                color: Theme.of(context).appBarTheme.backgroundColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.translate('navigation'),
                        style: TextStyle(
                          fontSize: AppFonts.titleLarge,
                          fontWeight: AppFonts.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      SwitchListTile(
                        title: Text(localizations.translate('show_bottom_nav_bar')),
                        value: _showBottomNavBar,
                        onChanged: (bool value) {
                          // Prevent disabling both navigation options
                          if (!value && !_showDrawer) {
                            // Show a warning snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(localizations.translate('navigation_warning')),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          
                          setState(() {
                            _showBottomNavBar = value;
                            navigationConfigService.toggleBottomNavBar(value);
                          });
                        },
                        secondary: const Icon(Icons.navigation),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                        ),
                      ),
                      SwitchListTile(
                        title: Text(localizations.translate('show_drawer_nav')),
                        value: _showDrawer,
                        onChanged: (bool value) {
                          // Prevent disabling both navigation options
                          if (!value && !_showBottomNavBar) {
                            // Show a warning snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(localizations.translate('navigation_warning')),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          
                          setState(() {
                            _showDrawer = value;
                            navigationConfigService.toggleDrawer(value);
                          });
                        },
                        secondary: const Icon(Icons.menu),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              Card(
                color: Theme.of(context).appBarTheme.backgroundColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.translate('theme'),
                        style: TextStyle(
                          fontSize: AppFonts.titleLarge,
                          fontWeight: AppFonts.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      _buildThemeOptions(localizations),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              Card(
                color: Theme.of(context).appBarTheme.backgroundColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.translate('language'),
                        style: TextStyle(
                          fontSize: AppFonts.titleLarge,
                          fontWeight: AppFonts.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      _buildLanguageOptions(localizations, localeService),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOptions(AppLocalizations localizations) {
    return Column(
      children: [
        RadioListTile<AppThemeMode>(
          title: Text(localizations.translate('light_theme')),
          secondary: const Icon(Icons.light_mode),
          value: AppThemeMode.light,
          groupValue: _themeMode,
          onChanged: (AppThemeMode? value) {
            if (value != null) {
              setState(() {
                _themeMode = value;
                navigationConfigService.setThemeMode(value);
              });
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusS),
          ),
        ),
        RadioListTile<AppThemeMode>(
          title: Text(localizations.translate('dark_theme')),
          secondary: const Icon(Icons.dark_mode),
          value: AppThemeMode.dark,
          groupValue: _themeMode,
          onChanged: (AppThemeMode? value) {
            if (value != null) {
              setState(() {
                _themeMode = value;
                navigationConfigService.setThemeMode(value);
              });
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusS),
          ),
        ),
        RadioListTile<AppThemeMode>(
          title: Text(localizations.translate('system_theme')),
          secondary: const Icon(Icons.auto_mode),
          value: AppThemeMode.system,
          groupValue: _themeMode,
          onChanged: (AppThemeMode? value) {
            if (value != null) {
              setState(() {
                _themeMode = value;
                navigationConfigService.setThemeMode(value);
              });
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusS),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageOptions(AppLocalizations localizations, LocaleService localeService) {
    return Column(
      children: [
        RadioListTile<Locale>(
          title: const Text('English'),
          secondary: const Icon(Icons.language),
          value: const Locale('en'),
          groupValue: _selectedLocale,
          onChanged: (Locale? value) {
            if (value != null) {
              setState(() {
                _selectedLocale = value;
                localeService.setLocale(value);
              });
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusS),
          ),
        ),
        RadioListTile<Locale>(
          title: const Text('Русский'),
          secondary: const Icon(Icons.language),
          value: const Locale('ru'),
          groupValue: _selectedLocale,
          onChanged: (Locale? value) {
            if (value != null) {
              setState(() {
                _selectedLocale = value;
                localeService.setLocale(value);
              });
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusS),
          ),
        ),
        RadioListTile<Locale>(
          title: const Text('Қазақша'), // Kazakh
          secondary: const Icon(Icons.language),
          value: const Locale('kk'), // Kazakh locale
          groupValue: _selectedLocale,
          onChanged: (Locale? value) {
            if (value != null) {
              setState(() {
                _selectedLocale = value;
                localeService.setLocale(value);
              });
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusS),
          ),
        ),
      ],
    );
  }
}