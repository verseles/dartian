import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:mustache_template/mustache_template.dart';

abstract class MakeCommand extends Command {
  String get templateName;
  String get typeName;
  String get defaultDirectory;

  MakeCommand() {
    argParser.addOption('name', abbr: 'n', help: 'The name of the $typeName.');
    argParser.addOption('directory', abbr: 'd', help: 'The target directory.', defaultsTo: '.');
  }

  @override
  void run() {
    if (argResults?['name'] == null) {
      print('The --name option is required.');
      return;
    }

    final name = argResults!['name'];
    final targetDirectory = argResults!['directory'];
    final filePath = p.join(targetDirectory, '$name.dart');
    final file = File(filePath);

    if (file.existsSync()) {
      print('$typeName already exists: $filePath');
      return;
    }

    final templateFile = File(p.join('packages', 'dartian_cli', 'lib', 'src', 'templates', '$templateName.mustache'));
    final template = Template(templateFile.readAsStringSync());
    final output = template.renderString({'name': name});

    file.createSync(recursive: true);
    file.writeAsStringSync(output);

    print('$typeName created: $filePath');
  }
}
