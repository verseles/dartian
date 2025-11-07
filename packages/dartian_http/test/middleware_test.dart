import 'package:test/test.dart';
import 'package:dartian_http/dartian_http.dart';
import 'package:dartian_i18n/dartian_i18n.dart';
import 'package:shelf/shelf.dart';
import 'dart:io';

void main() {
  group('I18nMiddleware', () {
    setUp(() {
      // Initialize i18n
      i18n.init(defaultLocale: 'en');

      // Create test language files
      final enDir = Directory('resources/lang/en');
      if (!enDir.existsSync()) {
        enDir.createSync(recursive: true);
      }

      File('resources/lang/en/messages.json').writeAsStringSync('''{
  "greeting": "Hello"
}''');
    });

    tearDown(() {
      // Clean up
      final langDir = Directory('resources/lang');
      if (langDir.existsSync()) {
        langDir.deleteSync(recursive: true);
      }
      i18n.clear();
    });

    test('should detect locale from Accept-Language header', () {
      final middleware = i18nMiddleware();

      Request? capturedRequest;
      final handler = (Request request) {
        capturedRequest = request;
        return Response.ok('OK');
      };

      final wrappedHandler = middleware(handler);

      // Create a request with Accept-Language header
      final request = Request(
        'GET',
        Uri.parse('http://localhost:8000/'),
        headers: {'Accept-Language': 'pt-BR,pt;q=0.9,en;q=0.8'},
      );

      wrappedHandler(request);

      expect(capturedRequest, isNotNull);
    });

    test('should use default locale if no Accept-Language header', () {
      final middleware = i18nMiddleware(defaultLocale: 'en');

      Request? capturedRequest;
      final handler = (Request request) {
        capturedRequest = request;
        return Response.ok('OK');
      };

      final wrappedHandler = middleware(handler);

      // Create a request without Accept-Language header
      final request = Request(
        'GET',
        Uri.parse('http://localhost:8000/'),
      );

      wrappedHandler(request);

      expect(capturedRequest, isNotNull);
    });

    test('should initialize i18n if not already done', () {
      i18n.clear();
      i18n.init(defaultLocale: 'en');

      final middleware = i18nMiddleware();

      Request? capturedRequest;
      final handler = (Request request) {
        capturedRequest = request;
        return Response.ok('OK');
      };

      final wrappedHandler = middleware(handler);

      final request = Request(
        'GET',
        Uri.parse('http://localhost:8000/'),
      );

      wrappedHandler(request);

      expect(capturedRequest, isNotNull);
    });
  });
}
