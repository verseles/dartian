import 'package:dartian_router/dartian_router.dart';
import 'package:dartian_http/dartian_http.dart';

void register(Router router) {
  router.get('/', (Request request) {
    return Response.ok('Hello, Dartian!');
  });
}
