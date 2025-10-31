import 'package:dartian_cli/src/commands/make_command.dart';

class MakeListenerCommand extends MakeCommand {
  @override
  final name = 'make:listener';
  @override
  final description = 'Create a new event listener class.';

  @override
  String get templateName => 'listener';
  @override
  String get typeName => 'Listener';
  @override
  String get defaultDirectory => 'app/listeners';
}
