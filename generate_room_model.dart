import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

void main() {
  // Create a minimal valid GLB file with a simple cube
  final gltfJson = '''
{
  "asset": {
    "version": "2.0"
  },
  "scenes": [
    {
      "nodes": [0]
    }
  ],
  "nodes": [
    {
      "mesh": 0
    }
  ],
  "meshes": [
    {
      "primitives": [
        {
          "attributes": {
            "POSITION": 0
          },
          "indices": 1
        }
      ]
    }
  ],
  "buffers": [
    {
      "byteLength": 96
    }
  ],
  "bufferViews": [
    {
      "buffer": 0,
      "byteOffset": 0,
      "byteLength": 48
    },
    {
      "buffer": 0,
      "byteOffset": 48,
      "byteLength": 48
    }
  ],
  "accessors": [
    {
      "bufferView": 0,
      "componentType": 5126,
      "count": 4,
      "type": "VEC3",
      "max": [1.0, 0.0, 1.0],
      "min": [-1.0, 0.0, -1.0]
    },
    {
      "bufferView": 1,
      "componentType": 5123,
      "count": 6,
      "type": "SCALAR"
    }
  ]
}
''';

  // Convert JSON to bytes
  final jsonBytes = utf8.encode(gltfJson);
  
  // Pad JSON to 4-byte boundary
  final jsonPadding = (4 - (jsonBytes.length & 3)) & 3;
  final paddedJsonBytes = List<int>.from(jsonBytes);
  for (int i = 0; i < jsonPadding; i++) {
    paddedJsonBytes.add(0x20); // Space character
  }
  
  // Create binary data for a simple square (4 vertices, 6 indices)
  final binaryData = [
    // 4 vertices (x, y, z) - 12 floats = 48 bytes
    0x00, 0x00, 0x80, 0xBF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0xBF, // (-1, 0, -1)
    0x00, 0x00, 0x80, 0x3F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0xBF, // (1, 0, -1)
    0x00, 0x00, 0x80, 0x3F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x3F, // (1, 0, 1)
    0x00, 0x00, 0x80, 0xBF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x3F, // (-1, 0, 1)
    
    // 6 indices (unsigned short) - 12 bytes
    0x00, 0x00, 0x01, 0x00, 0x02, 0x00, 0x00, 0x00, 0x02, 0x00, 0x03, 0x00,
    
    // Padding to 4-byte boundary
    0x00, 0x00, 0x00, 0x00
  ];
  
  // Create GLB header (12 bytes)
  final header = [
    0x67, 0x6C, 0x54, 0x46, // 'glTF' magic
    0x02, 0x00, 0x00, 0x00, // Version 2
    // Total length will be set later
  ];
  
  // Create JSON chunk header (8 bytes)
  final jsonLength = paddedJsonBytes.length;
  final jsonChunkHeader = [
    jsonLength & 0xFF,
    (jsonLength >> 8) & 0xFF,
    (jsonLength >> 16) & 0xFF,
    (jsonLength >> 24) & 0xFF,
    0x4A, 0x53, 0x4F, 0x4E // 'JSON'
  ];
  
  // Create binary chunk header (8 bytes)
  final binLength = binaryData.length;
  final binChunkHeader = [
    binLength & 0xFF,
    (binLength >> 8) & 0xFF,
    (binLength >> 16) & 0xFF,
    (binLength >> 24) & 0xFF,
    0x42, 0x49, 0x4E, 0x00 // 'BIN' + null
  ];
  
  // Calculate total length
  final totalLength = 12 + 8 + jsonLength + 8 + binLength;
  
  // Update header with total length
  header.addAll([
    totalLength & 0xFF,
    (totalLength >> 8) & 0xFF,
    (totalLength >> 16) & 0xFF,
    (totalLength >> 24) & 0xFF,
  ]);
  
  // Write GLB file
  final file = File('assets/models/room.glb');
  final bytes = BytesBuilder();
  bytes.add(header);
  bytes.add(jsonChunkHeader);
  bytes.add(paddedJsonBytes);
  bytes.add(binChunkHeader);
  bytes.add(binaryData);
  
  file.writeAsBytesSync(bytes.takeBytes());
  
  // Use debugPrint instead of print for production code
  // ignore: avoid_print
  print('Generated room.glb file with size: ${file.lengthSync()} bytes');
}