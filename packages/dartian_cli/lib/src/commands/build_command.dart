import 'package:args/command_runner.dart';
// import 'package:dartian_cli/src/commands/build/exe_command.dart';
// import 'package:dartian_cli/src/commands/build/aot_command.dart';
// import 'package:dartian_cli/src/commands/build/wasm_command.dart';

class BuildCommand extends Command {
  @override
  final name = 'build';
  @override
  final description = 'Build the Dartian application.';

  BuildCommand() {
    // addSubcommand(ExeCommand());
    // addSubcommand(AotCommand());
    // addSubcommand(WasmCommand());
  }
}
