import 'package:dartian_cli/dartian_cli.dart';
import 'package:test/test.dart';

void main() {
  group('DartianCli', () {
    test('version command returns version', () {
      final result = DartianCli.run(['version']);
      expect(result, contains('Dartian'));
      expect(result, contains(DartianCli.version));
    });

    test('help command returns help message', () {
      final result = DartianCli.run(['help']);
      expect(result, contains('Available commands:'));
      expect(result, contains('dartian'));
    });

    test('no arguments shows help', () {
      final result = DartianCli.run([]);
      expect(result, contains('Available commands:'));
    });

    test('serve command shows usage', () {
      final result = DartianCli.run(['serve']);
      expect(result, contains('dartian serve'));
      expect(result, contains('host'));
      expect(result, contains('port'));
    });

    test('new command shows usage', () {
      final result = DartianCli.run(['new']);
      expect(result, contains('dartian new'));
      expect(result, contains('project-name'));
    });

    test('queue command without subcommand shows usage', () {
      final result = DartianCli.run(['queue']);
      expect(result, contains('Usage:'));
      expect(result, contains('queue:work'));
    });

    test('queue:work command shows usage', () {
      final result = DartianCli.run(['queue', 'work']);
      expect(result, contains('queue:work'));
      expect(result, contains('driver'));
    });

    test('schedule command without subcommand shows usage', () {
      final result = DartianCli.run(['schedule']);
      expect(result, contains('Usage:'));
      expect(result, contains('schedule:run'));
    });

    test('schedule:run command shows usage', () {
      final result = DartianCli.run(['schedule', 'run']);
      expect(result, contains('schedule:run'));
    });

    test('build command without type shows usage', () {
      final result = DartianCli.run(['build']);
      expect(result, contains('Usage:'));
      expect(result, contains('dartian build'));
      expect(result, contains('exe'));
      expect(result, contains('aot-snapshot'));
      expect(result, contains('wasm'));
    });

    test('build command with type shows usage', () {
      final result = DartianCli.run(['build', 'exe']);
      expect(result, contains('dartian build'));
    });

    test('migrate command shows usage', () {
      final result = DartianCli.run(['migrate']);
      expect(result, contains('dartian migrate'));
      expect(result, contains('database'));
    });

    test('test command shows usage', () {
      final result = DartianCli.run(['test']);
      expect(result, contains('dartian test'));
      expect(result, contains('coverage'));
    });

    test('unknown command shows help', () {
      final result = DartianCli.run(['unknown']);
      expect(result, contains('Available commands:'));
    });

    test('make command without subcommand shows error', () {
      final result = DartianCli.run(['make']);
      expect(result, contains('Make command requires a subcommand'));
      expect(result, contains('make:view'));
    });

    test('make:controller shows result', () {
      final result = DartianCli.run(['make', 'controller', 'TestController']);
      // Just verify it doesn't crash and returns something
      expect(result, isNotEmpty);
    });

    test('make:model shows result', () {
      final result = DartianCli.run(['make', 'model', 'TestModel']);
      expect(result, isNotEmpty);
    });

    test('make:migration shows result', () {
      final result = DartianCli.run(['make', 'migration', 'test_migration']);
      expect(result, isNotEmpty);
    });

    test('make:request shows result', () {
      final result = DartianCli.run(['make', 'request', 'TestRequest']);
      expect(result, isNotEmpty);
    });

    test('make:provider shows result', () {
      final result = DartianCli.run(['make', 'provider', 'TestProvider']);
      expect(result, isNotEmpty);
    });

    test('make:test shows result', () {
      final result = DartianCli.run(['make', 'test', 'test_example']);
      expect(result, isNotEmpty);
    });

    test('make with unknown subcommand shows error', () {
      final result = DartianCli.run(['make', 'unknown', 'TestName']);
      expect(result, contains('Unknown make subcommand'));
      expect(result, contains('Available:'));
    });
  });
}
