import 'package:shelf/shelf.dart';
import 'dart:io';
import '../../session.dart';

Middleware sessionMiddleware(SessionManager sessionManager) {
  return (Handler innerHandler) {
    return (Request request) async {
      String? sessionId;
      if (request.headers.containsKey(HttpHeaders.cookieHeader)) {
        final cookies = request.headers[HttpHeaders.cookieHeader]!
            .split(';')
            .map((c) => c.trim())
            .where((c) => c.isNotEmpty)
            .map((c) {
              final parts = c.split('=');
              return MapEntry(parts[0], parts.length > 1 ? parts[1] : '');
            })
            .fold<Map<String, String>>({}, (map, entry) {
              map[entry.key] = entry.value;
              return map;
            });

        sessionId = cookies['dartian_session'];
      }

      final session = sessionManager.startSession(sessionId);

      final updatedRequest = request.change(context: {
        ...request.context,
        'dartian.session': session,
      });

      final response = await innerHandler(updatedRequest);

      return response.change(headers: {
        HttpHeaders.setCookieHeader:
            'dartian_session=${session.id}; HttpOnly; Path=/',
      });
    };
  };
}
