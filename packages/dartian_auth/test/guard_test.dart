import 'package:dartian_auth/dartian_auth.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('JwtGuard', () {
    late JwtGuard guard;
    const testSecret = 'test-secret-key-12345';

    setUp(() {
      guard = JwtGuard(jwtSecret: testSecret);
    });

    Handler createTestHandler() {
      return (Request request) {
        final user = request.context['user'];
        final isAuth = request.context['is_authenticated'];
        return Response.ok('user: $user, auth: $isAuth');
      };
    }

    group('middleware', () {
      test('should reject request without token', () async {
        final middleware = guard.middleware();
        final handler = middleware(createTestHandler());
        final request = Request('GET', Uri.parse('http://localhost/protected'));

        final response = await handler(request);

        expect(response.statusCode, equals(401));
        final body = await response.readAsString();
        expect(body, contains('No token provided'));
      });

      test('should reject request with invalid token', () async {
        final middleware = guard.middleware();
        final handler = middleware(createTestHandler());
        final request = Request(
          'GET',
          Uri.parse('http://localhost/protected'),
          headers: {'Authorization': 'Bearer invalid-token'},
        );

        final response = await handler(request);

        expect(response.statusCode, equals(401));
        final body = await response.readAsString();
        expect(body, contains('Invalid or expired token'));
      });

      test('should accept request with valid token', () async {
        final jwt = JWT.create({
          'id': '123',
          'email': 'test@example.com',
        }, secret: testSecret);

        final middleware = guard.middleware();
        final handler = middleware(createTestHandler());
        final request = Request(
          'GET',
          Uri.parse('http://localhost/protected'),
          headers: {'Authorization': 'Bearer ${jwt.token}'},
        );

        final response = await handler(request);

        expect(response.statusCode, equals(200));
      });

      test('should add user data to request context', () async {
        final jwt = JWT.create({
          'id': '456',
          'role': 'admin',
        }, secret: testSecret);

        final middleware = guard.middleware();
        Handler testHandler = (Request request) {
          final user = request.context['user'] as Map<String, dynamic>?;
          expect(user, isNotNull);
          expect(user!['id'], equals('456'));
          expect(user['role'], equals('admin'));
          expect(request.context['is_authenticated'], isTrue);
          expect(request.context['guard'], equals('jwt'));
          return Response.ok('ok');
        };

        final handler = middleware(testHandler);
        final request = Request(
          'GET',
          Uri.parse('http://localhost/api/users'),
          headers: {'Authorization': 'Bearer ${jwt.token}'},
        );

        await handler(request);
      });

      test('should reject expired token', () async {
        final jwt = JWT.create(
          {'id': '123'},
          secret: testSecret,
          expiresIn: const Duration(
            seconds: -2,
          ), // Negative duration creates already expired token
        );

        final middleware = guard.middleware();
        final handler = middleware(createTestHandler());
        final request = Request(
          'GET',
          Uri.parse('http://localhost/api/data'),
          headers: {'Authorization': 'Bearer ${jwt.token}'},
        );

        final response = await handler(request);

        expect(response.statusCode, equals(401));
        final body = await response.readAsString();
        expect(body, contains('Invalid or expired token'));
      });

      test('should skip authentication for excepted routes', () async {
        final guardWithExcept = JwtGuard(
          jwtSecret: testSecret,
          exceptRoutes: ['public', 'api/health'],
        );

        final middleware = guardWithExcept.middleware();
        final handler = middleware(createTestHandler());
        final request = Request('GET', Uri.parse('http://localhost/public'));

        final response = await handler(request);

        expect(response.statusCode, equals(200));
      });

      test('should skip authentication for wildcard excepted routes', () async {
        final guardWithExcept = JwtGuard(
          jwtSecret: testSecret,
          exceptRoutes: ['public/*', 'docs/*'],
        );

        final middleware = guardWithExcept.middleware();
        final handler = middleware(createTestHandler());
        final request = Request(
          'GET',
          Uri.parse('http://localhost/public/page'),
        );

        final response = await handler(request);

        expect(response.statusCode, equals(200));
      });

      test('should not match partial routes without wildcard', () async {
        final guardWithExcept = JwtGuard(
          jwtSecret: testSecret,
          exceptRoutes: ['api/login'],
        );

        final middleware = guardWithExcept.middleware();
        final handler = middleware(createTestHandler());
        final request = Request(
          'GET',
          Uri.parse('http://localhost/api/login/callback'),
        );

        final response = await handler(request);

        expect(response.statusCode, equals(401));
      });
    });

    group('check', () {
      test('should return false for request without token', () async {
        final request = Request('GET', Uri.parse('http://localhost/'));
        final result = await guard.check(request);
        expect(result, isFalse);
      });

      test('should return false for invalid token', () async {
        final request = Request(
          'GET',
          Uri.parse('http://localhost/'),
          headers: {'Authorization': 'Bearer invalid'},
        );
        final result = await guard.check(request);
        expect(result, isFalse);
      });

      test('should return true for valid token', () async {
        final jwt = JWT.create({'id': '123'}, secret: testSecret);
        final request = Request(
          'GET',
          Uri.parse('http://localhost/'),
          headers: {'Authorization': 'Bearer ${jwt.token}'},
        );
        final result = await guard.check(request);
        expect(result, isTrue);
      });

      test('should return false for expired token', () async {
        final jwt = JWT.create(
          {'id': '123'},
          secret: testSecret,
          expiresIn: const Duration(seconds: -2),
        );

        final request = Request(
          'GET',
          Uri.parse('http://localhost/'),
          headers: {'Authorization': 'Bearer ${jwt.token}'},
        );
        final result = await guard.check(request);
        expect(result, isFalse);
      });
    });

    group('user', () {
      test('should return null when no user in context', () {
        final request = Request('GET', Uri.parse('http://localhost/'));
        final user = guard.user(request);
        expect(user, isNull);
      });

      test('should return user data from context', () {
        final userData = {'id': '123', 'name': 'Test'};
        final request = Request(
          'GET',
          Uri.parse('http://localhost/'),
          context: {'user': userData},
        );
        final user = guard.user(request);
        expect(user, equals(userData));
      });
    });
  });

  group('SessionGuard', () {
    late SessionGuard guard;

    setUp(() {
      guard = SessionGuard();
    });

    Handler createTestHandler() {
      return (Request request) {
        final user = request.context['user'];
        final isAuth = request.context['is_authenticated'];
        return Response.ok('user: $user, auth: $isAuth');
      };
    }

    group('middleware', () {
      test('should reject request without session cookie', () async {
        final middleware = guard.middleware();
        final handler = middleware(createTestHandler());
        final request = Request('GET', Uri.parse('http://localhost/protected'));

        final response = await handler(request);

        expect(response.statusCode, equals(401));
        final body = await response.readAsString();
        expect(body, contains('No session cookie found'));
      });

      test('should reject request with invalid session ID', () async {
        final middleware = guard.middleware();
        final handler = middleware(createTestHandler());
        final request = Request(
          'GET',
          Uri.parse('http://localhost/protected'),
          headers: {'cookie': 'dartian_session=invalid-session-id'},
        );

        final response = await handler(request);

        expect(response.statusCode, equals(401));
        final body = await response.readAsString();
        expect(body, contains('Invalid or expired session'));
      });

      test('should accept request with valid session', () async {
        final sessionId = guard.createSession(
          'user123',
          data: {'email': 'test@example.com'},
        );

        final middleware = guard.middleware();
        final handler = middleware(createTestHandler());
        final request = Request(
          'GET',
          Uri.parse('http://localhost/dashboard'),
          headers: {'cookie': 'dartian_session=$sessionId'},
        );

        final response = await handler(request);

        expect(response.statusCode, equals(200));
      });

      test('should add session data to request context', () async {
        final sessionId = guard.createSession(
          'user456',
          data: {'role': 'admin', 'name': 'Admin User'},
        );

        final middleware = guard.middleware();
        Handler testHandler = (Request request) {
          final user = request.context['user'] as Map<String, dynamic>?;
          final userId = request.context['user_id'];
          final sessionIdFromContext = request.context['session_id'];

          expect(user, isNotNull);
          expect(user!['role'], equals('admin'));
          expect(userId, equals('user456'));
          expect(sessionIdFromContext, equals(sessionId));
          expect(request.context['is_authenticated'], isTrue);
          expect(request.context['guard'], equals('session'));
          return Response.ok('ok');
        };

        final handler = middleware(testHandler);
        final request = Request(
          'GET',
          Uri.parse('http://localhost/profile'),
          headers: {'cookie': 'dartian_session=$sessionId'},
        );

        await handler(request);
      });

      test('should reject expired session', () async {
        final guardShortSession = SessionGuard(
          sessionDuration: const Duration(milliseconds: 1),
        );
        final sessionId = guardShortSession.createSession('user123');

        // Wait for expiration
        await Future.delayed(const Duration(milliseconds: 10));

        final middleware = guardShortSession.middleware();
        final handler = middleware(createTestHandler());
        final request = Request(
          'GET',
          Uri.parse('http://localhost/api/data'),
          headers: {'cookie': 'dartian_session=$sessionId'},
        );

        final response = await handler(request);

        expect(response.statusCode, equals(401));
        final body = await response.readAsString();
        expect(body, contains('Invalid or expired session'));
      });

      test('should skip authentication for excepted routes', () async {
        final guardWithExcept = SessionGuard(
          exceptRoutes: ['login', 'register'],
        );

        final middleware = guardWithExcept.middleware();
        final handler = middleware(createTestHandler());
        final request = Request('GET', Uri.parse('http://localhost/login'));

        final response = await handler(request);

        expect(response.statusCode, equals(200));
      });

      test('should skip authentication for wildcard excepted routes', () async {
        final guardWithExcept = SessionGuard(exceptRoutes: ['public/*']);

        final middleware = guardWithExcept.middleware();
        final handler = middleware(createTestHandler());
        final request = Request(
          'GET',
          Uri.parse('http://localhost/public/about'),
        );

        final response = await handler(request);

        expect(response.statusCode, equals(200));
      });

      test('should parse session from cookie with multiple values', () async {
        final sessionId = guard.createSession('user789');

        final middleware = guard.middleware();
        final handler = middleware(createTestHandler());
        final request = Request(
          'GET',
          Uri.parse('http://localhost/api/user'),
          headers: {
            'cookie': 'other=value; dartian_session=$sessionId; another=test',
          },
        );

        final response = await handler(request);

        expect(response.statusCode, equals(200));
      });

      test('should use custom session cookie name', () async {
        final customGuard = SessionGuard(sessionCookieName: 'custom_session');
        final sessionId = customGuard.createSession('user999');

        final middleware = customGuard.middleware();
        final handler = middleware(createTestHandler());
        final request = Request(
          'GET',
          Uri.parse('http://localhost/api/data'),
          headers: {'cookie': 'custom_session=$sessionId'},
        );

        final response = await handler(request);

        expect(response.statusCode, equals(200));
      });

      test('should remove expired session during middleware check', () async {
        final guardShortSession = SessionGuard(
          sessionDuration: const Duration(milliseconds: 1),
        );
        final sessionId = guardShortSession.createSession('user111');

        // Verify session exists
        expect(guardShortSession.getSession(sessionId), isNotNull);

        // Wait for expiration
        await Future.delayed(const Duration(milliseconds: 10));

        final middleware = guardShortSession.middleware();
        final handler = middleware(createTestHandler());
        final request = Request(
          'GET',
          Uri.parse('http://localhost/api/data'),
          headers: {'cookie': 'dartian_session=$sessionId'},
        );

        await handler(request);

        // Session should be removed
        expect(guardShortSession.getSession(sessionId), isNull);
      });
    });

    group('check', () {
      test('should return false for request without session', () async {
        final request = Request('GET', Uri.parse('http://localhost/'));
        final result = await guard.check(request);
        expect(result, isFalse);
      });

      test('should return false for invalid session', () async {
        final request = Request(
          'GET',
          Uri.parse('http://localhost/'),
          headers: {'cookie': 'dartian_session=invalid'},
        );
        final result = await guard.check(request);
        expect(result, isFalse);
      });

      test('should return true for valid session', () async {
        final sessionId = guard.createSession('user123');
        final request = Request(
          'GET',
          Uri.parse('http://localhost/'),
          headers: {'cookie': 'dartian_session=$sessionId'},
        );
        final result = await guard.check(request);
        expect(result, isTrue);
      });

      test('should return false for expired session', () async {
        final guardShortSession = SessionGuard(
          sessionDuration: const Duration(milliseconds: 1),
        );
        final sessionId = guardShortSession.createSession('user123');

        await Future.delayed(const Duration(milliseconds: 10));

        final request = Request(
          'GET',
          Uri.parse('http://localhost/'),
          headers: {'cookie': 'dartian_session=$sessionId'},
        );
        final result = await guardShortSession.check(request);
        expect(result, isFalse);
      });
    });

    group('user', () {
      test('should return null when no session in context', () {
        final request = Request('GET', Uri.parse('http://localhost/'));
        final user = guard.user(request);
        expect(user, isNull);
      });

      test('should return user data from session', () {
        final session = Session.create('user123', const Duration(hours: 1));
        final userData = {'email': 'test@example.com', 'role': 'admin'};
        final sessionWithData = Session(
          id: session.id,
          userId: session.userId,
          createdAt: session.createdAt,
          expiresAt: session.expiresAt,
          data: userData,
        );

        final request = Request(
          'GET',
          Uri.parse('http://localhost/'),
          context: {'session': sessionWithData},
        );
        final user = guard.user(request);
        expect(user, equals(userData));
      });
    });

    group('session management', () {
      test('createSession should create session without data', () {
        final sessionId = guard.createSession('user123');
        expect(sessionId, isNotNull);

        final session = guard.getSession(sessionId);
        expect(session, isNotNull);
        expect(session!.userId, equals('user123'));
      });

      test('createSession should create session with data', () {
        final data = {'email': 'test@example.com', 'name': 'Test User'};
        final sessionId = guard.createSession('user456', data: data);

        final session = guard.getSession(sessionId);
        expect(session, isNotNull);
        expect(session!.data, equals(data));
      });

      test('destroySession should remove session', () {
        final sessionId = guard.createSession('user789');
        expect(guard.getSession(sessionId), isNotNull);

        guard.destroySession(sessionId);
        expect(guard.getSession(sessionId), isNull);
      });

      test('cleanupExpiredSessions should remove expired sessions', () {
        final guardShortSession = SessionGuard(
          sessionDuration: const Duration(milliseconds: 1),
        );

        final sessionId1 = guardShortSession.createSession('user1');
        final sessionId2 = guardShortSession.createSession('user2');

        // Verify both sessions exist
        expect(guardShortSession.getSession(sessionId1), isNotNull);
        expect(guardShortSession.getSession(sessionId2), isNotNull);

        // Wait for expiration
        Future.delayed(const Duration(milliseconds: 10), () {
          guardShortSession.cleanupExpiredSessions();

          // Both sessions should be removed
          expect(guardShortSession.getSession(sessionId1), isNull);
          expect(guardShortSession.getSession(sessionId2), isNull);
        });
      });

      test('getSession should return null for non-existent session', () {
        final session = guard.getSession('non-existent-id');
        expect(session, isNull);
      });
    });
  });
}
