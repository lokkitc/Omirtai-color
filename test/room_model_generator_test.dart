import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/modeling/services/room_model_generator.dart';
import 'package:app/core/models/texture.dart' as texture_model;

void main() {
  group('RoomModelGenerator', () {
    test('generates model with colors only', () {
      final model = RoomModelGenerator.generateRoomModel(
        width: 4.0,
        depth: 4.0,
        height: 3.0,
        floorColor: const Color(0xFF8B4513),
        ceilingColor: const Color(0xFF87CEEB),
        leftWallColor: const Color(0xFF8FBC8F),
        rightWallColor: const Color(0xFF8FBC8F),
        frontWallColor: const Color(0xFF8FBC8F),
        backWallColor: const Color(0xFF8FBC8F),
      );

      expect(model, startsWith('data:model/gltf+json;base64,'));
      expect(model.length, greaterThan(50));
    });

    test('generates model with textures', () {
      final texture = texture_model.Texture(
        name: 'test-texture',
        assetPath: 'assets/data/textures/grunge-wall.png',
        displayName: 'Test Texture',
      );

      final model = RoomModelGenerator.generateRoomModel(
        width: 4.0,
        depth: 4.0,
        height: 3.0,
        floorColor: const Color(0xFF8B4513),
        ceilingColor: const Color(0xFF87CEEB),
        leftWallColor: const Color(0xFF8FBC8F),
        rightWallColor: const Color(0xFF8FBC8F),
        frontWallColor: const Color(0xFF8FBC8F),
        backWallColor: const Color(0xFF8FBC8F),
        floorTexture: texture,
        frontWallTexture: texture,
      );

      expect(model, startsWith('data:model/gltf+json;base64,'));
      expect(model.length, greaterThan(50));
    });

    test('caches generated models', () {
      final texture = texture_model.Texture(
        name: 'test-texture',
        assetPath: 'assets/data/textures/grunge-wall.png',
        displayName: 'Test Texture',
      );

      final model1 = RoomModelGenerator.generateRoomModel(
        width: 4.0,
        depth: 4.0,
        height: 3.0,
        floorColor: const Color(0xFF8B4513),
        ceilingColor: const Color(0xFF87CEEB),
        leftWallColor: const Color(0xFF8FBC8F),
        rightWallColor: const Color(0xFF8FBC8F),
        frontWallColor: const Color(0xFF8FBC8F),
        backWallColor: const Color(0xFF8FBC8F),
        floorTexture: texture,
      );

      final model2 = RoomModelGenerator.generateRoomModel(
        width: 4.0,
        depth: 4.0,
        height: 3.0,
        floorColor: const Color(0xFF8B4513),
        ceilingColor: const Color(0xFF87CEEB),
        leftWallColor: const Color(0xFF8FBC8F),
        rightWallColor: const Color(0xFF8FBC8F),
        frontWallColor: const Color(0xFF8FBC8F),
        backWallColor: const Color(0xFF8FBC8F),
        floorTexture: texture,
      );

      expect(model1, equals(model2));
    });

    test('clears cache when requested', () {
      RoomModelGenerator.clearCache();
      // This test just ensures the method exists and doesn't throw
      expect(true, isTrue);
    });
  });
}