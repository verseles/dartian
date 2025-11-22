# dartian_http

HTTP kernel for Dartian with middleware pipeline, CORS, CSRF protection - Built on Shelf.

## Features

- Shelf-based HTTP kernel
- Middleware pipeline
- CORS support
- CSRF protection
- Request/Response helpers

## Installation

```yaml
dependencies:
  dartian_http: ^1.0.0
```

## Usage

```dart
import 'package:dartian_http/dartian_http.dart';

// Create HTTP kernel
final kernel = HttpKernel();

// Add middleware
kernel.use(CorsMiddleware(
  allowOrigin: '*',
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE'],
));

kernel.use(CsrfMiddleware());

// Create handler
final handler = kernel.build((request) async {
  return Response.ok('Hello World');
});

// Start server
final server = await serve(handler, 'localhost', 8080);
print('Server running on http://localhost:8080');
```

## Part of Dartian

This package is part of the [Dartian](https://github.com/verseles/dartian) framework.

## License

AGPL-3.0 - See [LICENSE](LICENSE) for details.
