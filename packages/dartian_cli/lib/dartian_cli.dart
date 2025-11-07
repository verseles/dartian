library dartian_cli;

import 'package:args/args.dart';
import 'dart:io';

class DartianCli {
  static const version = '0.0.1';

  static String run(List<String> arguments) {
    final parser = ArgParser()
      ..addCommand('version')
      ..addCommand('help')
      ..addCommand('new')
      ..addCommand('serve')
      ..addCommand('make')
      ..addCommand('migrate')
      ..addCommand('queue')
      ..addCommand('schedule')
      ..addCommand('test')
      ..addCommand('build');

    final results = parser.parse(arguments);

    if (results.command == null) {
      if (results.arguments.isEmpty) {
        return _showHelp();
      }
    }

    final command = results.command?.name;
    final commandArgs = results.command?.arguments ?? [];

    switch (command) {
      case 'version':
        return 'Dartian $version';
      case 'help':
        return _showHelp();
      case 'serve':
        // Serve command is now handled in bin/dartian.dart with ServeCommand
        return 'Use: dartian serve [--host localhost] [--port 8000]';
      case 'make':
        return _handleMakeCommand(commandArgs);
      case 'new':
      case 'migrate':
      case 'queue':
      case 'schedule':
      case 'test':
      case 'build':
        return 'Not implemented yet';
      default:
        return _showHelp();
    }
  }

  static String _handleMakeCommand(List<String> arguments) {
    if (arguments.isEmpty) {
      return 'Make command requires a subcommand (e.g., make:view, make:controller)';
    }

    final subcommand = arguments[0];
    final args = arguments.sublist(1);

    switch (subcommand) {
      case 'view':
        return _makeView(args);
      case 'lang':
        return _makeLang(args);
      case 'controller':
        return _makeController(args);
      case 'model':
        return _makeModel(args);
      case 'migration':
        return _makeMigration(args);
      case 'request':
        return _makeRequest(args);
      case 'provider':
        return _makeProvider(args);
      case 'test':
        return _makeTest(args);
      default:
        return 'Unknown make subcommand: $subcommand. Available: view, lang, controller, model, migration, request, provider, test';
    }
  }

  static String _makeView(List<String> arguments) {
    if (arguments.isEmpty) {
      return 'Usage: dartian make:view <name>';
    }

    final name = arguments[0];
    return _generateView(name);
  }

  static String _makeLang(List<String> arguments) {
    if (arguments.isEmpty) {
      return 'Usage: dartian make:lang <locale>';
    }

    final locale = arguments[0];
    return _generateLanguage(locale);
  }

  static String _generateView(String name) {
    try {
      // Create views directory if it doesn't exist
      final viewsDir = Directory('resources/views');
      if (!viewsDir.existsSync()) {
        viewsDir.createSync(recursive: true);
      }

      // Parse path to create subdirectories
      final parts = name.split('/');
      parts.last; // ignore unused variable
      final subDir = parts.length > 1 ? parts.sublist(0, parts.length - 1) : null;

      // Create subdirectory if needed
      if (subDir != null && subDir.isNotEmpty) {
        final subDirPath = 'resources/views/${subDir.join('/')}';
        final subDirObj = Directory(subDirPath);
        if (!subDirObj.existsSync()) {
          subDirObj.createSync(recursive: true);
        }
      }

      // Generate template file
      final templatePath = 'resources/views/$name.mustache';
      final templateFile = File(templatePath);

      // Check if file already exists
      if (templateFile.existsSync()) {
        return 'Error: Template already exists at $templatePath';
      }

      // Generate boilerplate content
      final content = '''<!DOCTYPE html>
<html>
<head>
  <title>{{title}}</title>
</head>
<body>
  <h1>{{heading}}</h1>
  <div class="content">
    {{#content}}
      <p>{{.}}</p>
    {{/content}}
  </div>
</body>
</html>''';

      templateFile.writeAsStringSync(content);

      return 'View template created successfully at $templatePath';
    } catch (e) {
      return 'Error creating view: $e';
    }
  }

  static String _generateLanguage(String locale) {
    try {
      // Create lang directory if it doesn't exist
      final langDir = Directory('resources/lang');
      if (!langDir.existsSync()) {
        langDir.createSync(recursive: true);
      }

      // Create locale directory
      final localeDirPath = 'resources/lang/$locale';
      final localeDir = Directory(localeDirPath);
      if (!localeDir.existsSync()) {
        localeDir.createSync(recursive: true);
      }

      // Generate messages file
      final messagesPath = '$localeDirPath/messages.json';
      final messagesFile = File(messagesPath);

      // Check if file already exists
      if (messagesFile.existsSync()) {
        return 'Error: Language file already exists at $messagesPath';
      }

      // Generate boilerplate content
      final content = '''{
  "app": {
    "title": "Application Title",
    "description": "Application Description"
  },
  "navigation": {
    "home": "Home",
    "about": "About",
    "contact": "Contact"
  },
  "buttons": {
    "save": "Save",
    "cancel": "Cancel",
    "submit": "Submit"
  },
  "messages": {
    "welcome": "Welcome, {name}!",
    "error": "An error occurred",
    "success": "Operation completed successfully"
  }
}''';

      messagesFile.writeAsStringSync(content);

      return 'Language file created successfully at $messagesPath';
    } catch (e) {
      return 'Error creating language file: $e';
    }
  }

  static String _makeController(List<String> arguments) {
    if (arguments.isEmpty) {
      return 'Usage: dartian make:controller <name>';
    }

    final name = arguments[0];
    return _generateController(name);
  }

  static String _generateController(String name) {
    try {
      // Create controllers directory if it doesn't exist
      final controllersDir = Directory('app/Http/Controllers');
      if (!controllersDir.existsSync()) {
        controllersDir.createSync(recursive: true);
      }

      // Generate controller file
      final controllerPath = 'app/Http/Controllers/$name.dart';
      final controllerFile = File(controllerPath);

      // Check if file already exists
      if (controllerFile.existsSync()) {
        return 'Error: Controller already exists at $controllerPath';
      }

      // Generate boilerplate content
      final content = '''import 'package:shelf/shelf.dart';

class $name {
  /// Handle incoming request
  Future<Response> index(Request request) async {
    return Response.ok('Welcome to $name');
  }

  /// Show a specific resource
  Future<Response> show(Request request, String id) async {
    return Response.ok('Showing resource: \$id');
  }

  /// Create a new resource
  Future<Response> store(Request request) async {
    return Response.ok('Resource created');
  }

  /// Update an existing resource
  Future<Response> update(Request request, String id) async {
    return Response.ok('Resource \$id updated');
  }

  /// Delete a resource
  Future<Response> destroy(Request request, String id) async {
    return Response.ok('Resource \$id deleted');
  }
}
''';

      controllerFile.writeAsStringSync(content);

      return 'Controller created successfully at $controllerPath';
    } catch (e) {
      return 'Error creating controller: $e';
    }
  }

  static String _makeModel(List<String> arguments) {
    if (arguments.isEmpty) {
      return 'Usage: dartian make:model <name>';
    }

    final name = arguments[0];
    return _generateModel(name);
  }

  static String _generateModel(String name) {
    try {
      // Create models directory if it doesn't exist
      final modelsDir = Directory('app/Models');
      if (!modelsDir.existsSync()) {
        modelsDir.createSync(recursive: true);
      }

      // Generate model file
      final modelPath = 'app/Models/$name.dart';
      final modelFile = File(modelPath);

      // Check if file already exists
      if (modelFile.existsSync()) {
        return 'Error: Model already exists at $modelPath';
      }

      // Convert name to table name (e.g., User -> users)
      final tableName = _toSnakeCase(_pluralize(name));

      // Generate boilerplate content
      final content = '''class $name {
  final int? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  $name({
    this.id,
    this.createdAt,
    this.updatedAt,
  });

  /// The table associated with the model
  static String get tableName => '$tableName';

  /// Convert model to map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create model instance from database map
  factory $name.fromMap(Map<String, dynamic> map) {
    return $name(
      id: map['id'] as int?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// Save the model to the database
  Future<$name> save() async {
    // Implementation will use ORM
    throw UnimplementedError('Implement with dartian_orm');
  }

  /// Delete the model from the database
  Future<bool> delete() async {
    // Implementation will use ORM
    throw UnimplementedError('Implement with dartian_orm');
  }

  /// Find a model by ID
  static Future<$name?> find(int id) async {
    // Implementation will use ORM
    throw UnimplementedError('Implement with dartian_orm');
  }

  /// Get all models
  static Future<List<$name>> all() async {
    // Implementation will use ORM
    throw UnimplementedError('Implement with dartian_orm');
  }
}
''';

      modelFile.writeAsStringSync(content);

      return 'Model created successfully at $modelPath';
    } catch (e) {
      return 'Error creating model: $e';
    }
  }

  static String _makeMigration(List<String> arguments) {
    if (arguments.isEmpty) {
      return 'Usage: dartian make:migration <name>';
    }

    final name = arguments[0];
    return _generateMigration(name);
  }

  static String _generateMigration(String name) {
    try {
      // Create migrations directory if it doesn't exist
      final migrationsDir = Directory('database/migrations');
      if (!migrationsDir.existsSync()) {
        migrationsDir.createSync(recursive: true);
      }

      // Generate timestamp prefix
      final now = DateTime.now();
      final timestamp = '${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';

      // Convert name to class name (e.g., create_users_table -> CreateUsersTable)
      final className = _toClassName(name);

      // Generate migration file
      final migrationPath = 'database/migrations/${timestamp}_$name.dart';
      final migrationFile = File(migrationPath);

      // Check if file already exists
      if (migrationFile.existsSync()) {
        return 'Error: Migration already exists at $migrationPath';
      }

      // Generate boilerplate content
      final content = '''import 'package:dartian_orm/dartian_orm.dart';

class $className extends Migration {
  @override
  Future<void> up() async {
    // Run the migrations
    // Example:
    // await schema.create('table_name', (table) {
    //   table.id();
    //   table.string('name');
    //   table.timestamps();
    // });
  }

  @override
  Future<void> down() async {
    // Reverse the migrations
    // Example:
    // await schema.dropIfExists('table_name');
  }
}
''';

      migrationFile.writeAsStringSync(content);

      return 'Migration created successfully at $migrationPath';
    } catch (e) {
      return 'Error creating migration: $e';
    }
  }

  static String _makeRequest(List<String> arguments) {
    if (arguments.isEmpty) {
      return 'Usage: dartian make:request <name>';
    }

    final name = arguments[0];
    return _generateRequest(name);
  }

  static String _generateRequest(String name) {
    try {
      // Create requests directory if it doesn't exist
      final requestsDir = Directory('app/Http/Requests');
      if (!requestsDir.existsSync()) {
        requestsDir.createSync(recursive: true);
      }

      // Generate request file
      final requestPath = 'app/Http/Requests/$name.dart';
      final requestFile = File(requestPath);

      // Check if file already exists
      if (requestFile.existsSync()) {
        return 'Error: Request already exists at $requestPath';
      }

      // Generate boilerplate content
      final content = '''class $name {
  final Map<String, dynamic> data;

  $name(this.data);

  /// Validation rules for the request
  Map<String, List<String>> rules() {
    return {
      // Example validation rules:
      // 'name': ['required', 'string', 'min:3'],
      // 'email': ['required', 'email'],
      // 'age': ['required', 'integer', 'min:18'],
    };
  }

  /// Custom validation messages
  Map<String, String> messages() {
    return {
      // Example custom messages:
      // 'name.required': 'The name field is required.',
      // 'email.email': 'Please provide a valid email address.',
    };
  }

  /// Authorize the request
  bool authorize() {
    // Return true to authorize, false to deny
    return true;
  }

  /// Validate the request
  Future<bool> validate() async {
    if (!authorize()) {
      throw Exception('Unauthorized');
    }

    // TODO: Implement validation logic based on rules()
    return true;
  }

  /// Get validated data
  Map<String, dynamic> validated() {
    return data;
  }

  /// Get a specific field from request data
  dynamic get(String key, [dynamic defaultValue]) {
    return data[key] ?? defaultValue;
  }

  /// Check if request has a field
  bool has(String key) {
    return data.containsKey(key);
  }
}
''';

      requestFile.writeAsStringSync(content);

      return 'Request validator created successfully at $requestPath';
    } catch (e) {
      return 'Error creating request: $e';
    }
  }

  static String _makeProvider(List<String> arguments) {
    if (arguments.isEmpty) {
      return 'Usage: dartian make:provider <name>';
    }

    final name = arguments[0];
    return _generateProvider(name);
  }

  static String _generateProvider(String name) {
    try {
      // Create providers directory if it doesn't exist
      final providersDir = Directory('app/Providers');
      if (!providersDir.existsSync()) {
        providersDir.createSync(recursive: true);
      }

      // Generate provider file
      final providerPath = 'app/Providers/$name.dart';
      final providerFile = File(providerPath);

      // Check if file already exists
      if (providerFile.existsSync()) {
        return 'Error: Provider already exists at $providerPath';
      }

      // Generate boilerplate content
      final content = '''import 'package:dartian_di/dartian_di.dart';

class $name extends ServiceProvider {
  @override
  Future<void> register() async {
    // Register services into the container
    // Example:
    // container.singleton<MyService>(() => MyService());
    // container.register<MyRepository>(() => MyRepositoryImpl());
  }

  @override
  Future<void> boot() async {
    // Bootstrap services after all providers are registered
    // This is called after all register() methods have been called
    // Use this to set up event listeners, configure services, etc.
  }
}
''';

      providerFile.writeAsStringSync(content);

      return 'Service provider created successfully at $providerPath';
    } catch (e) {
      return 'Error creating provider: $e';
    }
  }

  static String _makeTest(List<String> arguments) {
    if (arguments.isEmpty) {
      return 'Usage: dartian make:test <name>';
    }

    final name = arguments[0];
    return _generateTest(name);
  }

  static String _generateTest(String name) {
    try {
      // Create test directory if it doesn't exist
      final testDir = Directory('test');
      if (!testDir.existsSync()) {
        testDir.createSync(recursive: true);
      }

      // Ensure name ends with _test
      final testName = name.endsWith('_test') ? name : '${name}_test';

      // Generate test file
      final testPath = 'test/$testName.dart';
      final testFile = File(testPath);

      // Check if file already exists
      if (testFile.existsSync()) {
        return 'Error: Test file already exists at $testPath';
      }

      // Convert to class name
      final className = _toClassName(testName.replaceAll('_test', ''));

      // Generate boilerplate content
      final content = '''import 'package:test/test.dart';

void main() {
  group('$className', () {
    setUp(() {
      // Setup code here
    });

    tearDown(() {
      // Cleanup code here
    });

    test('should pass basic test', () {
      expect(true, isTrue);
    });

    test('should test specific functionality', () {
      // Add your test here
      expect(1 + 1, equals(2));
    });
  });
}
''';

      testFile.writeAsStringSync(content);

      return 'Test file created successfully at $testPath';
    } catch (e) {
      return 'Error creating test: $e';
    }
  }

  // Helper methods
  static String _toSnakeCase(String input) {
    return input
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match.group(0)!.toLowerCase()}')
        .replaceFirst(RegExp(r'^_'), '');
  }

  static String _pluralize(String input) {
    // Simple pluralization rules
    if (input.endsWith('y')) {
      return '${input.substring(0, input.length - 1)}ies';
    } else if (input.endsWith('s') || input.endsWith('x') || input.endsWith('ch') || input.endsWith('sh')) {
      return '${input}es';
    }
    return '${input}s';
  }

  static String _toClassName(String input) {
    return input
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join('');
  }

  static String _showHelp() {
    return '''Dartian $version

Usage: dartian <command> [arguments]

Available commands:
  version              Show Dartian version
  help                 Show this help message
  new <project>        Create a new Dartian project
  serve                Start development server
  make:<subcommand>    Generate code (controller, model, etc.)
  migrate              Run database migrations
  queue:<subcommand>   Queue worker commands
  schedule:<subcommand> Scheduler commands
  test                 Run tests
  build                Build for production

Run "dartian help <command>" for more information on a specific command.''';
  }
}
