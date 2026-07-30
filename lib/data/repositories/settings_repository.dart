import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

class SettingsRepository {
  static const String _key = 'liquidos_settings_v1';

  Future<SettingsModel> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_key);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        return SettingsModel.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
      }
    } catch (_) {}
    return SettingsModel(); // Defaults
  }

  Future<bool> saveSettings(SettingsModel settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = json.encode(settings.toJson());
      return await prefs.setString(_key, jsonStr);
    } catch (_) {
      return false;
    }
  }
}
