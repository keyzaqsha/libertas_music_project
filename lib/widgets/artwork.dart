import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Gambar album dengan cache, placeholder saat memuat, dan ikon jika gagal.
class Artwork extends StatelessWidget {
  const Artwork(
    this.url, {
    super.key,
    this.size,
    this.radius = AppTheme.radiusSm,
    this.circle = false,
  });

  final String url;
  final double? size; // null = isi ruang yang tersedia
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: AppTheme.surfaceHigh,
      alignment: Alignment.center,
      child: const Icon(
        Icons.music_note_rounded,
        color: AppTheme.textSecondary,
      ),
    );
    final image = url.isEmpty
        ? fallback
        : CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(color: AppTheme.surfaceHigh),
            errorWidget: (_, _, _) => fallback,
          );
    return SizedBox(
      width: size,
      height: size,
      child: circle
          ? ClipOval(child: image)
          : ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: image,
            ),
    );
  }
}
