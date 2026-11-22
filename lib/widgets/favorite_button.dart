import 'package:material_ui/material_ui.dart';

import '../models/track.dart';
import '../services/favorite_service.dart';
import '../theme/app_theme.dart';

/// Tombol hati yang langsung berubah saat favorit ditambah/dihapus dari halaman mana pun.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton(this.track, {super.key, this.size = 24});

  final Track track;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: favoriteService.favorites,
      builder: (context, _, _) {
        final fav = favoriteService.isFavorite(track);
        return IconButton(
          tooltip: fav ? 'Remove from Library' : 'Add to Library',
          iconSize: size,
          onPressed: () => favoriteService.toggle(track),
          icon: Icon(
            fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: fav ? AppTheme.accent : AppTheme.textSecondary,
          ),
        );
      },
    );
  }
}
