import 'package:get_it/get_it.dart';

/// Dartian Dependency Injection Container
/// Wraps get_it to provide a simpler API
class DIContainer {
  final GetIt _getIt = GetIt.instance;

  /// Register a singleton service
  /// [T] - Service type
  /// [factory] - Factory function to create the service
  /// [instanceName] - Optional name for the service instance
  void registerSingleton<T extends Object>(
    T Function() factory, {
    String? instanceName,
  }) {
    _getIt.registerSingleton<T>(factory(), instanceName: instanceName);
  }

  /// Register a factory service (new instance each time)
  /// [T] - Service type
  /// [factory] - Factory function to create the service
  /// [instanceName] - Optional name for the service instance
  void registerFactory<T extends Object>(
    T Function() factory, {
    String? instanceName,
  }) {
    _getIt.registerFactory<T>(factory, instanceName: instanceName);
  }

  /// Register an async singleton service
  /// [T] - Service type
  /// [factory] - Async factory function to create the service
  /// [instanceName] - Optional name for the service instance
  void registerSingletonAsync<T extends Object>(
    Future<T> Function() factory, {
    String? instanceName,
  }) {
    _getIt.registerSingletonAsync<T>(factory, instanceName: instanceName);
  }

  /// Get a service from the container
  /// [T] - Service type
  /// [instanceName] - Optional name for the service instance
  T get<T extends Object>({String? instanceName}) {
    return _getIt.get<T>(instanceName: instanceName);
  }

  /// Get an async service from the container
  /// [T] - Service type
  /// [instanceName] - Optional name for the service instance
  Future<T> getAsync<T extends Object>({String? instanceName}) {
    return _getIt.getAsync<T>(instanceName: instanceName);
  }

  /// Check if a service is registered
  /// [T] - Service type
  /// [instanceName] - Optional name for the service instance
  bool isRegistered<T extends Object>({String? instanceName}) {
    return _getIt.isRegistered<T>(instanceName: instanceName);
  }

  /// Reset the container (unregister all services)
  Future<void> reset() {
    return _getIt.reset();
  }

  /// Check if GetIt is ready (for async singletons)
  Future<void> ready() {
    return _getIt.allReady();
  }
}
