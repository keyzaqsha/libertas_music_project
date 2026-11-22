import 'package:just_audio/just_audio.dart';
import 'package:material_ui/material_ui.dart';

import '../models/track.dart';
import '../services/audio_service.dart';

/// Putar [track] dan tampilkan pesan jika gagal (tidak ada preview / error jaringan).
Future<void> playTrack(BuildContext context, Track track) async {
  final messenger = ScaffoldMessenger.of(context);
  final error = await audioService.play(track);
  if (error != null) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(error)));
  }
}

/// Tombol play/pause untuk lagu yang sedang aktif; menampilkan spinner saat audio dimuat.
class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({super.key, this.size = 32, this.color = Colors.white});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: audioService.player.playerStateStream,
      builder: (context, snap) {
        final state = snap.data ?? audioService.player.playerState;
        final loading =
            state.processingState == ProcessingState.loading ||
            state.processingState == ProcessingState.buffering;
        if (loading) {
          return SizedBox.square(
            dimension: size + 16,
            child: Padding(
              padding: EdgeInsets.all(size / 3),
              child: CircularProgressIndicator(strokeWidth: 2.5, color: color),
            ),
          );
        }
        final playing = isPlaying(state);
        return IconButton(
          tooltip: playing ? 'Pause' : 'Play',
          iconSize: size,
          color: color,
          onPressed: audioService.togglePlay,
          icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
        );
      },
    );
  }
}
