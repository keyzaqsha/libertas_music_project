import 'package:just_audio/just_audio.dart';
import 'package:material_ui/material_ui.dart';

import '../models/track.dart';
import '../services/audio_service.dart';
import '../services/music_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/artwork.dart';
import '../widgets/favorite_button.dart';
import '../widgets/mini_player.dart';
import '../widgets/play_pause_button.dart';
import '../widgets/track_card.dart';

/// Info lagu + tracklist album asalnya.
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.track});

  final Track track;

  static Route<void> route(Track track) =>
      MaterialPageRoute(builder: (_) => DetailScreen(track: track));

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late final Future<List<Track>>? _album = widget.track.collectionId == null
      ? null
      : musicApi.albumTracks(widget.track.collectionId!);

  @override
  Widget build(BuildContext context) {
    final t = widget.track;
    final text = Theme.of(context).textTheme;
    final info = [
      t.primaryGenreName,
      t.year,
      if (t.trackTimeMillis > 0) formatDuration(t.duration),
    ].where((s) => s.isNotEmpty).join(' · ');

    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: const MiniPlayer(),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Center(
            child: Artwork(
              t.artwork(600),
              size: (MediaQuery.sizeOf(context).width * 0.7).clamp(
                200.0,
                360.0,
              ),
              radius: AppTheme.radiusLg,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.gutter),
            child: Column(
              children: [
                Text(
                  t.trackName,
                  style: text.headlineSmall!.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  t.artistName,
                  style: text.titleMedium!.copyWith(color: AppTheme.accent),
                  textAlign: TextAlign.center,
                ),
                if (t.collectionName.isNotEmpty)
                  Text(
                    t.collectionName,
                    style: const TextStyle(color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 4),
                Text(
                  info,
                  style: text.bodySmall!.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _PlayPreviewButton(track: t)),
                    const SizedBox(width: 12),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceHigh,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: FavoriteButton(t),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_album != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.gutter,
                32,
                AppTheme.gutter,
                8,
              ),
              child: Text('From the Album', style: text.titleLarge),
            ),
            FutureBuilder(
              future: _album,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snap.hasError || snap.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.gutter,
                    ),
                    child: Text(
                      snap.hasError
                          ? '${snap.error}'
                          : 'Tracklist is not available.',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  );
                }
                final tracks = snap.data!;
                return Column(
                  children: [
                    for (final (i, song) in tracks.indexed)
                      TrackCard(
                        track: song,
                        leading: SizedBox(
                          width: 28,
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        trailing: Text(
                          formatDuration(song.duration),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        onTap: () => playTrack(context, song),
                      ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// "Play Preview" untuk lagu lain; berubah jadi play/pause jika lagu ini yang sedang aktif.
class _PlayPreviewButton extends StatelessWidget {
  const _PlayPreviewButton({required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    if (!track.hasPreview) {
      return const FilledButton(
        onPressed: null,
        child: Text('Preview not available'),
      );
    }
    return ValueListenableBuilder(
      valueListenable: audioService.current,
      builder: (context, current, _) => StreamBuilder<PlayerState>(
        stream: audioService.player.playerStateStream,
        builder: (context, snap) {
          final active = current?.trackId == track.trackId;
          final playing = active && snap.hasData && isPlaying(snap.data!);
          return FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
            ),
            onPressed: () => playTrack(context, track),
            icon: Icon(
              playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
            ),
            label: Text(playing ? 'Pause' : 'Play Preview'),
          );
        },
      ),
    );
  }
}
