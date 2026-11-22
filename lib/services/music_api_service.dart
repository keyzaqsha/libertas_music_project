import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/track.dart';

/// Error dengan pesan yang siap ditampilkan ke pengguna.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

/// Mengambil data lagu dari iTunes Search API (https://itunes.apple.com).
class MusicApiService {
  MusicApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Cari lagu berdasarkan judul atau artis.
  Future<List<Track>> search(String term, {int limit = 25}) => _get('/search', {
    'term': term.trim(),
    'entity': 'song',
    'limit': '$limit',
  });

  /// Lagu teratas dari satu artis (dipakai di Home).
  Future<List<Track>> artistSongs(String artist, {int limit = 5}) =>
      _get('/search', {
        'term': artist,
        'entity': 'song',
        'attribute': 'artistTerm',
        'limit': '$limit',
      });

  /// Lagu dari beberapa artis sekaligus (Home). Artis yang gagal (mis. kena rate limit)
  /// diganti daftar kosong; error hanya dilempar jika semuanya gagal.
  Future<List<List<Track>>> songsOfArtists(List<String> artists) async {
    final errors = <Object>[];
    final results = await Future.wait(
      artists.map(
        (a) => artistSongs(a).catchError((Object e) {
          errors.add(e);
          return <Track>[];
        }),
      ),
    );
    if (artists.isNotEmpty && errors.length == artists.length) {
      throw errors.first;
    }
    return results;
  }

  /// Tracklist satu album.
  Future<List<Track>> albumTracks(int collectionId) =>
      _get('/lookup', {'id': '$collectionId', 'entity': 'song'});

  Future<List<Track>> _get(String path, Map<String, String> query) async {
    final http.Response res;
    try {
      res = await _client
          .get(Uri.https('itunes.apple.com', path, query))
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw ApiException('The server took too long to respond. Try again.');
    } on http.ClientException {
      throw ApiException(
        'No internet connection. Check your network and try again.',
      );
    }

    // iTunes membatasi ~20 request/menit dan membalas 403/429 jika terlampaui.
    if (res.statusCode == 403 || res.statusCode == 429) {
      throw ApiException('Too many requests. Wait a minute, then try again.');
    }
    if (res.statusCode != 200) {
      throw ApiException('Server error (${res.statusCode}). Try again later.');
    }

    try {
      final results = jsonDecode(utf8.decode(res.bodyBytes))['results'] as List;
      return results
          .cast<Map<String, dynamic>>()
          // lookup juga mengembalikan data album; ambil lagunya saja.
          .where((j) => j['kind'] == 'song' && j['trackId'] is int)
          .map(Track.fromJson)
          .toList();
    } on FormatException {
      throw ApiException('Received unexpected data from the server.');
    } on TypeError {
      throw ApiException('Received unexpected data from the server.');
    }
  }
}

final musicApi = MusicApiService();
