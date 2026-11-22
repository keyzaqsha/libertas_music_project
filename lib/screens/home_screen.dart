import 'package:material_ui/material_ui.dart';

import '../models/track.dart';
import '../services/history_service.dart';
import '../services/music_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/album_card.dart';
import '../widgets/artwork.dart';
import '../widgets/message_state.dart';
import '../widgets/track_card.dart';
import 'detail_screen.dart';
import 'search_screen.dart';

/// Artis pilihan untuk Home. iTunes tidak punya endpoint "rekomendasi",
/// dan kata kunci umum seperti "top hits" justru menghasilkan lagu karaoke.
const _featuredArtists = [
  'Taylor Swift',
  'The Weeknd',
  'Tulus',
  'Billie Eilish',
  'NIKI',
  'Bruno Mars',
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<List<Track>>> _data = _load();

  Future<List<List<Track>>> _load() =>
      musicApi.songsOfArtists(_featuredArtists);

  Future<void> _refresh() async {
    final next = _load();
    setState(() => _data = next);
    await next.catchError((_) => <List<Track>>[]);
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 11) return 'Good morning';
    if (h < 15) return 'Good afternoon';
    if (h < 19) return 'Good evening';
    return 'Good night';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder(
            future: _data,
            builder: (context, snap) {
              return ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.gutter,
                      16,
                      AppTheme.gutter,
                      20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipOval(
                              child: Image.asset(
                                'assets/logo.png',
                                width: 28,
                                height: 28,
                                semanticLabel: 'Libertas logo',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'LIBERTAS',
                              style: text.labelLarge!.copyWith(
                                color: AppTheme.accent,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 4,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(_greeting, style: text.headlineLarge),
                        Text(
                          'Your Music. Your Mood. Your World.',
                          style: text.bodyMedium!.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (snap.connectionState != ConnectionState.done)
                    const Padding(
                      padding: EdgeInsets.all(48),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (snap.hasError)
                    MessageState(
                      icon: Icons.wifi_off_rounded,
                      title: 'Couldn\'t load music',
                      message: '${snap.error}',
                      action: FilledButton(
                        onPressed: _refresh,
                        child: const Text('Try again'),
                      ),
                    )
                  else
                    ..._content(context, snap.data!),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, List<List<Track>> perArtist) {
    final withSongs = perArtist.where((songs) => songs.isNotEmpty).toList();
    final featured = withSongs.map((songs) => songs.first).toList();
    final recommended = [
      for (final songs in withSongs) ...songs.skip(1).take(2),
    ];

    return [
      _FeaturedCarousel(tracks: featured),
      const _SectionTitle('Popular Artists'),
      SizedBox(
        height: 120,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.gutter),
          itemCount: featured.length,
          separatorBuilder: (_, _) => const SizedBox(width: 16),
          itemBuilder: (context, i) {
            final t = featured[i];
            return GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SearchScreen(initialQuery: t.artistName),
                ),
              ),
              child: SizedBox(
                width: 84,
                child: Column(
                  children: [
                    Artwork(t.artwork(300), size: 84, circle: true),
                    const SizedBox(height: 8),
                    Text(
                      t.artistName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      ValueListenableBuilder(
        valueListenable: historyService.played,
        builder: (context, played, _) {
          if (played.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle('Recently Played'),
              SizedBox(
                height: 196,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.gutter,
                  ),
                  itemCount: played.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, i) => AlbumCard(
                    track: played[i],
                    onTap: () =>
                        Navigator.of(context)
                            .push(DetailScreen.route(played[i])),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      const _SectionTitle('Recommended Songs'),
      for (final t in recommended)
        TrackCard(
          track: t,
          onTap: () => Navigator.of(context).push(DetailScreen.route(t)),
        ),
    ];
  }
}

class _FeaturedCarousel extends StatelessWidget {
  const _FeaturedCarousel({required this.tracks});

  final List<Track> tracks;

  @override
  Widget build(BuildContext context) {
    // Tinggi mengikuti lebar layar supaya proporsional di HP kecil maupun besar.
    final height = (MediaQuery.sizeOf(context).width * 0.8).clamp(240.0, 420.0);
    return SizedBox(
      height: height,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.88),
        itemCount: tracks.length,
        itemBuilder: (context, i) {
          final t = tracks[i];
          return GestureDetector(
            onTap: () => Navigator.of(context).push(DetailScreen.route(t)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Artwork(t.artwork(600), radius: 0),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xE6000000)],
                          stops: [0.45, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'FEATURED',
                            style: TextStyle(
                              color: AppTheme.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t.trackName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            t.artistName,
                            style: const TextStyle(color: Color(0xCCFFFFFF)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppTheme.gutter,
      28,
      AppTheme.gutter,
      12,
    ),
    child: Text(title, style: Theme.of(context).textTheme.titleLarge),
  );
}
