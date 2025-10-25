import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/scene_manager.dart';
import '../services/editing_service.dart';
import '../models/object_3d.dart';
import '../models/geometry.dart';

/// Библиотека объектов для создания новых 3D объектов
class CadObjectLibrary extends StatefulWidget {
  final SceneManager sceneManager;
  final EditingService editingService;

  const CadObjectLibrary({
    super.key,
    required this.sceneManager,
    required this.editingService,
  });

  @override
  State<CadObjectLibrary> createState() => _CadObjectLibraryState();
}

class _CadObjectLibraryState extends State<CadObjectLibrary> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ObjectType? _selectedType;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          left: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Заголовок
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.library_books),
                const SizedBox(width: 8),
                Text(
                  'Object Library',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          
          // Поиск
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search objects...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          
          // Список объектов
          Expanded(
            child: _buildObjectList(),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectList() {
    final filteredObjects = _getFilteredObjects();
    
    if (filteredObjects.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No objects found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredObjects.length,
      itemBuilder: (context, index) {
        final object = filteredObjects[index];
        return _buildObjectItem(object);
      },
    );
  }

  Widget _buildObjectItem(Object3D object) {
    final isSelected = widget.editingService.selectedObjects.contains(object.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _buildObjectIcon(object),
        title: Text(
          object.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: _buildObjectSubtitle(object),
        trailing: _buildObjectActions(object),
        selected: isSelected,
        onTap: () => _toggleObjectSelection(object),
        onLongPress: () => _showObjectContextMenu(object),
      ),
    );
  }

  Widget _buildObjectIcon(Object3D object) {
    IconData iconData;
    Color iconColor = Colors.grey;
    
    if (object is SimpleObject3D) {
      switch (object.type) {
        case ObjectType.cube:
          iconData = Icons.crop_square;
          iconColor = Colors.blue;
          break;
        case ObjectType.sphere:
          iconData = Icons.circle;
          iconColor = Colors.red;
          break;
        case ObjectType.cylinder:
          iconData = Icons.radio_button_unchecked;
          iconColor = Colors.green;
          break;
        case ObjectType.cone:
          iconData = Icons.change_history;
          iconColor = Colors.orange;
          break;
        case ObjectType.pyramid:
          iconData = Icons.pentagon;
          iconColor = Colors.purple;
          break;
        case ObjectType.plane:
          iconData = Icons.crop_landscape;
          iconColor = Colors.cyan;
          break;
        case ObjectType.torus:
          iconData = Icons.donut_large;
          iconColor = Colors.pink;
          break;
      }
    } else if (object is ObjectGroup) {
      iconData = Icons.group;
      iconColor = Colors.brown;
    } else {
      iconData = Icons.crop_square;
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  Widget _buildObjectSubtitle(Object3D object) {
    if (object is ObjectGroup) {
      return Text('Group (${object.children.length} objects)');
    }
    
    final geometry = object.geometry;
    return Text(
      '${(geometry.length / 1000).toStringAsFixed(1)}m × '
      '${(geometry.width / 1000).toStringAsFixed(1)}m × '
      '${(geometry.height / 1000).toStringAsFixed(1)}m',
    );
  }

  Widget _buildObjectActions(Object3D object) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleObjectAction(value, object),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'duplicate',
          child: ListTile(
            leading: Icon(Icons.copy),
            title: Text('Duplicate'),
            dense: true,
          ),
        ),
        const PopupMenuItem(
          value: 'rename',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('Rename'),
            dense: true,
          ),
        ),
        if (object is ObjectGroup)
          const PopupMenuItem(
            value: 'ungroup',
            child: ListTile(
              leading: Icon(Icons.group_remove),
              title: Text('Ungroup'),
              dense: true,
            ),
          ),
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Delete', style: TextStyle(color: Colors.red)),
            dense: true,
          ),
        ),
      ],
    );
  }

  List<Object3D> _getFilteredObjects() {
    final objects = widget.sceneManager.objects;
    
    if (_searchQuery.isEmpty) {
      return objects;
    }
    
    return objects.where((object) {
      return object.name.toLowerCase().contains(_searchQuery) ||
             (object is ObjectGroup && 
              object.children.any((child) => 
                child.name.toLowerCase().contains(_searchQuery)));
    }).toList();
  }

  void _toggleObjectSelection(Object3D object) {
    if (widget.editingService.selectedObjects.contains(object.id)) {
      widget.editingService.deselectObject(object.id);
    } else {
      widget.editingService.selectObject(object.id);
    }
  }

  void _showObjectContextMenu(Object3D object) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info),
              title: Text('Object: ${object.name}'),
              subtitle: Text('Type: ${object.runtimeType}'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicate'),
              onTap: () {
                Navigator.pop(context);
                widget.editingService.duplicateSelected();
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(object);
              },
            ),
            if (object is ObjectGroup)
              ListTile(
                leading: const Icon(Icons.group_remove),
                title: const Text('Ungroup'),
                onTap: () {
                  Navigator.pop(context);
                  widget.editingService.ungroupSelected();
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(object);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleObjectAction(String action, Object3D object) {
    switch (action) {
      case 'duplicate':
        widget.editingService.duplicateSelected();
        break;
      case 'rename':
        _showRenameDialog(object);
        break;
      case 'ungroup':
        if (object is ObjectGroup) {
          widget.editingService.ungroupSelected();
        }
        break;
      case 'delete':
        _showDeleteConfirmation(object);
        break;
    }
  }

  void _showRenameDialog(Object3D object) {
    final controller = TextEditingController(text: object.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Object'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
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
                final updatedObject = object.copyWith(
                  name: controller.text,
                  updatedAt: DateTime.now(),
                );
                widget.sceneManager.updateObject(updatedObject);
                Navigator.pop(context);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Object3D object) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Object'),
        content: Text('Are you sure you want to delete "${object.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.editingService.deleteSelected();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
