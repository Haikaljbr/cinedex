import '../../data/models/cast_member.dart';
import '../../data/models/movie.dart';
import '../../data/models/video.dart';

/// Langkah pengolahan data mentah dari API sebelum ditampilkan.
class MovieUtils {
  MovieUtils._();

  /// Mengubah `genre_ids` (misal [28, 12]) menjadi nama genre
  /// (misal ["Aksi", "Petualangan"]) memakai peta hasil `/genre/movie/list`.
  /// Id yang tidak dikenal dilewati.
  static List<String> mapGenreNames(
    List<int> genreIds,
    Map<int, String> genreMap,
  ) {
    return genreIds.map((id) => genreMap[id]).whereType<String>().toList();
  }

  /// Menyaring film yang tidak punya poster agar daftar tetap rapi.
  /// Film duplikat (id sama) juga dibuang.
  static List<Movie> filterDisplayable(List<Movie> movies) {
    final seen = <int>{};
    return movies.where((m) => m.hasPoster && seen.add(m.id)).toList();
  }

  /// Memilih trailer terbaik dari daftar video:
  /// 1. Hanya video YouTube.
  /// 2. Prioritas `type == "Trailer"` yang resmi, lalu Trailer biasa,
  ///    lalu Teaser resmi, lalu Teaser biasa.
  /// Mengembalikan null bila tidak ada yang cocok.
  static Video? pickTrailer(List<Video> videos) {
    final youtube = videos.where((v) => v.isYouTube).toList();

    Video? firstWhere(bool Function(Video v) test) {
      for (final v in youtube) {
        if (test(v)) return v;
      }
      return null;
    }

    return firstWhere((v) => v.type == 'Trailer' && v.official) ??
        firstWhere((v) => v.type == 'Trailer') ??
        firstWhere((v) => v.type == 'Teaser' && v.official) ??
        firstWhere((v) => v.type == 'Teaser');
  }

  /// Mengurutkan pemeran berdasarkan `order` lalu mengambil [limit] teratas.
  static List<CastMember> topCast(List<CastMember> cast, {int limit = 10}) {
    final sorted = [...cast]..sort((a, b) => a.order.compareTo(b.order));
    return sorted.take(limit).toList();
  }
}
