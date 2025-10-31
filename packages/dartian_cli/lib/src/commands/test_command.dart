import 'dart:io';
import 'package:args/command_runner.dart';

class TestCommand extends Command {
  @override
  final name = 'test';
  @override
  final description = 'Run tests for the Dartian application.';

  @override
  void run() async {
    print('Running tests...');
    final process = await Process.start('dart', ['test'], runInShell: true);
    await stdout.addStream(process.stdout);
    await stderr.addStream(process.stderr);
  }
}
