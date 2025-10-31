import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

class MakeLangCommand extends Command {
  @override
  final name = 'make:lang';
  @override
  final description = 'Create a new language file.';

  MakeLangCommand() {
    argParser.addOption('name', abbr: 'n', help: 'The name of the language (e.g., en, fr).');
    argParser.addOption('directory', abbr: 'd', help: 'The target directory.', defaultsTo: '.');
  }

  @override
  void run() {
    if (argResults?['name'] == null) {
      print('The --name option is required.');
      return;
    }

    final langName = argResults!['name'];
    final targetDirectory = argResults!['directory'];
    final langPath = p.join(targetDirectory, 'resources', 'lang', langName, 'messages.dart');
    final langFile = File(langPath);

    if (langFile.existsSync()) {
      print('Language file already exists: $langPath');
      return;
    }

    langFile.createSync(recursive: true);
    langFile.writeAsStringSync('const messages = {};');

    print('Language file created: $langPath');
  }
}
