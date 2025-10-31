import 'package:dartian_cli/src/commands/make_command.dart';

class MakeMigrationCommand extends MakeCommand {
  @override
  final name = 'make:migration';
  @override
  final description = 'Create a new migration class.';

  @override
  String get templateName => 'migration';
  @override
  String get typeName => 'Migration';
  @override
  String get defaultDirectory => 'database/migrations';
}
