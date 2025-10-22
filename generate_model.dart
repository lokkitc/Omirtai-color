import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

void main() {
  // Создаем простую коробку как тестовую модель
  final gltf = {
    'asset': {'version': '2.0'},
    'scenes': [{'nodes': [0]}],
    'nodes': [{'mesh': 0}],
    'meshes': [{
      'primitives': [{
        'attributes': {'POSITION': 0},
        'indices': 1
      }]
    }],
    'buffers': [{
      'uri': 'data:application/octet-stream;base64,AAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAgD8AAAAA',
      'byteLength': 48
    }, {
      'uri': 'data:application/octet-stream;base64AAEAAAADAAIA',
      'byteLength': 12
    }],
    'bufferViews': [{
      'buffer': 0,
      'byteOffset': 0,
      'byteLength': 48
    }, {
      'buffer': 1,
      'byteOffset': 0,
      'byteLength': 12
    }],
    'accessors': [{
      'bufferView': 0,
      'byteOffset': 0,
      'componentType': 5126,
      'count': 4,
      'type': 'VEC3',
      'max': [1.0, 1.0, 1.0],
      'min': [0.0, 0.0, 0.0]
    }, {
      'bufferView': 1,
      'byteOffset': 0,
      'componentType': 5123,
      'count': 6,
      'type': 'SCALAR'
    }]
  };

  final jsonString = jsonEncode(gltf);
  final bytes = utf8.encode(jsonString);
  
  // Создаем GLB заголовок
  final glbHeader = Uint8List(12);
  final headerData = ByteData.view(glbHeader.buffer);
  headerData.setUint32(0, 0x46546C67, Endian.little); // magic
  headerData.setUint32(4, 2, Endian.little); // version
  headerData.setUint32(8, 12 + 8 + bytes.length, Endian.little); // length
  
  // Создаем JSON chunk
  final jsonChunkHeader = Uint8List(8);
  final jsonChunkData = ByteData.view(jsonChunkHeader.buffer);
  jsonChunkData.setUint32(0, bytes.length, Endian.little);
  jsonChunkData.setUint32(4, 0x4E4F534A, Endian.little); // JSON
  
  // Записываем в файл
  final file = File('assets/models/room.glb');
  final sink = file.openWrite();
  sink.add(glbHeader);
  sink.add(jsonChunkHeader);
  sink.add(bytes);
  sink.close();
  
  // ignore: avoid_print
  print('Generated room.glb file');
}