import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:app/ui/routes/app_router.dart';
import 'package:app/shared/theme/app_theme.dart';
import 'package:app/core/services/navigation_config_service.dart';
import 'package:app/core/services/locale_service.dart';
import 'package:app/localization/app_localizations.dart';
import 'package:app/core/constants/localization_keys.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize services
    navigationConfigService.init();
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => navigationConfigService,
        ),
        ChangeNotifierProvider(
          create: (context) => LocaleService()..init(),
        ),
      ],
      child: Consumer<LocaleService>(
        builder: (context, localeService, child) {
          return Consumer<NavigationConfigService>(
            builder: (context, navigationService, child) {
              return MaterialApp(
                // Use localized app title with fallback
                title: AppLocalizations.maybeOf(context)?.translate(LocalizationKeys.appTitle) ?? 'Omirtai Color',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: navigationService.getFlutterThemeMode(),
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: LocaleService.supportedLocales,
                locale: localeService.locale,
                onGenerateRoute: AppRouter.generateRoute,
                initialRoute: AppRouter.home,
              );
            },
          );
        },
      ),
    );
  }
}