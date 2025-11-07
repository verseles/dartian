library dartian_cli;

import 'package:args/args.dart';
import 'dart:io';

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
    final commandArgs = results.command?.arguments ?? [];

    switch (command) {
      case 'version':
        return 'Dartian $version';
      case 'help':
        return _showHelp();
      case 'serve':
        // This would be implemented with hot reload
        return 'Serve command with hot reload (placeholder)';
      case 'make':
        return _handleMakeCommand(commandArgs);
      case 'new':
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

  static String _handleMakeCommand(List<String> arguments) {
    if (arguments.isEmpty) {
      return 'Make command requires a subcommand (e.g., make:view, make:controller)';
    }

    final subcommand = arguments[0];
    final args = arguments.sublist(1);

    switch (subcommand) {
      case 'view':
        return _makeView(args);
      case 'controller':
      case 'model':
      case 'migration':
      case 'request':
      case 'provider':
      case 'test':
        return 'Generator for $subcommand not yet implemented';
      default:
        return 'Unknown make subcommand: $subcommand. Available: view, controller, model, migration, request, provider, test';
    }
  }

  static String _makeView(List<String> arguments) {
    if (arguments.isEmpty) {
      return 'Usage: dartian make:view <name>';
    }

    final name = arguments[0];
    return _generateView(name);
  }

  static String _generateView(String name) {
    try {
      // Create views directory if it doesn't exist
      final viewsDir = Directory('resources/views');
      if (!viewsDir.existsSync()) {
        viewsDir.createSync(recursive: true);
      }

      // Parse path to create subdirectories
      final parts = name.split('/');
      parts.last; // ignore unused variable
      final subDir = parts.length > 1 ? parts.sublist(0, parts.length - 1) : null;

      // Create subdirectory if needed
      if (subDir != null && subDir.isNotEmpty) {
        final subDirPath = 'resources/views/${subDir.join('/')}';
        final subDirObj = Directory(subDirPath);
        if (!subDirObj.existsSync()) {
          subDirObj.createSync(recursive: true);
        }
      }

      // Generate template file
      final templatePath = 'resources/views/$name.mustache';
      final templateFile = File(templatePath);

      // Check if file already exists
      if (templateFile.existsSync()) {
        return 'Error: Template already exists at $templatePath';
      }

      // Generate boilerplate content
      final content = '''<!DOCTYPE html>
<html>
<head>
  <title>{{title}}</title>
</head>
<body>
  <h1>{{heading}}</h1>
  <div class="content">
    {{#content}}
      <p>{{.}}</p>
    {{/content}}
  </div>
</body>
</html>''';

      templateFile.writeAsStringSync(content);

      return 'View template created successfully at $templatePath';
    } catch (e) {
      return 'Error creating view: $e';
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
