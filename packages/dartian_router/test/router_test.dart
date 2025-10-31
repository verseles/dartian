import 'package:dartian_router/dartian_router.dart';
import 'package:dartian_http/dartian_http.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import 'test_server.dart';

void main() {
  group('Router', () {
    final server = TestServer();
    Router? router;

    setUp(() {
      router = Router();
    });

    tearDown(() async {
      await server.stop();
    });

    test('handles basic routes', () async {
      router!.get('/', (Request request) => DartianResponse.text('Hello'));
      await server.start(router!.handler);
      final response = await http.get(Uri.parse('http://localhost:${server.port}/'));
      expect(response.statusCode, 200);
      expect(response.body, 'Hello');
    });

    test('handles route parameters', () async {
      router!.get('/users/<id>', (Request request) {
        final params = request.context['shelf_router/params'] as Map<String, String>;
        return DartianResponse.text('User ${params['id']}');
      });
      await server.start(router!.handler);
      final response = await http.get(Uri.parse('http://localhost:${server.port}/users/123'));
      expect(response.statusCode, 200);
      expect(response.body, 'User 123');
    });

    test('handles route groups', () async {
      router!.group('/api', (router) {
        router.get('/users', (Request request) => DartianResponse.text('API Users'));
      });
      await server.start(router!.handler);
      final response = await http.get(Uri.parse('http://localhost:${server.port}/api/users'));
      expect(response.statusCode, 200);
      expect(response.body, 'API Users');
    });

    test('handles named routes', () async {
      router!.get('/profile', (Request request) {}, name: 'profile');
      expect(router!.route('profile'), '/profile');
    });

    test('returns 404 for unknown routes', () async {
      await server.start(router!.handler);
      final response = await http.get(Uri.parse('http://localhost:${server.port}/not-found'));
      expect(response.statusCode, 404);
    });
  });
}
