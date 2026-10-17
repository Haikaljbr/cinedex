import 'package:flutter/foundation.dart';

import '../data/models/genre.dart';
import '../data/models/movie.dart';
import '../data/repositories/movie_repository.dart';
import 'view_state.dart';

/// State halaman Beranda: carousel, daftar genre, section film,
/// dan hasil filter genre.
class HomeProvider extends ChangeNotifier {
  HomeProvider(this._repository);

  final MovieRepository _repository;

  static const int carouselCount = 5;

  LoadStatus status = LoadStatus.initial;
  UiError? error;

  List<Movie> nowPlaying = const [];
  List<Movie> popular = const [];
  List<Movie> topRated = const [];
  List<Movie> upcoming = const [];
  List<Genre> genres = const [];

  /// Genre yang dipilih; null berarti chip "Semua".
  Genre? selectedGenre;
  LoadStatus genreStatus = LoadStatus.initial;
  UiError? genreError;
  List<Movie> genreMovies = const [];

  // Penanda request agar hasil discover lama tidak menimpa pilihan terbaru.
  int _genreRequestId = 0;

  List<Movie> get carouselMovies => nowPlaying.take(carouselCount).toList();

  List<String> genreNamesOf(Movie movie) => _repository.genreNamesOf(movie);

  /// Memuat semua data Beranda secara paralel.
  Future<void> loadHome() async {
    status = LoadStatus.loading;
    error = null;
    notifyListeners();

    try {
      await _fetchAll();
      status = LoadStatus.success;
    } catch (e) {
      error = UiError.from(e);
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  /// Pull-to-refresh. Data lama tetap tampil bila refresh gagal;
  /// pesan error dikembalikan untuk ditampilkan sebagai SnackBar.
  Future<String?> refresh() async {
    if (status != LoadStatus.success) {
      await loadHome();
      return null;
    }
    try {
      await _fetchAll(forceRefresh: true);
      if (selectedGenre != null) await _loadGenreMovies(selectedGenre!);
      notifyListeners();
      return null;
    } catch (e) {
      return UiError.from(e).message;
    }
  }

  Future<void> _fetchAll({bool forceRefresh = false}) async {
    final results = await Future.wait([
      _repository.getNowPlaying(),
      _repository.getPopular(),
      _repository.getTopRated(),
      _repository.getUpcoming(),
    ]);
    genres = await _repository.getGenres(forceRefresh: forceRefresh);
    nowPlaying = results[0];
    popular = results[1];
    topRated = results[2];
    upcoming = results[3];
  }

  /// Dipanggil saat chip genre ditekan. `null` = kembali ke tampilan awal.
  Future<void> selectGenre(Genre? genre) async {
    if (genre == selectedGenre) return;
    selectedGenre = genre;
    if (genre == null) {
      _genreRequestId++;
      genreStatus = LoadStatus.initial;
      genreMovies = const [];
      notifyListeners();
      return;
    }
    await _loadGenreMovies(genre);
  }

  Future<void> retryGenre() async {
    final genre = selectedGenre;
    if (genre != null) await _loadGenreMovies(genre);
  }

  Future<void> _loadGenreMovies(Genre genre) async {
    final requestId = ++_genreRequestId;
    genreStatus = LoadStatus.loading;
    genreError = null;
    notifyListeners();

    try {
      final movies = await _repository.getMoviesByGenre(genre.id);
      if (requestId != _genreRequestId) return;
      genreMovies = movies;
      genreStatus = LoadStatus.success;
    } catch (e) {
      if (requestId != _genreRequestId) return;
      genreError = UiError.from(e);
      genreStatus = LoadStatus.error;
    }
    notifyListeners();
  }
}
