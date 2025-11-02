import 'package:dartian_http/dartian_http.dart';
import 'package:dartian_router/dartian_router.dart';
import 'package:dartian_di/dartian_di.dart';
import '../routes/web.dart';
import '../app/http/controllers/health_controller.dart';

void main() async {
  final container = Container();
  container.singleton<HealthController>(HealthController());

  final router = Router(container: container);
  webRoutes(router);

  final kernel = HttpKernel();
  await kernel.start(router.handler);
}
