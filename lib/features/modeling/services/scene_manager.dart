import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/object_3d.dart';
import '../models/geometry.dart';
import 'storage_service.dart';

/// Менеджер 3D сцены
class SceneManager extends ChangeNotifier {
  final StorageService _storageService;
  final Map<String, Object3D> _objects = {};
  final Map<String, String> _parentGroups = {}; // childId -> parentId
  final Set<String> _selectedObjects = {};
  final List<SceneOperation> _operationHistory = [];
  int _historyIndex = -1;
  
  // Размеры сцены (50x50x50 метров = 50000x50000x50000 мм)
  static const double sceneSize = 50000.0; // мм
  static const double sceneHalfSize = sceneSize / 2;
  
  // Ограничения сцены
  static const BoundingBox sceneBounds = BoundingBox(
    min: Position3D(-sceneHalfSize, -sceneHalfSize, -sceneHalfSize),
    max: Position3D(sceneHalfSize, sceneHalfSize, sceneHalfSize),
  );

  SceneManager(this._storageService);

  /// Все объекты в сцене
  List<Object3D> get objects => _objects.values.toList();

  /// Выбранные объекты
  List<Object3D> get selectedObjects => 
      _selectedObjects.map((id) => _objects[id]).whereType<Object3D>().toList();

  /// Количество объектов
  int get objectCount => _objects.length;

  /// Можно ли отменить операцию
  bool get canUndo => _historyIndex >= 0;

  /// Можно ли повторить операцию
  bool get canRedo => _historyIndex < _operationHistory.length - 1;

  /// Добавляет объект в сцену
  Future<void> addObject(Object3D object) async {
    if (_objects.containsKey(object.id)) {
      throw Exception('Object with id ${object.id} already exists');
    }

    // Проверяем, что объект помещается в сцену
    if (!_isObjectInSceneBounds(object)) {
      throw Exception('Object is outside scene bounds');
    }

    _objects[object.id] = object;
    _addToHistory(AddObjectOperation(object));
    notifyListeners();
  }

  /// Удаляет объект из сцены
  Future<void> removeObject(String objectId) async {
    final object = _objects[objectId];
    if (object == null) return;

    // Удаляем все дочерние объекты, если это группа
    if (object is ObjectGroup) {
      for (final child in object.children) {
        await removeObject(child.id);
      }
    }

    // Удаляем из родительской группы
    final parentId = _parentGroups[objectId];
    if (parentId != null) {
      await removeFromGroup(objectId, parentId);
    }

    _objects.remove(objectId);
    _parentGroups.remove(objectId);
    _selectedObjects.remove(objectId);
    _addToHistory(RemoveObjectOperation(object));
    notifyListeners();
  }

  /// Обновляет объект
  Future<void> updateObject(Object3D updatedObject) async {
    final existingObject = _objects[updatedObject.id];
    if (existingObject == null) {
      throw Exception('Object with id ${updatedObject.id} not found');
    }

    // Проверяем, что обновленный объект помещается в сцену
    if (!_isObjectInSceneBounds(updatedObject)) {
      throw Exception('Updated object is outside scene bounds');
    }

    _objects[updatedObject.id] = updatedObject;
    _addToHistory(UpdateObjectOperation(existingObject, updatedObject));
    notifyListeners();
  }

  /// Перемещает объект
  Future<void> moveObject(String objectId, Position3D newPosition) async {
    final object = _objects[objectId];
    if (object == null) return;

    final updatedObject = object.copyWith(
      position: newPosition,
      updatedAt: DateTime.now(),
    );

    await updateObject(updatedObject);
  }

  /// Поворачивает объект
  Future<void> rotateObject(String objectId, Rotation3D newRotation) async {
    final object = _objects[objectId];
    if (object == null) return;

    final updatedObject = object.copyWith(
      rotation: newRotation,
      updatedAt: DateTime.now(),
    );

    await updateObject(updatedObject);
  }

  /// Масштабирует объект
  Future<void> scaleObject(String objectId, Scale3D newScale) async {
    final object = _objects[objectId];
    if (object == null) return;

    final updatedObject = object.copyWith(
      scale: newScale,
      updatedAt: DateTime.now(),
    );

    await updateObject(updatedObject);
  }

  /// Создает группу из выбранных объектов
  Future<ObjectGroup> createGroupFromSelection(String groupName) async {
    if (_selectedObjects.isEmpty) {
      throw Exception('No objects selected');
    }

    final selectedObjectsList = selectedObjects;
    final groupId = _generateId();
    
    // Вычисляем bounding box для группы
    final boundingBox = _calculateGroupBoundingBox(selectedObjectsList);
    
    final group = ObjectGroup(
      id: groupId,
      name: groupName,
      geometry: boundingBox.size,
      position: boundingBox.center,
      rotation: const Rotation3D(),
      scale: const Scale3D.uniform(1.0),
      color: Colors.blue,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      children: selectedObjectsList,
      groupType: GroupType.container,
    );

    // Добавляем группу в сцену
    await addObject(group);

    // Устанавливаем родительские связи
    for (final child in selectedObjectsList) {
      _parentGroups[child.id] = groupId;
    }

    // Очищаем выбор
    clearSelection();

    return group;
  }

  /// Разгруппировывает объекты
  Future<void> ungroupObjects(String groupId) async {
    final group = _objects[groupId];
    if (group is! ObjectGroup) return;

    // Удаляем родительские связи
    for (final child in group.children) {
      _parentGroups.remove(child.id);
    }

    // Удаляем группу
    await removeObject(groupId);
  }

  /// Добавляет объект в группу
  Future<void> addToGroup(String objectId, String groupId) async {
    final object = _objects[objectId];
    final group = _objects[groupId];
    
    if (object == null || group is! ObjectGroup) return;

    // Удаляем из текущей группы, если есть
    final currentParent = _parentGroups[objectId];
    if (currentParent != null) {
      await removeFromGroup(objectId, currentParent);
    }

    // Добавляем в новую группу
    final updatedGroup = group.addChild(object);
    await updateObject(updatedGroup);
    _parentGroups[objectId] = groupId;
  }

  /// Удаляет объект из группы
  Future<void> removeFromGroup(String objectId, String groupId) async {
    final group = _objects[groupId];
    if (group is! ObjectGroup) return;

    final updatedGroup = group.removeChild(objectId);
    await updateObject(updatedGroup);
    _parentGroups.remove(objectId);
  }

  /// Выбирает объект
  void selectObject(String objectId) {
    if (_objects.containsKey(objectId)) {
      _selectedObjects.add(objectId);
      notifyListeners();
    }
  }

  /// Снимает выбор с объекта
  void deselectObject(String objectId) {
    _selectedObjects.remove(objectId);
    notifyListeners();
  }

  /// Очищает выбор
  void clearSelection() {
    _selectedObjects.clear();
    notifyListeners();
  }

  /// Выбирает все объекты
  void selectAll() {
    _selectedObjects.addAll(_objects.keys);
    notifyListeners();
  }

  /// Получает объект по ID
  Object3D? getObject(String objectId) => _objects[objectId];

  /// Получает объекты в области
  List<Object3D> getObjectsInBounds(BoundingBox bounds) {
    return _objects.values.where((object) {
      return object.boundingBox.intersects(bounds);
    }).toList();
  }

  /// Получает объекты по типу
  List<T> getObjectsByType<T>() {
    return _objects.values.whereType<T>().toList();
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

  /// Сохраняет сцену
  Future<void> saveScene(String name) async {
    final scene = Scene(
      name: name,
      objects: objects,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await _storageService.saveScene(scene);
  }

  /// Загружает сцену
  Future<void> loadScene(String name) async {
    final scene = await _storageService.loadScene(name);
    if (scene == null) return;

    _objects.clear();
    _parentGroups.clear();
    _selectedObjects.clear();
    clearHistory();

    for (final object in scene.objects) {
      _objects[object.id] = object;
      
      // Восстанавливаем родительские связи
      if (object is ObjectGroup) {
        for (final child in object.children) {
          _parentGroups[child.id] = object.id;
        }
      }
    }

    notifyListeners();
  }

  /// Очищает сцену
  void clearScene() {
    _objects.clear();
    _parentGroups.clear();
    _selectedObjects.clear();
    clearHistory();
    notifyListeners();
  }

  /// Проверяет, помещается ли объект в границы сцены
  bool _isObjectInSceneBounds(Object3D object) {
    final objectBounds = object.boundingBox;
    return sceneBounds.intersects(objectBounds);
  }

  /// Вычисляет bounding box для группы объектов
  BoundingBox _calculateGroupBoundingBox(List<Object3D> objects) {
    if (objects.isEmpty) {
      return const BoundingBox(
        min: Position3D(0, 0, 0),
        max: Position3D(0, 0, 0),
      );
    }

    BoundingBox result = objects.first.boundingBox;
    for (int i = 1; i < objects.length; i++) {
      result = result.union(objects[i].boundingBox);
    }

    return result;
  }

  /// Добавляет операцию в историю
  void _addToHistory(SceneOperation operation) {
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

  /// Выполняет операцию
  Future<void> _executeOperation(SceneOperation operation, {required bool undo}) async {
    switch (operation.runtimeType) {
      case AddObjectOperation:
        final op = operation as AddObjectOperation;
        if (undo) {
          await removeObject(op.object.id);
        } else {
          await addObject(op.object);
        }
        break;
      case RemoveObjectOperation:
        final op = operation as RemoveObjectOperation;
        if (undo) {
          await addObject(op.object);
        } else {
          await removeObject(op.object.id);
        }
        break;
      case UpdateObjectOperation:
        final op = operation as UpdateObjectOperation;
        if (undo) {
          await updateObject(op.oldObject);
        } else {
          await updateObject(op.newObject);
        }
        break;
    }
  }

  /// Генерирует уникальный ID
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

/// Класс сцены
class Scene {
  final String name;
  final List<Object3D> objects;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Scene({
    required this.name,
    required this.objects,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'objects': objects.map((obj) => obj.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static Scene fromJson(Map<String, dynamic> json) {
    final objectsJson = json['objects'] as List<dynamic>;
    final objects = objectsJson.map((objJson) {
      final objMap = objJson as Map<String, dynamic>;
      final type = objMap['type'] as String;
      
      if (type == 'group') {
        return ObjectGroup.fromJson(objMap);
      } else {
        return SimpleObject3D.fromJson(objMap);
      }
    }).toList();

    return Scene(
      name: json['name'] as String,
      objects: objects,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Базовый класс для операций сцены
abstract class SceneOperation {}

class AddObjectOperation extends SceneOperation {
  final Object3D object;
  AddObjectOperation(this.object);
}

class RemoveObjectOperation extends SceneOperation {
  final Object3D object;
  RemoveObjectOperation(this.object);
}

class UpdateObjectOperation extends SceneOperation {
  final Object3D oldObject;
  final Object3D newObject;
  UpdateObjectOperation(this.oldObject, this.newObject);
}
