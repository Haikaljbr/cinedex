import 'package:intl/intl.dart';

/// Fungsi format tampilan data film. Semua fungsi murni (tanpa efek samping)
/// sehingga mudah diuji di `test/formatters_test.dart`.
class Formatters {
  Formatters._();

  /// `vote_average` TMDB berskala 0-10, dikonversi ke skala bintang 0-5.
  static double toStarScale(double voteAverage) {
    return (voteAverage / 2).clamp(0, 5).toDouble();
  }

  /// Rating bintang dengan 1 angka desimal, contoh 8.46 -> "4.2".
  static String formatStarRating(double voteAverage) {
    return toStarScale(voteAverage).toStringAsFixed(1);
  }

  /// Durasi menit ke format singkat, contoh 135 -> "2j 15m".
  static String formatRuntime(int? minutes) {
    if (minutes == null || minutes <= 0) return '-';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) return '${mins}m';
    if (mins == 0) return '${hours}j';
    return '${hours}j ${mins}m';
  }

  /// Tanggal "2026-10-17" ke format Indonesia "17 Oktober 2026".
  /// Memerlukan `initializeDateFormatting('id_ID')` di `main()`.
  static String formatReleaseDate(String? rawDate) {
    final date = DateTime.tryParse(rawDate ?? '');
    if (date == null) return 'Belum diketahui';
    return DateFormat('d MMMM y', 'id_ID').format(date);
  }

  /// Tahun rilis saja, contoh "2026-10-17" -> "2026".
  static String releaseYear(String? rawDate) {
    final date = DateTime.tryParse(rawDate ?? '');
    return date == null ? '-' : '${date.year}';
  }

  /// Jumlah vote ringkas, contoh 12345 -> "12,3 rb".
  static String formatVoteCount(int count) {
    if (count < 1000) return '$count';
    final thousands = (count / 1000).toStringAsFixed(1).replaceAll('.', ',');
    return '${thousands.replaceAll(RegExp(r',0$'), '')} rb';
  }
}
