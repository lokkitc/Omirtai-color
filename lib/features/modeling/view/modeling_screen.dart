import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:provider/provider.dart';
import 'package:app/localization/app_localizations.dart';
import 'package:app/core/constants/app_spacing.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/localization_keys.dart';
import 'room_controller.dart';
import 'room_settings_dialog.dart';

class ModelingScreen extends StatelessWidget {
  const ModelingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RoomParameters(),
      child: const ModelingScreenContent(),
    );
  }
}

class ModelingScreenContent extends StatefulWidget {
  const ModelingScreenContent({super.key});

  @override
  State<ModelingScreenContent> createState() => _ModelingScreenContentState();
}

class _ModelingScreenContentState extends State<ModelingScreenContent> {
  bool _hasError = false;
  String? _errorMessage;
  final int _errorCount = 0;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final roomParams = Provider.of<RoomParameters>(context);
    
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    localizations.translate(LocalizationKeys.modelingScreen),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    _showRoomSettingsDialog(context, roomParams);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              localizations.translate(LocalizationKeys.modelingScreenDescription),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.l),
            Expanded(
              child: _buildModelViewer(roomParams),
            ),
          ],
        ),
      ),
    );
  }

  void _showRoomSettingsDialog(BuildContext context, RoomParameters roomParams) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RoomSettingsDialog(roomParams: roomParams);
      },
    );
  }

  Widget _buildModelViewer(RoomParameters roomParams) {
    final localizations = AppLocalizations.of(context);
    
    if (_hasError && _errorCount > 1) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              _errorMessage ?? localizations.translate(LocalizationKeys.modelLoadingError),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              localizations.translate(LocalizationKeys.modelLoadingErrorDescription),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.m),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _errorMessage = null;
                });
                // Попробуем использовать локальный файл активов
                roomParams.useAssetModel();
              },
              child: Text(localizations.translate(LocalizationKeys.retryWithAsset)),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              localizations.translate(LocalizationKeys.usingAssetModelInfo),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Используем динамически сгенерированную модель комнаты
    // Оборачиваем в Consumer для автоматического обновления при изменении параметров
    // Используем ValueKey для принудительной перезагрузки при изменении параметров
    return Consumer<RoomParameters>(
      builder: (context, roomParams, child) {
        return ModelViewer(
          key: ValueKey(
            '${roomParams.roomWidth}_${roomParams.roomDepth}_${roomParams.roomHeight}_'
            '${roomParams.floorColor}_'
            '${roomParams.ceilingColor}_'
            '${roomParams.frontWallColor}_'
            '${roomParams.backWallColor}_'
            '${roomParams.leftWallColor}_'
            '${roomParams.rightWallColor}_'
            '${roomParams.hashCode}' // Добавляем hashCode для лучшего обновления
          ),
          src: roomParams.generatedModel,
          alt: localizations.translate(LocalizationKeys.roomModelAlt),
          ar: true,
          arModes: ['scene-viewer', 'webxr', 'quick-look'],
          environmentImage: 'neutral',
          exposure: 1.0,
          shadowIntensity: 1.0,
          shadowSoftness: 1.0,
          autoPlay: true,
          cameraControls: true,
          interactionPrompt: InteractionPrompt.auto,
          disableZoom: false,
          // Position the camera inside the room for interior viewing
          cameraOrbit: '0deg 90deg 1.5m',
          // Set camera target to center of the room
          cameraTarget: '0m 1.5m 0m',
          // Enable smooth camera movements
          interpolationDecay: 10,
        );
      },
    );
  }
}