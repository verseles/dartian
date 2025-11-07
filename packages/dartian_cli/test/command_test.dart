import 'package:test/test.dart';
import 'package:dartian_cli/dartian_cli.dart';

void main() {
  group('Command Parsing', () {
    test('version command returns correct version', () {
      final result = DartianCli.run(['version']);
      expect(result, equals('Dartian 0.0.1'));
    });

    test('help command shows help message', () {
      final result = DartianCli.run(['help']);
      expect(result, contains('Usage: dartian'));
      expect(result, contains('version'));
      expect(result, contains('help'));
      expect(result, contains('new'));
      expect(result, contains('serve'));
      expect(result, contains('make'));
      expect(result, contains('migrate'));
      expect(result, contains('queue'));
      expect(result, contains('schedule'));
      expect(result, contains('test'));
      expect(result, contains('build'));
    });

    test('unknown subcommand shows help message', () {
      final result = DartianCli.run(['make']);
      expect(result, contains('Make command requires a subcommand'));
    });

    test('no arguments shows help', () {
      final result = DartianCli.run([]);
      expect(result, contains('Usage: dartian'));
    });

    test('rejects unknown commands', () {
      final result = DartianCli.run(['unknown']);
      expect(result, contains('Usage: dartian'));
    });

    test('serve command placeholder', () {
      final result = DartianCli.run(['serve']);
      expect(result, contains('placeholder'));
    });

    test('new command not implemented', () {
      final result = DartianCli.run(['new', 'test']);
      expect(result, equals('Not implemented yet'));
    });
  });
}

