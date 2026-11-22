import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/track.dart';

/// Menyimpan lagu favorit di SharedPreferences.
/// Skema: key "favorites" -> `List<String>`, tiap item = JSON satu [Track].
class FavoriteService {
  static const _key = 'favorites';

  /// UI mendengarkan notifier ini, jadi perubahan langsung terlihat di semua halaman.
  final favorites = ValueNotifier<List<Track>>([]);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    favorites.value = decodeTracks(prefs.getStringList(_key));
  }

  bool isFavorite(Track track) =>
      favorites.value.any((t) => t.trackId == track.trackId);

  Future<void> toggle(Track track) =>
      isFavorite(track) ? remove(track) : add(track);

  Future<void> add(Track track) async {
    if (isFavorite(track)) return; // cegah duplikasi trackId
    await _save([track, ...favorites.value]);
  }

  Future<void> remove(Track track) =>
      _save(favorites.value.where((t) => t.trackId != track.trackId).toList());

  Future<void> _save(List<Track> tracks) async {
    favorites.value = tracks;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, encodeTracks(tracks));
  }
}

List<String> encodeTracks(List<Track> tracks) =>
    tracks.map((t) => jsonEncode(t.toJson())).toList();

/// Item yang rusak dilewati satu per satu, supaya data lain tetap terbaca.
List<Track> decodeTracks(List<String>? raw) {
  final tracks = <Track>[];
  for (final s in raw ?? const <String>[]) {
    try {
      tracks.add(Track.fromJson(jsonDecode(s) as Map<String, dynamic>));
    } catch (_) {}
  }
  return tracks;
}

final favoriteService = FavoriteService();
