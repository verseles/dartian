# dartian_router

Fluent routing DSL for Dartian with groups, prefixes, and named routes - built on shelf_router.

## Features

- Fluent chainable API
- Route groups with prefixes
- Named routes
- All HTTP methods (GET, POST, PUT, DELETE)
- Built on top of shelf_router

## Installation

```yaml
dependencies:
  dartian_router: ^1.0.0
```

## Usage

```dart
import 'package:dartian_router/dartian_router.dart';

final router = Router();

// Simple routes
router
  .get('/', (request) => Response.ok('Home'))
  .get('/about', (request) => Response.ok('About'))
  .post('/users', (request) => Response.ok('Create user'));

// Route with parameters
router.shelfRouter.get('/users/<id>', (request, String id) {
  return Response.ok('User: $id');
});

// Named routes
router.get('/profile', handler, name: 'profile');
final url = router.getRoute('profile'); // '/profile'

// Route groups
router.group('/api', (api) {
  api.get('/users', usersHandler);
  api.get('/posts', postsHandler);
});
// Creates: /api/users, /api/posts
```

## Part of Dartian

This package is part of the [Dartian](https://github.com/verseles/dartian) framework.

## License

AGPL-3.0 - See [LICENSE](LICENSE) for details.
