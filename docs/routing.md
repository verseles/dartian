# Routing in Dartian

The Dartian routing engine provides a simple, fluent, and expressive API for defining the endpoints of your application. All web routes are defined in the `routes/web.dart` file.

## Basic Routing

The most basic route accepts a path and a handler. The handler is a function that receives a `DartianRequest` object and must return a `DartianResponse`.

```dart
// routes/web.dart
import 'package:dartian_router/dartian_router.dart';
import 'package:dartian_http/dartian_http.dart';

void register(Router router) {
  router.get('/', (DartianRequest request) {
    return DartianResponse.text('Hello, World!');
  });

  router.post('/users', (DartianRequest request) {
    // Logic to create a user...
    return DartianResponse.json({'status': 'success'});
  });
}
```

### Available Router Methods

The router provides methods for all standard HTTP verbs:

```dart
router.get(path, handler);
router.post(path, handler);
router.put(path, handler);
router.patch(path, handler);
router.delete(path, handler);
```

## Route Parameters

Sometimes you will need to capture segments of the URI within your route. For example, you may need to capture a user's ID from the URL. You can do so by defining route parameters:

```dart
router.get('/users/<id>', (DartianRequest request) {
  final String id = request.param('id');
  return DartianResponse.text('User ID: $id');
});
```

Parameters are wrapped in `<...>` and are passed to the handler via the `request.param()` method.

## Named Routes

Named routes allow you to conveniently generate URLs for specific routes. You can specify a name for a route by chaining the `name` method onto the route definition:

```dart
router.get('/users/profile', (DartianRequest request) {
  // ...
}, name: 'profile');
```

You can then generate URLs to this route using the `route()` helper:

```dart
// In a controller or another part of your application...
String profileUrl = router.route('profile'); // /users/profile
```

If the named route defines parameters, you can pass them as a map to the `route` method:

```dart
router.get('/users/<id>', handler, name: 'user.show');

String userUrl = router.route('user.show', {'id': '123'}); // /users/123
```

## Route Groups

Route groups allow you to share route attributes, such as a common prefix, across a large number of routes without needing to define those attributes on each individual route.

```dart
router.group('/api', (router) {
  router.get('/users', (DartianRequest request) {
    // Handles /api/users
  });

  router.get('/posts', (DartianRequest request) {
    // Handles /api/posts
  });
});
```

You can also nest groups for more complex routing structures.
