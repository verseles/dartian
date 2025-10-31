import 'package:dartian_cli/src/commands/make_command.dart';

class MakeJobCommand extends MakeCommand {
  @override
  final name = 'make:job';
  @override
  final description = 'Create a new job class.';

  @override
  String get templateName => 'job';
  @override
  String get typeName => 'Job';
  @override
  String get defaultDirectory => 'app/jobs';
}
