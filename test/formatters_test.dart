import 'package:cinedex/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  group('Formatters', () {
    test('rating 0-10 dikonversi ke bintang 0-5 dengan 1 desimal', () {
      expect(Formatters.toStarScale(8.46), closeTo(4.23, 0.001));
      expect(Formatters.formatStarRating(8.46), '4.2');
      expect(Formatters.formatStarRating(10), '5.0');
      expect(Formatters.formatStarRating(0), '0.0');
    });

    test('durasi menit diformat menjadi jam dan menit', () {
      expect(Formatters.formatRuntime(135), '2j 15m');
      expect(Formatters.formatRuntime(120), '2j');
      expect(Formatters.formatRuntime(45), '45m');
      expect(Formatters.formatRuntime(null), '-');
      expect(Formatters.formatRuntime(0), '-');
    });

    test('tanggal rilis diformat ke bahasa Indonesia', () {
      expect(Formatters.formatReleaseDate('2026-10-17'), '17 Oktober 2026');
      expect(Formatters.formatReleaseDate('2024-03-01'), '1 Maret 2024');
      expect(Formatters.formatReleaseDate(''), 'Belum diketahui');
      expect(Formatters.formatReleaseDate(null), 'Belum diketahui');
    });

    test('jumlah vote diringkas', () {
      expect(Formatters.formatVoteCount(950), '950');
      expect(Formatters.formatVoteCount(12345), '12,3 rb');
      expect(Formatters.formatVoteCount(2000), '2 rb');
    });
  });
}
