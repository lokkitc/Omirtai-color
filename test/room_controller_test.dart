import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/modeling/view/room_controller.dart';

void main() {
  group('RoomParameters', () {
    late RoomParameters roomParams;

    setUp(() {
      roomParams = RoomParameters();
    });

    test('initial values are correct', () {
      expect(roomParams.roomWidth, 4.0);
      expect(roomParams.roomDepth, 4.0);
      expect(roomParams.roomHeight, 3.0);
      expect(roomParams.floorColor, const Color(0xFF8B4513));
      expect(roomParams.ceilingColor, const Color(0xFF87CEEB));
      expect(roomParams.leftWallColor, const Color(0xFF8FBC8F));
      expect(roomParams.rightWallColor, const Color(0xFF8FBC8F));
      expect(roomParams.frontWallColor, const Color(0xFF8FBC8F));
      expect(roomParams.backWallColor, const Color(0xFF8FBC8F));
    });

    test('generated model is valid', () {
      final model = roomParams.generatedModel;
      expect(model.startsWith('data:model/gltf+json;base64,'), true);
      expect(model.length > 'data:model/gltf+json;base64,'.length, true);
    });

    test('parameters can be updated', () {
      roomParams.roomWidth = 5.0;
      expect(roomParams.roomWidth, 5.0);

      roomParams.floorColor = Colors.red;
      expect(roomParams.floorColor, Colors.red);
    });

    test('reset to default works', () {
      // Изменяем значения
      roomParams.roomWidth = 5.0;
      roomParams.floorColor = Colors.red;

      // Сбрасываем к значениям по умолчанию
      roomParams.resetToDefault();

      // Проверяем, что значения сброшены
      expect(roomParams.roomWidth, 4.0);
      expect(roomParams.floorColor, const Color(0xFF8B4513));
    });
  });
}