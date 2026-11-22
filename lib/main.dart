import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
import 'screens/search_screen.dart';
import 'services/favorite_service.dart';
import 'services/history_service.dart';
import 'theme/app_theme.dart';
import 'widgets/mini_player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Seperti Apple Music di HP: layout pemutar dirancang untuk portrait.
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Muat data lokal sebelum UI tampil, supaya favorit langsung terlihat.
  await Future.wait([favoriteService.load(), historyService.load()]);
  runApp(const LibertasApp());
}

class LibertasApp extends StatelessWidget {
  const LibertasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Libertas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const RootShell(),
    );
  }
}

/// Kerangka utama: 3 tab + mini player + bottom navigation.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack menjaga posisi scroll & hasil pencarian saat pindah tab.
      body: IndexedStack(
        index: _tab,
        children: const [HomeScreen(), SearchScreen(), LibraryScreen()],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_rounded),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(Icons.library_music_outlined),
                selectedIcon: Icon(Icons.library_music_rounded),
                label: 'Library',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
