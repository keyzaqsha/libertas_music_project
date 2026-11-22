import 'package:material_ui/material_ui.dart';

import '../models/track.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import 'artwork.dart';

/// Baris lagu: artwork kecil, judul, artis. Lagu yang sedang aktif ditandai warna aksen.
class TrackCard extends StatelessWidget {
  const TrackCard({
    super.key,
    required this.track,
    required this.onTap,
    this.trailing,
    this.leading,
  });

  final Track track;
  final VoidCallback onTap;
  final Widget? trailing;

  /// Pengganti artwork, mis. nomor urut di tracklist album.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall!
        .copyWith(color: AppTheme.textSecondary);
    return ValueListenableBuilder(
      valueListenable: audioService.current,
      builder: (context, current, _) {
        final active = current?.trackId == track.trackId;
        return InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.gutter,
              vertical: 8,
            ),
            child: Row(
              children: [
                leading ?? Artwork(track.artwork(200), size: 52),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.trackName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: active ? AppTheme.accent : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        track.hasPreview
                            ? track.artistName
                            : '${track.artistName} · No preview',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: muted,
                      ),
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        );
      },
    );
  }
}
