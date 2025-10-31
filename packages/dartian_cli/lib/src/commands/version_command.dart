import 'package:args/command_runner.dart';

class VersionCommand extends Command {
  @override
  final name = 'version';
  @override
  final description = 'Print the Dartian CLI version.';
}
