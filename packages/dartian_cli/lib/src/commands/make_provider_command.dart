import 'package:dartian_cli/src/commands/make_command.dart';

class MakeProviderCommand extends MakeCommand {
  @override
  final name = 'make:provider';
  @override
  final description = 'Create a new service provider class.';

  @override
  String get templateName => 'provider';
  @override
  String get typeName => 'Provider';
  @override
  String get defaultDirectory => 'app/providers';
}
