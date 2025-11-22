# Dartian

A Laravel-inspired web framework for Dart - HTTP, routing, DI, ORM, auth, queues, and more.

## Features

- **HTTP Kernel**: Built on Shelf with middleware support
- **Routing**: Fluent DSL with groups, prefixes, and named routes
- **Dependency Injection**: Auto-discovery with annotations
- **ORM**: Drift-based with SQLite and PostgreSQL support
- **Redis**: Caching and pub/sub
- **Queues**: Background job processing
- **Scheduler**: Cron-based task scheduling
- **Views**: Mustache templates with SSR
- **i18n**: Multi-language support
- **Auth**: Session, JWT, and password hashing

## Installation

```yaml
dependencies:
  dartian: ^1.0.0
```

Or install individual packages:

```yaml
dependencies:
  dartian_http: ^1.0.0
  dartian_router: ^1.0.0
  dartian_di: ^1.0.0
```

## Quick Start

```dart
import 'package:dartian/dartian.dart';
import 'package:shelf/shelf_io.dart' as io;

void main() async {
  // Create router
  final router = Router();
  
  router
    .get('/', (request) => Response.ok('Hello, Dartian!'))
    .get('/users', (request) => Response.ok('Users list'));
  
  router.group('/api', (api) {
    api.get('/status', (request) => Response.ok('OK'));
  });
  
  // Create HTTP kernel with middleware
  final kernel = HttpKernel();
  kernel.use(CorsMiddleware(allowOrigin: '*'));
  
  final handler = kernel.build(router.handler);
  
  // Start server
  final server = await io.serve(handler, 'localhost', 8080);
  print('Server running on http://localhost:${server.port}');
}
```

## Documentation

See the [GitHub repository](https://github.com/verseles/dartian) for full documentation.

## Packages

| Package | Description |
|---------|-------------|
| [dartian_core](https://pub.dev/packages/dartian_core) | Core utilities |
| [dartian_http](https://pub.dev/packages/dartian_http) | HTTP kernel |
| [dartian_router](https://pub.dev/packages/dartian_router) | Routing |
| [dartian_di](https://pub.dev/packages/dartian_di) | Dependency injection |
| [dartian_orm](https://pub.dev/packages/dartian_orm) | ORM |
| [dartian_redis](https://pub.dev/packages/dartian_redis) | Redis |
| [dartian_queue](https://pub.dev/packages/dartian_queue) | Job queues |
| [dartian_scheduler](https://pub.dev/packages/dartian_scheduler) | Scheduler |
| [dartian_view](https://pub.dev/packages/dartian_view) | Views |
| [dartian_i18n](https://pub.dev/packages/dartian_i18n) | i18n |
| [dartian_auth](https://pub.dev/packages/dartian_auth) | Auth |
| [dartian_console](https://pub.dev/packages/dartian_console) | CLI |

## License

AGPL-3.0 - See [LICENSE](LICENSE) for details.
