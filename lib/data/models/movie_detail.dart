import '../../core/constants/api_constants.dart';
import 'genre.dart';

/// Detail lengkap film dari endpoint `/movie/{id}`.
class MovieDetail {
  const MovieDetail({
    required this.id,
    required this.title,
    required this.tagline,
    required this.overview,
    required this.voteAverage,
    required this.voteCount,
    required this.genres,
    this.runtime,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
  });

  final int id;
  final String title;
  final String tagline;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final int? runtime;
  final String? releaseDate;
  final List<Genre> genres;

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    return MovieDetail(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title:
          (json['title'] as String?) ??
          (json['original_title'] as String?) ??
          'Tanpa Judul',
      tagline: (json['tagline'] as String?)?.trim() ?? '',
      overview: (json['overview'] as String?)?.trim() ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
      runtime: (json['runtime'] as num?)?.toInt(),
      releaseDate: json['release_date'] as String?,
      genres: (json['genres'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(Genre.fromJson)
          .toList(),
    );
  }

  /// Dipakai saat sinopsis/tagline id-ID kosong dan diganti versi en-US.
  MovieDetail copyWith({String? overview, String? tagline}) {
    return MovieDetail(
      id: id,
      title: title,
      tagline: tagline ?? this.tagline,
      overview: overview ?? this.overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      voteAverage: voteAverage,
      voteCount: voteCount,
      runtime: runtime,
      releaseDate: releaseDate,
      genres: genres,
    );
  }

  String? get posterUrl =>
      ApiConstants.imageUrl(posterPath, ApiConstants.posterLargeSize);

  String? get backdropUrl =>
      ApiConstants.imageUrl(backdropPath, ApiConstants.backdropSize);
}
