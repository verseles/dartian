import 'container.dart';
import 'service_provider.dart';

/// Base class for DI modules
/// Modules are used to group related service registrations
abstract class DIModule {
  /// Register services provided by this module
  void register(DIContainer container);

  /// Get all service providers from this module
  List<ServiceProvider> providers() {
    return [];
  }
}

/// A simple module implementation
class SimpleModule extends DIModule {
  final void Function(DIContainer) _registerFn;

  SimpleModule(this._registerFn);

  @override
  void register(DIContainer container) {
    _registerFn(container);
  }
}

/// Extension to make module usage easier
extension DIModuleExtension on DIModule {
  /// Convert a function to a module
  static DIModule create(void Function(DIContainer) registerFn) {
    return SimpleModule(registerFn);
  }
}
