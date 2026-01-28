import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'tictactoe_score.dart';

class TicTacToeScoreStore {
  static const _key = 'tictactoe_score_v1';

  Future<TicTacToeScore> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return TicTacToeScore.empty;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return TicTacToeScore.empty;
      return TicTacToeScore.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return TicTacToeScore.empty;
    }
  }

  Future<void> save(TicTacToeScore score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(score.toJson()));
  }
}
