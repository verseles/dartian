import 'package:dartian_cli/src/commands/make_command.dart';

class MakeRuleCommand extends MakeCommand {
  @override
  final name = 'make:rule';
  @override
  final description = 'Create a new validation rule class.';

  @override
  String get templateName => 'rule';
  @override
  String get typeName => 'Rule';
  @override
  String get defaultDirectory => 'app/rules';
}
