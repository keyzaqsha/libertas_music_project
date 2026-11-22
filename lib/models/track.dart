/// Satu lagu dari iTunes Search API.
class Track {
  final int trackId;
  final String trackName;
  final String artistName;
  final String collectionName;
  final int? collectionId; // dipakai untuk mengambil tracklist album
  final String artworkUrl100;
  final String? previewUrl; // null jika lagu tidak punya preview
  final int trackTimeMillis;
  final String releaseDate;
  final String primaryGenreName;

  const Track({
    required this.trackId,
    required this.trackName,
    required this.artistName,
    required this.collectionName,
    required this.collectionId,
    required this.artworkUrl100,
    required this.previewUrl,
    required this.trackTimeMillis,
    required this.releaseDate,
    required this.primaryGenreName,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    final preview = (json['previewUrl'] as String?)?.trim() ?? '';
    return Track(
      trackId: json['trackId'] as int,
      trackName: json['trackName'] as String? ?? 'Unknown title',
      artistName: json['artistName'] as String? ?? 'Unknown artist',
      collectionName: json['collectionName'] as String? ?? '',
      collectionId: json['collectionId'] as int?,
      artworkUrl100: json['artworkUrl100'] as String? ?? '',
      previewUrl: preview.isEmpty ? null : preview,
      trackTimeMillis: json['trackTimeMillis'] as int? ?? 0,
      releaseDate: json['releaseDate'] as String? ?? '',
      primaryGenreName: json['primaryGenreName'] as String? ?? '',
    );
  }

  /// Kunci JSON sama dengan API, jadi data favorit bisa dibaca ulang lewat [Track.fromJson].
  Map<String, dynamic> toJson() => {
    'trackId': trackId,
    'trackName': trackName,
    'artistName': artistName,
    'collectionName': collectionName,
    'collectionId': collectionId,
    'artworkUrl100': artworkUrl100,
    'previewUrl': previewUrl,
    'trackTimeMillis': trackTimeMillis,
    'releaseDate': releaseDate,
    'primaryGenreName': primaryGenreName,
  };

  bool get hasPreview => previewUrl != null;

  /// API hanya memberi gambar 100x100; server Apple menyediakan ukuran lain lewat URL yang sama.
  String artwork([int size = 600]) =>
      artworkUrl100.replaceFirst('100x100', '${size}x$size');

  String get year => releaseDate.length >= 4 ? releaseDate.substring(0, 4) : '';

  Duration get duration => Duration(milliseconds: trackTimeMillis);
}

/// 197950 ms -> "3:17"
String formatDuration(Duration d) {
  final s = d.inSeconds;
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}
