import 'package:dartian_cli/src/commands/make_command.dart';

class MakeModelCommand extends MakeCommand {
  @override
  final name = 'make:model';
  @override
  final description = 'Create a new model class.';

  @override
  String get templateName => 'model';
  @override
  String get typeName => 'Model';
  @override
  String get defaultDirectory => 'app/models';
}
