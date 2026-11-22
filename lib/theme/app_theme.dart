import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

/// Design system Libertas: satu sumber warna, ukuran, dan gaya untuk semua halaman.
class AppTheme {
  // Warna
  static const background = Color(0xFF0B0B0D); // hitam pekat, latar utama
  static const surface = Color(0xFF1C1C1F); // charcoal, kartu & mini player
  static const surfaceHigh = Color(0xFF2A2A2E); // search bar, track slider
  static const accent = Color(
    0xFFFF4D6D,
  ); // coral merah muda, identitas Libertas
  static const textSecondary = Color(0xFF9B9BA1);

  // Ukuran
  static const gutter = 20.0; // padding kiri-kanan halaman
  static const radiusSm = 10.0; // thumbnail & kartu kecil
  static const radiusLg = 20.0; // artwork besar

  static ThemeData get dark {
    final text = GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
        .apply(bodyColor: Colors.white, displayColor: Colors.white);

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accent,
        surface: background,
        surfaceContainerHighest: surfaceHigh,
      ),
      textTheme: text.copyWith(
        // Judul tebal & rapat ala Apple Music.
        headlineLarge: text.headlineLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
        titleLarge: text.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: gutter,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected) ? accent : textSecondary,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: s.contains(WidgetState.selected) ? accent : textSecondary,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceHigh,
        hintStyle: const TextStyle(color: textSecondary),
        prefixIconColor: textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide.none,
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: Colors.white,
        inactiveTrackColor: surfaceHigh,
        thumbColor: Colors.white,
        trackHeight: 4,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: accent),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surfaceHigh,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}
