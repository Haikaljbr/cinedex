import 'package:cinedex/data/repositories/movie_repository.dart';
import 'package:cinedex/data/services/tmdb_service.dart';
import 'package:cinedex/providers/search_provider.dart';
import 'package:cinedex/providers/view_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('debounce: ketikan beruntun hanya memicu satu request', () async {
    final queries = <String>[];
    final client = MockClient((request) async {
      queries.add(request.url.queryParameters['query']!);
      return http.Response(
        '{"results":[{"id":7,"title":"Avatar","poster_path":"/p.jpg"}]}',
        200,
      );
    });
    final provider = SearchProvider(
      MovieRepository(TmdbService(token: 't', client: client)),
    );

    provider.onQueryChanged('a');
    provider.onQueryChanged('ava');
    provider.onQueryChanged('avatar');
    expect(queries, isEmpty);

    await Future<void>.delayed(const Duration(milliseconds: 700));

    expect(queries, ['avatar']);
    expect(provider.status, LoadStatus.success);
    expect(provider.results.single.title, 'Avatar');

    provider.onQueryChanged('');
    expect(provider.status, LoadStatus.initial);
    provider.dispose();
  });
}
