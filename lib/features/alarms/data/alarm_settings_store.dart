import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/alarm_settings.dart';

class AlarmSettingsStore {
  static const _key = 'alarm_settings_v1';

  Future<AlarmSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return AlarmSettings.defaultValue;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return AlarmSettings.defaultValue;
      return AlarmSettings.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return AlarmSettings.defaultValue;
    }
  }

  Future<void> save(AlarmSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(settings.toJson()));
  }
}
