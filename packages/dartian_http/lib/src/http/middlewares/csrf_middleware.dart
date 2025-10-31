import 'package:shelf/shelf.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import '../response.dart';
import '../../session.dart';

Middleware csrfMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final session = request.context['dartian.session'] as Session?;
      if (session == null) {
        // CSRF protection requires a session.
        return await innerHandler(request);
      }

      if (!session.has('_csrf_token')) {
        session.set('_csrf_token', _generateToken());
      }
      final token = session.get('_csrf_token') as String;

      if (['POST', 'PUT', 'PATCH', 'DELETE'].contains(request.method)) {
        final requestToken = request.headers['x-csrf-token'] ?? (await request.readAsString());

        if (requestToken != token) {
          return DartianResponse.json({'message': 'CSRF token mismatch'}, status: 403);
        }
      }

      return await innerHandler(request);
    };
  };
}

String _generateToken() {
  final random = Random.secure();
  final bytes = List<int>.generate(32, (_) => random.nextInt(256));
  return base64Url.encode(bytes);
}
