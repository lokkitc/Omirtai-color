import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/object_3d.dart';
import 'scene_manager.dart';

/// Сервис для локального хранения данных
class StorageService {
  static const String _scenesKey = 'cad_scenes';
  static const String _currentSceneKey = 'current_scene';
  static const String _settingsKey = 'cad_settings';
  
  final SharedPreferences _prefs;
  final String _storagePath;

  StorageService(this._prefs, this._storagePath);

  /// Сохраняет сцену
  Future<void> saveScene(Scene scene) async {
    try {
      // Сохраняем в SharedPreferences для быстрого доступа
      final scenesJson = _prefs.getString(_scenesKey) ?? '{}';
      final scenes = jsonDecode(scenesJson) as Map<String, dynamic>;
      scenes[scene.name] = scene.toJson();
      await _prefs.setString(_scenesKey, jsonEncode(scenes));

      // Сохраняем в файл для резервного копирования
      final file = File('$_storagePath/scenes/${scene.name}.json');
      await file.create(recursive: true);
      await file.writeAsString(jsonEncode(scene.toJson()));
    } catch (e) {
      print('Error saving scene: $e');
    }
  }

  /// Загружает сцену
  Future<Scene?> loadScene(String sceneName) async {
    try {
      // Сначала пробуем загрузить из SharedPreferences
      final scenesJson = _prefs.getString(_scenesKey) ?? '{}';
      final scenes = jsonDecode(scenesJson) as Map<String, dynamic>;
      if (scenes.containsKey(sceneName)) {
        return Scene.fromJson(scenes[sceneName] as Map<String, dynamic>);
      }

      // Если нет в SharedPreferences, пробуем загрузить из файла
      final file = File('$_storagePath/scenes/$sceneName.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        return Scene.fromJson(json);
      }
    } catch (e) {
      print('Error loading scene: $e');
    }
    return null;
  }

  /// Получает список всех сцен
  Future<List<String>> getSceneNames() async {
    try {
      final scenesDir = Directory('$_storagePath/scenes');
      if (await scenesDir.exists()) {
        final files = await scenesDir.list().toList();
        return files
            .where((file) => file.path.endsWith('.json'))
            .map((file) => file.path.split('/').last.replaceAll('.json', ''))
            .toList();
      }
    } catch (e) {
      print('Error getting scene names: $e');
    }
    return [];
  }

  /// Удаляет сцену
  Future<void> deleteScene(String sceneName) async {
    try {
      final file = File('$_storagePath/scenes/$sceneName.json');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting scene: $e');
    }
  }

  /// Сохраняет настройки
  Future<void> saveSettings(CadSettings settings) async {
    try {
      final file = File('$_storagePath/settings.json');
      await file.create(recursive: true);
      await file.writeAsString(jsonEncode(settings.toJson()));
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  /// Загружает настройки
  Future<CadSettings> loadSettings() async {
    try {
      final file = File('$_storagePath/settings.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        return CadSettings.fromJson(json);
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
    return CadSettings();
  }

  /// Очищает все данные
  Future<void> clearAll() async {
    try {
      final scenesDir = Directory('$_storagePath');
      if (await scenesDir.exists()) {
        await scenesDir.delete(recursive: true);
      }
    } catch (e) {
      print('Error clearing data: $e');
    }
  }

  /// Создает резервную копию всех данных
  Future<void> createBackup(String backupPath) async {
    try {
      final backupDir = Directory(backupPath);
      await backupDir.create(recursive: true);

      // Копируем все сцены
      final scenesDir = Directory('$_storagePath/scenes');
      if (await scenesDir.exists()) {
        final backupScenesDir = Directory('$backupPath/scenes');
        await backupScenesDir.create(recursive: true);
        
        final files = await scenesDir.list().toList();
        for (final file in files) {
          if (file is File && file.path.endsWith('.json')) {
            final fileName = file.path.split('/').last;
            await file.copy('$backupPath/scenes/$fileName');
          }
        }
      }

      // Копируем настройки
      final settingsFile = File('$_storagePath/settings.json');
      if (await settingsFile.exists()) {
        await settingsFile.copy('$backupPath/settings.json');
      }
    } catch (e) {
      print('Error creating backup: $e');
    }
  }

  /// Восстанавливает данные из резервной копии
  Future<void> restoreFromBackup(String backupPath) async {
    try {
      // Очищаем текущие данные
      await clearAll();

      // Восстанавливаем сцены
      final backupScenesDir = Directory('$backupPath/scenes');
      if (await backupScenesDir.exists()) {
        final scenesDir = Directory('$_storagePath/scenes');
        await scenesDir.create(recursive: true);
        
        final files = await backupScenesDir.list().toList();
        for (final file in files) {
          if (file is File && file.path.endsWith('.json')) {
            final fileName = file.path.split('/').last;
            await file.copy('$_storagePath/scenes/$fileName');
          }
        }
      }

      // Восстанавливаем настройки
      final backupSettingsFile = File('$backupPath/settings.json');
      if (await backupSettingsFile.exists()) {
        await backupSettingsFile.copy('$_storagePath/settings.json');
      }
    } catch (e) {
      print('Error restoring from backup: $e');
    }
  }
}

/// Настройки CAD приложения
class CadSettings {
  final bool showGrid;
  final bool snapToGrid;
  final double gridSize;
  final bool showAxes;
  final bool showBoundingBoxes;
  final Color backgroundColor;
  final bool autoSave;
  final int autoSaveInterval; // в минутах

  CadSettings({
    this.showGrid = true,
    this.snapToGrid = true,
    this.gridSize = 100.0,
    this.showAxes = true,
    this.showBoundingBoxes = false,
    this.backgroundColor = const Color(0xFF1E1E1E),
    this.autoSave = true,
    this.autoSaveInterval = 5,
  });

  /// Сериализация в JSON
  Map<String, dynamic> toJson() {
    return {
      'showGrid': showGrid,
      'snapToGrid': snapToGrid,
      'gridSize': gridSize,
      'showAxes': showAxes,
      'showBoundingBoxes': showBoundingBoxes,
      'backgroundColor': backgroundColor.value,
      'autoSave': autoSave,
      'autoSaveInterval': autoSaveInterval,
    };
  }

  /// Десериализация из JSON
  static CadSettings fromJson(Map<String, dynamic> json) {
    return CadSettings(
      showGrid: json['showGrid'] as bool? ?? true,
      snapToGrid: json['snapToGrid'] as bool? ?? true,
      gridSize: (json['gridSize'] as num?)?.toDouble() ?? 100.0,
      showAxes: json['showAxes'] as bool? ?? true,
      showBoundingBoxes: json['showBoundingBoxes'] as bool? ?? false,
      backgroundColor: Color(json['backgroundColor'] as int? ?? 0xFF1E1E1E),
      autoSave: json['autoSave'] as bool? ?? true,
      autoSaveInterval: json['autoSaveInterval'] as int? ?? 5,
    );
  }
}



