import 'package:flutter/material.dart';

/// Palet warna CineDex (dark theme dengan satu warna aksen).
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0E0F14);
  static const Color surface = Color(0xFF181A21);
  static const Color surfaceVariant = Color(0xFF242731);
  static const Color divider = Color(0xFF2A2D37);

  /// Satu-satunya warna aksen: tombol, chip aktif, bintang rating, indikator.
  static const Color accent = Color(0xFFFF6B3D);
  static const Color onAccent = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFFF5F6FA);
  static const Color textSecondary = Color(0xFFA3A6B4);
  static const Color textMuted = Color(0xFF6C6F7D);

  static const Color error = Color(0xFFFF5C6C);

  static const Color shimmerBase = Color(0xFF1C1E26);
  static const Color shimmerHighlight = Color(0xFF2C2F3A);

  /// Gradien gelap di atas gambar agar teks tetap terbaca.
  static LinearGradient get imageScrim => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      background.withValues(alpha: 0.0),
      background.withValues(alpha: 0.55),
      background,
    ],
    stops: const [0.35, 0.7, 1.0],
  );
}
