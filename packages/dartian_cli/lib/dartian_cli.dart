library dartian_cli;

import 'package:args/args.dart';

class DartianCli {
  static const version = '0.0.1';

  static String run(List<String> arguments) {
    final parser = ArgParser()
      ..addCommand('version')
      ..addCommand('help')
      ..addCommand('new')
      ..addCommand('serve')
      ..addCommand('make')
      ..addCommand('migrate')
      ..addCommand('queue')
      ..addCommand('schedule')
      ..addCommand('test')
      ..addCommand('build');

    final results = parser.parse(arguments);

    if (results.command == null) {
      if (results.arguments.isEmpty) {
        return _showHelp();
      }
    }

    final command = results.command?.name;

    switch (command) {
      case 'version':
        return 'Dartian $version';
      case 'help':
        return _showHelp();
      case 'new':
      case 'serve':
      case 'make':
      case 'migrate':
      case 'queue':
      case 'schedule':
      case 'test':
      case 'build':
        return 'Not implemented yet';
      default:
        return _showHelp();
    }
  }

  static String _showHelp() {
    return '''Dartian $version

Usage: dartian <command> [arguments]

Available commands:
  version              Show Dartian version
  help                 Show this help message
  new <project>        Create a new Dartian project
  serve                Start development server
  make:<subcommand>    Generate code (controller, model, etc.)
  migrate              Run database migrations
  queue:<subcommand>   Queue worker commands
  schedule:<subcommand> Scheduler commands
  test                 Run tests
  build                Build for production

Run "dartian help <command>" for more information on a specific command.''';
  }
}
