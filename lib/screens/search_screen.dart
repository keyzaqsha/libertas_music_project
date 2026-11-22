import 'package:material_ui/material_ui.dart';

import '../models/track.dart';
import '../services/history_service.dart';
import '../services/music_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/message_state.dart';
import '../widgets/track_card.dart';
import 'detail_screen.dart';

/// Tab Search. Juga dibuka dari Home (tap artis) dengan [initialQuery].
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Future<List<Track>>? _results; // null = belum mencari, tampilkan riwayat
  String _term = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) _search(widget.initialQuery!);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String term) {
    term = term.trim();
    if (term.isEmpty) return;
    _controller.text = term;
    // Tanpa context, jadi aman dipanggil dari initState (tap artis di Home).
    FocusManager.instance.primaryFocus?.unfocus();
    historyService.addSearch(term);
    setState(() {
      _term = term;
      _results = musicApi.search(term);
    });
  }

  void _clear() {
    _controller.clear();
    setState(() => _results = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search', style: Theme.of(context).textTheme.headlineLarge),
        toolbarHeight: 72,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.gutter,
              0,
              AppTheme.gutter,
              8,
            ),
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) => TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onSubmitted: _search,
                decoration: InputDecoration(
                  hintText: 'Songs or artists',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear',
                          icon: const Icon(Icons.close_rounded),
                          onPressed: _clear,
                        ),
                ),
              ),
            ),
          ),
          Expanded(child: _results == null ? _history() : _resultList()),
        ],
      ),
    );
  }

  Widget _resultList() {
    return FutureBuilder(
      future: _results,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return MessageState(
            icon: Icons.wifi_off_rounded,
            title: 'Something went wrong',
            message: '${snap.error}',
            action: FilledButton(
              onPressed: () => _search(_term),
              child: const Text('Try again'),
            ),
          );
        }
        final tracks = snap.data!;
        if (tracks.isEmpty) {
          return MessageState(
            icon: Icons.search_off_rounded,
            title: 'No results',
            message: 'Nothing found for "$_term". Try another title or artist.',
          );
        }
        return ListView.builder(
          itemCount: tracks.length,
          itemBuilder: (context, i) => TrackCard(
            track: tracks[i],
            onTap: () =>
                Navigator.of(context).push(DetailScreen.route(tracks[i])),
          ),
        );
      },
    );
  }

  Widget _history() {
    return ValueListenableBuilder(
      valueListenable: historyService.searches,
      builder: (context, searches, _) {
        if (searches.isEmpty) {
          return const MessageState(
            icon: Icons.graphic_eq_rounded,
            title: 'Find your sound',
            message: 'Search millions of songs by title or artist.',
          );
        }
        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppTheme.gutter, 8, 8, 0),
              child: Row(
                children: [
                  Text(
                    'Recent Searches',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: historyService.clearSearches,
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
            for (final s in searches)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.gutter,
                ),
                leading: const Icon(
                  Icons.history_rounded,
                  color: AppTheme.textSecondary,
                ),
                title: Text(s),
                onTap: () => _search(s),
              ),
          ],
        );
      },
    );
  }
}
