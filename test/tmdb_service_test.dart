import 'dart:io';

import 'package:cinedex/data/services/api_exception.dart';
import 'package:cinedex/data/services/tmdb_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('TmdbService', () {
    test(
      'mengirim header Bearer dan language=id-ID lalu parsing hasil',
      () async {
        late http.Request captured;
        final service = TmdbService(
          token: 'token-uji',
          client: MockClient((request) async {
            captured = request;
            return http.Response(
              '{"results":[{"id":1,"title":"Film A","poster_path":"/a.jpg"}]}',
              200,
            );
          }),
        );

        final movies = await service.fetchPopular();

        expect(captured.headers['Authorization'], 'Bearer token-uji');
        expect(captured.url.path, '/3/movie/popular');
        expect(captured.url.queryParameters['language'], 'id-ID');
        expect(movies.single.title, 'Film A');
      },
    );

    test(
      'error jaringan dan status non-200 dipetakan ke exception sendiri',
      () async {
        TmdbService withResponse(Future<http.Response> Function() handler) =>
            TmdbService(token: 't', client: MockClient((_) => handler()));

        await expectLater(
          withResponse(
            () => throw const SocketException('offline'),
          ).fetchPopular(),
          throwsA(isA<NoInternetException>()),
        );
        await expectLater(
          withResponse(() async => http.Response('{}', 401)).fetchPopular(),
          throwsA(
            isA<ServerException>().having(
              (e) => e.statusCode,
              'statusCode',
              401,
            ),
          ),
        );
        await expectLater(
          withResponse(
            () async => http.Response('bukan json', 200),
          ).fetchPopular(),
          throwsA(isA<ParsingException>()),
        );
        await expectLater(
          TmdbService(
            token: '',
            client: MockClient((_) async => http.Response('', 200)),
          ).fetchPopular(),
          throwsA(isA<MissingTokenException>()),
        );
      },
    );
  });
}
