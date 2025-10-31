import 'dart:io';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('new command', () {
    Directory? tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('dartian_new_command_test_');
    });

    tearDown(() {
      tempDir?.deleteSync(recursive: true);
    });

    test('creates a new project', () async {
      final projectRoot = Platform.environment['PWD']!;
      final templatesPath = p.normalize(p.join(projectRoot, 'packages/dartian_cli/templates/project'));
      final cliScriptPath = p.normalize(p.join(projectRoot, 'packages/dartian_cli/bin/dartian.dart'));

      final result = await Process.run(
        'dart',
        [cliScriptPath, 'new', 'test_project'],
        workingDirectory: tempDir!.path,
        environment: {'DARTIAN_TEMPLATES_PATH': templatesPath},
      );

      expect(result.exitCode, 0, reason: "Process exited with code ${result.exitCode}. Stderr: ${result.stderr}\nStdout: ${result.stdout}");

      final projectDir = Directory(p.join(tempDir!.path, 'test_project'));
      expect(projectDir.existsSync(), isTrue);

      final pubspec = File(p.join(projectDir.path, 'pubspec.yaml'));
      expect(pubspec.existsSync(), isTrue);
      expect(pubspec.readAsStringSync(), contains('name: test_project'));
    });
  });
}
