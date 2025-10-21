import 'package:flutter/material.dart';
import 'package:app/localization/app_localizations.dart';
import 'package:app/core/services/persistence_service.dart';

class LocaleService extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> init() async {
    final storedLocaleCode = PersistenceService().loadLanguage();
    
    if (storedLocaleCode != 'en') {
      _locale = Locale(storedLocaleCode);
    }
    
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    
    // Save to persistence service
    await PersistenceService().saveLanguage(locale.languageCode);
    
    notifyListeners();
  }

  // Get supported locales
  static List<Locale> get supportedLocales => const [
        Locale('en'), // English
        Locale('ru'), // Russian
        Locale('kk'), // Kazakh
      ];

  // Get localization delegates
  static List<LocalizationsDelegate<dynamic>> get localizationDelegates => [
        AppLocalizations.delegate,
      ];
}