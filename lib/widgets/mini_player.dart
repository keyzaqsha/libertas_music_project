import 'package:material_ui/material_ui.dart';

import '../screens/now_playing_screen.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import 'artwork.dart';
import 'play_pause_button.dart';

/// Pemutar kecil di atas bottom navigation. Tap untuk membuka Now Playing.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: audioService.current,
      builder: (context, track, _) {
        if (track == null) return const SizedBox.shrink();
        return Material(
          color: AppTheme.surface,
          child: InkWell(
            onTap: () => Navigator.of(context).push(NowPlayingScreen.route()),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder<Duration>(
                  stream: audioService.player.positionStream,
                  builder: (context, snap) {
                    final total =
                        audioService.player.duration?.inMilliseconds ?? 0;
                    final pos = snap.data?.inMilliseconds ?? 0;
                    return LinearProgressIndicator(
                      value: total == 0 ? 0 : (pos / total).clamp(0, 1),
                      minHeight: 2,
                      backgroundColor: AppTheme.surfaceHigh,
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                  child: Row(
                    children: [
                      Artwork(track.artwork(200), size: 44, radius: 8),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.trackName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              track.artistName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PlayPauseButton(size: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
