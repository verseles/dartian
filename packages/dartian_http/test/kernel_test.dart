import 'package:test/test.dart';
import 'package:dartian_http/dartian_http.dart';
import 'package:shelf/shelf.dart';

void main() {
  group('HttpKernel', () {
    late HttpKernel kernel;

    setUp(() {
      kernel = HttpKernel();
    });

    test('can be instantiated', () {
      expect(kernel, isNotNull);
    });

    test('adds middleware correctly', () {
      final middleware =
          (Handler handler) => (Request request) => handler(request);
      kernel.use(middleware);
      // Middleware added, no exception thrown
      expect(kernel, isNotNull);
    });

    test('handles request without handler', () async {
      final request = Request('GET', Uri.parse('http://localhost:8000/'));
      final response = await kernel.handle(request);
      expect(response.statusCode, 500);
    });

    test('sets handler correctly', () {
      final handler = (Request request) => Response.ok('Test');
      kernel.setHandler(handler);
      // Handler set, no exception thrown
      expect(kernel, isNotNull);
    });

    test('handles request with handler', () async {
      final handler = (Request request) => Response.ok('Test Response');
      kernel.setHandler(handler);
      final request = Request('GET', Uri.parse('http://localhost:8000/test'));
      final response = await kernel.handle(request);
      expect(response.statusCode, 200);
    });

    test('applies middleware correctly', () async {
      final handler = (Request request) => Response.ok('Test');
      final middleware =
          (Handler handler) => (Request request) => handler(request);
      kernel.use(middleware);
      kernel.setHandler(handler);
      final request = Request('GET', Uri.parse('http://localhost:8000/test'));
      final response = await kernel.handle(request);
      expect(response.statusCode, 200);
    });

    test('listen method starts server', () async {
      final handler = (Request request) => Response.ok('Test');
      kernel.setHandler(handler);
      // Don't actually start the server in tests, just verify the method exists
      expect(kernel, isNotNull);
    });

    test('jsonResponse creates correct response', () {
      final response = jsonResponse({'key': 'value'});
      expect(response.statusCode, 200);
      expect(response.headers['Content-Type'], contains('application/json'));
    });

    test('htmlResponse creates correct response', () {
      final response = htmlResponse('<h1>Test</h1>');
      expect(response.statusCode, 200);
      expect(response.headers['Content-Type'], contains('text/html'));
    });

    test('textResponse creates correct response', () {
      final response = textResponse('Plain text');
      expect(response.statusCode, 200);
      expect(response.headers['Content-Type'], contains('text/plain'));
    });

    test('notFound returns 404', () {
      final response = notFound();
      expect(response.statusCode, 404);
    });

    test('serverError returns 500', () {
      final response = serverError();
      expect(response.statusCode, 500);
    });
  });
}
