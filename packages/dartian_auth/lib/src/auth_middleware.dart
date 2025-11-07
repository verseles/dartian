import 'package:shelf/shelf.dart';
import 'jwt.dart';

/// Authentication middleware
class AuthMiddleware {
  final String? jwtSecret;

  AuthMiddleware({this.jwtSecret});

  /// Middleware function for request handling
  Middleware get middleware {
    return (Handler handler) {
      return (Request request) async {
        try {
          // Extract token from Authorization header
          final token = _extractToken(request);

          Map<String, dynamic> authContext = {};
          authContext['is_authenticated'] = false;

          if (token != null) {
            // Verify JWT token
            final jwt = JWT.verify(token, secret: jwtSecret);

            if (jwt != null) {
              authContext['user'] = jwt.payload;
              authContext['auth_token'] = token;
              authContext['is_authenticated'] = true;
            }
          }

          // Add auth context to request
          final updatedRequest = request.change(context: authContext);

          return await handler(updatedRequest);
        } catch (e) {
          // Error in authentication
          final authContext = {
            'is_authenticated': false,
            'auth_error': e.toString(),
          };

          final updatedRequest = request.change(context: authContext);
          return await handler(updatedRequest);
        }
      };
    };
  }

  /// Extract token from Authorization header
  String? _extractToken(Request request) {
    final authHeader = request.headers['Authorization'];

    if (authHeader == null) {
      return null;
    }

    // Check for Bearer token
    if (authHeader.startsWith('Bearer ')) {
      return authHeader.substring(7);
    }

    return null;
  }
}

/// Extension for easy access to auth data
extension AuthContext on Request {
  /// Check if user is authenticated
  bool get isAuthenticated {
    return context['is_authenticated'] as bool? ?? false;
  }

  /// Get current user data
  Map<String, dynamic>? get user {
    return context['user'] as Map<String, dynamic>?;
  }

  /// Get current user ID
  String? get userId {
    return user?['id']?.toString();
  }

  /// Get authentication token
  String? get authToken {
    return context['auth_token'] as String?;
  }
}
