import 'package:flutter/material.dart';
import 'package:app/localization/app_localizations.dart';
// import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_fonts.dart';
import 'package:app/core/constants/app_spacing.dart';
import 'package:app/core/constants/localization_keys.dart'; // Add this import
import 'package:app/features/colors/view/collection/color_collection_page.dart';

class ColorsScreen extends StatelessWidget {
  const ColorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            const SizedBox(height: AppSpacing.xs),
            Text(
              localizations.translate(LocalizationKeys.settingsNote),
              style: TextStyle(
                fontSize: AppFonts.bodySmall,
                color: Theme.of(context).hintColor,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Card(
              color: Theme.of(context).appBarTheme.backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusM),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    
                    Text(
                      localizations.translate(LocalizationKeys.colorCollection),
                      style: TextStyle(
                        fontSize: AppFonts.titleLarge,
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ColorCollectionPage(collectionName: 'Classic'),
                          ),
                        );
                      },
                      child: Text(localizations.translate(LocalizationKeys.classic)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}