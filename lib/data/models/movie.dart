import '../../core/constants/api_constants.dart';

/// Ringkasan film dari endpoint daftar (popular, search, discover, dll).
class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.voteAverage,
    required this.voteCount,
    required this.genreIds,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
  });

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String? releaseDate;
  final List<int> genreIds;

  /// Parsing JSON TMDB ke objek Dart. Semua field diberi nilai default
  /// agar aman ketika API mengirim null atau field tidak ada.
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title:
          (json['title'] as String?) ??
          (json['original_title'] as String?) ??
          'Tanpa Judul',
      overview: (json['overview'] as String?)?.trim() ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
      releaseDate: json['release_date'] as String?,
      genreIds: (json['genre_ids'] as List<dynamic>? ?? const [])
          .whereType<num>()
          .map((e) => e.toInt())
          .toList(),
    );
  }

  bool get hasPoster => posterPath != null && posterPath!.isNotEmpty;

  String? get posterUrl =>
      ApiConstants.imageUrl(posterPath, ApiConstants.posterSize);

  /// Backdrop untuk carousel; jika kosong pakai poster sebagai cadangan.
  String? get backdropUrl =>
      ApiConstants.imageUrl(backdropPath, ApiConstants.backdropSize) ??
      ApiConstants.imageUrl(posterPath, ApiConstants.posterLargeSize);
}
