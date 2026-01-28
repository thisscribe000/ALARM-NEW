import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/world_city.dart';

class WorldClockStore {
  static const _key = 'world_clock_cities_v1';

  Future<List<WorldCity>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((m) => WorldCity.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<WorldCity> cities) async {
    final prefs = await SharedPreferences.getInstance();
    final data = cities.map((c) => c.toJson()).toList();
    await prefs.setString(_key, jsonEncode(data));
  }
}
