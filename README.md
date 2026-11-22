# Libertas

**Your Music. Your Mood. Your World.**

Libertas adalah aplikasi *music discovery* Android berbasis Flutter yang terinspirasi dari Apple Music. Pengguna dapat menjelajahi lagu, mencari judul atau artis, melihat informasi album, mendengarkan preview lagu, dan menyimpan lagu favorit.

Proyek Ujian Tengah Praktikum (UTP) Mobile Programming.

| | |
|---|---|
| Nama | Keyza Aqsha Putra Suprianto |
| NPM | 065122102 |
| Kelas | D |
| Program Studi | Ilmu Komputer, Universitas Pakuan |
| Opsi Data | **Opsi 3**: Public REST API + Local Storage |

## Fitur

- **Home**: greeting sesuai waktu, *featured carousel*, popular artists, recently played, dan recommended songs.
- **Search**: pencarian lagu berdasarkan judul atau artis, riwayat pencarian, serta *loading*, *error*, dan *empty state*.
- **Detail**: artwork, artis, album, genre, tahun rilis, durasi, tracklist album, tombol play preview, dan tombol favorit.
- **Now Playing**: artwork besar, *progress bar* yang bisa digeser, durasi, play/pause, dan favorit.
- **Library**: daftar lagu favorit yang tersimpan di perangkat, dengan *swipe to remove* dan *undo*.
- **Mini player**: tampil di atas bottom navigation selama ada lagu yang diputar.

## Library (pubspec.yaml)

| Package | Kegunaan |
|---|---|
| `http` | Mengambil data dari iTunes Search API |
| `shared_preferences` | Menyimpan favorit, riwayat pencarian, dan recently played |
| `just_audio` | Memutar preview audio |
| `google_fonts` | Font Inter |
| `cached_network_image` | Menampilkan dan meng-*cache* artwork album |

## Public API: iTunes Search API

| Kegunaan | Endpoint |
|---|---|
| Pencarian lagu | `GET https://itunes.apple.com/search?term={kata kunci}&entity=song&limit=25` |
| Lagu per artis (Home) | `GET https://itunes.apple.com/search?term={artis}&entity=song&attribute=artistTerm&limit=5` |
| Tracklist album | `GET https://itunes.apple.com/lookup?id={collectionId}&entity=song` |

Field yang dipakai: `trackId`, `trackName`, `artistName`, `collectionName`, `collectionId`, `artworkUrl100`, `previewUrl`, `trackTimeMillis`, `releaseDate`, `primaryGenreName`.

## Skema Local Storage (SharedPreferences)

| Key | Tipe | Isi |
|---|---|---|
| `favorites` | `List<String>` | JSON lagu favorit, unik berdasarkan `trackId` |
| `search_history` | `List<String>` | Maksimal 10 kata kunci terakhir |
| `recently_played` | `List<String>` | JSON maksimal 20 lagu terakhir yang diputar |

## Struktur Project

```
lib/
├── main.dart                   # Entry point, tab Home/Search/Library, mini player
├── models/track.dart           # Model Track + parsing JSON
├── services/
│   ├── music_api_service.dart  # Request ke iTunes API + penanganan error
│   ├── favorite_service.dart   # Favorit (SharedPreferences)
│   ├── history_service.dart    # Riwayat pencarian & recently played
│   └── audio_service.dart      # Pemutar preview (just_audio)
├── screens/                    # home, search, detail, now_playing, library
├── widgets/                    # artwork, track_card, album_card, mini_player,
│                               # play_pause_button, favorite_button, message_state
└── theme/app_theme.dart        # Warna, ukuran, dan tema gelap
test/libertas_test.dart         # Unit & widget test
```

## Menjalankan

```bash
flutter pub get
flutter run
```

Build APK:

```bash
flutter build apk --release
```

Menjalankan test:

```bash
flutter test
```

## Catatan

- Audio yang diputar adalah **preview resmi 30 detik** dari iTunes. Lagu penuh tidak tersedia melalui API publik ini karena dilindungi hak cipta.
- iTunes Search API membatasi sekitar 20 request per menit. Jika batas ini terlampaui, aplikasi menampilkan pesan untuk menunggu sebentar.
- Data lagu dan artwork © Apple. Aplikasi ini dibuat untuk keperluan pembelajaran.
