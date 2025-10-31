import 'package:dartian_cli/src/commands/make_command.dart';

class MakeMiddlewareCommand extends MakeCommand {
  @override
  final name = 'make:middleware';
  @override
  final description = 'Create a new middleware class.';

  @override
  String get templateName => 'middleware';
  @override
  String get typeName => 'Middleware';
  @override
  String get defaultDirectory => 'app/http/middleware';
}
