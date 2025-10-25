import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:provider/provider.dart';
import '../services/scene_manager.dart';
import '../services/editing_service.dart';
import '../services/rendering_service.dart';

/// Компонент для просмотра 3D сцены
class CadSceneViewer extends StatefulWidget {
  final SceneManager sceneManager;
  final EditingService editingService;

  const CadSceneViewer({
    super.key,
    required this.sceneManager,
    required this.editingService,
  });

  @override
  State<CadSceneViewer> createState() => _CadSceneViewerState();
}

class _CadSceneViewerState extends State<CadSceneViewer> {
  late RenderingService _renderingService;
  String? _currentModel;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _renderingService = RenderingService(widget.sceneManager);
    _generateModel();
  }

  @override
  void didUpdateWidget(CadSceneViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sceneManager != widget.sceneManager ||
        oldWidget.editingService != widget.editingService) {
      _generateModel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating 3D scene...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading 3D scene',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateModel,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_currentModel == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.crop_square,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No objects in scene',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add objects using the toolbar',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return _buildModelViewer();
  }

  Widget _buildModelViewer() {
    return Consumer<SceneManager>(
      builder: (context, sceneManager, child) {
        return Consumer<EditingService>(
          builder: (context, editingService, child) {
            return ModelViewer(
              key: ValueKey(_currentModel),
              src: _currentModel!,
              alt: '3D CAD Scene',
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
              // Позиционируем камеру для обзора сцены
              cameraOrbit: '45deg 60deg 10m',
              cameraTarget: '0m 0m 0m',
              interpolationDecay: 10,
              // Включаем освещение
              skyboxImage: 'neutral',
              // Настройки для лучшей производительности
              minCameraOrbit: 'auto auto 1m',
              maxCameraOrbit: 'auto auto 100m',
              // Обработка событий
              onWebViewCreated: (controller) {
                _setupWebView(controller);
              },
            );
          },
        );
      },
    );
  }

  void _setupWebView(dynamic controller) {
    // Настройка WebView для обработки событий
    // В реальном приложении здесь можно добавить JavaScript для
    // обработки кликов по объектам и других взаимодействий
  }

  Future<void> _generateModel() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final model = _renderingService.generateSceneModel();
      
      if (mounted) {
        setState(() {
          _currentModel = model;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// Обновляет модель при изменении сцены
  void _onSceneChanged() {
    _generateModel();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

/// Виджет для отображения информации о сцене
class SceneInfoWidget extends StatelessWidget {
  final SceneManager sceneManager;
  final EditingService editingService;

  const SceneInfoWidget({
    super.key,
    required this.sceneManager,
    required this.editingService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Информация об объектах
          _buildInfoItem(
            icon: Icons.crop_square,
            label: 'Objects',
            value: sceneManager.objectCount.toString(),
          ),
          const SizedBox(width: 16),
          
          // Информация о выбранных объектах
          _buildInfoItem(
            icon: Icons.check_circle_outline,
            label: 'Selected',
            value: editingService.selectedCount.toString(),
          ),
          const SizedBox(width: 16),
          
          // Режим редактирования
          _buildInfoItem(
            icon: _getModeIcon(editingService.currentMode),
            label: 'Mode',
            value: _getModeName(editingService.currentMode),
          ),
          const SizedBox(width: 16),
          
          // Привязывание к сетке
          if (editingService.isSnapToGridEnabled)
            _buildInfoItem(
              icon: Icons.grid_on,
              label: 'Snap',
              value: 'Grid',
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  IconData _getModeIcon(EditingMode mode) {
    switch (mode) {
      case EditingMode.select:
        return Icons.mouse;
      case EditingMode.move:
        return Icons.open_with;
      case EditingMode.rotate:
        return Icons.rotate_right;
      case EditingMode.scale:
        return Icons.aspect_ratio;
      case EditingMode.create:
        return Icons.add;
      case EditingMode.delete:
        return Icons.delete;
    }
  }

  String _getModeName(EditingMode mode) {
    switch (mode) {
      case EditingMode.select:
        return 'Select';
      case EditingMode.move:
        return 'Move';
      case EditingMode.rotate:
        return 'Rotate';
      case EditingMode.scale:
        return 'Scale';
      case EditingMode.create:
        return 'Create';
      case EditingMode.delete:
        return 'Delete';
    }
  }
}
