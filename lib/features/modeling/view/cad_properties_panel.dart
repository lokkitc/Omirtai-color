import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/scene_manager.dart';
import '../services/editing_service.dart';
import '../models/object_3d.dart';
import '../models/geometry.dart';
import 'package:app/core/models/texture.dart' as texture_model;

/// Панель свойств для редактирования объектов
class CadPropertiesPanel extends StatefulWidget {
  final SceneManager sceneManager;
  final EditingService editingService;

  const CadPropertiesPanel({
    super.key,
    required this.sceneManager,
    required this.editingService,
  });

  @override
  State<CadPropertiesPanel> createState() => _CadPropertiesPanelState();
}

class _CadPropertiesPanelState extends State<CadPropertiesPanel> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _xController = TextEditingController();
  final TextEditingController _yController = TextEditingController();
  final TextEditingController _zController = TextEditingController();
  final TextEditingController _pitchController = TextEditingController();
  final TextEditingController _yawController = TextEditingController();
  final TextEditingController _rollController = TextEditingController();
  final TextEditingController _scaleXController = TextEditingController();
  final TextEditingController _scaleYController = TextEditingController();
  final TextEditingController _scaleZController = TextEditingController();

  Object3D? _selectedObject;
  Color _selectedColor = Colors.blue;
  texture_model.Texture? _selectedTexture;

  @override
  void initState() {
    super.initState();
    _updateFromSelection();
  }

  @override
  void didUpdateWidget(CadPropertiesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.editingService.selectedObjects != widget.editingService.selectedObjects) {
      _updateFromSelection();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _xController.dispose();
    _yController.dispose();
    _zController.dispose();
    _pitchController.dispose();
    _yawController.dispose();
    _rollController.dispose();
    _scaleXController.dispose();
    _scaleYController.dispose();
    _scaleZController.dispose();
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
                const Icon(Icons.tune),
                const SizedBox(width: 8),
                Text(
                  'Properties',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          
          // Содержимое панели
          Expanded(
            child: _selectedObject == null
                ? _buildNoSelection()
                : _buildPropertiesContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSelection() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mouse,
            size: 48,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No object selected',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Select an object to edit its properties',
            style: TextStyle(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Основная информация
          _buildSection(
            title: 'Basic Properties',
            children: [
              _buildTextField(
                label: 'Name',
                controller: _nameController,
                onChanged: _updateObjectName,
              ),
              const SizedBox(height: 16),
              _buildColorPicker(),
              const SizedBox(height: 16),
              _buildTexturePicker(),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Геометрия
          _buildSection(
            title: 'Geometry',
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Length (mm)',
                      controller: _lengthController,
                      onChanged: _updateGeometry,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      label: 'Width (mm)',
                      controller: _widthController,
                      onChanged: _updateGeometry,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Height (mm)',
                controller: _heightController,
                onChanged: _updateGeometry,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Позиция
          _buildSection(
            title: 'Position',
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'X (mm)',
                      controller: _xController,
                      onChanged: _updatePosition,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      label: 'Y (mm)',
                      controller: _yController,
                      onChanged: _updatePosition,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Z (mm)',
                controller: _zController,
                onChanged: _updatePosition,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Поворот
          _buildSection(
            title: 'Rotation',
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Pitch (°)',
                      controller: _pitchController,
                      onChanged: _updateRotation,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      label: 'Yaw (°)',
                      controller: _yawController,
                      onChanged: _updateRotation,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Roll (°)',
                controller: _rollController,
                onChanged: _updateRotation,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Масштаб
          _buildSection(
            title: 'Scale',
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Scale X',
                      controller: _scaleXController,
                      onChanged: _updateScale,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      label: 'Scale Y',
                      controller: _scaleYController,
                      onChanged: _updateScale,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Scale Z',
                controller: _scaleZController,
                onChanged: _updateScale,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Действия
          _buildSection(
            title: 'Actions',
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _duplicateObject,
                      icon: const Icon(Icons.copy),
                      label: const Text('Duplicate'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _deleteObject,
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      keyboardType: TextInputType.number,
      onChanged: (_) => onChanged(),
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Color'),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _selectedColor,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _showColorPicker,
                child: const Text('Choose Color'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTexturePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Texture'),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
                image: _selectedTexture != null
                    ? DecorationImage(
                        image: AssetImage(_selectedTexture!.assetPath),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _selectedTexture == null
                  ? const Icon(Icons.texture, size: 20)
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _showTexturePicker,
                child: Text(_selectedTexture?.displayName ?? 'Choose Texture'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _updateFromSelection() {
    final selectedObjects = widget.editingService.selectedObjects;
    if (selectedObjects.length == 1) {
      final objectId = selectedObjects.first;
      final object = widget.sceneManager.getObject(objectId);
      if (object != null) {
        _selectedObject = object;
        _updateControllers();
      }
    } else {
      _selectedObject = null;
    }
    setState(() {});
  }

  void _updateControllers() {
    if (_selectedObject == null) return;

    _nameController.text = _selectedObject!.name;
    _lengthController.text = _selectedObject!.geometry.length.toString();
    _widthController.text = _selectedObject!.geometry.width.toString();
    _heightController.text = _selectedObject!.geometry.height.toString();
    _xController.text = _selectedObject!.position.x.toString();
    _yController.text = _selectedObject!.position.y.toString();
    _zController.text = _selectedObject!.position.z.toString();
    _pitchController.text = _selectedObject!.rotation.pitch.toString();
    _yawController.text = _selectedObject!.rotation.yaw.toString();
    _rollController.text = _selectedObject!.rotation.roll.toString();
    _scaleXController.text = _selectedObject!.scale.x.toString();
    _scaleYController.text = _selectedObject!.scale.y.toString();
    _scaleZController.text = _selectedObject!.scale.z.toString();
    _selectedColor = _selectedObject!.color;
    _selectedTexture = _selectedObject!.texture;
  }

  void _updateObjectName() {
    if (_selectedObject == null) return;
    
    final updatedObject = _selectedObject!.copyWith(
      name: _nameController.text,
      updatedAt: DateTime.now(),
    );
    
    widget.sceneManager.updateObject(updatedObject);
    _selectedObject = updatedObject;
  }

  void _updateGeometry() {
    if (_selectedObject == null) return;
    
    final length = double.tryParse(_lengthController.text) ?? _selectedObject!.geometry.length;
    final width = double.tryParse(_widthController.text) ?? _selectedObject!.geometry.width;
    final height = double.tryParse(_heightController.text) ?? _selectedObject!.geometry.height;
    
    final updatedObject = _selectedObject!.copyWith(
      geometry: Geometry(length: length, width: width, height: height),
      updatedAt: DateTime.now(),
    );
    
    widget.sceneManager.updateObject(updatedObject);
    _selectedObject = updatedObject;
  }

  void _updatePosition() {
    if (_selectedObject == null) return;
    
    final x = double.tryParse(_xController.text) ?? _selectedObject!.position.x;
    final y = double.tryParse(_yController.text) ?? _selectedObject!.position.y;
    final z = double.tryParse(_zController.text) ?? _selectedObject!.position.z;
    
    final updatedObject = _selectedObject!.copyWith(
      position: Position3D(x, y, z),
      updatedAt: DateTime.now(),
    );
    
    widget.sceneManager.updateObject(updatedObject);
    _selectedObject = updatedObject;
  }

  void _updateRotation() {
    if (_selectedObject == null) return;
    
    final pitch = double.tryParse(_pitchController.text) ?? _selectedObject!.rotation.pitch;
    final yaw = double.tryParse(_yawController.text) ?? _selectedObject!.rotation.yaw;
    final roll = double.tryParse(_rollController.text) ?? _selectedObject!.rotation.roll;
    
    final updatedObject = _selectedObject!.copyWith(
      rotation: Rotation3D(pitch: pitch, yaw: yaw, roll: roll),
      updatedAt: DateTime.now(),
    );
    
    widget.sceneManager.updateObject(updatedObject);
    _selectedObject = updatedObject;
  }

  void _updateScale() {
    if (_selectedObject == null) return;
    
    final scaleX = double.tryParse(_scaleXController.text) ?? _selectedObject!.scale.x;
    final scaleY = double.tryParse(_scaleYController.text) ?? _selectedObject!.scale.y;
    final scaleZ = double.tryParse(_scaleZController.text) ?? _selectedObject!.scale.z;
    
    final updatedObject = _selectedObject!.copyWith(
      scale: Scale3D(scaleX, scaleY, scaleZ),
      updatedAt: DateTime.now(),
    );
    
    widget.sceneManager.updateObject(updatedObject);
    _selectedObject = updatedObject;
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Color'),
        content: SizedBox(
          width: 300,
          height: 200,
          child: GridView.count(
            crossAxisCount: 6,
            children: [
              Colors.red,
              Colors.green,
              Colors.blue,
              Colors.yellow,
              Colors.orange,
              Colors.purple,
              Colors.pink,
              Colors.cyan,
              Colors.brown,
              Colors.grey,
              Colors.black,
              Colors.white,
            ].map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                  _updateColor();
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(
                      color: _selectedColor == color ? Colors.black : Colors.grey,
                      width: 2,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showTexturePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Texture'),
        content: SizedBox(
          width: 300,
          height: 200,
          child: ListView(
            children: [
              ListTile(
                title: const Text('None'),
                leading: const Icon(Icons.clear),
                onTap: () {
                  setState(() {
                    _selectedTexture = null;
                  });
                  _updateTexture();
                  Navigator.pop(context);
                },
              ),
              ...texture_model.Texture.getAvailableTextures().map((texture) {
                return ListTile(
                  title: Text(texture.displayName),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                      image: DecorationImage(
                        image: AssetImage(texture.assetPath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedTexture = texture;
                    });
                    _updateTexture();
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _updateColor() {
    if (_selectedObject == null) return;
    
    final updatedObject = _selectedObject!.copyWith(
      color: _selectedColor,
      updatedAt: DateTime.now(),
    );
    
    widget.sceneManager.updateObject(updatedObject);
    _selectedObject = updatedObject;
  }

  void _updateTexture() {
    if (_selectedObject == null) return;
    
    final updatedObject = _selectedObject!.copyWith(
      texture: _selectedTexture,
      updatedAt: DateTime.now(),
    );
    
    widget.sceneManager.updateObject(updatedObject);
    _selectedObject = updatedObject;
  }

  void _duplicateObject() {
    if (_selectedObject == null) return;
    
    widget.editingService.duplicateSelected();
  }

  void _deleteObject() {
    if (_selectedObject == null) return;
    
    widget.editingService.deleteSelected();
  }
}
