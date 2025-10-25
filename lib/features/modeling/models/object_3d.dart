import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'geometry.dart';
import 'package:app/core/models/texture.dart' as texture_model;

/// Базовый класс для всех 3D объектов
abstract class Object3D {
  final String id;
  final String name;
  final Geometry geometry;
  final Position3D position;
  final Rotation3D rotation;
  final Scale3D scale;
  final Color color;
  final texture_model.Texture? texture;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVisible;
  final bool isLocked;

  const Object3D({
    required this.id,
    required this.name,
    required this.geometry,
    required this.position,
    required this.rotation,
    required this.scale,
    required this.color,
    this.texture,
    required this.createdAt,
    required this.updatedAt,
    this.isVisible = true,
    this.isLocked = false,
  });

  /// Создает копию объекта с новыми параметрами
  Object3D copyWith({
    String? id,
    String? name,
    Geometry? geometry,
    Position3D? position,
    Rotation3D? rotation,
    Scale3D? scale,
    Color? color,
    texture_model.Texture? texture,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVisible,
    bool? isLocked,
  });

  /// Получает матрицу трансформации объекта
  TransformMatrix get transformMatrix {
    final translation = TransformMatrix.translation(position);
    final rotationMatrix = TransformMatrix.rotation(rotation);
    final scaleMatrix = TransformMatrix.scale(scale);
    
    return translation * rotationMatrix * scaleMatrix;
  }

  /// Проверяет, содержит ли объект точку
  bool containsPoint(Position3D point) {
    // Базовая реализация - проверка по bounding box
    final halfLength = geometry.length / 2;
    final halfWidth = geometry.width / 2;
    final halfHeight = geometry.height / 2;

    return point.x >= position.x - halfLength &&
           point.x <= position.x + halfLength &&
           point.y >= position.y - halfWidth &&
           point.y <= position.y + halfWidth &&
           point.z >= position.z - halfHeight &&
           point.z <= position.z + halfHeight;
  }

  /// Получает bounding box объекта
  BoundingBox get boundingBox {
    final halfLength = geometry.length / 2;
    final halfWidth = geometry.width / 2;
    final halfHeight = geometry.height / 2;

    return BoundingBox(
      min: Position3D(
        position.x - halfLength,
        position.y - halfWidth,
        position.z - halfHeight,
      ),
      max: Position3D(
        position.x + halfLength,
        position.y + halfWidth,
        position.z + halfHeight,
      ),
    );
  }

  /// Сериализация в JSON
  Map<String, dynamic> toJson();

  /// Десериализация из JSON
  static Object3D fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    if (type == 'group') {
      return ObjectGroup.fromJson(json);
    } else {
      return SimpleObject3D.fromJson(json);
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Object3D && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Object3D(id: $id, name: $name, type: ${runtimeType})';
}

/// Простой 3D объект (куб, сфера, цилиндр и т.д.)
class SimpleObject3D extends Object3D {
  final ObjectType type;

  const SimpleObject3D({
    required super.id,
    required super.name,
    required super.geometry,
    required super.position,
    required super.rotation,
    required super.scale,
    required super.color,
    super.texture,
    required super.createdAt,
    required super.updatedAt,
    super.isVisible,
    super.isLocked,
    required this.type,
  });

  @override
  SimpleObject3D copyWith({
    String? id,
    String? name,
    Geometry? geometry,
    Position3D? position,
    Rotation3D? rotation,
    Scale3D? scale,
    Color? color,
    texture_model.Texture? texture,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVisible,
    bool? isLocked,
    ObjectType? type,
  }) {
    return SimpleObject3D(
      id: id ?? this.id,
      name: name ?? this.name,
      geometry: geometry ?? this.geometry,
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      color: color ?? this.color,
      texture: texture ?? this.texture,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVisible: isVisible ?? this.isVisible,
      isLocked: isLocked ?? this.isLocked,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': 'simple',
      'objectType': type.name,
      'geometry': {
        'length': geometry.length,
        'width': geometry.width,
        'height': geometry.height,
      },
      'position': {
        'x': position.x,
        'y': position.y,
        'z': position.z,
      },
      'rotation': {
        'pitch': rotation.pitch,
        'yaw': rotation.yaw,
        'roll': rotation.roll,
      },
      'scale': {
        'x': scale.x,
        'y': scale.y,
        'z': scale.z,
      },
      'color': color.value,
      'texture': texture?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isVisible': isVisible,
      'isLocked': isLocked,
    };
  }

  @override
  static SimpleObject3D fromJson(Map<String, dynamic> json) {
    return SimpleObject3D(
      id: json['id'] as String,
      name: json['name'] as String,
      geometry: Geometry(
        length: (json['geometry'] as Map)['length'] as double,
        width: (json['geometry'] as Map)['width'] as double,
        height: (json['geometry'] as Map)['height'] as double,
      ),
      position: Position3D(
        (json['position'] as Map)['x'] as double,
        (json['position'] as Map)['y'] as double,
        (json['position'] as Map)['z'] as double,
      ),
      rotation: Rotation3D(
        pitch: (json['rotation'] as Map)['pitch'] as double,
        yaw: (json['rotation'] as Map)['yaw'] as double,
        roll: (json['rotation'] as Map)['roll'] as double,
      ),
      scale: Scale3D(
        (json['scale'] as Map)['x'] as double,
        (json['scale'] as Map)['y'] as double,
        (json['scale'] as Map)['z'] as double,
      ),
      color: Color(json['color'] as int),
      texture: json['texture'] != null 
          ? texture_model.Texture.fromJson(json['texture'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isVisible: json['isVisible'] as bool? ?? true,
      isLocked: json['isLocked'] as bool? ?? false,
      type: ObjectType.values.firstWhere(
        (e) => e.name == json['objectType'],
        orElse: () => ObjectType.cube,
      ),
    );
  }
}

/// Группа объектов
class ObjectGroup extends Object3D {
  final List<Object3D> children;
  final GroupType groupType;

  const ObjectGroup({
    required super.id,
    required super.name,
    required super.geometry,
    required super.position,
    required super.rotation,
    required super.scale,
    required super.color,
    super.texture,
    required super.createdAt,
    required super.updatedAt,
    super.isVisible,
    super.isLocked,
    required this.children,
    required this.groupType,
  });

  @override
  ObjectGroup copyWith({
    String? id,
    String? name,
    Geometry? geometry,
    Position3D? position,
    Rotation3D? rotation,
    Scale3D? scale,
    Color? color,
    texture_model.Texture? texture,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVisible,
    bool? isLocked,
    List<Object3D>? children,
    GroupType? groupType,
  }) {
    return ObjectGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      geometry: geometry ?? this.geometry,
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      color: color ?? this.color,
      texture: texture ?? this.texture,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVisible: isVisible ?? this.isVisible,
      isLocked: isLocked ?? this.isLocked,
      children: children ?? this.children,
      groupType: groupType ?? this.groupType,
    );
  }

  /// Добавляет объект в группу
  ObjectGroup addChild(Object3D child) {
    final newChildren = List<Object3D>.from(children)..add(child);
    return copyWith(
      children: newChildren,
      updatedAt: DateTime.now(),
    );
  }

  /// Удаляет объект из группы
  ObjectGroup removeChild(String childId) {
    final newChildren = children.where((child) => child.id != childId).toList();
    return copyWith(
      children: newChildren,
      updatedAt: DateTime.now(),
    );
  }

  /// Получает все объекты в группе (включая вложенные)
  List<Object3D> getAllObjects() {
    final List<Object3D> allObjects = [];
    
    for (final child in children) {
      allObjects.add(child);
      if (child is ObjectGroup) {
        allObjects.addAll(child.getAllObjects());
      }
    }
    
    return allObjects;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': 'group',
      'groupType': groupType.name,
      'geometry': {
        'length': geometry.length,
        'width': geometry.width,
        'height': geometry.height,
      },
      'position': {
        'x': position.x,
        'y': position.y,
        'z': position.z,
      },
      'rotation': {
        'pitch': rotation.pitch,
        'yaw': rotation.yaw,
        'roll': rotation.roll,
      },
      'scale': {
        'x': scale.x,
        'y': scale.y,
        'z': scale.z,
      },
      'color': color.value,
      'texture': texture?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isVisible': isVisible,
      'isLocked': isLocked,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }

  @override
  static ObjectGroup fromJson(Map<String, dynamic> json) {
    final childrenJson = json['children'] as List<dynamic>;
    final children = childrenJson.map((childJson) {
      final childMap = childJson as Map<String, dynamic>;
      final type = childMap['type'] as String;
      
      if (type == 'group') {
        return ObjectGroup.fromJson(childMap);
      } else {
        return SimpleObject3D.fromJson(childMap);
      }
    }).toList();

    return ObjectGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      geometry: Geometry(
        length: (json['geometry'] as Map)['length'] as double,
        width: (json['geometry'] as Map)['width'] as double,
        height: (json['geometry'] as Map)['height'] as double,
      ),
      position: Position3D(
        (json['position'] as Map)['x'] as double,
        (json['position'] as Map)['y'] as double,
        (json['position'] as Map)['z'] as double,
      ),
      rotation: Rotation3D(
        pitch: (json['rotation'] as Map)['pitch'] as double,
        yaw: (json['rotation'] as Map)['yaw'] as double,
        roll: (json['rotation'] as Map)['roll'] as double,
      ),
      scale: Scale3D(
        (json['scale'] as Map)['x'] as double,
        (json['scale'] as Map)['y'] as double,
        (json['scale'] as Map)['z'] as double,
      ),
      color: Color(json['color'] as int),
      texture: json['texture'] != null 
          ? texture_model.Texture.fromJson(json['texture'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isVisible: json['isVisible'] as bool? ?? true,
      isLocked: json['isLocked'] as bool? ?? false,
      children: children,
      groupType: GroupType.values.firstWhere(
        (e) => e.name == json['groupType'],
        orElse: () => GroupType.container,
      ),
    );
  }
}

/// Типы простых объектов
enum ObjectType {
  cube,
  sphere,
  cylinder,
  cone,
  pyramid,
  plane,
  torus,
}

/// Типы групп
enum GroupType {
  container,
  assembly,
  component,
}

/// Bounding box для объекта
class BoundingBox {
  final Position3D min;
  final Position3D max;

  const BoundingBox({
    required this.min,
    required this.max,
  });

  /// Центр bounding box
  Position3D get center {
    return Position3D(
      (min.x + max.x) / 2,
      (min.y + max.y) / 2,
      (min.z + max.z) / 2,
    );
  }

  /// Размеры bounding box
  Geometry get size {
    return Geometry(
      length: max.x - min.x,
      width: max.y - min.y,
      height: max.z - min.z,
    );
  }

  /// Проверяет пересечение с другим bounding box
  bool intersects(BoundingBox other) {
    return min.x <= other.max.x &&
           max.x >= other.min.x &&
           min.y <= other.max.y &&
           max.y >= other.min.y &&
           min.z <= other.max.z &&
           max.z >= other.min.z;
  }

  /// Объединяет два bounding box
  BoundingBox union(BoundingBox other) {
    return BoundingBox(
      min: Position3D(
        math.min(min.x, other.min.x),
        math.min(min.y, other.min.y),
        math.min(min.z, other.min.z),
      ),
      max: Position3D(
        math.max(max.x, other.max.x),
        math.max(max.y, other.max.y),
        math.max(max.z, other.max.z),
      ),
    );
  }

  @override
  String toString() => 'BoundingBox(min: $min, max: $max)';
}
