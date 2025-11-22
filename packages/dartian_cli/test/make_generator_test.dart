import 'dart:io';
import 'package:test/test.dart';
import 'package:dartian_console/dartian_console.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    // Create a temporary directory for test files
    tempDir = Directory.systemTemp.createTempSync('dartian_cli_test_');
    Directory.current = tempDir;
  });

  tearDown(() {
    // Clean up temporary directory
    Directory.current = Directory.current.parent;
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('make:controller command', () {
    test('should create controller file', () {
      final result = DartianCli.run(['make', 'controller', 'TestController']);
      expect(result, contains('Controller created successfully'));
      expect(File('app/Http/Controllers/TestController.dart').existsSync(), isTrue);
    });

    test('should fail if controller already exists', () {
      // Create first
      DartianCli.run(['make', 'controller', 'TestController']);
      // Try to create again
      final result = DartianCli.run(['make', 'controller', 'TestController']);
      expect(result, contains('Error: Controller already exists'));
    });

    test('should show usage when no name provided', () {
      final result = DartianCli.run(['make', 'controller']);
      expect(result, contains('Usage:'));
    });
  });

  group('make:model command', () {
    test('should create model file', () {
      final result = DartianCli.run(['make', 'model', 'User']);
      expect(result, contains('Model created successfully'));
      expect(File('app/Models/User.dart').existsSync(), isTrue);
    });

    test('should fail if model already exists', () {
      DartianCli.run(['make', 'model', 'User']);
      final result = DartianCli.run(['make', 'model', 'User']);
      expect(result, contains('Error: Model already exists'));
    });

    test('should show usage when no name provided', () {
      final result = DartianCli.run(['make', 'model']);
      expect(result, contains('Usage:'));
    });

    test('should generate correct table name for User model', () {
      DartianCli.run(['make', 'model', 'User']);
      final content = File('app/Models/User.dart').readAsStringSync();
      expect(content, contains("'users'")); // Pluralized
    });

    test('should generate correct table name for Category model', () {
      DartianCli.run(['make', 'model', 'Category']);
      final content = File('app/Models/Category.dart').readAsStringSync();
      expect(content, contains("'categories'")); // y -> ies
    });

    test('should generate correct table name for Status model', () {
      DartianCli.run(['make', 'model', 'Status']);
      final content = File('app/Models/Status.dart').readAsStringSync();
      expect(content, contains("'statuses'")); // s -> es
    });

    test('should generate correct table name for Box model', () {
      DartianCli.run(['make', 'model', 'Box']);
      final content = File('app/Models/Box.dart').readAsStringSync();
      expect(content, contains("'boxes'")); // x -> es
    });
  });

  group('make:migration command', () {
    test('should create migration file', () {
      final result = DartianCli.run(['make', 'migration', 'create_users_table']);
      expect(result, contains('Migration created successfully'));
    });

    test('should fail if migration already exists', () {
      DartianCli.run(['make', 'migration', 'create_users_table']);
      final result = DartianCli.run(['make', 'migration', 'create_users_table']);
      expect(result, contains('Error: Migration already exists'));
    });

    test('should show usage when no name provided', () {
      final result = DartianCli.run(['make', 'migration']);
      expect(result, contains('Usage:'));
    });
  });

  group('make:request command', () {
    test('should create request file', () {
      final result = DartianCli.run(['make', 'request', 'CreateUserRequest']);
      expect(result, contains('created successfully'));
      expect(File('app/Http/Requests/CreateUserRequest.dart').existsSync(), isTrue);
    });

    test('should fail if request already exists', () {
      DartianCli.run(['make', 'request', 'CreateUserRequest']);
      final result = DartianCli.run(['make', 'request', 'CreateUserRequest']);
      expect(result, contains('Error:'));
      expect(result, contains('already exists'));
    });

    test('should show usage when no name provided', () {
      final result = DartianCli.run(['make', 'request']);
      expect(result, contains('Usage:'));
    });
  });

  group('make:provider command', () {
    test('should create provider file', () {
      final result = DartianCli.run(['make', 'provider', 'AppServiceProvider']);
      expect(result, contains('created successfully'));
      expect(File('app/Providers/AppServiceProvider.dart').existsSync(), isTrue);
    });

    test('should fail if provider already exists', () {
      DartianCli.run(['make', 'provider', 'AppServiceProvider']);
      final result = DartianCli.run(['make', 'provider', 'AppServiceProvider']);
      expect(result, contains('Error:'));
      expect(result, contains('already exists'));
    });

    test('should show usage when no name provided', () {
      final result = DartianCli.run(['make', 'provider']);
      expect(result, contains('Usage:'));
    });
  });

  group('make:test command', () {
    test('should create test file', () {
      final result = DartianCli.run(['make', 'test', 'UserTest']);
      expect(result, contains('Test file created successfully'));
      expect(File('test/UserTest_test.dart').existsSync(), isTrue);
    });

    test('should fail if test already exists', () {
      DartianCli.run(['make', 'test', 'UserTest']);
      final result = DartianCli.run(['make', 'test', 'UserTest']);
      expect(result, contains('Error:'));
      expect(result, contains('already exists'));
    });

    test('should show usage when no name provided', () {
      final result = DartianCli.run(['make', 'test']);
      expect(result, contains('Usage:'));
    });
  });

  group('Pluralization rules', () {
    test('should pluralize words ending in y', () {
      DartianCli.run(['make', 'model', 'Party']);
      final content = File('app/Models/Party.dart').readAsStringSync();
      expect(content, contains("'parties'"));
    });

    test('should pluralize words ending in sh', () {
      DartianCli.run(['make', 'model', 'Wish']);
      final content = File('app/Models/Wish.dart').readAsStringSync();
      expect(content, contains("'wishes'"));
    });

    test('should pluralize words ending in ch', () {
      DartianCli.run(['make', 'model', 'Match']);
      final content = File('app/Models/Match.dart').readAsStringSync();
      expect(content, contains("'matches'"));
    });

    test('should pluralize regular words', () {
      DartianCli.run(['make', 'model', 'Post']);
      final content = File('app/Models/Post.dart').readAsStringSync();
      expect(content, contains("'posts'"));
    });
  });

  group('Snake case conversion', () {
    test('should convert PascalCase to snake_case in table names', () {
      DartianCli.run(['make', 'model', 'UserProfile']);
      final content = File('app/Models/UserProfile.dart').readAsStringSync();
      expect(content, contains("'user_profiles'"));
    });

    test('should handle single word correctly', () {
      DartianCli.run(['make', 'model', 'Item']);
      final content = File('app/Models/Item.dart').readAsStringSync();
      expect(content, contains("'items'"));
    });
  });
}
