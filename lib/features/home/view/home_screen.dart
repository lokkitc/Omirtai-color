import 'package:flutter/material.dart';
import 'package:app/localization/app_localizations.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_fonts.dart';
import 'package:app/core/constants/app_spacing.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home,
              size: AppFonts.displaySmall,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              localizations.translate('home_screen'),
              style: TextStyle(
                fontSize: AppFonts.headlineSmall,
                fontWeight: AppFonts.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.l),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                localizations.translate('home_screen_description'),
                style: const TextStyle(
                  fontSize: AppFonts.bodyLarge,
                  color: AppColors.gray,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}