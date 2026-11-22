import 'package:material_ui/material_ui.dart';

import '../models/track.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/artwork.dart';
import '../widgets/favorite_button.dart';
import '../widgets/play_pause_button.dart';
import 'detail_screen.dart';

/// Pemutar layar penuh, dibuka dari mini player dengan animasi slide dari bawah.
class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  static Route<void> route() => PageRouteBuilder(
    pageBuilder: (_, _, _) => const NowPlayingScreen(),
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (_, animation, _, child) => SlideTransition(
      position: Tween(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation),
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: audioService.current,
      builder: (context, track, _) {
        if (track == null) {
          // Pemutaran gagal saat layar ini terbuka: tutup kembali.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) Navigator.of(context).maybePop();
          });
          return const Scaffold();
        }
        return _NowPlaying(track: track);
      },
    );
  }
}

class _NowPlaying extends StatelessWidget {
  const _NowPlaying({required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final screen = MediaQuery.sizeOf(context);
    // Ikut tinggi layar juga, supaya tetap muat di mode split-screen.
    final artSize = (screen.width - 56)
        .clamp(0.0, screen.height * 0.42)
        .clamp(120.0, 420.0);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.gutter + 8),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Close',
                    iconSize: 32,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Song details',
                    icon: const Icon(Icons.info_outline_rounded),
                    onPressed: () =>
                        Navigator.of(context).push(DetailScreen.route(track)),
                  ),
                ],
              ),
              const Spacer(),
              Artwork(
                track.artwork(600),
                size: artSize,
                radius: AppTheme.radiusLg,
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.trackName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleLarge,
                        ),
                        Text(
                          track.artistName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleMedium!.copyWith(
                            color: AppTheme.accent,
                          ),
                        ),
                        if (track.collectionName.isNotEmpty)
                          Text(
                            track.collectionName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  FavoriteButton(track, size: 28),
                ],
              ),
              const SizedBox(height: 12),
              const _ProgressBar(),
              const PlayPauseButton(size: 64),
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.graphic_eq_rounded,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '30-second preview · provided by iTunes',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Slider posisi + durasi. Bisa digeser untuk pindah posisi.
class _ProgressBar extends StatelessWidget {
  const _ProgressBar();

  @override
  Widget build(BuildContext context) {
    final player = audioService.player;
    return StreamBuilder<Duration?>(
      stream: player.durationStream,
      builder: (context, durSnap) {
        final total = durSnap.data ?? Duration.zero;
        return StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, posSnap) {
            final pos = posSnap.data ?? Duration.zero;
            final max = total.inMilliseconds.toDouble();
            final label = TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            );
            return Column(
              children: [
                Slider(
                  value: pos.inMilliseconds.clamp(0, max).toDouble(),
                  max: max > 0 ? max : 1,
                  onChanged: max > 0
                      ? (v) => player.seek(Duration(milliseconds: v.round()))
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatDuration(pos), style: label),
                      Text('-${formatDuration(total - pos)}', style: label),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
