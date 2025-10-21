import 'package:flutter/material.dart';
import 'package:app/localization/app_localizations.dart';
// import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_fonts.dart';
import 'package:app/core/constants/app_spacing.dart';
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    
                    Text(
                      'RAL-Colors',
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
                      child: const Text('Classic'),
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