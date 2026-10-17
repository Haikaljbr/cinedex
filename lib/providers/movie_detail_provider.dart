import 'package:flutter/foundation.dart';

import '../data/models/cast_member.dart';
import '../data/models/movie_detail.dart';
import '../data/models/video.dart';
import '../data/repositories/movie_repository.dart';
import 'view_state.dart';

/// State halaman Detail untuk satu film. Dibuat baru setiap kali
/// halaman Detail dibuka.
class MovieDetailProvider extends ChangeNotifier {
  MovieDetailProvider(this._repository, this.movieId);

  final MovieRepository _repository;
  final int movieId;

  LoadStatus status = LoadStatus.initial;
  UiError? error;
  MovieDetail? detail;
  List<CastMember> cast = const [];
  Video? trailer;

  /// Detail, cast, dan trailer diambil paralel. Cast dan trailer bersifat
  /// pelengkap: jika gagal, halaman tetap tampil tanpa bagian tersebut.
  Future<void> load() async {
    status = LoadStatus.loading;
    error = null;
    notifyListeners();

    final castFuture = _repository
        .getTopCast(movieId)
        .catchError((Object _) => const <CastMember>[]);
    final trailerFuture = _repository
        .getTrailer(movieId)
        .catchError((Object _) => null);

    try {
      detail = await _repository.getMovieDetail(movieId);
      cast = await castFuture;
      trailer = await trailerFuture;
      status = LoadStatus.success;
    } catch (e) {
      error = UiError.from(e);
      status = LoadStatus.error;
    }
    notifyListeners();
  }
}
