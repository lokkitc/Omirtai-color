import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/scene_manager.dart';
import '../services/editing_service.dart';
import '../models/object_3d.dart';
import '../models/geometry.dart';

/// Панель инструментов для CAD приложения
class CadToolbar extends StatelessWidget {
  final SceneManager sceneManager;
  final EditingService editingService;

  const CadToolbar({
    super.key,
    required this.sceneManager,
    required this.editingService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Режимы редактирования
          _buildSection(
            title: 'Edit',
            children: [
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
            ],
          ),
          
          const Divider(),
          
          // Создание объектов
          _buildSection(
            title: 'Create',
            children: [
              _buildToolButton(
                icon: Icons.crop_square,
                onPressed: () => _createCube(),
                tooltip: 'Create Cube',
              ),
              _buildToolButton(
                icon: Icons.circle,
                onPressed: () => _createSphere(),
                tooltip: 'Create Sphere',
              ),
              _buildToolButton(
                icon: Icons.radio_button_unchecked,
                onPressed: () => _createCylinder(),
                tooltip: 'Create Cylinder',
              ),
              _buildToolButton(
                icon: Icons.change_history,
                onPressed: () => _createCone(),
                tooltip: 'Create Cone',
              ),
              _buildToolButton(
                icon: Icons.pentagon,
                onPressed: () => _createPyramid(),
                tooltip: 'Create Pyramid',
              ),
              _buildToolButton(
                icon: Icons.crop_landscape,
                onPressed: () => _createPlane(),
                tooltip: 'Create Plane',
              ),
            ],
          ),
          
          const Divider(),
          
          // Операции
          _buildSection(
            title: 'Operations',
            children: [
              _buildToolButton(
                icon: Icons.copy,
                onPressed: editingService.selectedCount > 0 
                    ? () => editingService.duplicateSelected()
                    : null,
                tooltip: 'Duplicate',
              ),
              _buildToolButton(
                icon: Icons.delete,
                onPressed: editingService.selectedCount > 0 
                    ? () => editingService.deleteSelected()
                    : null,
                tooltip: 'Delete',
              ),
              _buildToolButton(
                icon: Icons.group,
                onPressed: editingService.selectedCount >= 2 
                    ? () => _createGroup(context)
                    : null,
                tooltip: 'Create Group',
              ),
              _buildToolButton(
                icon: Icons.group_remove,
                onPressed: editingService.selectedCount > 0 
                    ? () => editingService.ungroupSelected()
                    : null,
                tooltip: 'Ungroup',
              ),
            ],
          ),
          
          const Divider(),
          
          // Настройки
          _buildSection(
            title: 'Settings',
            children: [
              _buildToolButton(
                icon: Icons.grid_on,
                isSelected: editingService.isSnapToGridEnabled,
                onPressed: () => editingService.setSnapToGrid(!editingService.isSnapToGridEnabled),
                tooltip: 'Snap to Grid',
              ),
              _buildToolButton(
                icon: Icons.anchor,
                isSelected: editingService.isSnapToObjectEnabled,
                onPressed: () => editingService.setSnapToObject(!editingService.isSnapToObjectEnabled),
                tooltip: 'Snap to Object',
              ),
            ],
          ),
          
          const Spacer(),
          
          // История
          _buildSection(
            title: 'History',
            children: [
              _buildToolButton(
                icon: Icons.undo,
                onPressed: editingService.canUndo 
                    ? () => editingService.undo()
                    : null,
                tooltip: 'Undo',
              ),
              _buildToolButton(
                icon: Icons.redo,
                onPressed: editingService.canRedo 
                    ? () => editingService.redo()
                    : null,
                tooltip: 'Redo',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required VoidCallback? onPressed,
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
            foregroundColor: onPressed == null 
                ? Colors.grey
                : null,
          ),
        ),
      ),
    );
  }

  void _createCube() {
    final cube = SimpleObject3D(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Cube ${sceneManager.objectCount + 1}',
      geometry: const Geometry(length: 1000, width: 1000, height: 1000),
      position: const Position3D(0, 0, 0),
      rotation: const Rotation3D(),
      scale: const Scale3D.uniform(1.0),
      color: Colors.blue,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      type: ObjectType.cube,
    );
    
    sceneManager.addObject(cube);
    editingService.selectObject(cube.id);
  }

  void _createSphere() {
    final sphere = SimpleObject3D(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Sphere ${sceneManager.objectCount + 1}',
      geometry: const Geometry(length: 1000, width: 1000, height: 1000),
      position: const Position3D(0, 0, 0),
      rotation: const Rotation3D(),
      scale: const Scale3D.uniform(1.0),
      color: Colors.red,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      type: ObjectType.sphere,
    );
    
    sceneManager.addObject(sphere);
    editingService.selectObject(sphere.id);
  }

  void _createCylinder() {
    final cylinder = SimpleObject3D(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Cylinder ${sceneManager.objectCount + 1}',
      geometry: const Geometry(length: 1000, width: 1000, height: 1000),
      position: const Position3D(0, 0, 0),
      rotation: const Rotation3D(),
      scale: const Scale3D.uniform(1.0),
      color: Colors.green,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      type: ObjectType.cylinder,
    );
    
    sceneManager.addObject(cylinder);
    editingService.selectObject(cylinder.id);
  }

  void _createCone() {
    final cone = SimpleObject3D(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Cone ${sceneManager.objectCount + 1}',
      geometry: const Geometry(length: 1000, width: 1000, height: 1000),
      position: const Position3D(0, 0, 0),
      rotation: const Rotation3D(),
      scale: const Scale3D.uniform(1.0),
      color: Colors.orange,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      type: ObjectType.cone,
    );
    
    sceneManager.addObject(cone);
    editingService.selectObject(cone.id);
  }

  void _createPyramid() {
    final pyramid = SimpleObject3D(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Pyramid ${sceneManager.objectCount + 1}',
      geometry: const Geometry(length: 1000, width: 1000, height: 1000),
      position: const Position3D(0, 0, 0),
      rotation: const Rotation3D(),
      scale: const Scale3D.uniform(1.0),
      color: Colors.purple,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      type: ObjectType.pyramid,
    );
    
    sceneManager.addObject(pyramid);
    editingService.selectObject(pyramid.id);
  }

  void _createPlane() {
    final plane = SimpleObject3D(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Plane ${sceneManager.objectCount + 1}',
      geometry: const Geometry(length: 1000, width: 1000, height: 100),
      position: const Position3D(0, 0, 0),
      rotation: const Rotation3D(),
      scale: const Scale3D.uniform(1.0),
      color: Colors.cyan,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      type: ObjectType.plane,
    );
    
    sceneManager.addObject(plane);
    editingService.selectObject(plane.id);
  }

  void _createGroup(BuildContext context) {
    // Показываем диалог для ввода имени группы
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Create Group'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Group Name',
              hintText: 'Enter group name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  editingService.createGroup(controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
