import 'package:cinedex/data/models/cast_member.dart';
import 'package:cinedex/data/models/movie.dart';
import 'package:cinedex/data/models/movie_detail.dart';
import 'package:cinedex/data/models/video.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Parsing model', () {
    test('Movie.fromJson membaca field TMDB dan membangun URL poster', () {
      final movie = Movie.fromJson({
        'id': 550,
        'title': 'Fight Club',
        'overview': ' Sinopsis ',
        'poster_path': '/abc.jpg',
        'backdrop_path': null,
        'vote_average': 8.4,
        'vote_count': 30000,
        'release_date': '1999-10-15',
        'genre_ids': [18, 53],
      });

      expect(movie.id, 550);
      expect(movie.title, 'Fight Club');
      expect(movie.overview, 'Sinopsis');
      expect(movie.genreIds, [18, 53]);
      expect(movie.hasPoster, isTrue);
      expect(movie.posterUrl, 'https://image.tmdb.org/t/p/w342/abc.jpg');
      // Backdrop kosong -> poster ukuran besar sebagai cadangan.
      expect(movie.backdropUrl, 'https://image.tmdb.org/t/p/w500/abc.jpg');
    });

    test('Movie.fromJson aman terhadap field null atau hilang', () {
      final movie = Movie.fromJson({'id': 1});

      expect(movie.title, 'Tanpa Judul');
      expect(movie.overview, '');
      expect(movie.voteAverage, 0);
      expect(movie.genreIds, isEmpty);
      expect(movie.hasPoster, isFalse);
      expect(movie.posterUrl, isNull);
    });

    test('MovieDetail.fromJson membaca runtime dan daftar genre', () {
      final detail = MovieDetail.fromJson({
        'id': 550,
        'title': 'Fight Club',
        'tagline': 'Mischief. Mayhem. Soap.',
        'overview': '',
        'runtime': 139,
        'genres': [
          {'id': 18, 'name': 'Drama'},
        ],
      });

      expect(detail.runtime, 139);
      expect(detail.genres.single.name, 'Drama');
      expect(detail.copyWith(overview: 'Baru').overview, 'Baru');
    });

    test('CastMember dan Video diparsing dengan nilai default', () {
      final cast = CastMember.fromJson({'id': 1, 'name': 'Edward Norton'});
      final video = Video.fromJson({
        'key': 'xyz',
        'site': 'YouTube',
        'type': 'Trailer',
      });

      expect(cast.order, 9999);
      expect(cast.profileUrl, isNull);
      expect(video.official, isFalse);
      expect(video.isYouTube, isTrue);
      expect(video.youtubeUrl, 'https://www.youtube.com/watch?v=xyz');
    });
  });
}
