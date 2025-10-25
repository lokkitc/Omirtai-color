import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/localization/app_localizations.dart';
import 'package:app/core/constants/app_spacing.dart';
import 'package:app/core/constants/localization_keys.dart';
import '../models/object_3d.dart';
import '../models/geometry.dart';
import '../services/scene_manager.dart';
import '../services/storage_service.dart';
import '../services/rendering_service.dart';
import '../services/editing_service.dart';
import 'cad_scene_viewer.dart';
import 'cad_properties_panel.dart';
import 'cad_object_library.dart';

class ModelingScreen extends StatelessWidget {
  const ModelingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => SceneManager(StorageService(
                  snapshot.data!,
                  'assets/cad_data',
                )),
              ),
              ChangeNotifierProvider(
                create: (context) => EditingService(
                  context.read<SceneManager>(),
                ),
              ),
              ChangeNotifierProvider(
                create: (context) => RenderingService(
                  context.read<SceneManager>(),
                ),
              ),
            ],
            child: const CadModelingScreen(),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class CadModelingScreen extends StatefulWidget {
  const CadModelingScreen({super.key});

  @override
  State<CadModelingScreen> createState() => _CadModelingScreenState();
}

class _CadModelingScreenState extends State<CadModelingScreen> {
  bool _showPropertiesPanel = false;
  bool _showObjectLibrary = false;
  bool _isFullscreen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Левая панель инструментов
          _buildToolbar(),
          
          // Основная область
          Expanded(
        child: Column(
              children: [
                // Верхняя панель
                _buildTopBar(),
                
                // 3D сцена
                Expanded(
                  child: _isFullscreen 
                      ? Consumer2<SceneManager, EditingService>(
                          builder: (context, sceneManager, editingService, child) {
                            return CadSceneViewer(
                              sceneManager: sceneManager,
                              editingService: editingService,
                            );
                          },
                        )
                      : Row(
                          children: [
                            // 3D просмотрщик
                            Expanded(
                              flex: 3,
                              child: Consumer2<SceneManager, EditingService>(
                                builder: (context, sceneManager, editingService, child) {
                                  return CadSceneViewer(
                                    sceneManager: sceneManager,
                                    editingService: editingService,
                                  );
                                },
                              ),
                            ),
                            
                            // Панель свойств (если включена)
                            if (_showPropertiesPanel)
                              SizedBox(
                                width: 300,
                                child: Consumer2<SceneManager, EditingService>(
                                  builder: (context, sceneManager, editingService, child) {
                                    return CadPropertiesPanel(
                                      sceneManager: sceneManager,
                                      editingService: editingService,
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          
          // Правая панель библиотеки объектов (если включена)
          if (_showObjectLibrary && !_isFullscreen)
            SizedBox(
              width: 250,
              child: Consumer2<SceneManager, EditingService>(
                builder: (context, sceneManager, editingService, child) {
                  return CadObjectLibrary(
                    sceneManager: sceneManager,
                    editingService: editingService,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Consumer<EditingService>(
      builder: (context, editingService, child) {
        return Container(
          width: 60,
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              // Основные инструменты редактирования
              _buildToolButton(
                icon: Icons.mouse,
                isSelected: editingService.currentMode == EditingMode.select,
                onPressed: () => editingService.setEditingMode(EditingMode.select),
                tooltip: 'Select',
              ),
              _buildToolButton(
                icon: Icons.open_with,
                isSelected: editingService.currentMode == EditingMode.move,
                onPressed: () => editingService.setEditingMode(EditingMode.move),
                tooltip: 'Move',
              ),
              _buildToolButton(
                icon: Icons.rotate_right,
                isSelected: editingService.currentMode == EditingMode.rotate,
                onPressed: () => editingService.setEditingMode(EditingMode.rotate),
                tooltip: 'Rotate',
              ),
              _buildToolButton(
                icon: Icons.aspect_ratio,
                isSelected: editingService.currentMode == EditingMode.scale,
                onPressed: () => editingService.setEditingMode(EditingMode.scale),
                tooltip: 'Scale',
              ),
              
              const Divider(),
              
              // Всплывающие меню
              _buildToolButton(
                icon: Icons.add,
                onPressed: () => _showCreateObjectsMenu(),
                tooltip: 'Create Objects',
              ),
              _buildToolButton(
                icon: Icons.build,
                onPressed: () => _showToolsMenu(editingService),
                tooltip: 'Tools',
              ),
              _buildToolButton(
                icon: Icons.history,
                onPressed: () => _showHistoryMenu(editingService),
                tooltip: 'History',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 60,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.s),
          
          // Информация о сцене
          Consumer<SceneManager>(
            builder: (context, sceneManager, child) {
              return Text(
                'Objects: ${sceneManager.objectCount}',
              style: Theme.of(context).textTheme.bodyMedium,
              );
            },
          ),
          
          const Spacer(),
          
          // Переключатели панелей
          IconButton(
            icon: Icon(_showPropertiesPanel ? Icons.arrow_back : Icons.arrow_forward),
            onPressed: () => setState(() => _showPropertiesPanel = !_showPropertiesPanel),
            tooltip: 'Properties Panel',
          ),
          IconButton(
            icon: Icon(_showObjectLibrary ? Icons.library_books : Icons.library_books_outlined),
            onPressed: () => setState(() => _showObjectLibrary = !_showObjectLibrary),
            tooltip: 'Object Library',
          ),
          IconButton(
            icon: Icon(_isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
            onPressed: () => setState(() => _isFullscreen = !_isFullscreen),
            tooltip: 'Fullscreen',
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
    bool isSelected = false,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.all(5),
        child: IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: isSelected 
                ? Colors.blue.withOpacity(0.2)
                : null,
            foregroundColor: Colors.grey,
          ),
        ),
      ),
    );
  }

  // Всплывающие меню
  void _showCreateObjectsMenu() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Objects'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.crop_square),
              title: const Text('Cube'),
              onTap: () {
                Navigator.pop(context);
                _createCube();
              },
            ),
            ListTile(
              leading: const Icon(Icons.circle),
              title: const Text('Sphere'),
              onTap: () {
                Navigator.pop(context);
                _createSphere();
              },
            ),
            ListTile(
              leading: const Icon(Icons.radio_button_unchecked),
              title: const Text('Cylinder'),
              onTap: () {
                Navigator.pop(context);
                _createCylinder();
              },
            ),
            ListTile(
              leading: const Icon(Icons.change_history),
              title: const Text('Cone'),
              onTap: () {
                Navigator.pop(context);
                _createCone();
              },
            ),
            ListTile(
              leading: const Icon(Icons.pentagon),
              title: const Text('Pyramid'),
              onTap: () {
                Navigator.pop(context);
                _createPyramid();
              },
            ),
            ListTile(
              leading: const Icon(Icons.crop_landscape),
              title: const Text('Plane'),
              onTap: () {
                Navigator.pop(context);
                _createPlane();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showToolsMenu(EditingService editingService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tools'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicate'),
              onTap: () {
                Navigator.pop(context);
                editingService.duplicateSelected();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                editingService.deleteSelected();
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Create Group'),
              onTap: () {
                Navigator.pop(context);
                _createGroup();
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_remove),
              title: const Text('Ungroup'),
              onTap: () {
                Navigator.pop(context);
                editingService.ungroupSelected();
              },
            ),
            ListTile(
              leading: Icon(editingService.isSnapToGridEnabled ? Icons.grid_on : Icons.grid_off),
              title: const Text('Snap to Grid'),
              onTap: () {
                Navigator.pop(context);
                editingService.setSnapToGrid(!editingService.isSnapToGridEnabled);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showHistoryMenu(EditingService editingService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('History'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.undo),
              title: const Text('Undo'),
              enabled: editingService.canUndo,
              onTap: editingService.canUndo ? () {
                Navigator.pop(context);
                editingService.undo();
              } : null,
            ),
            ListTile(
              leading: const Icon(Icons.redo),
              title: const Text('Redo'),
              enabled: editingService.canRedo,
              onTap: editingService.canRedo ? () {
                Navigator.pop(context);
                editingService.redo();
              } : null,
            ),
            ListTile(
              leading: const Icon(Icons.fullscreen),
              title: const Text('Toggle Fullscreen'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _isFullscreen = !_isFullscreen);
              },
            ),
          ],
        ),
        ),
      );
    }

  // Методы создания объектов
  void _createCube() {
    final sceneManager = context.read<SceneManager>();
    final editingService = context.read<EditingService>();
    
    final cube = SimpleObject3D(
      name: 'Cube ${sceneManager.objectCount + 1}',
      type: ObjectType.cube,
      geometry: Geometry(
        length: 100,
        width: 100,
        height: 100,
      ),
      position: Position3D(0, 0, 0),
      rotation: Rotation3D(pitch: 0, yaw: 0, roll: 0),
      scale: Scale3D(1, 1, 1),
      color: Colors.blue,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    sceneManager.addObject(cube);
    editingService.selectObject(cube.id);
  }

  void _createSphere() {
    final sceneManager = context.read<SceneManager>();
    final editingService = context.read<EditingService>();
    
    final sphere = SimpleObject3D(
      name: 'Sphere ${sceneManager.objectCount + 1}',
      type: ObjectType.sphere,
      geometry: Geometry(
        length: 100,
        width: 100,
        height: 100,
      ),
      position: Position3D(0, 0, 0),
      rotation: Rotation3D(pitch: 0, yaw: 0, roll: 0),
      scale: Scale3D(1, 1, 1),
      color: Colors.red,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    sceneManager.addObject(sphere);
    editingService.selectObject(sphere.id);
  }

  void _createCylinder() {
    final sceneManager = context.read<SceneManager>();
    final editingService = context.read<EditingService>();
    
    final cylinder = SimpleObject3D(
      name: 'Cylinder ${sceneManager.objectCount + 1}',
      type: ObjectType.cylinder,
      geometry: Geometry(
        length: 50,
        width: 50,
        height: 100,
      ),
      position: Position3D(0, 0, 0),
      rotation: Rotation3D(pitch: 0, yaw: 0, roll: 0),
      scale: Scale3D(1, 1, 1),
      color: Colors.green,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    sceneManager.addObject(cylinder);
    editingService.selectObject(cylinder.id);
  }

  void _createCone() {
    final sceneManager = context.read<SceneManager>();
    final editingService = context.read<EditingService>();
    
    final cone = SimpleObject3D(
      name: 'Cone ${sceneManager.objectCount + 1}',
      type: ObjectType.cone,
      geometry: Geometry(
        length: 50,
        width: 50,
        height: 100,
      ),
      position: Position3D(0, 0, 0),
      rotation: Rotation3D(pitch: 0, yaw: 0, roll: 0),
      scale: Scale3D(1, 1, 1),
      color: Colors.orange,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    sceneManager.addObject(cone);
    editingService.selectObject(cone.id);
  }

  void _createPyramid() {
    final sceneManager = context.read<SceneManager>();
    final editingService = context.read<EditingService>();
    
    final pyramid = SimpleObject3D(
      name: 'Pyramid ${sceneManager.objectCount + 1}',
      type: ObjectType.pyramid,
      geometry: Geometry(
        length: 100,
        width: 100,
        height: 100,
      ),
      position: Position3D(0, 0, 0),
      rotation: Rotation3D(pitch: 0, yaw: 0, roll: 0),
      scale: Scale3D(1, 1, 1),
      color: Colors.purple,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    sceneManager.addObject(pyramid);
    editingService.selectObject(pyramid.id);
  }

  void _createPlane() {
    final sceneManager = context.read<SceneManager>();
    final editingService = context.read<EditingService>();
    
    final plane = SimpleObject3D(
      name: 'Plane ${sceneManager.objectCount + 1}',
      type: ObjectType.plane,
      geometry: Geometry(
        length: 200,
        width: 200,
        height: 1,
      ),
      position: Position3D(0, 0, 0),
      rotation: Rotation3D(pitch: 0, yaw: 0, roll: 0),
      scale: Scale3D(1, 1, 1),
      color: Colors.cyan,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    sceneManager.addObject(plane);
    editingService.selectObject(plane.id);
  }

  void _createGroup() {
    final editingService = context.read<EditingService>();
    if (editingService.selectedCount >= 2) {
      // TODO: Implement group creation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group creation not implemented yet')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least 2 objects to create a group')),
      );
    }
  }
}