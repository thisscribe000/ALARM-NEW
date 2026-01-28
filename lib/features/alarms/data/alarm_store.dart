import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/alarm.dart';

class AlarmStore {
  static const _key = 'alarms_v1';

  Future<List<Alarm>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((m) => Alarm.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<Alarm> alarms) async {
    final prefs = await SharedPreferences.getInstance();
    final list = alarms.map((a) => a.toJson()).toList();
    await prefs.setString(_key, jsonEncode(list));
  }
}
