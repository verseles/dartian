import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

class MakeViewCommand extends Command {
  @override
  final name = 'make:view';
  @override
  final description = 'Create a new view file.';

  MakeViewCommand() {
    argParser.addOption('name', abbr: 'n', help: 'The name of the view.');
    argParser.addOption('directory', abbr: 'd', help: 'The target directory.', defaultsTo: '.');
  }

  @override
  void run() {
    if (argResults?['name'] == null) {
      print('The --name option is required.');
      return;
    }

    final viewName = argResults!['name'];
    final targetDirectory = argResults!['directory'];
    final viewPath = p.join(targetDirectory, 'resources', 'views', '$viewName.mustache');
    final viewFile = File(viewPath);

    if (viewFile.existsSync()) {
      print('View already exists: $viewPath');
      return;
    }

    viewFile.createSync(recursive: true);
    viewFile.writeAsStringSync('{{! Your HTML here }}');

    print('View created: $viewPath');
  }
}
