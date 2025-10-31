import 'package:args/command_runner.dart';
import 'package:dartian_cli/src/commands/new_command.dart';
import 'package:dartian_cli/src/commands/version_command.dart';
import 'package:dartian_cli/src/commands/serve_command.dart';
import 'package:dartian_cli/src/commands/make_view_command.dart';
import 'package:dartian_cli/src/commands/make_lang_command.dart';
import 'package:dartian_cli/src/commands/make_controller_command.dart';
import 'package:dartian_cli/src/commands/make_model_command.dart';
import 'package:dartian_cli/src/commands/make_migration_command.dart';
import 'package:dartian_cli/src/commands/make_middleware_command.dart';
import 'package:dartian_cli/src/commands/make_provider_command.dart';
import 'package:dartian_cli/src/commands/make_request_command.dart';
import 'package:dartian_cli/src/commands/make_test_command.dart';
import 'package:dartian_cli/src/commands/make_job_command.dart';
import 'package:dartian_cli/src/commands/make_listener_command.dart';
import 'package:dartian_cli/src/commands/make_policy_command.dart';
import 'package:dartian_cli/src/commands/make_rule_command.dart';
import 'package:dartian_cli/src/commands/build_command.dart';
import 'package:dartian_cli/src/commands/test_command.dart';

Future<int?> run(List<String> arguments) async {
  final runner = CommandRunner('dartian', 'A powerful Dart framework for building scalable and maintainable applications.')
    ..addCommand(NewCommand())
    ..addCommand(VersionCommand())
    ..addCommand(ServeCommand())
    ..addCommand(MakeViewCommand())
    ..addCommand(MakeLangCommand())
    ..addCommand(MakeControllerCommand())
    ..addCommand(MakeModelCommand())
    ..addCommand(MakeMigrationCommand())
    ..addCommand(MakeMiddlewareCommand())
    ..addCommand(MakeProviderCommand())
    ..addCommand(MakeRequestCommand())
    ..addCommand(MakeTestCommand())
    ..addCommand(MakeJobCommand())
    ..addCommand(MakeListenerCommand())
    ..addCommand(MakePolicyCommand())
    ..addCommand(MakeRuleCommand())
    ..addCommand(BuildCommand())
    ..addCommand(TestCommand());

  try {
    return await runner.run(arguments);
  } catch (error) {
    if (error is UsageException) {
      print(error);
      return 64; // Command line usage error
    } else {
      print('An unexpected error occurred: $error');
      return 1; // General error
    }
  }
}
