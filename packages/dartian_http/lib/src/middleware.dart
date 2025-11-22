import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shelf/shelf.dart';
import 'package:dartian_i18n/dartian_i18n.dart';

/// Middleware for internationalization
Middleware i18nMiddleware({String defaultLocale = 'en'}) {
  return (Handler handler) {
    return (Request request) async {
      // Initialize i18n if not already done
      i18n.init(defaultLocale: defaultLocale);

      // Detect locale from Accept-Language header
      final acceptLanguage = request.headers['Accept-Language'];
      final detectedLocale = I18nUtils.detectFromHeader(acceptLanguage);

      if (detectedLocale != null) {
        i18n.setLocale(detectedLocale);
      }

      // Call next handler
      return await handler(request);
    };
  };
}

/// CORS Middleware for handling Cross-Origin Resource Sharing
///
/// Example usage:
/// ```dart
/// final handler = Pipeline()
///   .addMiddleware(corsMiddleware(
///     allowedOrigins: ['https://example.com', 'https://app.example.com'],
///     allowedMethods: ['GET', 'POST', 'PUT', 'DELETE'],
///   ))
///   .addHandler(router);
/// ```
Middleware corsMiddleware({
  List<String>? allowedOrigins,
  List<String> allowedMethods = const [
    'GET',
    'POST',
    'PUT',
    'DELETE',
    'PATCH',
    'OPTIONS',
  ],
  List<String> allowedHeaders = const [
    'Origin',
    'Content-Type',
    'Accept',
    'Authorization',
    'X-CSRF-Token',
  ],
  List<String> exposedHeaders = const [],
  bool allowCredentials = true,
  int maxAge = 86400, // 24 hours
}) {
  return (Handler handler) {
    return (Request request) async {
      final origin = request.headers['origin'];

      // Check if origin is allowed
      bool isOriginAllowed = false;
      if (allowedOrigins == null || allowedOrigins.isEmpty) {
        // In development, allow all origins
        isOriginAllowed = true;
      } else if (origin != null) {
        isOriginAllowed = allowedOrigins.any((allowed) {
          if (allowed == '*') return true;
          if (allowed.endsWith('*')) {
            final prefix = allowed.substring(0, allowed.length - 1);
            return origin.startsWith(prefix);
          }
          return origin == allowed;
        });
      }

      // Handle preflight OPTIONS request
      if (request.method == 'OPTIONS') {
        return Response.ok(
          null,
          headers: {
            if (isOriginAllowed && origin != null)
              'Access-Control-Allow-Origin': origin,
            'Access-Control-Allow-Methods': allowedMethods.join(', '),
            'Access-Control-Allow-Headers': allowedHeaders.join(', '),
            if (exposedHeaders.isNotEmpty)
              'Access-Control-Expose-Headers': exposedHeaders.join(', '),
            if (allowCredentials) 'Access-Control-Allow-Credentials': 'true',
            'Access-Control-Max-Age': maxAge.toString(),
          },
        );
      }

      // Process actual request
      final response = await handler(request);

      // Add CORS headers to response
      return response.change(
        headers: {
          if (isOriginAllowed && origin != null)
            'Access-Control-Allow-Origin': origin,
          if (exposedHeaders.isNotEmpty)
            'Access-Control-Expose-Headers': exposedHeaders.join(', '),
          if (allowCredentials) 'Access-Control-Allow-Credentials': 'true',
        },
      );
    };
  };
}

/// CSRF Protection Middleware using Double Submit Cookie pattern
///
/// Generates and validates CSRF tokens to prevent Cross-Site Request Forgery attacks.
///
/// Example usage:
/// ```dart
/// final csrfMiddleware = CsrfMiddleware(secretKey: 'your-secret-key-here');
/// final handler = Pipeline()
///   .addMiddleware(csrfMiddleware.middleware())
///   .addHandler(router);
/// ```
class CsrfMiddleware {
  final String secretKey;
  final String tokenName;
  final String cookieName;
  final Duration tokenExpiry;
  final List<String> safeMethods;

  CsrfMiddleware({
    required this.secretKey,
    this.tokenName = 'X-CSRF-Token',
    this.cookieName = 'XSRF-TOKEN',
    this.tokenExpiry = const Duration(hours: 24),
    this.safeMethods = const ['GET', 'HEAD', 'OPTIONS'],
  });

  /// Generates a cryptographically secure CSRF token
  String _generateToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final token = base64Url.encode(bytes);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Create HMAC signature to prevent tampering
    final payload = '$token:$timestamp';
    final hmac = Hmac(sha256, utf8.encode(secretKey));
    final signature = base64Url.encode(
      hmac.convert(utf8.encode(payload)).bytes,
    );

    return '$payload:$signature';
  }

  /// Validates CSRF token
  bool _validateToken(String token) {
    try {
      final parts = token.split(':');
      if (parts.length != 3) return false;

      final tokenValue = parts[0];
      final timestamp = int.parse(parts[1]);
      final signature = parts[2];

      // Check if token has expired
      final tokenAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (tokenAge > tokenExpiry.inMilliseconds) return false;

      // Verify HMAC signature
      final payload = '$tokenValue:$timestamp';
      final hmac = Hmac(sha256, utf8.encode(secretKey));
      final expectedSignature = base64Url.encode(
        hmac.convert(utf8.encode(payload)).bytes,
      );

      return signature == expectedSignature;
    } catch (e) {
      return false;
    }
  }

  /// Creates the CSRF middleware
  Middleware middleware() {
    return (Handler handler) {
      return (Request request) async {
        // Safe methods don't need CSRF protection
        if (safeMethods.contains(request.method.toUpperCase())) {
          final response = await handler(request);

          // Generate token for safe requests
          final token = _generateToken();

          // Add token to cookie for subsequent requests
          return response.change(
            headers: {
              'Set-Cookie':
                  '$cookieName=$token; Path=/; SameSite=Strict; HttpOnly',
            },
          );
        }

        // Validate CSRF token for unsafe methods
        final headerToken =
            request.headers[tokenName.toLowerCase()] ??
            request.headers[tokenName];
        final cookieToken = _extractTokenFromCookie(request.headers['cookie']);

        if (headerToken == null || cookieToken == null) {
          return Response.forbidden(
            json.encode({'error': 'CSRF token missing'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        if (headerToken != cookieToken) {
          return Response.forbidden(
            json.encode({'error': 'CSRF token mismatch'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        if (!_validateToken(headerToken)) {
          return Response.forbidden(
            json.encode({'error': 'Invalid or expired CSRF token'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // Token is valid, process request
        final response = await handler(request);

        // Rotate token after successful request
        final newToken = _generateToken();

        return response.change(
          headers: {
            'Set-Cookie':
                '$cookieName=$newToken; Path=/; SameSite=Strict; HttpOnly',
          },
        );
      };
    };
  }

  String? _extractTokenFromCookie(String? cookieHeader) {
    if (cookieHeader == null) return null;

    final cookies = cookieHeader.split(';');
    for (final cookie in cookies) {
      final trimmed = cookie.trim();
      if (trimmed.startsWith('$cookieName=')) {
        return trimmed.substring(cookieName.length + 1);
      }
    }

    return null;
  }
}
