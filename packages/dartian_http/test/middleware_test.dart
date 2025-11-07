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

  group('CORS Middleware', () {
    test('should allow all origins when allowedOrigins is null', () async {
      final middleware = corsMiddleware();
      final handler = (Request request) => Response.ok('OK');
      final wrappedHandler = middleware(handler);

      final request = Request(
        'GET',
        Uri.parse('http://localhost:8000/'),
        headers: {'origin': 'https://example.com'},
      );

      final response = await wrappedHandler(request);
      expect(response.statusCode, 200);
      expect(response.headers['Access-Control-Allow-Origin'], 'https://example.com');
    });

    test('should handle OPTIONS preflight request', () async {
      final middleware = corsMiddleware(
        allowedOrigins: ['https://example.com'],
      );
      final handler = (Request request) => Response.ok('Should not reach here');
      final wrappedHandler = middleware(handler);

      final request = Request(
        'OPTIONS',
        Uri.parse('http://localhost:8000/'),
        headers: {'origin': 'https://example.com'},
      );

      final response = await wrappedHandler(request);
      expect(response.statusCode, 200);
      expect(response.headers['Access-Control-Allow-Origin'], 'https://example.com');
      expect(response.headers['Access-Control-Allow-Methods'], contains('GET'));
      expect(response.headers['Access-Control-Allow-Methods'], contains('POST'));
      expect(response.headers['Access-Control-Max-Age'], '86400');
    });

    test('should reject disallowed origin', () async {
      final middleware = corsMiddleware(
        allowedOrigins: ['https://allowed.com'],
      );
      final handler = (Request request) => Response.ok('OK');
      final wrappedHandler = middleware(handler);

      final request = Request(
        'GET',
        Uri.parse('http://localhost:8000/'),
        headers: {'origin': 'https://notallowed.com'},
      );

      final response = await wrappedHandler(request);
      expect(response.statusCode, 200);
      expect(response.headers['Access-Control-Allow-Origin'], isNull);
    });

    test('should support wildcard origin', () async {
      final middleware = corsMiddleware(
        allowedOrigins: ['*'],
      );
      final handler = (Request request) => Response.ok('OK');
      final wrappedHandler = middleware(handler);

      final request = Request(
        'GET',
        Uri.parse('http://localhost:8000/'),
        headers: {'origin': 'https://anything.com'},
      );

      final response = await wrappedHandler(request);
      expect(response.statusCode, 200);
      expect(response.headers['Access-Control-Allow-Origin'], 'https://anything.com');
    });

    test('should support prefix matching', () async {
      final middleware = corsMiddleware(
        allowedOrigins: ['https://example.com*'],
      );
      final handler = (Request request) => Response.ok('OK');
      final wrappedHandler = middleware(handler);

      final request = Request(
        'GET',
        Uri.parse('http://localhost:8000/'),
        headers: {'origin': 'https://example.com.br'},
      );

      final response = await wrappedHandler(request);
      expect(response.statusCode, 200);
      expect(response.headers['Access-Control-Allow-Origin'], 'https://example.com.br');
    });

    test('should add credentials header when allowCredentials is true', () async {
      final middleware = corsMiddleware(
        allowedOrigins: ['https://example.com'],
        allowCredentials: true,
      );
      final handler = (Request request) => Response.ok('OK');
      final wrappedHandler = middleware(handler);

      final request = Request(
        'GET',
        Uri.parse('http://localhost:8000/'),
        headers: {'origin': 'https://example.com'},
      );

      final response = await wrappedHandler(request);
      expect(response.headers['Access-Control-Allow-Credentials'], 'true');
    });

    test('should add exposed headers when provided', () async {
      final middleware = corsMiddleware(
        allowedOrigins: ['https://example.com'],
        exposedHeaders: ['X-Custom-Header', 'X-Another-Header'],
      );
      final handler = (Request request) => Response.ok('OK');
      final wrappedHandler = middleware(handler);

      final request = Request(
        'GET',
        Uri.parse('http://localhost:8000/'),
        headers: {'origin': 'https://example.com'},
      );

      final response = await wrappedHandler(request);
      expect(response.headers['Access-Control-Expose-Headers'], contains('X-Custom-Header'));
    });

    test('should handle request without origin header', () async {
      final middleware = corsMiddleware(
        allowedOrigins: ['https://example.com'],
      );
      final handler = (Request request) => Response.ok('OK');
      final wrappedHandler = middleware(handler);

      final request = Request(
        'GET',
        Uri.parse('http://localhost:8000/'),
      );

      final response = await wrappedHandler(request);
      expect(response.statusCode, 200);
      expect(response.headers['Access-Control-Allow-Origin'], isNull);
    });
  });

  group('CSRF Middleware', () {
    late CsrfMiddleware csrfMiddleware;

    setUp(() {
      csrfMiddleware = CsrfMiddleware(secretKey: 'test-secret-key-12345');
    });

    test('should generate token for safe methods', () async {
      final middleware = csrfMiddleware.middleware();
      final handler = (Request request) => Response.ok('OK');
      final wrappedHandler = middleware(handler);

      final request = Request('GET', Uri.parse('http://localhost:8000/'));
      final response = await wrappedHandler(request);

      expect(response.statusCode, 200);
      expect(response.headers['Set-Cookie'], isNotNull);
      expect(response.headers['Set-Cookie'], contains('XSRF-TOKEN='));
    });

    test('should reject POST request without CSRF token', () async {
      final middleware = csrfMiddleware.middleware();
      final handler = (Request request) => Response.ok('Should not reach here');
      final wrappedHandler = middleware(handler);

      final request = Request('POST', Uri.parse('http://localhost:8000/'));
      final response = await wrappedHandler(request);

      expect(response.statusCode, 403);
      expect(await response.readAsString(), contains('CSRF token missing'));
    });

    test('should reject POST request with token mismatch', () async {
      final middleware = csrfMiddleware.middleware();
      final handler = (Request request) => Response.ok('Should not reach here');
      final wrappedHandler = middleware(handler);

      final request = Request(
        'POST',
        Uri.parse('http://localhost:8000/'),
        headers: {
          'X-CSRF-Token': 'token-in-header',
          'cookie': 'XSRF-TOKEN=different-token-in-cookie',
        },
      );
      final response = await wrappedHandler(request);

      expect(response.statusCode, 403);
      expect(await response.readAsString(), contains('CSRF token mismatch'));
    });

    test('should reject POST request with invalid token format', () async {
      final middleware = csrfMiddleware.middleware();
      final handler = (Request request) => Response.ok('Should not reach here');
      final wrappedHandler = middleware(handler);

      final invalidToken = 'invalid-token-format';
      final request = Request(
        'POST',
        Uri.parse('http://localhost:8000/'),
        headers: {
          'X-CSRF-Token': invalidToken,
          'cookie': 'XSRF-TOKEN=$invalidToken',
        },
      );
      final response = await wrappedHandler(request);

      expect(response.statusCode, 403);
      expect(await response.readAsString(), contains('Invalid or expired CSRF token'));
    });

    test('should accept POST request with valid token', () async {
      final middleware = csrfMiddleware.middleware();
      final handler = (Request request) => Response.ok('Success');
      final wrappedHandler = middleware(handler);

      // First, get a token from a safe request
      final getRequest = Request('GET', Uri.parse('http://localhost:8000/'));
      final getResponse = await wrappedHandler(getRequest);

      // Extract token from Set-Cookie header
      final setCookie = getResponse.headers['Set-Cookie']!;
      final tokenMatch = RegExp(r'XSRF-TOKEN=([^;]+)').firstMatch(setCookie);
      expect(tokenMatch, isNotNull);
      final token = tokenMatch!.group(1)!;

      // Now make a POST request with the token
      final postRequest = Request(
        'POST',
        Uri.parse('http://localhost:8000/'),
        headers: {
          'X-CSRF-Token': token,
          'cookie': 'XSRF-TOKEN=$token',
        },
      );
      final postResponse = await wrappedHandler(postRequest);

      expect(postResponse.statusCode, 200);
      expect(await postResponse.readAsString(), 'Success');
    });

    test('should rotate token after successful POST request', () async {
      final middleware = csrfMiddleware.middleware();
      final handler = (Request request) => Response.ok('Success');
      final wrappedHandler = middleware(handler);

      // Get initial token
      final getRequest = Request('GET', Uri.parse('http://localhost:8000/'));
      final getResponse = await wrappedHandler(getRequest);
      final initialToken = RegExp(r'XSRF-TOKEN=([^;]+)')
          .firstMatch(getResponse.headers['Set-Cookie']!)!
          .group(1)!;

      // Make POST request with token
      final postRequest = Request(
        'POST',
        Uri.parse('http://localhost:8000/'),
        headers: {
          'X-CSRF-Token': initialToken,
          'cookie': 'XSRF-TOKEN=$initialToken',
        },
      );
      final postResponse = await wrappedHandler(postRequest);

      // Check that a new token was issued
      final newToken = RegExp(r'XSRF-TOKEN=([^;]+)')
          .firstMatch(postResponse.headers['Set-Cookie']!)!
          .group(1)!;

      expect(newToken, isNot(equals(initialToken)));
    });

    test('should use custom token and cookie names', () async {
      final customCsrf = CsrfMiddleware(
        secretKey: 'test-secret',
        tokenName: 'X-Custom-CSRF-Token',
        cookieName: 'CUSTOM-CSRF',
      );
      final middleware = customCsrf.middleware();
      final handler = (Request request) => Response.ok('OK');
      final wrappedHandler = middleware(handler);

      final request = Request('GET', Uri.parse('http://localhost:8000/'));
      final response = await wrappedHandler(request);

      expect(response.headers['Set-Cookie'], contains('CUSTOM-CSRF='));
    });

    test('should allow HEAD method without token', () async {
      final middleware = csrfMiddleware.middleware();
      final handler = (Request request) => Response.ok('OK');
      final wrappedHandler = middleware(handler);

      final request = Request('HEAD', Uri.parse('http://localhost:8000/'));
      final response = await wrappedHandler(request);

      expect(response.statusCode, 200);
    });

    test('should allow OPTIONS method without token', () async {
      final middleware = csrfMiddleware.middleware();
      final handler = (Request request) => Response.ok('OK');
      final wrappedHandler = middleware(handler);

      final request = Request('OPTIONS', Uri.parse('http://localhost:8000/'));
      final response = await wrappedHandler(request);

      expect(response.statusCode, 200);
    });
  });
}
