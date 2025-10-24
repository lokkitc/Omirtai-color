import 'package:flutter/material.dart';
import 'package:app/localization/app_localizations.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_fonts.dart';
import 'package:app/core/constants/app_spacing.dart';
import 'package:app/core/constants/localization_keys.dart';
import 'package:app/features/calculators/view/area_calculator/area_calculator_screen.dart';
import 'package:app/features/calculators/view/volume_calculator/volume_calculator_screen.dart';

class CalculatorsScreen extends StatelessWidget {
  const CalculatorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              localizations.translate(LocalizationKeys.calculatorsScreen),
              style: TextStyle(
                fontSize: AppFonts.headlineSmall,
                fontWeight: AppFonts.bold,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: AppSpacing.xs),
              Text(
                localizations.translate(LocalizationKeys.calculatorsScreenDescription),
                style: TextStyle(
                  fontSize: AppFonts.bodySmall,
                  color: Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(height: AppSpacing.l),
            // const SizedBox(height: AppSpacing.m),
            // Padding(
            //   padding: const EdgeInsets.symmetric(),
            //   child: Text(
            //     localizations.translate(LocalizationKeys.calculatorsScreenDescription),
            //     style: TextStyle(
            //       fontSize: AppFonts.bodyLarge,
            //       color: AppColors.gray,
            //     ),
            //     textAlign: TextAlign.start,
            //   ),
            // ),
            // const SizedBox(height: AppSpacing.xxl),
            // Calculator options in card-based layout
            _CalculatorOptionCard(
              icon: Icons.square_foot,
              title: localizations.translate(LocalizationKeys.areaCalculator),
              description: localizations.translate(LocalizationKeys.calculateArea),
              
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AreaCalculatorScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.s),
            _CalculatorOptionCard(
              icon: Icons.inventory_2,
              title: localizations.translate(LocalizationKeys.volumeCalculator),
              description: localizations.translate(LocalizationKeys.calculateVolume),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VolumeCalculatorScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _CalculatorOptionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _CalculatorOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  State<_CalculatorOptionCard> createState() => _CalculatorOptionCardState();
}

class _CalculatorOptionCardState extends State<_CalculatorOptionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      transform: Matrix4.diagonal3Values(_isPressed ? 0.98 : 1.0, _isPressed ? 0.98 : 1.0, 1.0),
      child: Card(
        color: Theme.of(context).appBarTheme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        ),
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s),
                  decoration: BoxDecoration(
                    color: Theme.of(context).appBarTheme.backgroundColor?.withAlpha(25) ?? 
                            AppColors.lightGray.withAlpha(25),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                  ),
                  child: Icon(
                    widget.icon,
                    color: Theme.of(context).appBarTheme.foregroundColor ?? AppColors.primary,
                    size: AppSpacing.iconL,
                  ),
                ),
                const SizedBox(width: AppSpacing.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: AppFonts.titleMedium,
                          fontWeight: AppFonts.semiBold,
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        widget.description,
                        style: TextStyle(
                          fontSize: AppFonts.bodyMedium,
                          color: AppColors.gray,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: AppSpacing.iconS,
                  color: AppColors.gray,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}