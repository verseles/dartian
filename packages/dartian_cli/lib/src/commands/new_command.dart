import 'dart:io';

class NewCommand {
  Future<void> run(List<String> arguments) async {
    if (arguments.isEmpty) {
      print('Error: Project name is required');
      print('Usage: dartian new <project-name>');
      return;
    }

    final projectName = arguments[0];

    // Validate project name
    if (!_isValidProjectName(projectName)) {
      print('Error: Invalid project name "$projectName"');
      print('Project name must start with a letter and contain only letters, numbers, and underscores');
      return;
    }

    final projectDir = Directory(projectName);

    // Check if directory already exists
    if (projectDir.existsSync()) {
      print('Error: Directory "$projectName" already exists');
      return;
    }

    print('🚀 Creating Dartian project: $projectName');
    print('');

    try {
      // Create project structure
      await _createProjectStructure(projectName);

      // Generate files
      await _generateFiles(projectName);

      print('');
      print('✅ Project created successfully!');
      print('');
      print('Next steps:');
      print('  cd $projectName');
      print('  dart pub get');
      print('  dartian serve');
      print('');
    } catch (e) {
      print('❌ Error creating project: $e');
      // Cleanup on error
      if (projectDir.existsSync()) {
        projectDir.deleteSync(recursive: true);
      }
      rethrow;
    }
  }

  bool _isValidProjectName(String name) {
    final regex = RegExp(r'^[a-z][a-z0-9_]*$');
    return regex.hasMatch(name);
  }

  Future<void> _createProjectStructure(String projectName) async {
    final directories = [
      '$projectName/app/Http/Controllers',
      '$projectName/app/Http/Middleware',
      '$projectName/app/Http/Requests',
      '$projectName/app/Models',
      '$projectName/app/Providers',
      '$projectName/config',
      '$projectName/database/migrations',
      '$projectName/public',
      '$projectName/resources/lang/en',
      '$projectName/resources/views',
      '$projectName/routes',
      '$projectName/storage/cache',
      '$projectName/storage/logs',
      '$projectName/test',
    ];

    print('📁 Creating directory structure...');
    for (final dir in directories) {
      await Directory(dir).create(recursive: true);
      print('  ✓ $dir');
    }
  }

  Future<void> _generateFiles(String projectName) async {
    print('');
    print('📝 Generating files...');

    // Generate pubspec.yaml
    await _generatePubspec(projectName);

    // Generate main.dart
    await _generateMain(projectName);

    // Generate routes
    await _generateRoutes(projectName);

    // Generate config files
    await _generateConfig(projectName);

    // Generate .env.example
    await _generateEnvExample(projectName);

    // Generate .gitignore
    await _generateGitignore(projectName);

    // Generate README
    await _generateReadme(projectName);

    // Generate example controller
    await _generateExampleController(projectName);

    // Generate example view
    await _generateExampleView(projectName);

    // Generate example test
    await _generateExampleTest(projectName);
  }

  Future<void> _generatePubspec(String projectName) async {
    final content = '''name: $projectName
description: A Dartian web application
version: 0.0.1
publish_to: none

environment:
  sdk: ^3.9.4

dependencies:
  dartian_core:
    git:
      url: https://github.com/verseles/dartian.git
      path: packages/dartian_core
  dartian_http:
    git:
      url: https://github.com/verseles/dartian.git
      path: packages/dartian_http
  dartian_router:
    git:
      url: https://github.com/verseles/dartian.git
      path: packages/dartian_router
  dartian_di:
    git:
      url: https://github.com/verseles/dartian.git
      path: packages/dartian_di
  dartian_orm:
    git:
      url: https://github.com/verseles/dartian.git
      path: packages/dartian_orm
  dartian_redis:
    git:
      url: https://github.com/verseles/dartian.git
      path: packages/dartian_redis
  dartian_queue:
    git:
      url: https://github.com/verseles/dartian.git
      path: packages/dartian_queue
  dartian_scheduler:
    git:
      url: https://github.com/verseles/dartian.git
      path: packages/dartian_scheduler
  dartian_view:
    git:
      url: https://github.com/verseles/dartian.git
      path: packages/dartian_view
  dartian_i18n:
    git:
      url: https://github.com/verseles/dartian.git
      path: packages/dartian_i18n
  dartian_auth:
    git:
      url: https://github.com/verseles/dartian.git
      path: packages/dartian_auth
  shelf: ^1.4.1

dev_dependencies:
  test: ^1.24.0
  dartian_cli:
    git:
      url: https://github.com/verseles/dartian.git
      path: packages/dartian_cli
''';

    await File('$projectName/pubspec.yaml').writeAsString(content);
    print('  ✓ pubspec.yaml');
  }

  Future<void> _generateMain(String projectName) async {
    final content = '''import 'dart:io';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:dartian_http/dartian_http.dart';
import 'package:dartian_router/dartian_router.dart';
import 'routes/web.dart' as web_routes;

Future<void> main() async {
  // Load environment variables
  final port = int.tryParse(Platform.environment['PORT'] ?? '8000') ?? 8000;
  final host = Platform.environment['HOST'] ?? 'localhost';

  // Create router
  final router = Router();

  // Register routes
  web_routes.register(router);

  // Create middleware pipeline
  final handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addMiddleware(corsMiddleware())
      .addHandler(router.handler);

  // Start server
  final server = await io.serve(handler, host, port);

  print('🚀 Server running on http://\${server.address.host}:\${server.port}');
  print('Press Ctrl+C to stop');
}
''';

    await File('$projectName/lib/main.dart').writeAsString(content);
    print('  ✓ lib/main.dart');
  }

  Future<void> _generateRoutes(String projectName) async {
    final content = '''import 'package:dartian_router/dartian_router.dart';
import 'package:shelf/shelf.dart';
import '../app/Http/Controllers/HomeController.dart';

void register(Router router) {
  final homeController = HomeController();

  // Welcome route
  router.get('/', homeController.index);

  // API routes example
  router.group('/api', (router) {
    router.get('/status', (Request request) {
      return Response.ok('{"status": "ok", "timestamp": "\${DateTime.now().toIso8601String()}"}',
        headers: {'Content-Type': 'application/json'},
      );
    });
  });
}
''';

    await File('$projectName/routes/web.dart').writeAsString(content);
    print('  ✓ routes/web.dart');
  }

  Future<void> _generateConfig(String projectName) async {
    final appConfig = '''/// Application configuration
class AppConfig {
  static const String name = 'Dartian Application';
  static const String env = String.fromEnvironment('ENV', defaultValue: 'development');
  static const bool debug = String.fromEnvironment('DEBUG', defaultValue: 'true') == 'true';

  static bool get isProduction => env == 'production';
  static bool get isDevelopment => env == 'development';
}
''';

    await File('$projectName/config/app.dart').writeAsString(appConfig);
    print('  ✓ config/app.dart');

    final dbConfig = '''/// Database configuration
class DatabaseConfig {
  static const String driver = String.fromEnvironment('DB_DRIVER', defaultValue: 'sqlite');
  static const String host = String.fromEnvironment('DB_HOST', defaultValue: 'localhost');
  static const int port = int.fromEnvironment('DB_PORT', defaultValue: 5432);
  static const String database = String.fromEnvironment('DB_DATABASE', defaultValue: 'dartian');
  static const String username = String.fromEnvironment('DB_USERNAME', defaultValue: 'root');
  static const String password = String.fromEnvironment('DB_PASSWORD', defaultValue: '');

  static String get sqlitePath => 'database/database.sqlite';
}
''';

    await File('$projectName/config/database.dart').writeAsString(dbConfig);
    print('  ✓ config/database.dart');
  }

  Future<void> _generateEnvExample(String projectName) async {
    final content = '''# Application
APP_NAME=Dartian Application
ENV=development
DEBUG=true
HOST=localhost
PORT=8000

# Database
DB_DRIVER=sqlite
DB_HOST=localhost
DB_PORT=5432
DB_DATABASE=dartian
DB_USERNAME=root
DB_PASSWORD=

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# Security
JWT_SECRET=your-secret-key-change-this-in-production
SESSION_LIFETIME=86400
''';

    await File('$projectName/.env.example').writeAsString(content);
    print('  ✓ .env.example');
  }

  Future<void> _generateGitignore(String projectName) async {
    final content = '''# Dart
.dart_tool/
.packages
build/
pubspec.lock

# IDE
.idea/
.vscode/
*.swp
*.swo
*~

# Environment
.env

# Storage
storage/cache/*
!storage/cache/.gitkeep
storage/logs/*
!storage/logs/.gitkeep

# Database
*.sqlite
*.sqlite-shm
*.sqlite-wal

# OS
.DS_Store
Thumbs.db
''';

    await File('$projectName/.gitignore').writeAsString(content);
    print('  ✓ .gitignore');

    // Create .gitkeep files
    await File('$projectName/storage/cache/.gitkeep').writeAsString('');
    await File('$projectName/storage/logs/.gitkeep').writeAsString('');
  }

  Future<void> _generateReadme(String projectName) async {
    final content = '''# $projectName

A web application built with Dartian framework.

## Getting Started

### Prerequisites

- Dart SDK >= 3.9.4
- Dartian CLI

### Installation

1. Install dependencies:
   ```bash
   dart pub get
   ```

2. Copy environment file:
   ```bash
   cp .env.example .env
   ```

3. Generate application key:
   ```bash
   # Edit .env and set your JWT_SECRET
   ```

### Development

Start the development server with hot reload:

```bash
dartian serve
```

The application will be available at http://localhost:8000

### Testing

Run tests:

```bash
dart test
```

### Database

Run migrations:

```bash
dartian migrate
```

Rollback migrations:

```bash
dartian migrate:rollback
```

### Production

Build AOT executable:

```bash
dartian build exe
```

Run production server:

```bash
./build/$projectName-aot
```

## Project Structure

```
$projectName/
├── app/
│   ├── Http/
│   │   ├── Controllers/    # Request handlers
│   │   ├── Middleware/     # HTTP middleware
│   │   └── Requests/       # Request validators
│   ├── Models/             # Data models
│   └── Providers/          # Service providers
├── config/                 # Configuration files
├── database/
│   └── migrations/         # Database migrations
├── public/                 # Public assets
├── resources/
│   ├── lang/              # Translations
│   └── views/             # Templates
├── routes/                # Route definitions
├── storage/               # Logs and cache
└── test/                  # Tests
```

## License

Copyright © 2025. All rights reserved.
''';

    await File('$projectName/README.md').writeAsString(content);
    print('  ✓ README.md');
  }

  Future<void> _generateExampleController(String projectName) async {
    final content = '''import 'package:shelf/shelf.dart';
import 'package:dartian_view/dartian_view.dart';

class HomeController {
  final _viewEngine = ViewEngine();

  /// Display the welcome page
  Future<Response> index(Request request) async {
    return _viewEngine.render('welcome', {
      'title': 'Welcome to Dartian',
      'message': 'Your application is ready!',
    });
  }
}
''';

    await File('$projectName/app/Http/Controllers/HomeController.dart').writeAsString(content);
    print('  ✓ app/Http/Controllers/HomeController.dart');
  }

  Future<void> _generateExampleView(String projectName) async {
    final content = '''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{title}}</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }
        .container {
            text-align: center;
            padding: 2rem;
        }
        h1 {
            font-size: 3rem;
            margin-bottom: 1rem;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        p {
            font-size: 1.25rem;
            opacity: 0.9;
        }
        .links {
            margin-top: 2rem;
        }
        a {
            color: white;
            text-decoration: none;
            margin: 0 1rem;
            padding: 0.5rem 1rem;
            border: 2px solid white;
            border-radius: 4px;
            transition: all 0.3s;
        }
        a:hover {
            background: white;
            color: #667eea;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>{{title}}</h1>
        <p>{{message}}</p>
        <div class="links">
            <a href="https://github.com/verseles/dartian" target="_blank">Documentation</a>
            <a href="/api/status" target="_blank">API Status</a>
        </div>
    </div>
</body>
</html>
''';

    await File('$projectName/resources/views/welcome.mustache').writeAsString(content);
    print('  ✓ resources/views/welcome.mustache');
  }

  Future<void> _generateExampleTest(String projectName) async {
    final content = '''import 'package:test/test.dart';

void main() {
  group('Application', () {
    test('should pass basic test', () {
      expect(true, isTrue);
    });

    test('should test arithmetic', () {
      expect(1 + 1, equals(2));
    });
  });
}
''';

    await File('$projectName/test/app_test.dart').writeAsString(content);
    print('  ✓ test/app_test.dart');
  }
}
