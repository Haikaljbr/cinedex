/// Konstanta TMDB API v3.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/';

  static const String language = 'id-ID';
  static const String fallbackLanguage = 'en-US';
  static const Duration timeout = Duration(seconds: 15);

  // Endpoint
  static const String nowPlaying = '/movie/now_playing';
  static const String popular = '/movie/popular';
  static const String topRated = '/movie/top_rated';
  static const String upcoming = '/movie/upcoming';
  static const String genreList = '/genre/movie/list';
  static const String discover = '/discover/movie';
  static const String search = '/search/movie';
  static String movieDetail(int id) => '/movie/$id';
  static String movieCredits(int id) => '/movie/$id/credits';
  static String movieVideos(int id) => '/movie/$id/videos';

  // Ukuran gambar
  static const String posterSize = 'w342';
  static const String posterLargeSize = 'w500';
  static const String backdropSize = 'w780';
  static const String profileSize = 'w185';

  /// Menyusun URL gambar lengkap, atau null jika path kosong.
  static String? imageUrl(String? path, String size) {
    if (path == null || path.isEmpty) return null;
    return '$imageBaseUrl$size$path';
  }

  static String youtubeUrl(String key) =>
      'https://www.youtube.com/watch?v=$key';
}
