import 'dart:convert';

import 'package:dartian_di/dartian_di.dart';
import 'package:dartian_router/dartian_router.dart';
import 'package:shelf/shelf.dart';

import 'services.dart';

/// Registers all routes for the hello world example.
void registerRoutes(Router router, DIContainer container) {
  // Home page
  router.get('/', (Request request) {
    return Response.ok(
      _homePage(),
      headers: {'Content-Type': 'text/html'},
    );
  })
  // Simple hello
  .get('/hello', (Request request) {
    final greeting = container.get<GreetingService>();
    return Response.ok(greeting.hello());
  })
  // Current time (new TimeService instance each request)
  .get('/time', (Request request) {
    final time = container.get<TimeService>();
    return Response.ok(
      'Current time: ${time.currentTime()} on ${time.currentDate()}',
    );
  })
  // JSON response example
  .get('/json', (Request request) {
    final time = container.get<TimeService>();
    final body = jsonEncode({
      'message': 'Hello from Dartian!',
      'framework': 'Dartian',
      'version': '1.0.0',
      'time': time.currentTime(),
      'date': time.currentDate(),
    });
    return Response.ok(body, headers: {'Content-Type': 'application/json'});
  });

  // Personalized greeting with route parameter (using shelf_router directly)
  router.shelfRouter.get('/hello/<name>', (Request request, String name) {
    final greeting = container.get<GreetingService>();
    return Response.ok(greeting.greet(name));
  });
}

String _homePage() => '''
<!DOCTYPE html>
<html>
<head>
  <title>Dartian Hello World</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
      max-width: 800px;
      margin: 50px auto;
      padding: 20px;
      background: #f5f5f5;
    }
    h1 { color: #2196F3; }
    .card {
      background: white;
      border-radius: 8px;
      padding: 20px;
      margin: 20px 0;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    a {
      color: #2196F3;
      text-decoration: none;
    }
    a:hover { text-decoration: underline; }
    code {
      background: #e8e8e8;
      padding: 2px 6px;
      border-radius: 4px;
      font-size: 14px;
    }
    ul { line-height: 2; }
  </style>
</head>
<body>
  <h1>Welcome to Dartian!</h1>

  <div class="card">
    <h2>Hello World Example</h2>
    <p>This is a simple example demonstrating Dartian's core features:</p>
    <ul>
      <li><strong>HTTP Kernel</strong> - Serving this page</li>
      <li><strong>Router</strong> - Handling URL routes</li>
      <li><strong>Dependency Injection</strong> - Managing services</li>
    </ul>
  </div>

  <div class="card">
    <h2>Try These Routes</h2>
    <ul>
      <li><a href="/hello">/hello</a> - Simple greeting</li>
      <li><a href="/hello/Dartian">/hello/Dartian</a> - Personalized greeting</li>
      <li><a href="/hello/World">/hello/World</a> - Another greeting</li>
      <li><a href="/time">/time</a> - Current time</li>
      <li><a href="/json">/json</a> - JSON response</li>
    </ul>
  </div>

  <div class="card">
    <h2>Learn More</h2>
    <p>
      Visit the <a href="https://github.com/verseles/dartian">Dartian GitHub repository</a>
      for documentation and more examples.
    </p>
  </div>
</body>
</html>
''';
