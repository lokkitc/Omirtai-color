import 'package:flutter/material.dart';
import 'package:app/localization/app_localizations.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_fonts.dart';
import 'package:app/core/constants/app_spacing.dart';
import 'package:app/core/constants/localization_keys.dart'; // Add this import

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
              localizations.translate(LocalizationKeys.homeScreen),
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
                localizations.translate(LocalizationKeys.homeScreenDescription),
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