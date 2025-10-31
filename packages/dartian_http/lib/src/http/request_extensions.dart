import 'package:shelf/shelf.dart';
import '../session.dart';
import '../auth/user.dart';

extension RequestExtensions on Request {
  Session? get session => context['dartian.session'] as Session?;
  User? get user => context['dartian.user'] as User?;
}
