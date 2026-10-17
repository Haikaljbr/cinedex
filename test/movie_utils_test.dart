import 'package:cinedex/core/utils/movie_utils.dart';
import 'package:cinedex/data/models/cast_member.dart';
import 'package:cinedex/data/models/movie.dart';
import 'package:cinedex/data/models/video.dart';
import 'package:flutter_test/flutter_test.dart';

Movie _movie(int id, {String? poster}) => Movie(
  id: id,
  title: 'Film $id',
  overview: '',
  voteAverage: 0,
  voteCount: 0,
  genreIds: const [],
  posterPath: poster,
);

Video _video(
  String key,
  String type, {
  bool official = false,
  String site = 'YouTube',
}) => Video(key: key, name: key, site: site, type: type, official: official);

void main() {
  group('MovieUtils', () {
    test('genre_ids dipetakan ke nama genre', () {
      final names = MovieUtils.mapGenreNames(
        [28, 12, 999],
        {28: 'Aksi', 12: 'Petualangan'},
      );
      expect(names, ['Aksi', 'Petualangan']);
    });

    test('film tanpa poster dan duplikat disaring', () {
      final result = MovieUtils.filterDisplayable([
        _movie(1, poster: '/a.jpg'),
        _movie(2),
        _movie(1, poster: '/a.jpg'),
        _movie(3, poster: ''),
      ]);
      expect(result.map((m) => m.id), [1]);
    });

    test('trailer resmi YouTube diprioritaskan', () {
      final picked = MovieUtils.pickTrailer([
        _video('teaser', 'Teaser', official: true),
        _video('vimeo', 'Trailer', official: true, site: 'Vimeo'),
        _video('fan', 'Trailer'),
        _video('resmi', 'Trailer', official: true),
      ]);
      expect(picked?.key, 'resmi');
      expect(MovieUtils.pickTrailer([_video('bts', 'Featurette')]), isNull);
    });

    test('cast diurutkan berdasarkan order dan dipotong 10 teratas', () {
      final cast = List.generate(
        15,
        (i) =>
            CastMember(id: i, name: 'Aktor $i', character: '', order: 14 - i),
      );
      final top = MovieUtils.topCast(cast);
      expect(top.length, 10);
      expect(top.first.order, 0);
      expect(top.last.order, 9);
    });
  });
}
