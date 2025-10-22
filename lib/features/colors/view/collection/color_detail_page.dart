import 'package:flutter/material.dart';
import 'package:app/features/colors/models/color_model.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_fonts.dart';
import 'package:app/core/constants/app_spacing.dart';
import 'package:app/core/constants/localization_keys.dart';
import 'package:app/localization/app_localizations.dart';

class ColorDetailPage extends StatelessWidget {
  final UnifiedRALColor color;

  const ColorDetailPage({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(color.code),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color swatch
            Center(
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Color(int.parse(color.hex.replaceAll('#', '0xFF'))),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gray.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    color.code,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppFonts.headlineSmall,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Color name
            Text(
              color.name,
              style: const TextStyle(
                fontSize: AppFonts.headlineSmall,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.m),

            // Collection
            _buildDetailRow(localizations.translate(LocalizationKeys.colorCollection), color.collection),
            const SizedBox(height: AppSpacing.s),

            // Group
            _buildDetailRow(localizations.translate(LocalizationKeys.colorGroup), color.group),
            const SizedBox(height: AppSpacing.xl),

            // Color values section
            Text(
              localizations.translate(LocalizationKeys.colorValues),
              style: const TextStyle(
                fontSize: AppFonts.headlineMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.m),

            // HEX
            _buildDetailRow(localizations.translate(LocalizationKeys.hexValue), color.hex),
            const SizedBox(height: AppSpacing.s),

            // RGB
            _buildDetailRow(localizations.translate(LocalizationKeys.rgbValueLabel), 
              localizations.translate(LocalizationKeys.rgbFormat)
                .replaceAll('{r}', color.rgb.r.toString())
                .replaceAll('{g}', color.rgb.g.toString())
                .replaceAll('{b}', color.rgb.b.toString())),
            const SizedBox(height: AppSpacing.s),

            // RGBA
            _buildDetailRow(localizations.translate(LocalizationKeys.rgbaValueLabel), 
              localizations.translate(LocalizationKeys.rgbaFormat)
                .replaceAll('{r}', color.rgba.r.toString())
                .replaceAll('{g}', color.rgba.g.toString())
                .replaceAll('{b}', color.rgba.b.toString())
                .replaceAll('{a}', color.rgba.a.toString())),
            const SizedBox(height: AppSpacing.s),

            // HSL
            _buildDetailRow(localizations.translate(LocalizationKeys.hslValueLabel), 
              localizations.translate(LocalizationKeys.hslFormat)
                .replaceAll('{h}', color.hsl.h.toString())
                .replaceAll('{s}', color.hsl.s.toString())
                .replaceAll('{l}', color.hsl.l.toString())),
            const SizedBox(height: AppSpacing.s),

            // HSV
            _buildDetailRow(localizations.translate(LocalizationKeys.hsvValueLabel), 
              localizations.translate(LocalizationKeys.hsvFormat)
                .replaceAll('{h}', color.hsv.h.toString())
                .replaceAll('{s}', color.hsv.s.toString())
                .replaceAll('{v}', color.hsv.v.toString())),
            const SizedBox(height: AppSpacing.s),

            // XYZ
            _buildDetailRow(localizations.translate(LocalizationKeys.xyzValueLabel), 
              localizations.translate(LocalizationKeys.xyzFormat)
                .replaceAll('{x}', color.xyz.x.toStringAsFixed(4))
                .replaceAll('{y}', color.xyz.y.toStringAsFixed(4))
                .replaceAll('{z}', color.xyz.z.toStringAsFixed(4))),
            const SizedBox(height: AppSpacing.s),

            // LAB
            _buildDetailRow(localizations.translate(LocalizationKeys.labValueLabel), 
              localizations.translate(LocalizationKeys.labFormat)
                .replaceAll('{l}', color.lab.l.toStringAsFixed(4))
                .replaceAll('{a}', color.lab.a.toStringAsFixed(4))
                .replaceAll('{b}', color.lab.b.toStringAsFixed(4))),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: AppFonts.bodyMedium,
              fontWeight: FontWeight.w500,
              color: AppColors.gray,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: AppFonts.bodyMedium,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}