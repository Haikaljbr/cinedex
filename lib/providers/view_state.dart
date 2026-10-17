import '../data/services/api_exception.dart';

/// Status pemuatan data yang dipakai semua provider.
enum LoadStatus { initial, loading, success, error }

/// Informasi error yang siap ditampilkan di UI.
class UiError {
  const UiError(this.message, {this.isOffline = false});

  final String message;

  /// True bila penyebabnya tidak ada koneksi internet (ikon berbeda di UI).
  final bool isOffline;

  factory UiError.from(Object error) {
    if (error is ApiException) {
      return UiError(error.message, isOffline: error is NoInternetException);
    }
    return const UiError('Terjadi kesalahan tak terduga. Silakan coba lagi.');
  }
}
