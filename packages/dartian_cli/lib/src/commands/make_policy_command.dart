import 'package:dartian_cli/src/commands/make_command.dart';

class MakePolicyCommand extends MakeCommand {
  @override
  final name = 'make:policy';
  @override
  final description = 'Create a new policy class.';

  @override
  String get templateName => 'policy';
  @override
  String get typeName => 'Policy';
  @override
  String get defaultDirectory => 'app/policies';
}
