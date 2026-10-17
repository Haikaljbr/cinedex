import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/config/env.dart';
import '../../core/constants/api_constants.dart';
import '../models/cast_member.dart';
import '../models/genre.dart';
import '../models/movie.dart';
import '../models/movie_detail.dart';
import '../models/video.dart';
import 'api_exception.dart';

/// Satu-satunya kelas yang melakukan panggilan HTTP ke TMDB API.
/// Tugasnya: menyusun request, menangani error jaringan, lalu mengubah
/// JSON menjadi model Dart.
class TmdbService {
  TmdbService({http.Client? client, String? token})
    : _client = client ?? http.Client(),
      _token = token ?? Env.tmdbReadToken;

  final http.Client _client;
  final String _token;

  // ---------------------------------------------------------------------------
  // Endpoint daftar film
  // ---------------------------------------------------------------------------

  Future<List<Movie>> fetchNowPlaying() =>
      _fetchMovies(ApiConstants.nowPlaying);

  Future<List<Movie>> fetchPopular() => _fetchMovies(ApiConstants.popular);

  Future<List<Movie>> fetchTopRated() => _fetchMovies(ApiConstants.topRated);

  Future<List<Movie>> fetchUpcoming() => _fetchMovies(ApiConstants.upcoming);

  /// Filter film berdasarkan genre, diurutkan dari yang paling populer.
  Future<List<Movie>> discoverByGenre(
    int genreId, {
    String sortBy = 'popularity.desc',
  }) {
    return _fetchMovies(
      ApiConstants.discover,
      query: {
        'with_genres': '$genreId',
        'sort_by': sortBy,
        'include_adult': 'false',
      },
    );
  }

  Future<List<Movie>> searchMovies(String query) {
    return _fetchMovies(
      ApiConstants.search,
      query: {'query': query, 'include_adult': 'false'},
    );
  }

  // ---------------------------------------------------------------------------
  // Endpoint genre & detail
  // ---------------------------------------------------------------------------

  Future<List<Genre>> fetchGenres() async {
    final json = await _get(ApiConstants.genreList);
    return _parse(
      () => (json['genres'] as List<dynamic>)
          .map((e) => Genre.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<MovieDetail> fetchMovieDetail(
    int id, {
    String language = ApiConstants.language,
  }) async {
    final json = await _get(ApiConstants.movieDetail(id), language: language);
    return _parse(() => MovieDetail.fromJson(json));
  }

  Future<List<CastMember>> fetchCredits(int id) async {
    final json = await _get(ApiConstants.movieCredits(id));
    return _parse(
      () => (json['cast'] as List<dynamic>? ?? const [])
          .map((e) => CastMember.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<List<Video>> fetchVideos(
    int id, {
    String language = ApiConstants.language,
  }) async {
    final json = await _get(ApiConstants.movieVideos(id), language: language);
    return _parse(
      () => (json['results'] as List<dynamic>? ?? const [])
          .map((e) => Video.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Helper internal
  // ---------------------------------------------------------------------------

  Future<List<Movie>> _fetchMovies(
    String path, {
    Map<String, String> query = const {},
  }) async {
    final json = await _get(path, query: query);
    return _parse(
      () => (json['results'] as List<dynamic>)
          .map((e) => Movie.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Request GET dasar: menambahkan header Bearer token dan `language`,
  /// memberi batas waktu 15 detik, lalu memetakan semua kegagalan
  /// ke [ApiException] agar UI cukup menangani satu jenis error.
  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String> query = const {},
    String language = ApiConstants.language,
  }) async {
    if (_token.isEmpty) throw const MissingTokenException();

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}$path',
    ).replace(queryParameters: {'language': language, ...query});

    final http.Response response;
    try {
      response = await _client
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $_token',
              'Accept': 'application/json',
            },
          )
          .timeout(ApiConstants.timeout);
    } on SocketException {
      throw const NoInternetException();
    } on TimeoutException {
      throw const RequestTimeoutException();
    } on http.ClientException {
      throw const NoInternetException();
    }

    if (response.statusCode != 200) {
      throw ServerException.fromStatus(response.statusCode);
    }

    try {
      // Decode manual sebagai UTF-8 agar karakter non-ASCII tidak rusak.
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return decoded as Map<String, dynamic>;
    } catch (_) {
      throw const ParsingException();
    }
  }

  /// Membungkus proses parsing JSON ke model; kegagalan tipe data
  /// diubah menjadi [ParsingException].
  T _parse<T>(T Function() parser) {
    try {
      return parser();
    } catch (_) {
      throw const ParsingException();
    }
  }
}
