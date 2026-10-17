/// Exception khusus aplikasi. Setiap jenis gangguan dipetakan ke pesan
/// yang ramah agar bisa langsung ditampilkan di layar error.
sealed class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Perangkat tidak terhubung ke internet / host tidak bisa dihubungi.
class NoInternetException extends ApiException {
  const NoInternetException()
    : super('Tidak ada koneksi internet. Periksa jaringanmu lalu coba lagi.');
}

/// Server tidak merespons dalam batas waktu (15 detik).
class RequestTimeoutException extends ApiException {
  const RequestTimeoutException()
    : super('Server terlalu lama merespons. Silakan coba lagi.');
}

/// Server merespons dengan status selain 200.
class ServerException extends ApiException {
  const ServerException(this.statusCode, String message) : super(message);

  final int statusCode;

  factory ServerException.fromStatus(int statusCode) {
    return switch (statusCode) {
      401 => ServerException(
        statusCode,
        'Token TMDB tidak valid. Periksa isi file .env.',
      ),
      404 => ServerException(statusCode, 'Data film tidak ditemukan.'),
      429 => ServerException(
        statusCode,
        'Terlalu banyak permintaan. Tunggu sebentar lalu coba lagi.',
      ),
      >= 500 => ServerException(
        statusCode,
        'Server TMDB sedang bermasalah. Coba beberapa saat lagi.',
      ),
      _ => ServerException(
        statusCode,
        'Terjadi kesalahan (kode $statusCode). Silakan coba lagi.',
      ),
    };
  }
}

/// Response tidak sesuai format JSON yang diharapkan.
class ParsingException extends ApiException {
  const ParsingException() : super('Data dari server tidak dapat dibaca.');
}

/// Token belum diisi di file `.env`.
class MissingTokenException extends ApiException {
  const MissingTokenException()
    : super(
        'Token TMDB belum diatur. Salin .env.example menjadi .env lalu isi '
        'TMDB_READ_TOKEN.',
      );
}
