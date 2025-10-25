import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/object_3d.dart';
import '../models/geometry.dart';
import 'scene_manager.dart';

/// Сервис для рендеринга 3D сцены
class RenderingService extends ChangeNotifier {
  final SceneManager _sceneManager;
  
  RenderingService(this._sceneManager);

  /// Генерирует GLTF модель всей сцены
  String generateSceneModel() {
    final objects = _sceneManager.objects;
    if (objects.isEmpty) {
      return _generateEmptyScene();
    }

    final gltf = {
      'asset': {'version': '2.0'},
      'scenes': [{'nodes': List.generate(objects.length, (i) => i)}],
      'nodes': _generateNodes(objects),
      'meshes': _generateMeshes(objects),
      'materials': _generateMaterials(objects),
      'textures': _generateTextures(objects),
      'images': _generateImages(objects),
      'samplers': _generateSamplers(objects),
      'buffers': _generateBuffers(objects),
      'bufferViews': _generateBufferViews(objects),
      'accessors': _generateAccessors(objects),
    };

    final jsonString = jsonEncode(gltf);
    final base64String = base64Encode(utf8.encode(jsonString));
    return 'data:model/gltf+json;base64,$base64String';
  }

  /// Генерирует GLTF модель для выбранных объектов
  String generateSelectionModel() {
    final selectedObjects = _sceneManager.selectedObjects;
    if (selectedObjects.isEmpty) {
      return _generateEmptyScene();
    }

    return _generateObjectsModel(selectedObjects);
  }

  /// Генерирует GLTF модель для группы объектов
  String generateGroupModel(ObjectGroup group) {
    return _generateObjectsModel(group.children);
  }

  /// Генерирует пустую сцену
  String _generateEmptyScene() {
    final gltf = {
      'asset': {'version': '2.0'},
      'scenes': [{'nodes': []}],
      'nodes': [],
      'meshes': [],
      'materials': [],
    };

    final jsonString = jsonEncode(gltf);
    final base64String = base64Encode(utf8.encode(jsonString));
    return 'data:model/gltf+json;base64,$base64String';
  }

  /// Генерирует модель для списка объектов
  String _generateObjectsModel(List<Object3D> objects) {
    final gltf = {
      'asset': {'version': '2.0'},
      'scenes': [{'nodes': List.generate(objects.length, (i) => i)}],
      'nodes': _generateNodes(objects),
      'meshes': _generateMeshes(objects),
      'materials': _generateMaterials(objects),
      'textures': _generateTextures(objects),
      'images': _generateImages(objects),
      'samplers': _generateSamplers(objects),
      'buffers': _generateBuffers(objects),
      'bufferViews': _generateBufferViews(objects),
      'accessors': _generateAccessors(objects),
    };

    final jsonString = jsonEncode(gltf);
    final base64String = base64Encode(utf8.encode(jsonString));
    return 'data:model/gltf+json;base64,$base64String';
  }

  /// Генерирует узлы сцены
  List<Map<String, dynamic>> _generateNodes(List<Object3D> objects) {
    return objects.map((object) {
      final index = objects.indexOf(object);
      final node = {
        'mesh': index,
        'translation': [object.position.x, object.position.y, object.position.z],
        'rotation': _eulerToQuaternion(object.rotation),
        'scale': [object.scale.x, object.scale.y, object.scale.z],
      };

      // Добавляем дочерние узлы для групп
      if (object is ObjectGroup && object.children.isNotEmpty) {
        final childNodes = List.generate(
          object.children.length,
          (i) => index + 1 + i,
        );
        node['children'] = childNodes;
      }

      return node;
    }).toList();
  }

  /// Генерирует меши объектов
  List<Map<String, dynamic>> _generateMeshes(List<Object3D> objects) {
    return objects.map((object) {
      final geometry = _generateObjectGeometry(object);
      return {
        'primitives': [{
          'attributes': {
            'POSITION': 0,
            'NORMAL': 1,
            'TEXCOORD_0': 2,
          },
          'indices': 3,
          'material': objects.indexOf(object),
        }],
      };
    }).toList();
  }

  /// Генерирует материалы
  List<Map<String, dynamic>> _generateMaterials(List<Object3D> objects) {
    return objects.map((object) {
      final material = {
        'name': object.name,
        'pbrMetallicRoughness': {
          'baseColorFactor': [
            object.color.red / 255.0,
            object.color.green / 255.0,
            object.color.blue / 255.0,
            object.color.alpha / 255.0,
          ],
          'metallicFactor': 0.0,
          'roughnessFactor': 0.5,
        },
      };

      // Добавляем текстуру, если есть
      if (object.texture != null) {
        final textureIndex = objects.indexOf(object);
        (material['pbrMetallicRoughness'] as Map<String, dynamic>)['baseColorTexture'] = {
          'index': textureIndex,
          'texCoord': 0,
        };
      }

      return material;
    }).toList();
  }

  /// Генерирует текстуры
  List<Map<String, dynamic>> _generateTextures(List<Object3D> objects) {
    return objects.where((object) => object.texture != null).map((object) {
      final textureIndex = objects.indexOf(object);
      return {
        'sampler': textureIndex,
        'source': textureIndex,
      };
    }).toList();
  }

  /// Генерирует изображения
  List<Map<String, dynamic>> _generateImages(List<Object3D> objects) {
    return objects.where((object) => object.texture != null).map((object) {
      return {
        'uri': object.texture!.assetPath,
      };
    }).toList();
  }

  /// Генерирует сэмплеры
  List<Map<String, dynamic>> _generateSamplers(List<Object3D> objects) {
    return objects.where((object) => object.texture != null).map((object) {
      return {
        'magFilter': 9729, // LINEAR
        'minFilter': 9987, // LINEAR_MIPMAP_LINEAR
        'wrapS': 10497,    // REPEAT
        'wrapT': 10497,    // REPEAT
      };
    }).toList();
  }

  /// Генерирует буферы
  List<Map<String, dynamic>> _generateBuffers(List<Object3D> objects) {
    final buffers = <Map<String, dynamic>>[];
    
    for (final object in objects) {
      final geometry = _generateObjectGeometry(object);
      
      // Буфер для вершин
      buffers.add(_createBufferFromFloat32List(geometry.vertices));
      
      // Буфер для нормалей
      buffers.add(_createBufferFromFloat32List(geometry.normals));
      
      // Буфер для UV координат
      buffers.add(_createBufferFromFloat32List(geometry.uvs));
      
      // Буфер для индексов
      buffers.add(_createBufferFromUint16List(geometry.indices));
    }

    return buffers;
  }

  /// Генерирует buffer views
  List<Map<String, dynamic>> _generateBufferViews(List<Object3D> objects) {
    final bufferViews = <Map<String, dynamic>>[];
    int bufferIndex = 0;

    for (final object in objects) {
      final geometry = _generateObjectGeometry(object);
      
      // Buffer view для вершин
      bufferViews.add({
        'buffer': bufferIndex++,
        'byteOffset': 0,
        'byteLength': geometry.vertices.length * 4,
      });
      
      // Buffer view для нормалей
      bufferViews.add({
        'buffer': bufferIndex++,
        'byteOffset': 0,
        'byteLength': geometry.normals.length * 4,
      });
      
      // Buffer view для UV координат
      bufferViews.add({
        'buffer': bufferIndex++,
        'byteOffset': 0,
        'byteLength': geometry.uvs.length * 4,
      });
      
      // Buffer view для индексов
      bufferViews.add({
        'buffer': bufferIndex++,
        'byteOffset': 0,
        'byteLength': geometry.indices.length * 2,
      });
    }

    return bufferViews;
  }

  /// Генерирует аксессоры
  List<Map<String, dynamic>> _generateAccessors(List<Object3D> objects) {
    final accessors = <Map<String, dynamic>>[];
    int bufferViewIndex = 0;

    for (final object in objects) {
      final geometry = _generateObjectGeometry(object);
      
      // Аксессор для вершин
      accessors.add({
        'bufferView': bufferViewIndex++,
        'byteOffset': 0,
        'componentType': 5126, // FLOAT
        'count': geometry.vertices.length ~/ 3,
        'type': 'VEC3',
        'max': geometry.bounds.max.toList(),
        'min': geometry.bounds.min.toList(),
      });
      
      // Аксессор для нормалей
      accessors.add({
        'bufferView': bufferViewIndex++,
        'byteOffset': 0,
        'componentType': 5126, // FLOAT
        'count': geometry.normals.length ~/ 3,
        'type': 'VEC3',
      });
      
      // Аксессор для UV координат
      accessors.add({
        'bufferView': bufferViewIndex++,
        'byteOffset': 0,
        'componentType': 5126, // FLOAT
        'count': geometry.uvs.length ~/ 2,
        'type': 'VEC2',
      });
      
      // Аксессор для индексов
      accessors.add({
        'bufferView': bufferViewIndex++,
        'byteOffset': 0,
        'componentType': 5123, // UNSIGNED_SHORT
        'count': geometry.indices.length,
        'type': 'SCALAR',
      });
    }

    return accessors;
  }

  /// Генерирует геометрию объекта
  ObjectGeometry _generateObjectGeometry(Object3D object) {
    switch (object.runtimeType) {
      case SimpleObject3D:
        return _generateSimpleObjectGeometry(object as SimpleObject3D);
      case ObjectGroup:
        return _generateGroupGeometry(object as ObjectGroup);
      default:
        return _generateSimpleObjectGeometry(object as SimpleObject3D);
    }
  }

  /// Генерирует геометрию простого объекта
  ObjectGeometry _generateSimpleObjectGeometry(SimpleObject3D object) {
    switch (object.type) {
      case ObjectType.cube:
        return _generateCubeGeometry(object);
      case ObjectType.sphere:
        return _generateSphereGeometry(object);
      case ObjectType.cylinder:
        return _generateCylinderGeometry(object);
      case ObjectType.cone:
        return _generateConeGeometry(object);
      case ObjectType.pyramid:
        return _generatePyramidGeometry(object);
      case ObjectType.plane:
        return _generatePlaneGeometry(object);
      case ObjectType.torus:
        return _generateTorusGeometry(object);
      default:
        return _generateCubeGeometry(object);
    }
  }

  /// Генерирует геометрию куба
  ObjectGeometry _generateCubeGeometry(SimpleObject3D object) {
    final halfLength = object.geometry.length / 2;
    final halfWidth = object.geometry.width / 2;
    final halfHeight = object.geometry.height / 2;

    final vertices = Float32List.fromList([
      // Передняя грань
      -halfLength, -halfWidth, halfHeight,
      halfLength, -halfWidth, halfHeight,
      halfLength, halfWidth, halfHeight,
      -halfLength, halfWidth, halfHeight,
      
      // Задняя грань
      -halfLength, -halfWidth, -halfHeight,
      -halfLength, halfWidth, -halfHeight,
      halfLength, halfWidth, -halfHeight,
      halfLength, -halfWidth, -halfHeight,
      
      // Левая грань
      -halfLength, -halfWidth, -halfHeight,
      -halfLength, -halfWidth, halfHeight,
      -halfLength, halfWidth, halfHeight,
      -halfLength, halfWidth, -halfHeight,
      
      // Правая грань
      halfLength, -halfWidth, -halfHeight,
      halfLength, halfWidth, -halfHeight,
      halfLength, halfWidth, halfHeight,
      halfLength, -halfWidth, halfHeight,
      
      // Верхняя грань
      -halfLength, halfWidth, -halfHeight,
      -halfLength, halfWidth, halfHeight,
      halfLength, halfWidth, halfHeight,
      halfLength, halfWidth, -halfHeight,
      
      // Нижняя грань
      -halfLength, -halfWidth, -halfHeight,
      halfLength, -halfWidth, -halfHeight,
      halfLength, -halfWidth, halfHeight,
      -halfLength, -halfWidth, halfHeight,
    ]);

    final normals = Float32List.fromList([
      // Передняя грань
      0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1,
      
      // Задняя грань
      0, 0, -1, 0, 0, -1, 0, 0, -1, 0, 0, -1,
      
      // Левая грань
      -1, 0, 0, -1, 0, 0, -1, 0, 0, -1, 0, 0,
      
      // Правая грань
      1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0,
      
      // Верхняя грань
      0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0,
      
      // Нижняя грань
      0, -1, 0, 0, -1, 0, 0, -1, 0, 0, -1, 0,
    ]);

    final uvs = Float32List.fromList([
      // Передняя грань
      0, 0, 1, 0, 1, 1, 0, 1,
      
      // Задняя грань
      1, 0, 1, 1, 0, 1, 0, 0,
      
      // Левая грань
      1, 0, 0, 0, 0, 1, 1, 1,
      
      // Правая грань
      0, 0, 1, 0, 1, 1, 0, 1,
      
      // Верхняя грань
      0, 1, 0, 0, 1, 0, 1, 1,
      
      // Нижняя грань
      0, 0, 1, 0, 1, 1, 0, 1,
    ]);

    final indices = Uint16List.fromList([
      0, 1, 2, 0, 2, 3,       // Передняя грань
      4, 5, 6, 4, 6, 7,       // Задняя грань
      8, 9, 10, 8, 10, 11,    // Левая грань
      12, 13, 14, 12, 14, 15, // Правая грань
      16, 17, 18, 16, 18, 19, // Верхняя грань
      20, 21, 22, 20, 22, 23, // Нижняя грань
    ]);

    return ObjectGeometry(
      vertices: vertices,
      normals: normals,
      uvs: uvs,
      indices: indices,
      bounds: object.boundingBox,
    );
  }

  /// Генерирует геометрию сферы
  ObjectGeometry _generateSphereGeometry(SimpleObject3D object) {
    // Упрощенная реализация - создаем куб
    return _generateCubeGeometry(object);
  }

  /// Генерирует геометрию цилиндра
  ObjectGeometry _generateCylinderGeometry(SimpleObject3D object) {
    // Упрощенная реализация - создаем куб
    return _generateCubeGeometry(object);
  }

  /// Генерирует геометрию конуса
  ObjectGeometry _generateConeGeometry(SimpleObject3D object) {
    // Упрощенная реализация - создаем куб
    return _generateCubeGeometry(object);
  }

  /// Генерирует геометрию пирамиды
  ObjectGeometry _generatePyramidGeometry(SimpleObject3D object) {
    // Упрощенная реализация - создаем куб
    return _generateCubeGeometry(object);
  }

  /// Генерирует геометрию плоскости
  ObjectGeometry _generatePlaneGeometry(SimpleObject3D object) {
    // Упрощенная реализация - создаем куб
    return _generateCubeGeometry(object);
  }

  /// Генерирует геометрию тора
  ObjectGeometry _generateTorusGeometry(SimpleObject3D object) {
    // Упрощенная реализация - создаем куб
    return _generateCubeGeometry(object);
  }

  /// Генерирует геометрию группы
  ObjectGeometry _generateGroupGeometry(ObjectGroup group) {
    // Для групп создаем объединенную геометрию всех дочерних объектов
    final allVertices = <double>[];
    final allNormals = <double>[];
    final allUvs = <double>[];
    final allIndices = <int>[];
    
    int vertexOffset = 0;

    for (final child in group.children) {
      final childGeometry = _generateObjectGeometry(child);
      
      // Добавляем вершины
      allVertices.addAll(childGeometry.vertices);
      
      // Добавляем нормали
      allNormals.addAll(childGeometry.normals);
      
      // Добавляем UV координаты
      allUvs.addAll(childGeometry.uvs);
      
      // Добавляем индексы с учетом смещения
      for (int i = 0; i < childGeometry.indices.length; i++) {
        allIndices.add(childGeometry.indices[i] + vertexOffset);
      }
      
      vertexOffset += childGeometry.vertices.length ~/ 3;
    }

    return ObjectGeometry(
      vertices: Float32List.fromList(allVertices),
      normals: Float32List.fromList(allNormals),
      uvs: Float32List.fromList(allUvs),
      indices: Uint16List.fromList(allIndices),
      bounds: group.boundingBox,
    );
  }

  /// Конвертирует углы Эйлера в кватернион
  List<double> _eulerToQuaternion(Rotation3D rotation) {
    final pitch = rotation.pitch * math.pi / 180;
    final yaw = rotation.yaw * math.pi / 180;
    final roll = rotation.roll * math.pi / 180;

    final cy = math.cos(yaw * 0.5);
    final sy = math.sin(yaw * 0.5);
    final cp = math.cos(pitch * 0.5);
    final sp = math.sin(pitch * 0.5);
    final cr = math.cos(roll * 0.5);
    final sr = math.sin(roll * 0.5);

    return [
      sr * cp * cy - cr * sp * sy,
      cr * sp * cy + sr * cp * sy,
      cr * cp * sy - sr * sp * cy,
      cr * cp * cy + sr * sp * sy,
    ];
  }

  /// Создает буфер из Float32List
  Map<String, dynamic> _createBufferFromFloat32List(Float32List data) {
    final byteData = Uint8List.view(data.buffer);
    final base64 = base64Encode(byteData);
    return {
      'uri': 'data:application/octet-stream;base64,$base64',
      'byteLength': byteData.length,
    };
  }

  /// Создает буфер из Uint16List
  Map<String, dynamic> _createBufferFromUint16List(Uint16List data) {
    final byteData = Uint8List.view(data.buffer);
    final base64 = base64Encode(byteData);
    return {
      'uri': 'data:application/octet-stream;base64,$base64',
      'byteLength': byteData.length,
    };
  }
}

/// Геометрия объекта
class ObjectGeometry {
  final Float32List vertices;
  final Float32List normals;
  final Float32List uvs;
  final Uint16List indices;
  final BoundingBox bounds;

  const ObjectGeometry({
    required this.vertices,
    required this.normals,
    required this.uvs,
    required this.indices,
    required this.bounds,
  });
}

/// Расширение для Position3D
extension Position3DExtension on Position3D {
  List<double> toList() => [x, y, z];
}
