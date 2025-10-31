import 'package:dartian_cli/src/commands/make_command.dart';

class MakeRequestCommand extends MakeCommand {
  @override
  final name = 'make:request';
  @override
  final description = 'Create a new form request class.';

  @override
  String get templateName => 'request';
  @override
  String get typeName => 'Request';
  @override
  String get defaultDirectory => 'app/http/requests';
}
