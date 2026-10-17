import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Membaca konfigurasi rahasia dari file `.env` (tidak ikut di-commit).
class Env {
  Env._();

  static const String _placeholder = 'isi_token_di_sini';

  /// Dipanggil sekali di `main()` sebelum aplikasi berjalan.
  static Future<void> load() => dotenv.load(fileName: '.env', isOptional: true);

  /// Token "API Read Access Token" dari themoviedb.org.
  static String get tmdbReadToken {
    if (!dotenv.isInitialized) return '';
    final token = dotenv.maybeGet('TMDB_READ_TOKEN')?.trim() ?? '';
    return token == _placeholder ? '' : token;
  }
}
