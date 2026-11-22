import 'package:material_ui/material_ui.dart';

import '../models/track.dart';
import '../theme/app_theme.dart';
import 'artwork.dart';

/// Kartu persegi untuk deretan horizontal (Recently Played).
class AlbumCard extends StatelessWidget {
  const AlbumCard({
    super.key,
    required this.track,
    required this.onTap,
    this.size = 150,
  });

  final Track track;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Artwork(track.artwork(400), size: size),
            const SizedBox(height: 8),
            Text(
              track.trackName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
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
    );
  }
}
