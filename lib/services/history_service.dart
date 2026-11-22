import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/track.dart';
import 'favorite_service.dart';

/// Riwayat pencarian & lagu yang terakhir diputar, disimpan di SharedPreferences.
/// Skema: "search_history" -> `List<String>` kata kunci,
///        "recently_played" -> `List<String>` JSON [Track].
class HistoryService {
  static const _searchKey = 'search_history';
  static const _playedKey = 'recently_played';

  final searches = ValueNotifier<List<String>>([]);
  final played = ValueNotifier<List<Track>>([]);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    searches.value = prefs.getStringList(_searchKey) ?? [];
    played.value = decodeTracks(prefs.getStringList(_playedKey));
  }

  /// Terbaru di depan, tanpa duplikat, maksimal 10.
  Future<void> addSearch(String term) async {
    term = term.trim();
    if (term.isEmpty) return;
    searches.value = [
      term,
      ...searches.value.where((s) => s.toLowerCase() != term.toLowerCase()),
    ].take(10).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_searchKey, searches.value);
  }

  Future<void> clearSearches() async {
    searches.value = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_searchKey);
  }

  /// Terbaru di depan, tanpa duplikat, maksimal 20.
  Future<void> addPlayed(Track track) async {
    played.value = [
      track,
      ...played.value.where((t) => t.trackId != track.trackId),
    ].take(20).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_playedKey, encodeTracks(played.value));
  }
}

final historyService = HistoryService();
