import 'package:dartian_cli/dartian_cli.dart';

void main(List<String> arguments) {
  // Check if serve command is being used
  if (arguments.isNotEmpty && arguments[0] == 'serve') {
    final serveArgs = arguments.sublist(1);
    runServer(serveArgs);
  } else {
    final output = DartianCli.run(arguments);
    print(output);
  }
}

void runServer(List<String> arguments) {
  // Simple serve implementation with hot reload placeholder
  print('Server listening on http://localhost:8000');
  print('Hot reload not yet implemented');
}
