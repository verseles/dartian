import 'package:dartian_cli/dartian_cli.dart';
import 'package:dartian_cli/src/commands/serve_command.dart';

void main(List<String> arguments) async {
  // Check if serve command is being used
  if (arguments.isNotEmpty && arguments[0] == 'serve') {
    final serveArgs = arguments.sublist(1);
    final command = ServeCommand();
    await command.run(serveArgs);
  } else {
    final output = DartianCli.run(arguments);
    print(output);
  }
}
