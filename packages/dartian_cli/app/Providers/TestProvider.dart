import 'package:dartian_di/dartian_di.dart';

class TestProvider extends ServiceProvider {
  @override
  Future<void> register() async {
    // Register services into the container
    // Example:
    // container.singleton<MyService>(() => MyService());
    // container.register<MyRepository>(() => MyRepositoryImpl());
  }

  @override
  Future<void> boot() async {
    // Bootstrap services after all providers are registered
    // This is called after all register() methods have been called
    // Use this to set up event listeners, configure services, etc.
  }
}
