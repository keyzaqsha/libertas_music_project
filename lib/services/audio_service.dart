import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/track.dart';
import 'history_service.dart';

/// Satu pemutar audio untuk seluruh aplikasi, jadi hanya satu preview yang berbunyi.
class AudioService {
  final player = AudioPlayer();

  /// Lagu yang sedang dimuat/diputar; null = mini player disembunyikan.
  final current = ValueNotifier<Track?>(null);

  /// Memutar preview 30 detik dari iTunes. Mengembalikan pesan error, atau null jika berhasil.
  Future<String?> play(Track track) async {
    if (!track.hasPreview) return 'Preview is not available for this song.';
    if (current.value?.trackId == track.trackId) {
      await togglePlay();
      return null;
    }

    current.value = track;
    historyService.addPlayed(track);
    try {
      await player.stop(); // hentikan lagu sebelumnya
      await player.setUrl(track.previewUrl!);
      player.play(); // tidak di-await: Future-nya baru selesai saat lagu habis
      return null;
    } on PlayerInterruptedException {
      return null; // pengguna sudah memilih lagu lain sebelum yang ini selesai dimuat
    } catch (_) {
      if (current.value?.trackId == track.trackId) current.value = null;
      return 'Could not play this preview. Check your connection and try again.';
    }
  }

  Future<void> togglePlay() async {
    if (isPlaying(player.playerState)) {
      await player.pause();
      return;
    }
    if (player.processingState == ProcessingState.completed) {
      await player.seek(Duration.zero);
    }
    player.play();
  }
}

/// just_audio tetap melaporkan playing=true setelah lagu selesai, jadi status completed dicek juga.
bool isPlaying(PlayerState s) =>
    s.playing && s.processingState != ProcessingState.completed;

final audioService = AudioService();
