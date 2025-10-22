import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:app/core/models/texture.dart' as texture_model;
import 'dart:io';

class RoomModelGenerator {
  // Cache for previously generated models
  static final Map<String, String> _modelCache = {};
  
  /// Генерирует GLTF-модель комнаты на основе параметров
  static String generateRoomModel({
    required double width,
    required double depth,
    required double height,
    required Color floorColor,
    required Color ceilingColor,
    required Color leftWallColor,
    required Color rightWallColor,
    required Color frontWallColor,
    required Color backWallColor,
    texture_model.Texture? floorTexture,
    texture_model.Texture? ceilingTexture,
    texture_model.Texture? leftWallTexture,
    texture_model.Texture? rightWallTexture,
    texture_model.Texture? frontWallTexture,
    texture_model.Texture? backWallTexture,
  }) {
    // Create a cache key based on parameters
    final cacheKey = '$width:$depth:$height:'
        '${floorColor.value}:${ceilingColor.value}:'
        '${leftWallColor.value}:${rightWallColor.value}:'
        '${frontWallColor.value}:${backWallColor.value}:'
        '${floorTexture?.name ?? "null"}:'
        '${ceilingTexture?.name ?? "null"}:'
        '${leftWallTexture?.name ?? "null"}:'
        '${rightWallTexture?.name ?? "null"}:'
        '${frontWallTexture?.name ?? "null"}:'
        '${backWallTexture?.name ?? "null"}';
    
    // Check if we have a cached version
    if (_modelCache.containsKey(cacheKey)) {
      return _modelCache[cacheKey]!;
    }
    
    // Нормализуем цвета в диапазон [0, 1]
    final floorColorRgb = _colorToRgbArray(floorColor);
    final ceilingColorRgb = _colorToRgbArray(ceilingColor);
    final leftWallColorRgb = _colorToRgbArray(leftWallColor);
    final rightWallColorRgb = _colorToRgbArray(rightWallColor);
    final frontWallColorRgb = _colorToRgbArray(frontWallColor);
    final backWallColorRgb = _colorToRgbArray(backWallColor);

    // Создаем вершины для пола (квадрат в плоскости XZ)
    // Вершины упорядочены для правильного отображения сверху (нормаль направлена вверх)
    final floorVertices = Float32List.fromList([
      -width / 2, 0, -depth / 2,  // Вершина 0
      -width / 2, 0, depth / 2,   // Вершина 3
      width / 2, 0, depth / 2,    // Вершина 2
      width / 2, 0, -depth / 2,   // Вершина 1
    ]);

    // Текстурные координаты для пола
    final floorUvs = Float32List.fromList([
      0.0, 0.0,  // Вершина 0
      0.0, 1.0,  // Вершина 3
      1.0, 1.0,  // Вершина 2
      1.0, 0.0,  // Вершина 1
    ]);

    // Создаем вершины для потолка
    // Вершины упорядочены для правильного отображения снизу (нормаль направлена вниз)
    final ceilingVertices = Float32List.fromList([
      -width / 2, height, depth / 2,   // Вершина 3 (обратный порядок для внутреннего просмотра)
      -width / 2, height, -depth / 2,  // Вершина 0
      width / 2, height, -depth / 2,   // Вершина 1
      width / 2, height, depth / 2,    // Вершина 2
    ]);

    // Текстурные координаты для потолка
    final ceilingUvs = Float32List.fromList([
      0.0, 0.0,  // Вершина 3
      0.0, 1.0,  // Вершина 0
      1.0, 1.0,  // Вершина 1
      1.0, 0.0,  // Вершина 2
    ]);

    // Создаем вершины для передней стены (Z = -depth/2)
    // Вершины упорядочены для правильного отображения со стороны комнаты (нормаль направлена внутрь)
    final frontWallVertices = Float32List.fromList([
      -width / 2, 0, -depth / 2,      // Вершина 0
      width / 2, 0, -depth / 2,       // Вершина 1
      width / 2, height, -depth / 2,  // Вершина 2
      -width / 2, height, -depth / 2, // Вершина 3
    ]);

    // Текстурные координаты для передней стены
    final frontWallUvs = Float32List.fromList([
      0.0, 0.0,  // Вершина 0
      1.0, 0.0,  // Вершина 1
      1.0, 1.0,  // Вершина 2
      0.0, 1.0,  // Вершина 3
    ]);

    // Создаем вершины для задней стены (Z = depth/2)
    // Вершины упорядочены для правильного отображения со стороны комнаты (нормаль направлена внутрь)
    final backWallVertices = Float32List.fromList([
      width / 2, 0, depth / 2,       // Вершина 1 (обратный порядок для внутреннего просмотра)
      -width / 2, 0, depth / 2,      // Вершина 0
      -width / 2, height, depth / 2, // Вершина 3
      width / 2, height, depth / 2,  // Вершина 2
    ]);

    // Текстурные координаты для задней стены
    final backWallUvs = Float32List.fromList([
      0.0, 0.0,  // Вершина 1
      1.0, 0.0,  // Вершина 0
      1.0, 1.0,  // Вершина 3
      0.0, 1.0,  // Вершина 2
    ]);

    // Создаем вершины для левой стены (X = -width/2)
    // Вершины упорядочены для правильного отображения со стороны комнаты (нормаль направлена внутрь)
    final leftWallVertices = Float32List.fromList([
      -width / 2, 0, depth / 2,      // Вершина 3 (обратный порядок для внутреннего просмотра)
      -width / 2, 0, -depth / 2,     // Вершина 0
      -width / 2, height, -depth / 2, // Вершина 3
      -width / 2, height, depth / 2, // Вершина 2
    ]);

    // Текстурные координаты для левой стены
    final leftWallUvs = Float32List.fromList([
      0.0, 0.0,  // Вершина 3
      1.0, 0.0,  // Вершина 0
      1.0, 1.0,  // Вершина 3
      0.0, 1.0,  // Вершина 2
    ]);

    // Создаем вершины для правой стены (X = width/2)
    // Вершины упорядочены для правильного отображения со стороны комнаты (нормаль направлена внутрь)
    final rightWallVertices = Float32List.fromList([
      width / 2, 0, -depth / 2,      // Вершина 0 (обратный порядок для внутреннего просмотра)
      width / 2, 0, depth / 2,       // Вершина 1
      width / 2, height, depth / 2,  // Вершина 2
      width / 2, height, -depth / 2, // Вершина 3
    ]);

    // Текстурные координаты для правой стены
    final rightWallUvs = Float32List.fromList([
      0.0, 0.0,  // Вершина 0
      1.0, 0.0,  // Вершина 1
      1.0, 1.0,  // Вершина 2
      0.0, 1.0,  // Вершина 3
    ]);

    // Индексы для всех поверхностей (2 треугольника на квадрат)
    // Используем правильный winding order для внутреннего просмотра
    final indices = Uint16List.fromList([0, 1, 2, 0, 2, 3]);

    // Создаем список текстур
    final textures = [
      floorTexture,
      ceilingTexture,
      frontWallTexture,
      backWallTexture,
      leftWallTexture,
      rightWallTexture,
    ];

    // Создаем GLTF JSON
    final gltf = {
      'asset': {
        'version': '2.0'
      },
      'scenes': [
        {
          'nodes': [0, 1, 2, 3, 4, 5] // 6 узлов для 6 поверхностей
        }
      ],
      'nodes': [
        {'mesh': 0}, // Пол
        {'mesh': 1}, // Потолок
        {'mesh': 2}, // Передняя стена
        {'mesh': 3}, // Задняя стена
        {'mesh': 4}, // Левая стена
        {'mesh': 5}, // Правая стена
      ],
      'meshes': [
        {
          'primitives': [
            {
              'attributes': {'POSITION': 0, 'TEXCOORD_0': 1},
              'indices': 2,
              'material': 0
            }
          ]
        },
        {
          'primitives': [
            {
              'attributes': {'POSITION': 3, 'TEXCOORD_0': 4},
              'indices': 5,
              'material': 1
            }
          ]
        },
        {
          'primitives': [
            {
              'attributes': {'POSITION': 6, 'TEXCOORD_0': 7},
              'indices': 8,
              'material': 2
            }
          ]
        },
        {
          'primitives': [
            {
              'attributes': {'POSITION': 9, 'TEXCOORD_0': 10},
              'indices': 11,
              'material': 3
            }
          ]
        },
        {
          'primitives': [
            {
              'attributes': {'POSITION': 12, 'TEXCOORD_0': 13},
              'indices': 14,
              'material': 4
            }
          ]
        },
        {
          'primitives': [
            {
              'attributes': {'POSITION': 15, 'TEXCOORD_0': 16},
              'indices': 17,
              'material': 5
            }
          ]
        }
      ],
      'buffers': [
        // Буферы для вершин и индексов каждой поверхности
        _createBufferFromFloat32List(floorVertices),
        _createBufferFromFloat32List(floorUvs),
        _createBufferFromUint16List(indices),
        _createBufferFromFloat32List(ceilingVertices),
        _createBufferFromFloat32List(ceilingUvs),
        _createBufferFromUint16List(indices),
        _createBufferFromFloat32List(frontWallVertices),
        _createBufferFromFloat32List(frontWallUvs),
        _createBufferFromUint16List(indices),
        _createBufferFromFloat32List(backWallVertices),
        _createBufferFromFloat32List(backWallUvs),
        _createBufferFromUint16List(indices),
        _createBufferFromFloat32List(leftWallVertices),
        _createBufferFromFloat32List(leftWallUvs),
        _createBufferFromUint16List(indices),
        _createBufferFromFloat32List(rightWallVertices),
        _createBufferFromFloat32List(rightWallUvs),
        _createBufferFromUint16List(indices),
        // Добавляем буферы для текстур
        ..._createTextureBuffers(textures),
      ],
      'bufferViews': [
        {'buffer': 0, 'byteOffset': 0, 'byteLength': floorVertices.length * 4},
        {'buffer': 1, 'byteOffset': 0, 'byteLength': floorUvs.length * 4},
        {'buffer': 2, 'byteOffset': 0, 'byteLength': indices.length * 2},
        {'buffer': 3, 'byteOffset': 0, 'byteLength': ceilingVertices.length * 4},
        {'buffer': 4, 'byteOffset': 0, 'byteLength': ceilingUvs.length * 4},
        {'buffer': 5, 'byteOffset': 0, 'byteLength': indices.length * 2},
        {'buffer': 6, 'byteOffset': 0, 'byteLength': frontWallVertices.length * 4},
        {'buffer': 7, 'byteOffset': 0, 'byteLength': frontWallUvs.length * 4},
        {'buffer': 8, 'byteOffset': 0, 'byteLength': indices.length * 2},
        {'buffer': 9, 'byteOffset': 0, 'byteLength': backWallVertices.length * 4},
        {'buffer': 10, 'byteOffset': 0, 'byteLength': backWallUvs.length * 4},
        {'buffer': 11, 'byteOffset': 0, 'byteLength': indices.length * 2},
        {'buffer': 12, 'byteOffset': 0, 'byteLength': leftWallVertices.length * 4},
        {'buffer': 13, 'byteOffset': 0, 'byteLength': leftWallUvs.length * 4},
        {'buffer': 14, 'byteOffset': 0, 'byteLength': indices.length * 2},
        {'buffer': 15, 'byteOffset': 0, 'byteLength': rightWallVertices.length * 4},
        {'buffer': 16, 'byteOffset': 0, 'byteLength': rightWallUvs.length * 4},
        {'buffer': 17, 'byteOffset': 0, 'byteLength': indices.length * 2},
        // Добавляем bufferViews для текстур
        ..._createTextureBufferViews(textures, 18), // Начинаем с индекса 18
      ],
      'accessors': [
        // Аксессоры для вершин пола
        {
          'bufferView': 0,
          'byteOffset': 0,
          'componentType': 5126, // FLOAT
          'count': floorVertices.length ~/ 3,
          'type': 'VEC3',
          'max': [width / 2, 0, depth / 2],
          'min': [-width / 2, 0, -depth / 2]
        },
        {
          'bufferView': 1,
          'byteOffset': 0,
          'componentType': 5126, // FLOAT
          'count': floorUvs.length ~/ 2,
          'type': 'VEC2'
        },
        {
          'bufferView': 2,
          'byteOffset': 0,
          'componentType': 5123, // UNSIGNED_SHORT
          'count': indices.length,
          'type': 'SCALAR'
        },
        // Аксессоры для вершин потолка
        {
          'bufferView': 3,
          'byteOffset': 0,
          'componentType': 5126,
          'count': ceilingVertices.length ~/ 3,
          'type': 'VEC3',
          'max': [width / 2, height, depth / 2],
          'min': [-width / 2, height, -depth / 2]
        },
        {
          'bufferView': 4,
          'byteOffset': 0,
          'componentType': 5126,
          'count': ceilingUvs.length ~/ 2,
          'type': 'VEC2'
        },
        {
          'bufferView': 5,
          'byteOffset': 0,
          'componentType': 5123,
          'count': indices.length,
          'type': 'SCALAR'
        },
        // Аксессоры для вершин передней стены
        {
          'bufferView': 6,
          'byteOffset': 0,
          'componentType': 5126,
          'count': frontWallVertices.length ~/ 3,
          'type': 'VEC3',
          'max': [width / 2, height, -depth / 2],
          'min': [-width / 2, 0, -depth / 2]
        },
        {
          'bufferView': 7,
          'byteOffset': 0,
          'componentType': 5126,
          'count': frontWallUvs.length ~/ 2,
          'type': 'VEC2'
        },
        {
          'bufferView': 8,
          'byteOffset': 0,
          'componentType': 5123,
          'count': indices.length,
          'type': 'SCALAR'
        },
        // Аксессоры для вершин задней стены
        {
          'bufferView': 9,
          'byteOffset': 0,
          'componentType': 5126,
          'count': backWallVertices.length ~/ 3,
          'type': 'VEC3',
          'max': [width / 2, height, depth / 2],
          'min': [-width / 2, 0, depth / 2]
        },
        {
          'bufferView': 10,
          'byteOffset': 0,
          'componentType': 5126,
          'count': backWallUvs.length ~/ 2,
          'type': 'VEC2'
        },
        {
          'bufferView': 11,
          'byteOffset': 0,
          'componentType': 5123,
          'count': indices.length,
          'type': 'SCALAR'
        },
        // Аксессоры для вершин левой стены
        {
          'bufferView': 12,
          'byteOffset': 0,
          'componentType': 5126,
          'count': leftWallVertices.length ~/ 3,
          'type': 'VEC3',
          'max': [-width / 2, height, depth / 2],
          'min': [-width / 2, 0, -depth / 2]
        },
        {
          'bufferView': 13,
          'byteOffset': 0,
          'componentType': 5126,
          'count': leftWallUvs.length ~/ 2,
          'type': 'VEC2'
        },
        {
          'bufferView': 14,
          'byteOffset': 0,
          'componentType': 5123,
          'count': indices.length,
          'type': 'SCALAR'
        },
        // Аксессоры для вершин правой стены
        {
          'bufferView': 15,
          'byteOffset': 0,
          'componentType': 5126,
          'count': rightWallVertices.length ~/ 3,
          'type': 'VEC3',
          'max': [width / 2, height, depth / 2],
          'min': [width / 2, 0, -depth / 2]
        },
        {
          'bufferView': 16,
          'byteOffset': 0,
          'componentType': 5126,
          'count': rightWallUvs.length ~/ 2,
          'type': 'VEC2'
        },
        {
          'bufferView': 17,
          'byteOffset': 0,
          'componentType': 5123,
          'count': indices.length,
          'type': 'SCALAR'
        },
        // Добавляем аксессоры для текстур
        ..._createTextureAccessors(textures, 18), // Начинаем с индекса 18
      ],
      'materials': _createMaterials([
        {'pbrMetallicRoughness': {'baseColorFactor': [...floorColorRgb, 1.0]}, 'name': 'Floor'},
        {'pbrMetallicRoughness': {'baseColorFactor': [...ceilingColorRgb, 1.0]}, 'name': 'Ceiling'},
        {'pbrMetallicRoughness': {'baseColorFactor': [...frontWallColorRgb, 1.0]}, 'name': 'FrontWall'},
        {'pbrMetallicRoughness': {'baseColorFactor': [...backWallColorRgb, 1.0]}, 'name': 'BackWall'},
        {'pbrMetallicRoughness': {'baseColorFactor': [...leftWallColorRgb, 1.0]}, 'name': 'LeftWall'},
        {'pbrMetallicRoughness': {'baseColorFactor': [...rightWallColorRgb, 1.0]}, 'name': 'RightWall'},
      ], textures),
      'textures': _createTextures(textures),
      'images': _createImages(textures),
      'samplers': _createSamplers(textures),
    };

    // Конвертируем в JSON и затем в data URI
    final jsonString = jsonEncode(gltf);
    final base64String = base64Encode(utf8.encode(jsonString));
    final result = 'data:model/gltf+json;base64,$base64String';
    
    // Cache the result
    _modelCache[cacheKey] = result;
    
    // Limit cache size to prevent memory issues
    if (_modelCache.length > 20) {
      _modelCache.remove(_modelCache.keys.first);
    }
    
    return result;
  }

  /// Конвертирует Color в массив RGB значений в диапазоне [0, 1]
  static List<double> _colorToRgbArray(Color color) {
    return [
      color.red / 255.0,
      color.green / 255.0,
      color.blue / 255.0,
    ];
  }

  /// Создает буфер из Float32List
  static Map<String, dynamic> _createBufferFromFloat32List(Float32List data) {
    final byteData = Uint8List.view(data.buffer);
    final base64 = base64Encode(byteData);
    return {
      'uri': 'data:application/octet-stream;base64,$base64',
      'byteLength': byteData.length
    };
  }

  /// Создает буфер из Uint16List
  static Map<String, dynamic> _createBufferFromUint16List(Uint16List data) {
    final byteData = Uint8List.view(data.buffer);
    final base64 = base64Encode(byteData);
    return {
      'uri': 'data:application/octet-stream;base64,$base64',
      'byteLength': byteData.length
    };
  }

  /// Создает буферы для текстур
  static List<Map<String, dynamic>> _createTextureBuffers(List<texture_model.Texture?> textures) {
    final List<Map<String, dynamic>> textureBuffers = [];
    
    for (final texture in textures) {
      if (texture != null) {
        try {
          // Читаем файл текстуры и конвертируем в base64
          final file = File(texture.assetPath);
          if (file.existsSync()) {
            final bytes = file.readAsBytesSync();
            final base64 = base64Encode(bytes);
            textureBuffers.add({
              'uri': 'data:image/png;base64,$base64',
              'byteLength': bytes.length,
            });
          } else {
            // Если файл не найден, добавляем пустой буфер
            textureBuffers.add({
              'uri': 'data:application/octet-stream;base64,',
              'byteLength': 0,
            });
          }
        } catch (e) {
          // В случае ошибки добавляем пустой буфер
          textureBuffers.add({
            'uri': 'data:application/octet-stream;base64,',
            'byteLength': 0,
          });
        }
      } else {
        // Для отсутствующих текстур добавляем пустой буфер
        textureBuffers.add({
          'uri': 'data:application/octet-stream;base64,',
          'byteLength': 0,
        });
      }
    }
    
    return textureBuffers;
  }

  /// Создает bufferViews для текстур
  static List<Map<String, dynamic>> _createTextureBufferViews(List<texture_model.Texture?> textures, int startIndex) {
    final List<Map<String, dynamic>> textureBufferViews = [];
    
    for (var i = 0; i < textures.length; i++) {
      if (textures[i] != null) {
        textureBufferViews.add({
          'buffer': startIndex + i,
          'byteOffset': 0,
          'byteLength': 0, // Будет обновлено при создании буфера
        });
      } else {
        textureBufferViews.add({
          'buffer': startIndex + i,
          'byteOffset': 0,
          'byteLength': 0,
        });
      }
    }
    
    return textureBufferViews;
  }

  /// Создает аксессоры для текстур
  static List<Map<String, dynamic>> _createTextureAccessors(List<texture_model.Texture?> textures, int startIndex) {
    final List<Map<String, dynamic>> textureAccessors = [];
    
    for (var i = 0; i < textures.length; i++) {
      if (textures[i] != null) {
        textureAccessors.add({
          'bufferView': startIndex + i,
          'byteOffset': 0,
          'componentType': 5121, // UNSIGNED_BYTE
          'count': 0, // Будет обновлено при создании буфера
          'type': 'SCALAR',
        });
      } else {
        textureAccessors.add({
          'bufferView': startIndex + i,
          'byteOffset': 0,
          'componentType': 5121, // UNSIGNED_BYTE
          'count': 0,
          'type': 'SCALAR',
        });
      }
    }
    
    return textureAccessors;
  }

  /// Создает материалы с поддержкой текстур
  static List<Map<String, dynamic>> _createMaterials(List<Map<String, dynamic>> baseMaterials, List<texture_model.Texture?> textures) {
    final materials = <Map<String, dynamic>>[];
    
    for (var i = 0; i < baseMaterials.length; i++) {
      final material = Map<String, dynamic>.from(baseMaterials[i]);
      
      // Если есть текстура для этой поверхности, добавляем ее к материалу
      if (textures[i] != null) {
        final pbr = Map<String, dynamic>.from(material['pbrMetallicRoughness'] as Map);
        pbr['baseColorTexture'] = {
          'index': i,
          'texCoord': 0
        };
        material['pbrMetallicRoughness'] = pbr;
      }
      
      materials.add(material);
    }
    
    return materials;
  }

  /// Создает текстуры
  static List<Map<String, dynamic>> _createTextures(List<texture_model.Texture?> textures) {
    final List<Map<String, dynamic>> gltfTextures = [];
    
    for (var i = 0; i < textures.length; i++) {
      if (textures[i] != null) {
        gltfTextures.add({
          'sampler': i,
          'source': i,
        });
      } else {
        // Добавляем пустую текстуру для сохранения индексов
        gltfTextures.add({});
      }
    }
    
    return gltfTextures;
  }

  /// Создает изображения
  static List<Map<String, dynamic>> _createImages(List<texture_model.Texture?> textures) {
    final List<Map<String, dynamic>> images = [];
    
    for (var i = 0; i < textures.length; i++) {
      if (textures[i] != null) {
        images.add({
          'uri': textures[i]!.assetPath,
        });
      } else {
        // Добавляем пустое изображение для сохранения индексов
        images.add({});
      }
    }
    
    return images;
  }

  /// Создает сэмплеры
  static List<Map<String, dynamic>> _createSamplers(List<texture_model.Texture?> textures) {
    final List<Map<String, dynamic>> samplers = [];
    
    for (var i = 0; i < textures.length; i++) {
      if (textures[i] != null) {
        samplers.add({
          'magFilter': 9729, // LINEAR
          'minFilter': 9987, // LINEAR_MIPMAP_LINEAR
          'wrapS': 10497,    // REPEAT
          'wrapT': 10497,    // REPEAT
        });
      } else {
        // Добавляем пустой сэмплер для сохранения индексов
        samplers.add({});
      }
    }
    
    return samplers;
  }
  
  /// Clear the model cache
  static void clearCache() {
    _modelCache.clear();
  }
}