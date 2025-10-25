import 'package:flutter/material.dart';
import '../models/object_3d.dart';
import '../models/geometry.dart';
import 'package:app/core/models/texture.dart' as texture_model;
import 'scene_manager.dart';

/// Сервис для редактирования 3D объектов
class EditingService extends ChangeNotifier {
  final SceneManager _sceneManager;
  
  // Режимы редактирования
  EditingMode _currentMode = EditingMode.select;
  TransformationMode _transformationMode = TransformationMode.move;
  
  // Выбранные объекты
  final Set<String> _selectedObjects = {};
  
  // Состояние инструментов
  bool _isSnapToGridEnabled = true;
  bool _isSnapToObjectEnabled = false;
  double _snapDistance = 50.0; // мм
  double _gridSize = 1000.0; // мм
  
  // История операций
  final List<EditingOperation> _operationHistory = [];
  int _historyIndex = -1;

  EditingService(this._sceneManager);

  /// Текущий режим редактирования
  EditingMode get currentMode => _currentMode;

  /// Текущий режим трансформации
  TransformationMode get transformationMode => _transformationMode;

  /// Выбранные объекты
  Set<String> get selectedObjects => Set.from(_selectedObjects);

  /// Количество выбранных объектов
  int get selectedCount => _selectedObjects.length;

  /// Включено ли привязывание к сетке
  bool get isSnapToGridEnabled => _isSnapToGridEnabled;

  /// Включено ли привязывание к объектам
  bool get isSnapToObjectEnabled => _isSnapToObjectEnabled;

  /// Расстояние привязывания
  double get snapDistance => _snapDistance;

  /// Размер сетки
  double get gridSize => _gridSize;

  /// Можно ли отменить операцию
  bool get canUndo => _historyIndex >= 0;

  /// Можно ли повторить операцию
  bool get canRedo => _historyIndex < _operationHistory.length - 1;

  /// Устанавливает режим редактирования
  void setEditingMode(EditingMode mode) {
    _currentMode = mode;
    notifyListeners();
  }

  /// Устанавливает режим трансформации
  void setTransformationMode(TransformationMode mode) {
    _transformationMode = mode;
    notifyListeners();
  }

  /// Выбирает объект
  void selectObject(String objectId) {
    if (_sceneManager.getObject(objectId) != null) {
      _selectedObjects.add(objectId);
      _sceneManager.selectObject(objectId);
      notifyListeners();
    }
  }

  /// Снимает выбор с объекта
  void deselectObject(String objectId) {
    _selectedObjects.remove(objectId);
    _sceneManager.deselectObject(objectId);
    notifyListeners();
  }

  /// Очищает выбор
  void clearSelection() {
    _selectedObjects.clear();
    _sceneManager.clearSelection();
    notifyListeners();
  }

  /// Выбирает все объекты
  void selectAll() {
    _selectedObjects.clear();
    for (final object in _sceneManager.objects) {
      _selectedObjects.add(object.id);
      _sceneManager.selectObject(object.id);
    }
    notifyListeners();
  }

  /// Выбирает объекты в области
  void selectObjectsInBounds(BoundingBox bounds) {
    final objectsInBounds = _sceneManager.getObjectsInBounds(bounds);
    for (final object in objectsInBounds) {
      _selectedObjects.add(object.id);
      _sceneManager.selectObject(object.id);
    }
    notifyListeners();
  }

  /// Перемещает выбранные объекты
  Future<void> moveSelectedObjects(Position3D delta) async {
    if (_selectedObjects.isEmpty) return;

    final operation = MoveObjectsOperation(
      objectIds: List.from(_selectedObjects),
      delta: delta,
    );

    await _executeOperation(operation);
  }

  /// Поворачивает выбранные объекты
  Future<void> rotateSelectedObjects(Rotation3D delta) async {
    if (_selectedObjects.isEmpty) return;

    final operation = RotateObjectsOperation(
      objectIds: List.from(_selectedObjects),
      delta: delta,
    );

    await _executeOperation(operation);
  }

  /// Масштабирует выбранные объекты
  Future<void> scaleSelectedObjects(Scale3D delta) async {
    if (_selectedObjects.isEmpty) return;

    final operation = ScaleObjectsOperation(
      objectIds: List.from(_selectedObjects),
      delta: delta,
    );

    await _executeOperation(operation);
  }

  /// Создает группу из выбранных объектов
  Future<void> createGroup(String groupName) async {
    if (_selectedObjects.length < 2) return;

    final operation = CreateGroupOperation(
      objectIds: List.from(_selectedObjects),
      groupName: groupName,
    );

    await _executeOperation(operation);
  }

  /// Разгруппировывает выбранные группы
  Future<void> ungroupSelected() async {
    final groupsToUngroup = _selectedObjects.where((id) {
      final object = _sceneManager.getObject(id);
      return object is ObjectGroup;
    }).toList();

    if (groupsToUngroup.isEmpty) return;

    final operation = UngroupObjectsOperation(
      groupIds: groupsToUngroup,
    );

    await _executeOperation(operation);
  }

  /// Дублирует выбранные объекты
  Future<void> duplicateSelected() async {
    if (_selectedObjects.isEmpty) return;

    final operation = DuplicateObjectsOperation(
      objectIds: List.from(_selectedObjects),
    );

    await _executeOperation(operation);
  }

  /// Удаляет выбранные объекты
  Future<void> deleteSelected() async {
    if (_selectedObjects.isEmpty) return;

    final operation = DeleteObjectsOperation(
      objectIds: List.from(_selectedObjects),
    );

    await _executeOperation(operation);
  }

  /// Применяет текстуру к выбранным объектам
  Future<void> applyTextureToSelected(texture_model.Texture? texture) async {
    if (_selectedObjects.isEmpty) return;

    final operation = ApplyTextureOperation(
      objectIds: List.from(_selectedObjects),
      texture: texture,
    );

    await _executeOperation(operation);
  }

  /// Применяет цвет к выбранным объектам
  Future<void> applyColorToSelected(Color color) async {
    if (_selectedObjects.isEmpty) return;

    final operation = ApplyColorOperation(
      objectIds: List.from(_selectedObjects),
      color: color,
      oldColor: color, // TODO: Get actual old color
    );

    await _executeOperation(operation);
  }

  /// Привязывает позицию к сетке
  Position3D snapToGrid(Position3D position) {
    if (!_isSnapToGridEnabled) return position;

    return Position3D(
      _snapToGrid(position.x),
      _snapToGrid(position.y),
      _snapToGrid(position.z),
    );
  }

  /// Привязывает позицию к объектам
  Position3D snapToObjects(Position3D position) {
    if (!_isSnapToObjectEnabled) return position;

    double minDistance = double.infinity;
    Position3D snappedPosition = position;

    for (final object in _sceneManager.objects) {
      if (_selectedObjects.contains(object.id)) continue;

      final distance = position.distanceTo(object.position);
      if (distance < minDistance && distance <= _snapDistance) {
        minDistance = distance;
        snappedPosition = object.position;
      }
    }

    return snappedPosition;
  }

  /// Включает/выключает привязывание к сетке
  void setSnapToGrid(bool enabled) {
    _isSnapToGridEnabled = enabled;
    notifyListeners();
  }

  /// Включает/выключает привязывание к объектам
  void setSnapToObject(bool enabled) {
    _isSnapToObjectEnabled = enabled;
    notifyListeners();
  }

  /// Устанавливает расстояние привязывания
  void setSnapDistance(double distance) {
    _snapDistance = distance;
    notifyListeners();
  }

  /// Устанавливает размер сетки
  void setGridSize(double size) {
    _gridSize = size;
    notifyListeners();
  }

  /// Отменяет последнюю операцию
  Future<void> undo() async {
    if (!canUndo) return;

    final operation = _operationHistory[_historyIndex];
    await _executeOperation(operation, undo: true);
    _historyIndex--;
    notifyListeners();
  }

  /// Повторяет отмененную операцию
  Future<void> redo() async {
    if (!canRedo) return;

    _historyIndex++;
    final operation = _operationHistory[_historyIndex];
    await _executeOperation(operation, undo: false);
    notifyListeners();
  }

  /// Очищает историю операций
  void clearHistory() {
    _operationHistory.clear();
    _historyIndex = -1;
    notifyListeners();
  }

  /// Выполняет операцию редактирования
  Future<void> _executeOperation(EditingOperation operation, {bool undo = false}) async {
    switch (operation.runtimeType) {
      case MoveObjectsOperation:
        await _executeMoveOperation(operation as MoveObjectsOperation, undo: undo);
        break;
      case RotateObjectsOperation:
        await _executeRotateOperation(operation as RotateObjectsOperation, undo: undo);
        break;
      case ScaleObjectsOperation:
        await _executeScaleOperation(operation as ScaleObjectsOperation, undo: undo);
        break;
      case CreateGroupOperation:
        await _executeCreateGroupOperation(operation as CreateGroupOperation, undo: undo);
        break;
      case UngroupObjectsOperation:
        await _executeUngroupOperation(operation as UngroupObjectsOperation, undo: undo);
        break;
      case DuplicateObjectsOperation:
        await _executeDuplicateOperation(operation as DuplicateObjectsOperation, undo: undo);
        break;
      case DeleteObjectsOperation:
        await _executeDeleteOperation(operation as DeleteObjectsOperation, undo: undo);
        break;
      case ApplyTextureOperation:
        await _executeApplyTextureOperation(operation as ApplyTextureOperation, undo: undo);
        break;
      case ApplyColorOperation:
        await _executeApplyColorOperation(operation as ApplyColorOperation, undo: undo);
        break;
    }
  }

  /// Выполняет операцию перемещения
  Future<void> _executeMoveOperation(MoveObjectsOperation operation, {required bool undo}) async {
    final delta = undo ? operation.delta * -1 : operation.delta;
    
    for (final objectId in operation.objectIds) {
      final object = _sceneManager.getObject(objectId);
      if (object == null) continue;

      final newPosition = object.position + delta;
      final snappedPosition = snapToGrid(snapToObjects(newPosition));
      
      await _sceneManager.moveObject(objectId, snappedPosition);
    }
  }

  /// Выполняет операцию поворота
  Future<void> _executeRotateOperation(RotateObjectsOperation operation, {required bool undo}) async {
    final delta = undo ? Rotation3D(
      pitch: -operation.delta.pitch,
      yaw: -operation.delta.yaw,
      roll: -operation.delta.roll,
    ) : operation.delta;
    
    for (final objectId in operation.objectIds) {
      final object = _sceneManager.getObject(objectId);
      if (object == null) continue;

      final newRotation = Rotation3D(
        pitch: object.rotation.pitch + delta.pitch,
        yaw: object.rotation.yaw + delta.yaw,
        roll: object.rotation.roll + delta.roll,
      );
      
      await _sceneManager.rotateObject(objectId, newRotation);
    }
  }

  /// Выполняет операцию масштабирования
  Future<void> _executeScaleOperation(ScaleObjectsOperation operation, {required bool undo}) async {
    final delta = undo ? Scale3D(
      1.0 / operation.delta.x,
      1.0 / operation.delta.y,
      1.0 / operation.delta.z,
    ) : operation.delta;
    
    for (final objectId in operation.objectIds) {
      final object = _sceneManager.getObject(objectId);
      if (object == null) continue;

      final newScale = Scale3D(
        object.scale.x * delta.x,
        object.scale.y * delta.y,
        object.scale.z * delta.z,
      );
      
      await _sceneManager.scaleObject(objectId, newScale);
    }
  }

  /// Выполняет операцию создания группы
  Future<void> _executeCreateGroupOperation(CreateGroupOperation operation, {required bool undo}) async {
    if (undo) {
      // Разгруппировываем
      for (final groupId in operation.createdGroupIds) {
        await _sceneManager.ungroupObjects(groupId);
      }
    } else {
      // Создаем группу
      final group = await _sceneManager.createGroupFromSelection(operation.groupName);
      operation.createdGroupIds.add(group.id);
    }
  }

  /// Выполняет операцию разгруппировки
  Future<void> _executeUngroupOperation(UngroupObjectsOperation operation, {required bool undo}) async {
    if (undo) {
      // Восстанавливаем группы (упрощенная реализация)
      // В реальном приложении нужно сохранять состояние групп
    } else {
      // Разгруппировываем
      for (final groupId in operation.groupIds) {
        await _sceneManager.ungroupObjects(groupId);
      }
    }
  }

  /// Выполняет операцию дублирования
  Future<void> _executeDuplicateOperation(DuplicateObjectsOperation operation, {required bool undo}) async {
    if (undo) {
      // Удаляем дублированные объекты
      for (final objectId in operation.duplicatedObjectIds) {
        await _sceneManager.removeObject(objectId);
      }
    } else {
      // Дублируем объекты
      for (final objectId in operation.objectIds) {
        final object = _sceneManager.getObject(objectId);
        if (object == null) continue;

        final duplicatedObject = _duplicateObject(object);
        await _sceneManager.addObject(duplicatedObject);
        operation.duplicatedObjectIds.add(duplicatedObject.id);
      }
    }
  }

  /// Выполняет операцию удаления
  Future<void> _executeDeleteOperation(DeleteObjectsOperation operation, {required bool undo}) async {
    if (undo) {
      // Восстанавливаем объекты
      for (final object in operation.deletedObjects) {
        await _sceneManager.addObject(object);
      }
    } else {
      // Удаляем объекты
      for (final objectId in operation.objectIds) {
        final object = _sceneManager.getObject(objectId);
        if (object != null) {
          operation.deletedObjects.add(object);
        }
        await _sceneManager.removeObject(objectId);
      }
    }
  }

  /// Выполняет операцию применения текстуры
  Future<void> _executeApplyTextureOperation(ApplyTextureOperation operation, {required bool undo}) async {
    final texture = undo ? operation.oldTexture : operation.texture;
    
    for (final objectId in operation.objectIds) {
      final object = _sceneManager.getObject(objectId);
      if (object == null) continue;

      final updatedObject = object.copyWith(
        texture: texture,
        updatedAt: DateTime.now(),
      );
      
      await _sceneManager.updateObject(updatedObject);
    }
  }

  /// Выполняет операцию применения цвета
  Future<void> _executeApplyColorOperation(ApplyColorOperation operation, {required bool undo}) async {
    final color = undo ? operation.oldColor : operation.color;
    
    for (final objectId in operation.objectIds) {
      final object = _sceneManager.getObject(objectId);
      if (object == null) continue;

      final updatedObject = object.copyWith(
        color: color,
        updatedAt: DateTime.now(),
      );
      
      await _sceneManager.updateObject(updatedObject);
    }
  }

  /// Дублирует объект
  Object3D _duplicateObject(Object3D object) {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final offset = Position3D(100, 100, 100); // Смещение для дубликата
    
    return object.copyWith(
      id: newId,
      name: '${object.name} (Copy)',
      position: object.position + offset,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Привязывает значение к сетке
  double _snapToGrid(double value) {
    return (value / _gridSize).round() * _gridSize;
  }

  /// Добавляет операцию в историю
  void _addToHistory(EditingOperation operation) {
    // Удаляем операции после текущего индекса
    if (_historyIndex < _operationHistory.length - 1) {
      _operationHistory.removeRange(_historyIndex + 1, _operationHistory.length);
    }

    _operationHistory.add(operation);
    _historyIndex = _operationHistory.length - 1;

    // Ограничиваем размер истории
    if (_operationHistory.length > 100) {
      _operationHistory.removeAt(0);
      _historyIndex--;
    }
  }
}

/// Режимы редактирования
enum EditingMode {
  select,
  move,
  rotate,
  scale,
  create,
  delete,
}

/// Режимы трансформации
enum TransformationMode {
  move,
  rotate,
  scale,
}

/// Базовый класс для операций редактирования
abstract class EditingOperation {}

class MoveObjectsOperation extends EditingOperation {
  final List<String> objectIds;
  final Position3D delta;
  
  MoveObjectsOperation({
    required this.objectIds,
    required this.delta,
  });
}

class RotateObjectsOperation extends EditingOperation {
  final List<String> objectIds;
  final Rotation3D delta;
  
  RotateObjectsOperation({
    required this.objectIds,
    required this.delta,
  });
}

class ScaleObjectsOperation extends EditingOperation {
  final List<String> objectIds;
  final Scale3D delta;
  
  ScaleObjectsOperation({
    required this.objectIds,
    required this.delta,
  });
}

class CreateGroupOperation extends EditingOperation {
  final List<String> objectIds;
  final String groupName;
  final List<String> createdGroupIds = [];
  
  CreateGroupOperation({
    required this.objectIds,
    required this.groupName,
  });
}

class UngroupObjectsOperation extends EditingOperation {
  final List<String> groupIds;
  
  UngroupObjectsOperation({
    required this.groupIds,
  });
}

class DuplicateObjectsOperation extends EditingOperation {
  final List<String> objectIds;
  final List<String> duplicatedObjectIds = [];
  
  DuplicateObjectsOperation({
    required this.objectIds,
  });
}

class DeleteObjectsOperation extends EditingOperation {
  final List<String> objectIds;
  final List<Object3D> deletedObjects = [];
  
  DeleteObjectsOperation({
    required this.objectIds,
  });
}

class ApplyTextureOperation extends EditingOperation {
  final List<String> objectIds;
  final texture_model.Texture? texture;
  final texture_model.Texture? oldTexture;
  
  ApplyTextureOperation({
    required this.objectIds,
    required this.texture,
    this.oldTexture,
  });
}

class ApplyColorOperation extends EditingOperation {
  final List<String> objectIds;
  final Color color;
  final Color oldColor;
  
  ApplyColorOperation({
    required this.objectIds,
    required this.color,
    required this.oldColor,
  });
}
