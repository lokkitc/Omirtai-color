import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/color_model.dart';
import '../models/color_factory.dart';

class RALColorService {
  static const String _classicColorsPath = 'assets/data/colors/RAL_classic.json';
  
  // Cache for loaded colors
  static Map<String, List<UnifiedRALColor>>? _cachedColors;

  /// Load RAL Classic colors from the JSON file
  static Future<List<UnifiedRALColor>> loadClassicColors() async {
    if (_cachedColors != null && _cachedColors!['classic'] != null) {
      return _cachedColors!['classic']!;
    }

    try {
      final String jsonString = await rootBundle.loadString(_classicColorsPath);
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      
      final List<UnifiedRALColor> colors = [];
      jsonMap.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          colors.add(RALColorFactory.createColorFromJson(
            code: key,
            collection: 'Classic',
            json: value,
          ));
        }
      });

      // Cache the loaded colors
      _cachedColors ??= {};
      _cachedColors!['classic'] = colors;

      return colors;
    } catch (e) {
      // Return empty list if there's an error loading the file
      return [];
    }
  }

  /// Get all available RAL color collections
  static List<String> getAvailableCollections() {
    return ['Classic']; // Add more collections here as they become available
  }

  /// Load colors for a specific collection
  static Future<List<UnifiedRALColor>> loadColorsForCollection(String collection) async {
    switch (collection) {
      case 'Classic':
        return await loadClassicColors();
      default:
        return [];
    }
  }

  /// Group colors by their group/category
  static Map<String, List<UnifiedRALColor>> groupColorsByGroup(List<UnifiedRALColor> colors) {
    final Map<String, List<UnifiedRALColor>> groupedColors = {};
    
    for (final color in colors) {
      if (groupedColors.containsKey(color.group)) {
        groupedColors[color.group]!.add(color);
      } else {
        groupedColors[color.group] = [color];
      }
    }
    
    return groupedColors;
  }
}