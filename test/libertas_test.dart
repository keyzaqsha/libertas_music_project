import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:libertas/models/track.dart';
import 'package:libertas/screens/library_screen.dart';
import 'package:libertas/screens/search_screen.dart';
import 'package:libertas/services/favorite_service.dart';
import 'package:libertas/services/history_service.dart';
import 'package:libertas/services/music_api_service.dart';

Map<String, dynamic> songJson(int id, {String? preview = 'https://x/p.m4a'}) =>
    {
      'wrapperType': 'track',
      'kind': 'song',
      'trackId': id,
      'trackName': 'Song $id',
      'artistName': 'Artist',
      'collectionName': 'Album',
      'collectionId': 99,
      'artworkUrl100': '',
      'previewUrl': ?preview,
      'trackTimeMillis': 197950,
      'releaseDate': '2024-05-28T07:00:00Z',
      'primaryGenreName': 'Pop',
    };

void main() {
  group('Track', () {
    test('parses JSON and survives a missing previewUrl', () {
      final t = Track.fromJson(songJson(1, preview: null));
      expect(t.hasPreview, isFalse);
      expect(t.year, '2024');
      expect(formatDuration(t.duration), '3:17');
      expect(Track.fromJson(t.toJson()).trackId, 1);
    });

    test('blank previewUrl counts as no preview', () {
      expect(Track.fromJson(songJson(1, preview: '  ')).hasPreview, isFalse);
    });

    test('artwork() asks Apple for a bigger image', () {
      final t = Track.fromJson({
        ...songJson(1),
        'artworkUrl100': 'https://a/100x100bb.jpg',
      });
      expect(t.artwork(600), 'https://a/600x600bb.jpg');
    });
  });

  group('MusicApiService', () {
    test('keeps only songs from the response', () async {
      final api = MusicApiService(
        client: MockClient((req) async {
          expect(req.url.queryParameters['term'], 'tulus');
          return http.Response(
            jsonEncode({
              'results': [
                {'wrapperType': 'collection', 'collectionId': 99},
                songJson(1),
                songJson(2),
              ],
            }),
            200,
          );
        }),
      );
      final tracks = await api.search('  tulus ');
      expect(tracks.map((t) => t.trackId), [1, 2]);
    });

    test('server error becomes a readable ApiException', () {
      final api = MusicApiService(
        client: MockClient((_) async => http.Response('', 503)),
      );
      expect(api.search('x'), throwsA(isA<ApiException>()));
    });

    test('rate limit (403) gets its own message', () {
      final api = MusicApiService(
        client: MockClient((_) async => http.Response('', 403)),
      );
      expect(
        api.search('x'),
        throwsA(predicate((e) => '$e'.contains('Too many requests'))),
      );
    });

    test('no connection becomes a readable ApiException', () {
      final api = MusicApiService(
        client: MockClient((_) async => throw http.ClientException('offline')),
      );
      expect(
        api.search('x'),
        throwsA(predicate((e) => '$e'.contains('No internet connection'))),
      );
    });
    test('Home survives one artist failing, errors only if all fail', () async {
      final someFail = MusicApiService(
        client: MockClient((req) async {
          if (req.url.queryParameters['term'] == 'B') {
            return http.Response('', 403);
          }
          return http.Response(
            jsonEncode({
              'results': [songJson(1)],
            }),
            200,
          );
        }),
      );
      final results = await someFail.songsOfArtists(['A', 'B', 'C']);
      expect(results.map((r) => r.length), [1, 0, 1]);

      final allFail = MusicApiService(
        client: MockClient((_) async => http.Response('', 403)),
      );
      expect(
        allFail.songsOfArtists(['A', 'B']),
        throwsA(predicate((e) => '$e'.contains('Too many requests'))),
      );
    });
  });

  group('FavoriteService', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('no duplicate trackId, and data survives an app restart', () async {
      final service = FavoriteService();
      final song = Track.fromJson(songJson(7));
      await service.add(song);
      await service.add(song);
      expect(service.favorites.value.length, 1);

      final reopened = FavoriteService(); // seperti aplikasi dibuka ulang
      await reopened.load();
      expect(reopened.isFavorite(song), isTrue);

      await reopened.toggle(song);
      expect(reopened.favorites.value, isEmpty);
    });

    test('a corrupted item does not wipe the other favorites', () async {
      SharedPreferences.setMockInitialValues({
        'favorites': ['{broken', jsonEncode(songJson(3))],
      });
      final service = FavoriteService();
      await service.load();
      expect(service.favorites.value.single.trackId, 3);
    });
  });

  test('search history is newest-first, deduped, max 10', () async {
    SharedPreferences.setMockInitialValues({});
    final h = HistoryService();
    for (var i = 0; i < 12; i++) {
      await h.addSearch('q$i');
    }
    await h.addSearch('Q5');
    expect(h.searches.value.first, 'Q5');
    expect(h.searches.value.length, 10);
    expect(h.searches.value.where((s) => s.toLowerCase() == 'q5').length, 1);
  });

  testWidgets('Library shows empty state, then a new favorite instantly', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: LibraryScreen()));
    expect(find.text('No favorites yet'), findsOneWidget);

    await favoriteService.add(Track.fromJson(songJson(5)));
    await tester.pump();
    expect(find.text('Song 5'), findsOneWidget);
    expect(find.text('No favorites yet'), findsNothing);
  });

  testWidgets('Search opened from an artist does not crash', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const MaterialApp(home: SearchScreen(initialQuery: 'Tulus')),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Tulus'), findsOneWidget); // terisi di search bar
  });
}
