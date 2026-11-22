import 'package:material_ui/material_ui.dart';

import '../services/favorite_service.dart';
import '../theme/app_theme.dart';
import '../widgets/favorite_button.dart';
import '../widgets/message_state.dart';
import '../widgets/track_card.dart';
import 'detail_screen.dart';

/// Daftar lagu favorit yang tersimpan di HP.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Library',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        toolbarHeight: 72,
      ),
      body: ValueListenableBuilder(
        valueListenable: favoriteService.favorites,
        builder: (context, favorites, _) {
          if (favorites.isEmpty) {
            return const Center(
              child: MessageState(
                icon: Icons.favorite_border_rounded,
                title: 'No favorites yet',
                message: 'Tap the heart on any song to save it here.',
              ),
            );
          }
          return ListView.builder(
            itemCount: favorites.length + 1,
            itemBuilder: (context, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.gutter,
                    0,
                    AppTheme.gutter,
                    8,
                  ),
                  child: Text(
                    '${favorites.length} saved ${favorites.length == 1 ? 'song' : 'songs'} · swipe left to remove',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                );
              }
              final t = favorites[i - 1];
              return Dismissible(
                key: ValueKey(t.trackId),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: AppTheme.accent,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: const Icon(Icons.delete_outline_rounded),
                ),
                onDismissed: (_) {
                  favoriteService.remove(t);
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text('Removed "${t.trackName}"'),
                        action: SnackBarAction(
                          label: 'Undo',
                          textColor: AppTheme.accent,
                          onPressed: () => favoriteService.add(t),
                        ),
                      ),
                    );
                },
                child: TrackCard(
                  track: t,
                  trailing: FavoriteButton(t),
                  onTap: () =>
                      Navigator.of(context).push(DetailScreen.route(t)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
