import 'package:dartian_router/dartian_router.dart';
import '../app/http/controllers/health_controller.dart';

void webRoutes(Router router) {
  router.get<HealthController>('/health', (controller) => controller.health);
}
