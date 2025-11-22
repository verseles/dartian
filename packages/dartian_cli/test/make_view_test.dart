import 'package:test/test.dart';
import 'package:dartian_console/dartian_console.dart';
import 'dart:io';

void main() {
  group('make:view command', () {
    setUp(() {
      // Ensure we're in a clean state
      final viewsDir = Directory('resources/views');
      if (viewsDir.existsSync()) {
        viewsDir.deleteSync(recursive: true);
      }
    });

    tearDown(() {
      // Clean up
      final viewsDir = Directory('resources/views');
      if (viewsDir.existsSync()) {
        viewsDir.deleteSync(recursive: true);
      }
    });

    test('should create view template', () {
      final result = DartianCli.run(['make', 'view', 'users/list']);

      expect(result, contains('View template created successfully'));
      expect(result, contains('resources/views/users/list.mustache'));

      final templateFile = File('resources/views/users/list.mustache');
      expect(templateFile.existsSync(), isTrue);

      final content = templateFile.readAsStringSync();
      expect(content, contains('<title>{{title}}</title>'));
      expect(content, contains('{{heading}}'));
    });

    test('should create view in root views directory', () {
      final result = DartianCli.run(['make', 'view', 'home']);

      expect(result, contains('View template created successfully'));
      expect(result, contains('resources/views/home.mustache'));

      final templateFile = File('resources/views/home.mustache');
      expect(templateFile.existsSync(), isTrue);
    });

    test('should handle nested paths', () {
      final result = DartianCli.run(['make', 'view', 'admin/users/show']);

      expect(result, contains('View template created successfully'));
      expect(result, contains('resources/views/admin/users/show.mustache'));

      final templateFile = File('resources/views/admin/users/show.mustache');
      expect(templateFile.existsSync(), isTrue);
    });

    test('should report error if template already exists', () {
      // Create template first
      File('resources/views/existing.mustache')..createSync(recursive: true);

      final result = DartianCli.run(['make', 'view', 'existing']);

      expect(result, contains('Error: Template already exists'));
    });

    test('should show usage if no name provided', () {
      final result = DartianCli.run(['make', 'view']);

      expect(result, contains('Usage: dartian make:view <name>'));
    });
  });
}
