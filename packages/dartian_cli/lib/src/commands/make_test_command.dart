import 'package:dartian_cli/src/commands/make_command.dart';

class MakeTestCommand extends MakeCommand {
  @override
  final name = 'make:test';
  @override
  final description = 'Create a new test file.';

  @override
  String get templateName => 'test';
  @override
  String get typeName => 'Test';
  @override
  String get defaultDirectory => 'test';
}
