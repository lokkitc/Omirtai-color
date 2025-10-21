import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/features/calculators/models/area_history_entry.dart';
import 'package:app/features/calculators/models/volume_history_entry.dart';

class PersistenceService {
  static const String _historyKey = 'calculator_history';
  static const String _volumeHistoryKey = 'volume_calculator_history';
  static const String _themeKey = 'selected_theme';
  static const String _languageKey = 'selected_language';

  // Singleton pattern
  static final PersistenceService _instance = PersistenceService._internal();
  factory PersistenceService() => _instance;
  PersistenceService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // History persistence methods for area calculator
  Future<void> saveHistory(List<AreaHistoryEntry> history) async {
    final List<Map<String, dynamic>> historyMaps = 
        history.map((entry) => entry.toMap()).toList();
    final String historyJson = jsonEncode(historyMaps);
    await _prefs.setString(_historyKey, historyJson);
  }

  Future<List<AreaHistoryEntry>> loadHistory() async {
    final String? historyJson = _prefs.getString(_historyKey);
    if (historyJson == null) return [];

    try {
      final List<dynamic> historyMaps = jsonDecode(historyJson);
      return historyMaps
          .map((map) => AreaHistoryEntry.fromMap(Map<String, dynamic>.from(map)))
          .toList();
    } catch (e) {
      // If there's an error decoding, return empty list
      return [];
    }
  }

  // History persistence methods for volume calculator
  Future<void> saveVolumeHistory(List<VolumeHistoryEntry> history) async {
    final List<Map<String, dynamic>> historyMaps = 
        history.map((entry) => entry.toMap()).toList();
    final String historyJson = jsonEncode(historyMaps);
    await _prefs.setString(_volumeHistoryKey, historyJson);
  }

  Future<List<VolumeHistoryEntry>> loadVolumeHistory() async {
    final String? historyJson = _prefs.getString(_volumeHistoryKey);
    if (historyJson == null) return [];

    try {
      final List<dynamic> historyMaps = jsonDecode(historyJson);
      return historyMaps
          .map((map) => VolumeHistoryEntry.fromMap(Map<String, dynamic>.from(map)))
          .toList();
    } catch (e) {
      // If there's an error decoding, return empty list
      return [];
    }
  }

  // Theme persistence methods
  Future<void> saveTheme(String theme) async {
    await _prefs.setString(_themeKey, theme);
  }

  String loadTheme() {
    return _prefs.getString(_themeKey) ?? 'system';
  }

  // Language persistence methods
  Future<void> saveLanguage(String language) async {
    await _prefs.setString(_languageKey, language);
  }

  String loadLanguage() {
    return _prefs.getString(_languageKey) ?? 'en';
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs.remove(_historyKey);
    await _prefs.remove(_volumeHistoryKey);
    await _prefs.remove(_themeKey);
    await _prefs.remove(_languageKey);
  }
}