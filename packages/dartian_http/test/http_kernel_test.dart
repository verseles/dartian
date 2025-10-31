import 'package:dartian_http/dartian_http.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart' as shelf;
import 'package:test/test.dart';

import 'test_server.dart';

void main() {
  group('HttpKernel', () {
    final server = TestServer();

    tearDown(() async {
      await server.stop();
    });

    test('handles a basic request', () async {
      await server.start((shelf.Request request) => shelf.Response.ok('Hello'));
      final response = await http.get(Uri.parse('http://localhost:${server.port}'));
      expect(response.statusCode, 200);
      expect(response.body, 'Hello');
    });
  });
}
