# Hello World Example

A simple Dartian web application demonstrating core framework features.

## Features Demonstrated

- **HTTP Kernel** - Basic HTTP server setup
- **Router** - URL routing with parameters
- **Dependency Injection** - Service registration and resolution
- **JSON Responses** - RESTful API endpoints

## Running the Example

```bash
# Navigate to this directory
cd examples/hello_world

# Install dependencies
dart pub get

# Run the server
dart run bin/server.dart
```

Then open http://localhost:8080 in your browser.

## Routes

| Method | Path | Description |
|--------|------|-------------|
| GET | `/` | Welcome page with HTML |
| GET | `/hello` | Simple text greeting |
| GET | `/hello/:name` | Personalized greeting |
| GET | `/time` | Current date and time |
| GET | `/json` | JSON response example |

## Project Structure

```
hello_world/
├── bin/
│   └── server.dart      # Application entry point
├── lib/
│   ├── hello_world.dart # Library exports
│   ├── services.dart    # Service classes
│   └── routes.dart      # Route definitions
├── pubspec.yaml         # Dependencies
└── README.md            # This file
```

## Code Highlights

### Dependency Injection

```dart
// Register a singleton (one instance shared)
container.registerSingleton<GreetingService>(() => GreetingService());

// Register a factory (new instance each time)
container.registerFactory<TimeService>(() => TimeService());

// Resolve dependencies
final greeting = container.get<GreetingService>();
```

### Routing

```dart
// Simple route
router.get('/hello', (request) {
  return Response.ok('Hello!');
});

// Route with parameter
router.get('/hello/:name', (request) {
  final name = request.params['name'];
  return Response.ok('Hello, $name!');
});

// JSON response
router.get('/json', (request) {
  return Response.json({'message': 'Hello!'});
});
```

## Next Steps

- Add middleware for logging or authentication
- Connect to a database with `dartian_orm`
- Add caching with `dartian_redis`
- Implement background jobs with `dartian_queue`
