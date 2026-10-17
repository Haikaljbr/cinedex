import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/movie.dart';
import '../data/repositories/movie_repository.dart';
import 'view_state.dart';

/// State halaman Pencarian dengan debounce 500 ms.
class SearchProvider extends ChangeNotifier {
  SearchProvider(this._repository);

  final MovieRepository _repository;

  static const Duration debounceDuration = Duration(milliseconds: 500);

  LoadStatus status = LoadStatus.initial;
  UiError? error;
  List<Movie> results = const [];
  String _query = '';
  Timer? _debounce;

  // Penanda request: hasil dari kata kunci lama diabaikan.
  int _requestId = 0;

  String get query => _query;

  /// Pencarian berhasil tetapi tidak ada film yang cocok.
  bool get isEmptyResult => status == LoadStatus.success && results.isEmpty;

  /// Dipanggil setiap kali teks berubah. Request baru dikirim hanya jika
  /// pengguna berhenti mengetik selama 500 ms, sehingga API tidak dipanggil
  /// untuk setiap huruf.
  void onQueryChanged(String value) {
    final trimmed = value.trim();
    _debounce?.cancel();
    if (trimmed == _query && status != LoadStatus.error) return;
    _query = trimmed;

    if (trimmed.isEmpty) {
      _requestId++;
      status = LoadStatus.initial;
      results = const [];
      error = null;
      notifyListeners();
      return;
    }

    _debounce = Timer(debounceDuration, () => _search(trimmed));
  }

  Future<void> retry() => _search(_query);

  Future<void> _search(String query) async {
    final requestId = ++_requestId;
    status = LoadStatus.loading;
    error = null;
    notifyListeners();

    try {
      final movies = await _repository.searchMovies(query);
      if (requestId != _requestId) return;
      results = movies;
      status = LoadStatus.success;
    } catch (e) {
      if (requestId != _requestId) return;
      error = UiError.from(e);
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
