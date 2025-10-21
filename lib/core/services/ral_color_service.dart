import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:app/core/models/ral_color.dart';

/// Service for loading and managing RAL classic colors
class RalColorService {
  static final RalColorService _instance = RalColorService._internal();
  factory RalColorService() => _instance;
  RalColorService._internal();

  Map<String, RalColor>? _ralColors;

  /// Load RAL colors from the JSON file
  Future<Map<String, RalColor>> loadRalColors() async {
    if (_ralColors != null) {
      return _ralColors!;
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/data/colors/RAL_classic.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      
      _ralColors = <String, RalColor>{};
      jsonMap.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          _ralColors![key] = RalColor.fromJson(key, value);
        }
      });

      return _ralColors!;
    } catch (e) {
      // Return empty map if there's an error
      _ralColors = <String, RalColor>{};
      return _ralColors!;
    }
  }

  /// Get a specific RAL color by code
  Future<RalColor?> getRalColor(String code) async {
    final colors = await loadRalColors();
    return colors[code];
  }

  /// Get all RAL colors
  Future<List<RalColor>> getAllRalColors() async {
    final colors = await loadRalColors();
    return colors.values.toList();
  }

  /// Get RAL colors by group
  Future<List<RalColor>> getRalColorsByGroup(String group) async {
    final colors = await loadRalColors();
    return colors.values.where((color) => color.group == group).toList();
  }

  /// Search RAL colors by name or code
  Future<List<RalColor>> searchRalColors(String query) async {
    final colors = await loadRalColors();
    final lowerQuery = query.toLowerCase();
    
    return colors.values.where((color) {
      return color.name.toLowerCase().contains(lowerQuery) || 
             color.code.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}