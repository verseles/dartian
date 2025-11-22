import 'package:shelf/shelf.dart';
import 'jwt.dart';
import 'session.dart';

/// Base interface for authentication guards
abstract class Guard {
  /// Create guard middleware
  Middleware middleware();

  /// Check if request is authenticated
  Future<bool> check(Request request);

  /// Get user data from request
  Map<String, dynamic>? user(Request request);
}

/// JWT-based authentication guard
class JwtGuard implements Guard {
  final String jwtSecret;
  final List<String> exceptRoutes;

  JwtGuard({required this.jwtSecret, this.exceptRoutes = const []});

  @override
  Middleware middleware() {
    return (Handler handler) {
      return (Request request) async {
        // Check if route is excepted
        if (_isExcepted(request.url.path)) {
          return await handler(request);
        }

        // Extract and verify JWT token
        final token = _extractToken(request);

        if (token == null) {
          return Response(
            401,
            body: '{"error": "Unauthorized", "message": "No token provided"}',
            headers: {'Content-Type': 'application/json'},
          );
        }

        final jwt = JWT.verify(token, secret: jwtSecret);

        if (jwt == null || _isTokenExpired(jwt)) {
          return Response(
            401,
            body:
                '{"error": "Unauthorized", "message": "Invalid or expired token"}',
            headers: {'Content-Type': 'application/json'},
          );
        }

        // Add user data to request context
        final authContext = {
          'user': jwt.payload,
          'auth_token': token,
          'is_authenticated': true,
          'guard': 'jwt',
        };

        final updatedRequest = request.change(context: authContext);
        return await handler(updatedRequest);
      };
    };
  }

  @override
  Future<bool> check(Request request) async {
    final token = _extractToken(request);
    if (token == null) return false;

    final jwt = JWT.verify(token, secret: jwtSecret);
    return jwt != null && !_isTokenExpired(jwt);
  }

  @override
  Map<String, dynamic>? user(Request request) {
    return request.context['user'] as Map<String, dynamic>?;
  }

  String? _extractToken(Request request) {
    final authHeader = request.headers['Authorization'];

    if (authHeader == null) {
      return null;
    }

    if (authHeader.startsWith('Bearer ')) {
      return authHeader.substring(7);
    }

    return null;
  }

  bool _isTokenExpired(JWT jwt) {
    final exp = jwt.payload['exp'];
    if (exp == null) return false;

    final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expiryDate);
  }

  bool _isExcepted(String path) {
    return exceptRoutes.any((route) {
      // Simple wildcard matching
      if (route.endsWith('*')) {
        final prefix = route.substring(0, route.length - 1);
        return path.startsWith(prefix);
      }
      return path == route;
    });
  }
}

/// Session-based authentication guard
class SessionGuard implements Guard {
  final Map<String, Session> _sessions = {};
  final Duration sessionDuration;
  final List<String> exceptRoutes;
  final String sessionCookieName;

  SessionGuard({
    this.sessionDuration = const Duration(hours: 24),
    this.exceptRoutes = const [],
    this.sessionCookieName = 'dartian_session',
  });

  @override
  Middleware middleware() {
    return (Handler handler) {
      return (Request request) async {
        // Check if route is excepted
        if (_isExcepted(request.url.path)) {
          return await handler(request);
        }

        // Extract session ID from cookie
        final sessionId = _extractSessionId(request);

        if (sessionId == null) {
          return Response(
            401,
            body:
                '{"error": "Unauthorized", "message": "No session cookie found"}',
            headers: {'Content-Type': 'application/json'},
          );
        }

        // Verify session
        final session = _sessions[sessionId];

        if (session == null || session.isExpired) {
          // Remove expired session
          if (session != null) {
            _sessions.remove(sessionId);
          }

          return Response(
            401,
            body:
                '{"error": "Unauthorized", "message": "Invalid or expired session"}',
            headers: {'Content-Type': 'application/json'},
          );
        }

        // Add user data to request context
        final authContext = {
          'user': session.data,
          'session': session,
          'session_id': sessionId,
          'user_id': session.userId,
          'is_authenticated': true,
          'guard': 'session',
        };

        final updatedRequest = request.change(context: authContext);
        return await handler(updatedRequest);
      };
    };
  }

  @override
  Future<bool> check(Request request) async {
    final sessionId = _extractSessionId(request);
    if (sessionId == null) return false;

    final session = _sessions[sessionId];
    return session != null && !session.isExpired;
  }

  @override
  Map<String, dynamic>? user(Request request) {
    final session = request.context['session'] as Session?;
    return session?.data;
  }

  /// Create a new session
  String createSession(String userId, {Map<String, dynamic>? data}) {
    final session = Session.create(userId, sessionDuration);
    if (data != null) {
      final updatedSession = Session(
        id: session.id,
        userId: session.userId,
        createdAt: session.createdAt,
        expiresAt: session.expiresAt,
        data: data,
      );
      _sessions[session.id] = updatedSession;
      return session.id;
    }

    _sessions[session.id] = session;
    return session.id;
  }

  /// Destroy a session
  void destroySession(String sessionId) {
    _sessions.remove(sessionId);
  }

  /// Get session by ID
  Session? getSession(String sessionId) {
    return _sessions[sessionId];
  }

  String? _extractSessionId(Request request) {
    final cookieHeader = request.headers['cookie'];
    if (cookieHeader == null) return null;

    final cookies = cookieHeader.split(';');
    for (final cookie in cookies) {
      final parts = cookie.trim().split('=');
      if (parts.length == 2 && parts[0] == sessionCookieName) {
        return parts[1];
      }
    }

    return null;
  }

  bool _isExcepted(String path) {
    return exceptRoutes.any((route) {
      if (route.endsWith('*')) {
        final prefix = route.substring(0, route.length - 1);
        return path.startsWith(prefix);
      }
      return path == route;
    });
  }

  /// Clean up expired sessions (should be called periodically)
  void cleanupExpiredSessions() {
    _sessions.removeWhere((_, session) => session.isExpired);
  }
}
