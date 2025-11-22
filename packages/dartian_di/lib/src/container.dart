import 'package:get_it/get_it.dart';

/// Exception thrown when a circular dependency is detected
class CircularDependencyException implements Exception {
  final List<Type> cycle;
  final String message;

  CircularDependencyException(this.cycle)
    : message =
          'Circular dependency detected: ${cycle.map((t) => t.toString()).join(' → ')} → ${cycle.first}';

  @override
  String toString() => message;
}

/// Dartian Dependency Injection Container
/// Wraps get_it to provide a simpler API with cycle detection
class DIContainer {
  final GetIt _getIt = GetIt.instance;

  /// Tracks dependencies for cycle detection
  /// Key: Service type, Value: List of types it depends on
  final Map<Type, Set<Type>> _dependencyGraph = {};

  /// Track services currently being resolved (for runtime cycle detection)
  final Set<Type> _resolvingStack = {};

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

  /// Register a lazy singleton service (created on first access)
  /// [T] - Service type
  /// [factory] - Factory function to create the service
  /// [instanceName] - Optional name for the service instance
  void registerLazySingleton<T extends Object>(
    T Function() factory, {
    String? instanceName,
  }) {
    _getIt.registerLazySingleton<T>(factory, instanceName: instanceName);
  }

  /// Unregister a service
  /// [T] - Service type
  /// [instanceName] - Optional name for the service instance
  void unregister<T extends Object>({String? instanceName}) {
    _getIt.unregister<T>(instanceName: instanceName);
    _dependencyGraph.remove(T);
  }

  /// Register dependencies for a service (for cycle detection)
  /// [T] - Service type
  /// [dependencies] - List of types that T depends on
  void registerDependencies<T extends Object>(List<Type> dependencies) {
    _dependencyGraph[T] = dependencies.toSet();
    _validateNoCycles(T);
  }

  /// Check if adding a dependency would create a cycle
  /// Returns the cycle path if found, null otherwise
  List<Type>? detectCycle<T extends Object>(Type dependency) {
    final visited = <Type>{};
    final path = <Type>[T];

    bool hasCycle(Type current) {
      if (current == T) return true;
      if (visited.contains(current)) return false;

      visited.add(current);
      path.add(current);

      final deps = _dependencyGraph[current] ?? {};
      for (final dep in deps) {
        if (hasCycle(dep)) return true;
      }

      path.removeLast();
      return false;
    }

    if (hasCycle(dependency)) {
      return path;
    }
    return null;
  }

  /// Validate that no cycles exist starting from the given type
  void _validateNoCycles(Type startType) {
    final visited = <Type>{};
    final recursionStack = <Type>{};
    final path = <Type>[];

    bool dfs(Type current) {
      visited.add(current);
      recursionStack.add(current);
      path.add(current);

      final dependencies = _dependencyGraph[current] ?? {};
      for (final dep in dependencies) {
        if (!visited.contains(dep)) {
          if (dfs(dep)) return true;
        } else if (recursionStack.contains(dep)) {
          // Found a cycle - build the cycle path
          final cycleStart = path.indexOf(dep);
          final cycle = path.sublist(cycleStart)..add(dep);
          throw CircularDependencyException(cycle);
        }
      }

      recursionStack.remove(current);
      path.removeLast();
      return false;
    }

    dfs(startType);
  }

  /// Get the dependency graph for debugging/visualization
  Map<Type, Set<Type>> get dependencyGraph =>
      Map.unmodifiable(_dependencyGraph);

  /// Check if a type has any registered dependencies
  bool hasDependencies<T extends Object>() => _dependencyGraph.containsKey(T);

  /// Get dependencies for a type
  Set<Type> getDependencies<T extends Object>() =>
      _dependencyGraph[T] ?? <Type>{};

  /// Clear dependency tracking (useful for testing)
  void clearDependencyGraph() {
    _dependencyGraph.clear();
    _resolvingStack.clear();
  }

  /// Register a singleton with explicit dependencies for cycle detection
  void registerSingletonWithDeps<T extends Object>(
    T Function() factory, {
    String? instanceName,
    List<Type> dependsOn = const [],
  }) {
    registerDependencies<T>(dependsOn);
    registerSingleton<T>(factory, instanceName: instanceName);
  }

  /// Register a factory with explicit dependencies for cycle detection
  void registerFactoryWithDeps<T extends Object>(
    T Function() factory, {
    String? instanceName,
    List<Type> dependsOn = const [],
  }) {
    registerDependencies<T>(dependsOn);
    registerFactory<T>(factory, instanceName: instanceName);
  }

  /// Register a lazy singleton with explicit dependencies for cycle detection
  void registerLazySingletonWithDeps<T extends Object>(
    T Function() factory, {
    String? instanceName,
    List<Type> dependsOn = const [],
  }) {
    registerDependencies<T>(dependsOn);
    registerLazySingleton<T>(factory, instanceName: instanceName);
  }
}
