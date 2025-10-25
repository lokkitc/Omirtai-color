import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Базовый класс для геометрических параметров
class Geometry {
  final double length; // длина в мм
  final double width;  // ширина в мм
  final double height; // высота в мм

  const Geometry({
    required this.length,
    required this.width,
    required this.height,
  });

  /// Создает копию с новыми параметрами
  Geometry copyWith({
    double? length,
    double? width,
    double? height,
  }) {
    return Geometry(
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  /// Объем объекта в мм³
  double get volume => length * width * height;

  /// Площадь поверхности в мм²
  double get surfaceArea => 2 * (length * width + length * height + width * height);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Geometry &&
        other.length == length &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode => Object.hash(length, width, height);

  @override
  String toString() => 'Geometry(length: $length, width: $width, height: $height)';
}

/// Класс для позиции в 3D пространстве
class Position3D {
  final double x;
  final double y;
  final double z;

  const Position3D(this.x, this.y, this.z);

  /// Создает копию с новыми координатами
  Position3D copyWith({
    double? x,
    double? y,
    double? z,
  }) {
    return Position3D(
      x ?? this.x,
      y ?? this.y,
      z ?? this.z,
    );
  }

  /// Расстояние до другой точки
  double distanceTo(Position3D other) {
    final dx = x - other.x;
    final dy = y - other.y;
    final dz = z - other.z;
    return math.sqrt(dx * dx + dy * dy + dz * dz);
  }

  /// Сложение позиций
  Position3D operator +(Position3D other) {
    return Position3D(x + other.x, y + other.y, z + other.z);
  }

  /// Вычитание позиций
  Position3D operator -(Position3D other) {
    return Position3D(x - other.x, y - other.y, z - other.z);
  }

  /// Умножение на скаляр
  Position3D operator *(double scalar) {
    return Position3D(x * scalar, y * scalar, z * scalar);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position3D &&
        other.x == x &&
        other.y == y &&
        other.z == z;
  }

  @override
  int get hashCode => Object.hash(x, y, z);

  @override
  String toString() => 'Position3D(x: $x, y: $y, z: $z)';
}

/// Класс для ориентации в 3D пространстве (углы Эйлера в градусах)
class Rotation3D {
  final double pitch; // поворот вокруг оси X
  final double yaw;   // поворот вокруг оси Y
  final double roll;  // поворот вокруг оси Z

  const Rotation3D({
    this.pitch = 0.0,
    this.yaw = 0.0,
    this.roll = 0.0,
  });

  /// Создает копию с новыми углами
  Rotation3D copyWith({
    double? pitch,
    double? yaw,
    double? roll,
  }) {
    return Rotation3D(
      pitch: pitch ?? this.pitch,
      yaw: yaw ?? this.yaw,
      roll: roll ?? this.roll,
    );
  }

  /// Нормализация углов в диапазон [0, 360)
  Rotation3D normalized() {
    return Rotation3D(
      pitch: _normalizeAngle(pitch),
      yaw: _normalizeAngle(yaw),
      roll: _normalizeAngle(roll),
    );
  }

  double _normalizeAngle(double angle) {
    while (angle < 0) angle += 360;
    while (angle >= 360) angle -= 360;
    return angle;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Rotation3D &&
        other.pitch == pitch &&
        other.yaw == yaw &&
        other.roll == roll;
  }

  @override
  int get hashCode => Object.hash(pitch, yaw, roll);

  @override
  String toString() => 'Rotation3D(pitch: $pitch, yaw: $yaw, roll: $roll)';
}

/// Класс для масштабирования
class Scale3D {
  final double x;
  final double y;
  final double z;

  const Scale3D(this.x, this.y, this.z);

  /// Равномерное масштабирование
  const Scale3D.uniform(double scale) : x = scale, y = scale, z = scale;

  /// Создает копию с новыми значениями масштаба
  Scale3D copyWith({
    double? x,
    double? y,
    double? z,
  }) {
    return Scale3D(
      x ?? this.x,
      y ?? this.y,
      z ?? this.z,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Scale3D &&
        other.x == x &&
        other.y == y &&
        other.z == z;
  }

  @override
  int get hashCode => Object.hash(x, y, z);

  @override
  String toString() => 'Scale3D(x: $x, y: $y, z: $z)';
}

/// Матрица трансформации 4x4
class TransformMatrix {
  final List<List<double>> _matrix;

  TransformMatrix._(this._matrix);

  /// Создает единичную матрицу
  factory TransformMatrix.identity() {
    return TransformMatrix._([
      [1, 0, 0, 0],
      [0, 1, 0, 0],
      [0, 0, 1, 0],
      [0, 0, 0, 1],
    ]);
  }

  /// Создает матрицу трансляции
  factory TransformMatrix.translation(Position3D position) {
    return TransformMatrix._([
      [1, 0, 0, position.x],
      [0, 1, 0, position.y],
      [0, 0, 1, position.z],
      [0, 0, 0, 1],
    ]);
  }

  /// Создает матрицу масштабирования
  factory TransformMatrix.scale(Scale3D scale) {
    return TransformMatrix._([
      [scale.x, 0, 0, 0],
      [0, scale.y, 0, 0],
      [0, 0, scale.z, 0],
      [0, 0, 0, 1],
    ]);
  }

  /// Создает матрицу поворота
  factory TransformMatrix.rotation(Rotation3D rotation) {
    final pitch = rotation.pitch * math.pi / 180;
    final yaw = rotation.yaw * math.pi / 180;
    final roll = rotation.roll * math.pi / 180;

    // Матрица поворота по оси X (pitch)
    final cosPitch = math.cos(pitch);
    final sinPitch = math.sin(pitch);
    final pitchMatrix = TransformMatrix._([
      [1, 0, 0, 0],
      [0, cosPitch, -sinPitch, 0],
      [0, sinPitch, cosPitch, 0],
      [0, 0, 0, 1],
    ]);

    // Матрица поворота по оси Y (yaw)
    final cosYaw = math.cos(yaw);
    final sinYaw = math.sin(yaw);
    final yawMatrix = TransformMatrix._([
      [cosYaw, 0, sinYaw, 0],
      [0, 1, 0, 0],
      [-sinYaw, 0, cosYaw, 0],
      [0, 0, 0, 1],
    ]);

    // Матрица поворота по оси Z (roll)
    final cosRoll = math.cos(roll);
    final sinRoll = math.sin(roll);
    final rollMatrix = TransformMatrix._([
      [cosRoll, -sinRoll, 0, 0],
      [sinRoll, cosRoll, 0, 0],
      [0, 0, 1, 0],
      [0, 0, 0, 1],
    ]);

    return rollMatrix * yawMatrix * pitchMatrix;
  }

  /// Умножение матриц
  TransformMatrix operator *(TransformMatrix other) {
    final result = List.generate(4, (i) => List.generate(4, (j) => 0.0));
    
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        for (int k = 0; k < 4; k++) {
          result[i][j] += _matrix[i][k] * other._matrix[k][j];
        }
      }
    }
    
    return TransformMatrix._(result);
  }

  /// Применение трансформации к точке
  Position3D transformPoint(Position3D point) {
    final x = _matrix[0][0] * point.x + _matrix[0][1] * point.y + _matrix[0][2] * point.z + _matrix[0][3];
    final y = _matrix[1][0] * point.x + _matrix[1][1] * point.y + _matrix[1][2] * point.z + _matrix[1][3];
    final z = _matrix[2][0] * point.x + _matrix[2][1] * point.y + _matrix[2][2] * point.z + _matrix[2][3];
    
    return Position3D(x, y, z);
  }

  /// Получение элемента матрицы
  double operator [](int index) {
    final row = index ~/ 4;
    final col = index % 4;
    return _matrix[row][col];
  }

  @override
  String toString() {
    return 'TransformMatrix(\n'
        '  [${_matrix[0][0]}, ${_matrix[0][1]}, ${_matrix[0][2]}, ${_matrix[0][3]}],\n'
        '  [${_matrix[1][0]}, ${_matrix[1][1]}, ${_matrix[1][2]}, ${_matrix[1][3]}],\n'
        '  [${_matrix[2][0]}, ${_matrix[2][1]}, ${_matrix[2][2]}, ${_matrix[2][3]}],\n'
        '  [${_matrix[3][0]}, ${_matrix[3][1]}, ${_matrix[3][2]}, ${_matrix[3][3]}],\n'
        ')';
  }
}
