import 'package:dartian_http/dartian_http.dart';
import 'package:dartian_http/src/session.dart';
import 'package:dartian_http/src/auth/jwt.dart';
import 'package:dartian_http/src/auth/user.dart';
import 'package:dartian_http/src/http/middlewares/session_middleware.dart';
import 'package:dartian_http/src/http/middlewares/auth_guard_middleware.dart';
import 'package:dartian_http/src/http/middlewares/cors_middleware.dart';
import 'package:dartian_http/src/http/middlewares/csrf_middleware.dart';
import 'package:dartian_http/src/http/middlewares/security_headers_middleware.dart';
import 'package:dartian_http/src/http/request_extensions.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

class MockUserProvider extends UserProvider {
  @override
  Future<User?> findById(int id) async {
    if (id == 1) {
      return User(id: 1, name: 'Test User', email: 'test@example.com');
    }
    return null;
  }
}

void main() {
  group('Authentication and Security', () {
    test('SessionMiddleware adds session to context', () async {
      final sessionManager = SessionManager();
      final middleware = sessionMiddleware(sessionManager);
      final handler = middleware((Request request) {
        expect(request.session, isNotNull);
        expect(request.session!.id, isNotNull);
        return Response.ok('Success');
      });
      final request = Request('GET', Uri.parse('http://localhost/'));
      await handler(request);
    });

    test('JWT generates and verifies a token', () {
      final jwt = JsonWebToken('secret');
      final token = jwt.generate({'sub': 1, 'name': 'Test'});
      final payload = jwt.verify(token);
      expect(payload, isNotNull);
      expect(payload!['sub'], 1);
    });

    test('AuthGuard protects a route (session)', () async {
      final sessionManager = SessionManager();
      final userProvider = MockUserProvider();

      final pipeline = const Pipeline()
          .addMiddleware(sessionMiddleware(sessionManager))
          .addMiddleware(authGuard(userProvider: userProvider, guard: 'session'))
          .addHandler((Request request) {
            expect(request.user, isNotNull);
            expect(request.user!.id, 1);
            return Response.ok('Success');
          });

      // Test without session
      var request = Request('GET', Uri.parse('http://localhost/'));
      var response = await pipeline(request);
      expect(response.statusCode, 401);

      // Test with session
      final session = sessionManager.startSession();
      session.set('user_id', 1);
      request = Request('GET', Uri.parse('http://localhost/'), headers: {'cookie': 'dartian_session=${session.id}'});
      response = await pipeline(request);
      expect(response.statusCode, 200);
    });

    test('CORS middleware adds headers', () async {
      final handler = corsMiddleware()((Request request) => Response.ok(''));
      final response = await handler(Request('GET', Uri.parse('http://localhost/')));
      expect(response.headers['access-control-allow-origin'], '*');
    });

    test('Security headers middleware adds headers', () async {
      final handler = securityHeadersMiddleware()((Request request) => Response.ok(''));
      final response = await handler(Request('GET', Uri.parse('http://localhost/')));
      expect(response.headers['x-frame-options'], 'DENY');
    });
  });
}
