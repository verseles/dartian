import 'package:dartian_http/dartian_http.dart';
import 'package:dartian_router/dartian_router.dart';
import 'package:{{project_name}}/routes/web.dart' as web_routes;

void main() async {
  final router = Router();
  web_routes.register(router);

  final kernel = HttpKernel();
  await kernel.start(router.handler);
}
