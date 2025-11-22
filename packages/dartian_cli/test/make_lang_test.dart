import 'package:test/test.dart';
import 'package:dartian_console/dartian_cli.dart';
import 'dart:io';

void main() {
  group('make:lang command', () {
    setUp(() {
      // Ensure we're in a clean state
      final langDir = Directory('resources/lang');
      if (langDir.existsSync()) {
        langDir.deleteSync(recursive: true);
      }
    });

    tearDown(() {
      // Clean up
      final langDir = Directory('resources/lang');
      if (langDir.existsSync()) {
        langDir.deleteSync(recursive: true);
      }
    });

    test('should create language file', () {
      final result = DartianCli.run(['make', 'lang', 'pt_BR']);

      expect(result, contains('Language file created successfully'));
      expect(result, contains('resources/lang/pt_BR/messages.json'));

      final messagesFile = File('resources/lang/pt_BR/messages.json');
      expect(messagesFile.existsSync(), isTrue);

      final content = messagesFile.readAsStringSync();
      expect(content, contains('"app"'));
      expect(content, contains('"title"'));
      expect(content, contains('"welcome": "Welcome, {name}!"'));
    });

    test('should create language file with simple locale', () {
      final result = DartianCli.run(['make', 'lang', 'es']);

      expect(result, contains('Language file created successfully'));
      expect(result, contains('resources/lang/es/messages.json'));

      final messagesFile = File('resources/lang/es/messages.json');
      expect(messagesFile.existsSync(), isTrue);
    });

    test('should report error if language file already exists', () {
      // Create language file first
      final langDir = Directory('resources/lang/en');
      langDir.createSync(recursive: true);
      File('resources/lang/en/messages.json')
        ..createSync()
        ..writeAsStringSync('{}');

      final result = DartianCli.run(['make', 'lang', 'en']);

      expect(result, contains('Error: Language file already exists'));
    });

    test('should show usage if no locale provided', () {
      final result = DartianCli.run(['make', 'lang']);

      expect(result, contains('Usage: dartian make:lang <locale>'));
    });
  });
}
