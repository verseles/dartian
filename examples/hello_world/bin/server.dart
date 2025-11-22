import 'dart:io';

import 'package:dartian_di/dartian_di.dart';
import 'package:dartian_http/dartian_http.dart';
import 'package:dartian_router/dartian_router.dart';
import 'package:hello_world/routes.dart';
import 'package:hello_world/services.dart';

void main() async {
  // Initialize dependency injection container
  final container = DIContainer()
    ..registerSingleton<GreetingService>(GreetingService.new)
    ..registerFactory<TimeService>(TimeService.new);

  // Create router and register routes
  final router = Router();
  registerRoutes(router, container);

  // Create HTTP kernel and set handler
  final kernel = HttpKernel()..setHandler(router.shelfRouter.call);

  // Start server
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  await kernel.listen('localhost', port);

  print('');
  print('  Dartian Hello World Example');
  print('  ============================');
  print('');
  print('  Available routes:');
  print('    GET  /              - Welcome page');
  print('    GET  /hello         - Simple greeting');
  print('    GET  /hello/<name>  - Personalized greeting');
  print('    GET  /time          - Current time');
  print('    GET  /json          - JSON response');
  print('');
  print('  Press Ctrl+C to stop');
  print('');
}
