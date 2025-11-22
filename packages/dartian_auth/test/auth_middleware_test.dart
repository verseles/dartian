import 'package:dartian_auth/dartian_auth.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('AuthMiddleware', () {
    late AuthMiddleware authMiddleware;
    const testSecret = 'test-secret-key-12345';

    setUp(() {
      authMiddleware = AuthMiddleware(jwtSecret: testSecret);
    });

    Handler createTestHandler({bool checkAuth = false}) {
      return (Request request) {
        if (checkAuth) {
          final isAuth = request.isAuthenticated;
          final userId = request.userId;
          return Response.ok('authenticated: $isAuth, userId: $userId');
        }
        return Response.ok('handler called');
      };
    }

    test('should create middleware without secret', () {
      final middleware = AuthMiddleware();
      expect(middleware, isNotNull);
      expect(middleware.jwtSecret, isNull);
    });

    test('should create middleware with secret', () {
      expect(authMiddleware.jwtSecret, equals(testSecret));
    });

    test('should pass through request without Authorization header', () async {
      final middleware = authMiddleware.middleware;
      final handler = middleware(createTestHandler());
      final request = Request('GET', Uri.parse('http://localhost/'));

      final response = await handler(request);

      expect(response.statusCode, equals(200));
    });

    test('should set is_authenticated to false when no token', () async {
      final middleware = authMiddleware.middleware;
      final handler = middleware(createTestHandler(checkAuth: true));
      final request = Request('GET', Uri.parse('http://localhost/'));

      final response = await handler(request);
      final body = await response.readAsString();

      expect(body, contains('authenticated: false'));
    });

    test('should extract and verify valid Bearer token', () async {
      final jwt = JWT.create({
        'id': '123',
        'email': 'test@example.com',
      }, secret: testSecret);

      final middleware = authMiddleware.middleware;
      final handler = middleware(createTestHandler(checkAuth: true));
      final request = Request(
        'GET',
        Uri.parse('http://localhost/'),
        headers: {'Authorization': 'Bearer ${jwt.token}'},
      );

      final response = await handler(request);
      final body = await response.readAsString();

      expect(body, contains('authenticated: true'));
      expect(body, contains('userId: 123'));
    });

    test('should set user data in context from JWT payload', () async {
      final jwt = JWT.create({
        'id': '456',
        'email': 'user@example.com',
        'role': 'admin',
      }, secret: testSecret);

      final middleware = authMiddleware.middleware;
      Handler testHandler = (Request request) {
        final user = request.user;
        expect(user, isNotNull);
        expect(user!['id'], equals('456'));
        expect(user['email'], equals('user@example.com'));
        expect(user['role'], equals('admin'));
        return Response.ok('ok');
      };

      final handler = middleware(testHandler);
      final request = Request(
        'GET',
        Uri.parse('http://localhost/'),
        headers: {'Authorization': 'Bearer ${jwt.token}'},
      );

      await handler(request);
    });

    test('should set auth_token in context', () async {
      final jwt = JWT.create({'id': '789'}, secret: testSecret);

      final middleware = authMiddleware.middleware;
      Handler testHandler = (Request request) {
        final token = request.authToken;
        expect(token, equals(jwt.token));
        return Response.ok('ok');
      };

      final handler = middleware(testHandler);
      final request = Request(
        'GET',
        Uri.parse('http://localhost/'),
        headers: {'Authorization': 'Bearer ${jwt.token}'},
      );

      await handler(request);
    });

    test('should handle invalid JWT token', () async {
      final middleware = authMiddleware.middleware;
      final handler = middleware(createTestHandler(checkAuth: true));
      final request = Request(
        'GET',
        Uri.parse('http://localhost/'),
        headers: {'Authorization': 'Bearer invalid-token'},
      );

      final response = await handler(request);
      final body = await response.readAsString();

      expect(body, contains('authenticated: false'));
    });

    test('should handle expired JWT token', () async {
      final jwt = JWT.create(
        {'id': '123'},
        secret: testSecret,
        expiresIn: const Duration(seconds: -2), // Create already-expired token
      );

      // No need to wait - token is already expired

      final middleware = authMiddleware.middleware;
      final handler = middleware(createTestHandler(checkAuth: true));
      final request = Request(
        'GET',
        Uri.parse('http://localhost/'),
        headers: {'Authorization': 'Bearer ${jwt.token}'},
      );

      final response = await handler(request);
      final body = await response.readAsString();

      expect(body, contains('authenticated: false'));
    });

    test('should ignore Authorization header without Bearer prefix', () async {
      final middleware = authMiddleware.middleware;
      final handler = middleware(createTestHandler(checkAuth: true));
      final request = Request(
        'GET',
        Uri.parse('http://localhost/'),
        headers: {'Authorization': 'Basic dXNlcjpwYXNz'},
      );

      final response = await handler(request);
      final body = await response.readAsString();

      expect(body, contains('authenticated: false'));
    });

    test('should set auth_error in context on exception', () async {
      final middleware = authMiddleware.middleware;
      Handler testHandler = (Request request) {
        final error = request.context['auth_error'];
        expect(error, isNotNull);
        return Response.ok('ok');
      };

      final handler = middleware(testHandler);
      final request = Request(
        'GET',
        Uri.parse('http://localhost/'),
        headers: {'Authorization': 'Bearer invalid'},
      );

      await handler(request);
    });
  });

  group('AuthContext extension', () {
    test('isAuthenticated should return false when context is empty', () {
      final request = Request('GET', Uri.parse('http://localhost/'));
      expect(request.isAuthenticated, isFalse);
    });

    test('isAuthenticated should return true when set in context', () {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/'),
        context: {'is_authenticated': true},
      );
      expect(request.isAuthenticated, isTrue);
    });

    test('user should return null when not in context', () {
      final request = Request('GET', Uri.parse('http://localhost/'));
      expect(request.user, isNull);
    });

    test('user should return user data when in context', () {
      final userData = {'id': '123', 'email': 'test@example.com'};
      final request = Request(
        'GET',
        Uri.parse('http://localhost/'),
        context: {'user': userData},
      );
      expect(request.user, equals(userData));
    });

    test('userId should return null when user not in context', () {
      final request = Request('GET', Uri.parse('http://localhost/'));
      expect(request.userId, isNull);
    });

    test('userId should return user ID from context', () {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/'),
        context: {
          'user': {'id': '456', 'email': 'test@example.com'},
        },
      );
      expect(request.userId, equals('456'));
    });

    test('authToken should return null when not in context', () {
      final request = Request('GET', Uri.parse('http://localhost/'));
      expect(request.authToken, isNull);
    });

    test('authToken should return token from context', () {
      const token = 'test-token-123';
      final request = Request(
        'GET',
        Uri.parse('http://localhost/'),
        context: {'auth_token': token},
      );
      expect(request.authToken, equals(token));
    });
  });
}
