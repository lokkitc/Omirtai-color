import 'package:flutter/material.dart';
import '../services/room_model_generator.dart';
import 'package:app/core/models/texture.dart' as texture_model;

class RoomParameters with ChangeNotifier {
  // Размеры комнаты в миллиметрах
  double _roomWidth = 4000.0; // 4 meters = 4000 mm
  double _roomDepth = 4000.0; // 4 meters = 4000 mm
  double _roomHeight = 3000.0; // 3 meters = 3000 mm

  // Цвета стен и пола
  Color _floorColor = const Color(0xFF8B4513); // Коричневый
  Color _ceilingColor = const Color(0xFF87CEEB); // Голубой
  Color _leftWallColor = const Color(0xFF8FBC8F); // Зеленовато-серый
  Color _rightWallColor = const Color(0xFF8FBC8F); // Зеленовато-серый
  Color _frontWallColor = const Color(0xFF8FBC8F); // Зеленовато-серый
  Color _backWallColor = const Color(0xFF8FBC8F); // Зеленовато-серый

  // Текстуры стен и пола
  texture_model.Texture? _floorTexture;
  texture_model.Texture? _ceilingTexture;
  texture_model.Texture? _leftWallTexture;
  texture_model.Texture? _rightWallTexture;
  texture_model.Texture? _frontWallTexture;
  texture_model.Texture? _backWallTexture;

  // Флаг для использования локального файла вместо data URI
  bool _useAssetModel = false;
  
  // Cache for the generated model
  String? _cachedModel;
  String? _cachedModelKey;

  // Геттеры для параметров комнаты
  double get roomWidth => _roomWidth;
  double get roomDepth => _roomDepth;
  double get roomHeight => _roomHeight;

  Color get floorColor => _floorColor;
  Color get ceilingColor => _ceilingColor;
  Color get leftWallColor => _leftWallColor;
  Color get rightWallColor => _rightWallColor;
  Color get frontWallColor => _frontWallColor;
  Color get backWallColor => _backWallColor;

  texture_model.Texture? get floorTexture => _floorTexture;
  texture_model.Texture? get ceilingTexture => _ceilingTexture;
  texture_model.Texture? get leftWallTexture => _leftWallTexture;
  texture_model.Texture? get rightWallTexture => _rightWallTexture;
  texture_model.Texture? get frontWallTexture => _frontWallTexture;
  texture_model.Texture? get backWallTexture => _backWallTexture;

  // Геттер для получения сгенерированной модели
  String get generatedModel {
    if (_useAssetModel) {
      // Используем локальный файл активов
      return 'asset:///assets/models/room.glb';
    } else {
      // Create a key for current parameters
      final currentKey = '$_roomWidth:$_roomDepth:$_roomHeight:'
          '${_floorColor.value}:${_ceilingColor.value}:'
          '${_leftWallColor.value}:${_rightWallColor.value}:'
          '${_frontWallColor.value}:${_backWallColor.value}:'
          '${_floorTexture?.name ?? "null"}:'
          '${_ceilingTexture?.name ?? "null"}:'
          '${_leftWallTexture?.name ?? "null"}:'
          '${_rightWallTexture?.name ?? "null"}:'
          '${_frontWallTexture?.name ?? "null"}:'
          '${_backWallTexture?.name ?? "null"}';
      
      // Check if we have a cached model for these parameters
      if (_cachedModel != null && _cachedModelKey == currentKey) {
        return _cachedModel!;
      }
      
      // Добавляем отладочный вывод
      debugPrint('Generating model with width: $_roomWidth, depth: $_roomDepth, height: $_roomHeight');
      final model = RoomModelGenerator.generateRoomModel(
        // Convert mm to meters for the model generator
        width: _roomWidth / 1000.0,
        depth: _roomDepth / 1000.0,
        height: _roomHeight / 1000.0,
        floorColor: _floorColor,
        ceilingColor: _ceilingColor,
        leftWallColor: _leftWallColor,
        rightWallColor: _rightWallColor,
        frontWallColor: _frontWallColor,
        backWallColor: _backWallColor,
        // Pass texture parameters
        floorTexture: _floorTexture,
        ceilingTexture: _ceilingTexture,
        leftWallTexture: _leftWallTexture,
        rightWallTexture: _rightWallTexture,
        frontWallTexture: _frontWallTexture,
        backWallTexture: _backWallTexture,
      );
      
      // Cache the model
      _cachedModel = model;
      _cachedModelKey = currentKey;
      
      return model;
    }
  }

  // Сеттеры для параметров комнаты
  set roomWidth(double value) {
    debugPrint('Setting room width to: $value mm');
    if (_roomWidth != value) {
      _roomWidth = value;
      _clearCache();
      notifyListeners();
    }
  }

  set roomDepth(double value) {
    debugPrint('Setting room depth to: $value mm');
    if (_roomDepth != value) {
      _roomDepth = value;
      _clearCache();
      notifyListeners();
    }
  }

  set roomHeight(double value) {
    debugPrint('Setting room height to: $value mm');
    if (_roomHeight != value) {
      _roomHeight = value;
      _clearCache();
      notifyListeners();
    }
  }

  set floorColor(Color value) {
    debugPrint('Setting floor color to: $value');
    if (_floorColor != value) {
      _floorColor = value;
      _clearCache();
      notifyListeners();
    }
  }

  set ceilingColor(Color value) {
    debugPrint('Setting ceiling color to: $value');
    if (_ceilingColor != value) {
      _ceilingColor = value;
      _clearCache();
      notifyListeners();
    }
  }

  set leftWallColor(Color value) {
    debugPrint('Setting left wall color to: $value');
    if (_leftWallColor != value) {
      _leftWallColor = value;
      _clearCache();
      notifyListeners();
    }
  }

  set rightWallColor(Color value) {
    debugPrint('Setting right wall color to: $value');
    if (_rightWallColor != value) {
      _rightWallColor = value;
      _clearCache();
      notifyListeners();
    }
  }

  set frontWallColor(Color value) {
    debugPrint('Setting front wall color to: $value');
    if (_frontWallColor != value) {
      _frontWallColor = value;
      _clearCache();
      notifyListeners();
    }
  }

  set backWallColor(Color value) {
    debugPrint('Setting back wall color to: $value');
    if (_backWallColor != value) {
      _backWallColor = value;
      _clearCache();
      notifyListeners();
    }
  }

  // Сеттеры для текстур
  set floorTexture(texture_model.Texture? value) {
    debugPrint('Setting floor texture to: ${value?.name ?? "none"}');
    if (_floorTexture != value) {
      _floorTexture = value;
      _clearCache();
      notifyListeners();
    }
  }

  set ceilingTexture(texture_model.Texture? value) {
    debugPrint('Setting ceiling texture to: ${value?.name ?? "none"}');
    if (_ceilingTexture != value) {
      _ceilingTexture = value;
      _clearCache();
      notifyListeners();
    }
  }

  set leftWallTexture(texture_model.Texture? value) {
    debugPrint('Setting left wall texture to: ${value?.name ?? "none"}');
    if (_leftWallTexture != value) {
      _leftWallTexture = value;
      _clearCache();
      notifyListeners();
    }
  }

  set rightWallTexture(texture_model.Texture? value) {
    debugPrint('Setting right wall texture to: ${value?.name ?? "none"}');
    if (_rightWallTexture != value) {
      _rightWallTexture = value;
      _clearCache();
      notifyListeners();
    }
  }

  set frontWallTexture(texture_model.Texture? value) {
    debugPrint('Setting front wall texture to: ${value?.name ?? "none"}');
    if (_frontWallTexture != value) {
      _frontWallTexture = value;
      _clearCache();
      notifyListeners();
    }
  }

  set backWallTexture(texture_model.Texture? value) {
    debugPrint('Setting back wall texture to: ${value?.name ?? "none"}');
    if (_backWallTexture != value) {
      _backWallTexture = value;
      _clearCache();
      notifyListeners();
    }
  }
  
  // Clear the model cache when parameters change
  void _clearCache() {
    _cachedModel = null;
    _cachedModelKey = null;
    _useAssetModel = false; // Переключаемся обратно на генерацию
  }

  // Метод для переключения на использование локального файла
  void useAssetModel() {
    _useAssetModel = true;
    notifyListeners();
  }

  // Метод для сброса к значениям по умолчанию
  void resetToDefault() {
    debugPrint('Resetting to default values');
    _roomWidth = 4000.0;
    _roomDepth = 4000.0;
    _roomHeight = 3000.0;
    
    _floorColor = const Color(0xFF8B4513);
    _ceilingColor = const Color(0xFF87CEEB);
    _leftWallColor = const Color(0xFF8FBC8F);
    _rightWallColor = const Color(0xFF8FBC8F);
    _frontWallColor = const Color(0xFF8FBC8F);
    _backWallColor = const Color(0xFF8FBC8F);
    
    _floorTexture = null;
    _ceilingTexture = null;
    _leftWallTexture = null;
    _rightWallTexture = null;
    _frontWallTexture = null;
    _backWallTexture = null;
    
    _clearCache();
    notifyListeners();
  }
}