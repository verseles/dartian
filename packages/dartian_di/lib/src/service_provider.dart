import 'container.dart';

/// Base class for service providers
/// Service providers are used to register services with the container
abstract class ServiceProvider {
  /// Register services with the container
  void register(DIContainer container);

  /// Bootstrap the provider (called after registration)
  Future<void> boot(DIContainer container) async {}
}
