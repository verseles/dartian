# Dartian

A Laravel-inspired web framework for Dart, designed for high-performance production deployments.

[![CI](https://github.com/verseles/dartian/actions/workflows/ci.yml/badge.svg)](https://github.com/verseles/dartian/actions/workflows/ci.yml)
[![pub package](https://img.shields.io/pub/v/dartian_core.svg)](https://pub.dev/packages/dartian_core)
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

## Features

- **HTTP Kernel** - Built on Shelf with middleware pipeline
- **Fluent Router** - Laravel-style routing with groups, prefixes, and middleware
- **Dependency Injection** - Auto-discovery with `@Singleton`, `@Service`, cycle detection
- **ORM** - Drift-based with relationships, migrations, and query builder
- **Redis** - Caching, pub/sub, and distributed locks
- **Queue System** - Sync, Isolate, and Redis-backed job processing
- **Task Scheduler** - Cron-based scheduling with timezone support
- **Authentication** - Session and JWT with bcrypt password hashing
- **Views** - Server-side rendering with Mustache templates
- **i18n** - Full internationalization support
- **CLI** - Artisan-like command interface with code generation

## Quick Start

### Installation

**Option 1: Single import (umbrella package)**
```yaml
dependencies:
  dartian: ^1.0.0  # Coming soon - use individual packages for now
```

**Option 2: Individual packages**
```yaml
dependencies:
  dartian_http: ^1.0.0
  dartian_router: ^1.0.0
  dartian_di: ^1.0.0
  # Add others as needed
```

**CLI Tool:**
```bash
dart pub global activate dartian_console
dartian new my_app
cd my_app
```

### Create a Simple Server

```dart
import 'package:dartian_http/dartian_http.dart';
import 'package:dartian_router/dartian_router.dart';

void main() async {
  final router = Router();

  router.get('/', (request) {
    return Response.ok('Hello, Dartian!');
  });

  router.get('/users/:id', (request) {
    final id = request.params['id'];
    return Response.json({'user': id});
  });

  final kernel = HttpKernel(router: router);
  await kernel.serve(port: 8080);

  print('Server running at http://localhost:8080');
}
```

### Dependency Injection

```dart
import 'package:dartian_di/dartian_di.dart';

// Annotations for auto-discovery
@Singleton()
class DatabaseService {
  Future<void> connect() async { /* ... */ }
}

@Service()
class UserRepository {
  final DatabaseService db;
  UserRepository(this.db);
}

@LazySingleton()
class CacheService {
  // Created on first access
}

// Manual registration with cycle detection
void main() {
  final container = DIContainer();

  container.registerSingletonWithDeps<DatabaseService>(
    () => DatabaseService(),
    dependsOn: [],
  );

  container.registerSingletonWithDeps<UserRepository>(
    () => UserRepository(container.get<DatabaseService>()),
    dependsOn: [DatabaseService],
  );

  // Circular dependencies are detected and throw CircularDependencyException
}
```

### ORM with Drift

```dart
import 'package:dartian_orm/dartian_orm.dart';

// Define a model
class User extends Model {
  String? name;
  String? email;

  @override
  Map<String, dynamic> toMap() => {'name': name, 'email': email};

  @override
  void fromMap(Map<String, dynamic> map) {
    name = map['name'];
    email = map['email'];
  }
}

// Use the repository
void main() async {
  final db = DartianDatabase.memory();
  final users = ModelRepository<User>(db);

  // Create
  final user = User()..name = 'John'..email = 'john@example.com';
  await user.save();

  // Query
  final allUsers = await users.all();
  final john = await users.find(1);
  final admins = await users.where('role', '=', 'admin');
}
```

### Redis & Caching

```dart
import 'package:dartian_redis/dartian_redis.dart';

void main() async {
  final redis = RedisClient();
  await redis.connect('localhost', 6379);

  // Caching
  await redis.set('key', 'value', expireIn: Duration(minutes: 5));
  final value = await redis.get('key');

  // Pub/Sub
  await redis.subscribe('channel', (message) {
    print('Received: $message');
  });
  await redis.publish('channel', 'Hello!');

  // Distributed Locks
  final lock = await redis.acquireLock('my-lock', timeout: Duration(seconds: 30));
  try {
    // Critical section
  } finally {
    await lock.release();
  }
}
```

### Queue System

```dart
import 'package:dartian_queue/dartian_queue.dart';

// Define a job
class SendEmailJob extends Job {
  final String email;
  final String subject;

  SendEmailJob(this.email, this.subject);

  @override
  Future<void> handle() async {
    // Send the email
    print('Sending email to $email: $subject');
  }

  @override
  Map<String, dynamic> toMap() => {'email': email, 'subject': subject};
}

void main() async {
  final queue = QueueManager();

  // Dispatch a job
  await queue.dispatch(SendEmailJob('user@example.com', 'Welcome!'));

  // Process jobs
  await queue.work();
}
```

### Task Scheduling

```dart
import 'package:dartian_scheduler/dartian_scheduler.dart';

void main() {
  final scheduler = Scheduler();

  // Run every minute
  scheduler.call(() => print('Tick!')).everyMinute();

  // Run daily at midnight
  scheduler.call(() => cleanupLogs()).dailyAt('00:00');

  // Run with cron expression
  scheduler.call(() => sendReports()).cron('0 9 * * MON');

  scheduler.start();
}
```

## Packages

All packages are available on [pub.dev](https://pub.dev/publishers/verseles.com/packages):

| Package | Version | Description |
|---------|---------|-------------|
| [dartian_core](https://pub.dev/packages/dartian_core) | [![pub](https://img.shields.io/pub/v/dartian_core.svg)](https://pub.dev/packages/dartian_core) | Core utilities and telemetry |
| [dartian_http](https://pub.dev/packages/dartian_http) | [![pub](https://img.shields.io/pub/v/dartian_http.svg)](https://pub.dev/packages/dartian_http) | HTTP kernel with Shelf integration |
| [dartian_router](https://pub.dev/packages/dartian_router) | [![pub](https://img.shields.io/pub/v/dartian_router.svg)](https://pub.dev/packages/dartian_router) | Fluent routing DSL |
| [dartian_di](https://pub.dev/packages/dartian_di) | [![pub](https://img.shields.io/pub/v/dartian_di.svg)](https://pub.dev/packages/dartian_di) | Dependency injection with auto-discovery |
| [dartian_orm](https://pub.dev/packages/dartian_orm) | [![pub](https://img.shields.io/pub/v/dartian_orm.svg)](https://pub.dev/packages/dartian_orm) | Drift-based ORM |
| [dartian_redis](https://pub.dev/packages/dartian_redis) | [![pub](https://img.shields.io/pub/v/dartian_redis.svg)](https://pub.dev/packages/dartian_redis) | Redis client with pub/sub and locks |
| [dartian_queue](https://pub.dev/packages/dartian_queue) | [![pub](https://img.shields.io/pub/v/dartian_queue.svg)](https://pub.dev/packages/dartian_queue) | Job queue system |
| [dartian_scheduler](https://pub.dev/packages/dartian_scheduler) | [![pub](https://img.shields.io/pub/v/dartian_scheduler.svg)](https://pub.dev/packages/dartian_scheduler) | Task scheduling |
| [dartian_view](https://pub.dev/packages/dartian_view) | [![pub](https://img.shields.io/pub/v/dartian_view.svg)](https://pub.dev/packages/dartian_view) | Mustache template engine |
| [dartian_i18n](https://pub.dev/packages/dartian_i18n) | [![pub](https://img.shields.io/pub/v/dartian_i18n.svg)](https://pub.dev/packages/dartian_i18n) | Internationalization |
| [dartian_auth](https://pub.dev/packages/dartian_auth) | [![pub](https://img.shields.io/pub/v/dartian_auth.svg)](https://pub.dev/packages/dartian_auth) | Authentication (session + JWT) |
| [dartian_console](https://pub.dev/packages/dartian_console) | [![pub](https://img.shields.io/pub/v/dartian_console.svg)](https://pub.dev/packages/dartian_console) | CLI with code generators |

## CLI Commands

```bash
# Project management
dartian new <project>        # Create new project
dartian serve                # Start dev server with hot reload

# Code generation
dartian make:controller <name>
dartian make:model <name>
dartian make:migration <name>
dartian make:request <name>
dartian make:provider <name>
dartian make:view <name>
dartian make:test <name>

# Database
dartian migrate              # Run migrations
dartian migrate:rollback     # Rollback last migration

# Background processing
dartian queue:work           # Start queue worker
dartian schedule:run         # Start scheduler

# Build
dartian build exe            # Build AOT executable
dartian build aot-snapshot   # Build AOT snapshot
```

## Requirements

- Dart SDK >= 3.9.4
- Redis (optional, for caching/queues)
- PostgreSQL or SQLite (for ORM)

## Development

```bash
# Run tests for all packages
for dir in packages/*/; do
  (cd "$dir" && dart test)
done

# Run analysis
for dir in packages/*/; do
  (cd "$dir" && dart analyze lib/)
done

# Format code
dart format packages/
```

## Architecture

Dartian follows a modular monorepo architecture:

```
dartian/
├── packages/
│   ├── dartian/             # Umbrella package (re-exports all)
│   ├── dartian_console/     # CLI tool
│   ├── dartian_core/        # Core utilities
│   ├── dartian_http/        # HTTP layer
│   ├── dartian_router/      # Routing
│   ├── dartian_di/          # Dependency injection
│   ├── dartian_orm/         # Database ORM
│   ├── dartian_redis/       # Redis client
│   ├── dartian_queue/       # Job queues
│   ├── dartian_scheduler/   # Task scheduling
│   ├── dartian_view/        # Template engine
│   ├── dartian_i18n/        # i18n support
│   └── dartian_auth/        # Authentication
├── examples/                # Example projects
└── scripts/                 # Build scripts
```

## License

This project is licensed under the AGPLv3 License - see the [LICENSE](LICENSE) file for details.

Commercial licensing is available for organizations that cannot use AGPL. Contact us for details.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Acknowledgments

- Inspired by [Laravel](https://laravel.com/)
- Built on [Shelf](https://pub.dev/packages/shelf)
- ORM powered by [Drift](https://pub.dev/packages/drift)
- DI powered by [get_it](https://pub.dev/packages/get_it)
