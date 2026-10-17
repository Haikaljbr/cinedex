import '../../core/constants/api_constants.dart';
import '../../core/utils/movie_utils.dart';
import '../models/cast_member.dart';
import '../models/genre.dart';
import '../models/movie.dart';
import '../models/movie_detail.dart';
import '../models/video.dart';
import '../services/tmdb_service.dart';

/// Penghubung antara provider (state UI) dan [TmdbService].
/// Di sini data mentah diolah: disaring, dilengkapi fallback, dan dipotong
/// sesuai kebutuhan tampilan.
class MovieRepository {
  MovieRepository(this._service);

  final TmdbService _service;

  List<Genre> _genres = const [];
  Map<int, String> _genreMap = const {};

  /// Peta id genre -> nama genre (sudah di-cache setelah [getGenres]).
  Map<int, String> get genreMap => _genreMap;

  /// Daftar genre hanya diambil sekali lalu disimpan di memori.
  Future<List<Genre>> getGenres({bool forceRefresh = false}) async {
    if (_genres.isNotEmpty && !forceRefresh) return _genres;
    _genres = await _service.fetchGenres();
    _genreMap = {for (final g in _genres) g.id: g.name};
    return _genres;
  }

  List<String> genreNamesOf(Movie movie) =>
      MovieUtils.mapGenreNames(movie.genreIds, _genreMap);

  Future<List<Movie>> getNowPlaying() async =>
      MovieUtils.filterDisplayable(await _service.fetchNowPlaying());

  Future<List<Movie>> getPopular() async =>
      MovieUtils.filterDisplayable(await _service.fetchPopular());

  Future<List<Movie>> getTopRated() async =>
      MovieUtils.filterDisplayable(await _service.fetchTopRated());

  Future<List<Movie>> getUpcoming() async =>
      MovieUtils.filterDisplayable(await _service.fetchUpcoming());

  Future<List<Movie>> getMoviesByGenre(int genreId) async =>
      MovieUtils.filterDisplayable(await _service.discoverByGenre(genreId));

  /// Hasil pencarian tidak disaring berdasarkan poster (film tanpa poster
  /// tetap tampil dengan gambar cadangan), hanya duplikat yang dibuang.
  Future<List<Movie>> searchMovies(String query) async {
    final results = await _service.searchMovies(query);
    final seen = <int>{};
    return results.where((m) => seen.add(m.id)).toList();
  }

  /// Detail film. Jika sinopsis/tagline bahasa Indonesia kosong,
  /// ambil ulang dalam bahasa Inggris (en-US) sebagai cadangan.
  Future<MovieDetail> getMovieDetail(int id) async {
    final detail = await _service.fetchMovieDetail(id);
    if (detail.overview.isNotEmpty && detail.tagline.isNotEmpty) return detail;

    try {
      final english = await _service.fetchMovieDetail(
        id,
        language: ApiConstants.fallbackLanguage,
      );
      return detail.copyWith(
        overview: detail.overview.isEmpty ? english.overview : null,
        tagline: detail.tagline.isEmpty ? english.tagline : null,
      );
    } catch (_) {
      // Fallback bersifat opsional: kalau gagal, tetap pakai data id-ID.
      return detail;
    }
  }

  /// 10 pemeran teratas, diurutkan berdasarkan `order`.
  Future<List<CastMember>> getTopCast(int id) async =>
      MovieUtils.topCast(await _service.fetchCredits(id));

  /// Trailer YouTube. Video berbahasa Indonesia sering tidak ada,
  /// jadi bila kosong dicari ulang di daftar video en-US.
  Future<Video?> getTrailer(int id) async {
    final localized = MovieUtils.pickTrailer(await _service.fetchVideos(id));
    if (localized != null) return localized;
    try {
      return MovieUtils.pickTrailer(
        await _service.fetchVideos(id, language: ApiConstants.fallbackLanguage),
      );
    } catch (_) {
      return null;
    }
  }
}
