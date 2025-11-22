# dartian_di

Dependency injection container for Dartian with auto-discovery annotations and cycle detection.

## Features

- Service container powered by get_it
- Auto-discovery annotations: `@Singleton`, `@Service`, `@LazySingleton`
- Named dependencies with `@Named`
- Module support with `@Module` and `@Provides`
- Circular dependency detection
- Code generation support

## Installation

```yaml
dependencies:
  dartian_di: ^1.0.0
```

## Usage

### Basic Registration

```dart
import 'package:dartian_di/dartian_di.dart';

final container = DIContainer();

// Singleton (one instance)
container.registerSingleton<DatabaseService>(() => DatabaseService());

// Factory (new instance each time)
container.registerFactory<RequestHandler>(() => RequestHandler());

// Lazy singleton (created on first access)
container.registerLazySingleton<CacheService>(() => CacheService());

// Get services
final db = container.get<DatabaseService>();
```

### Annotations for Auto-Discovery

```dart
@Singleton()
class DatabaseService { }

@Service()
class UserRepository { }

@LazySingleton()
class ExpensiveService { }

@Singleton(name: 'primary')
class PrimaryDatabase { }
```

### Cycle Detection

```dart
// Detect circular dependencies at registration time
container.registerSingletonWithDeps<ServiceA>(
  () => ServiceA(),
  dependsOn: [ServiceB], // Will throw if B depends on A
);
```

## Part of Dartian

This package is part of the [Dartian](https://github.com/verseles/dartian) framework.

## License

AGPL-3.0 - See [LICENSE](LICENSE) for details.
