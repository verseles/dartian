import 'package:dartian_cli/src/commands/make_command.dart';

class MakeControllerCommand extends MakeCommand {
  @override
  final name = 'make:controller';
  @override
  final description = 'Create a new controller class.';

  @override
  String get templateName => 'controller';
  @override
  String get typeName => 'Controller';
  @override
  String get defaultDirectory => 'app/http/controllers';
}
