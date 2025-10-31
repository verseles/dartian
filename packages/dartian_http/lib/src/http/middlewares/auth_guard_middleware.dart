import 'package:shelf/shelf.dart';
import '../response.dart';
import '../../auth/jwt.dart';
import '../../auth/user.dart';
import '../../session.dart';

abstract class UserProvider {
  Future<User?> findById(int id);
}

Middleware authGuard({
  String guard = 'session',
  required UserProvider userProvider,
  JsonWebToken? jwt,
}) {
  return (Handler innerHandler) {
    return (Request request) async {
      int? userId;
      User? user;

      if (guard == 'session') {
        final session = request.context['dartian.session'] as Session?;
        if (session != null && session.has('user_id')) {
          userId = session.get('user_id') as int?;
        }
      } else if (guard == 'jwt') {
        final authHeader = request.headers['authorization'];
        if (authHeader != null && authHeader.startsWith('Bearer ')) {
          final token = authHeader.substring(7);
          final payload = jwt?.verify(token);
          if (payload != null && payload.containsKey('sub')) {
            userId = payload['sub'] as int?;
          }
        }
      }

      if (userId != null) {
        user = await userProvider.findById(userId);
      }

      if (user != null) {
        final updatedRequest = request.change(context: {
          ...request.context,
          'dartian.user': user,
        });
        return await innerHandler(updatedRequest);
      }

      return DartianResponse.json({'message': 'Unauthorized'}, status: 401);
    };
  };
}
