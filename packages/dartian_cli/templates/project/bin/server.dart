import 'package:dartian_http/dartian_http.dart';
import 'package:dartian_router/dartian_router.dart';
import 'package:{{project_name}}/routes/web.dart' as web_routes;
import 'package:shelf/shelf_io.dart' as shelf_io;

void main() async {
  final router = Router();
  web_routes.register(router);

  final kernel = HttpKernel()..addMiddleware(logRequests());

  final server = await shelf_io.serve(
    kernel.handler(router.handler),
    'localhost',
    8080,
  );

  print('Server listening on port ${server.port}');
}
