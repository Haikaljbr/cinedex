import 'package:flutter/widgets.dart';

/// Jarak (padding/margin) standar.
class AppSpacing {
  AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Radius sudut komponen.
class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 14;
  static const double lg = 20;
  static const double pill = 100;

  static BorderRadius get card => BorderRadius.circular(md);
  static BorderRadius get large => BorderRadius.circular(lg);
  static BorderRadius get rounded => BorderRadius.circular(pill);
}

/// Ukuran tetap komponen (poster, carousel, avatar).
class AppSizes {
  AppSizes._();

  // Poster mengikuti rasio TMDB 2:3.
  static const double posterWidth = 128;
  static const double posterHeight = 192;
  static const double posterAspectRatio = 2 / 3;

  static const double carouselHeight = 220;
  static const double carouselViewport = 0.86;

  static const double backdropHeight = 300;
  static const double detailPosterWidth = 112;
  static const double detailPosterHeight = 168;

  static const double castAvatar = 72;
  static const double genreChipHeight = 38;
  static const double iconSm = 16;
  static const double iconMd = 22;
  static const double iconLg = 64;
}
