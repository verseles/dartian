import 'dart:io';
import 'dart:isolate';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

class NewCommand extends Command {
  @override
  final name = 'new';
  @override
  final description = 'Create a new Dartian project.';

  NewCommand() {
    argParser.addOption('directory', abbr: 'd', help: 'The directory to create the project in.');
  }

  @override
  Future<void> run() async {
    if (argResults!.rest.isEmpty) {
      throw UsageException('Project name is required.', usage);
    }
    final projectName = argResults!.rest.first;
    final projectDir = Directory(p.join(argResults!['directory'] ?? Directory.current.path, projectName));

    if (await projectDir.exists()) {
      print('Error: Directory "$projectName" already exists.');
      return;
    }

    await projectDir.create(recursive: true);

    final packageUri = await Isolate.resolvePackageUri(Uri.parse('package:dartian_cli/'));
    final templatesPath = p.join(p.dirname(packageUri!.toFilePath()), '../templates/project');
    final templateDir = Directory(templatesPath);

    await for (var entity in templateDir.list(recursive: true)) {
      if (entity is File) {
        final relativePath = p.relative(entity.path, from: templateDir.path);
        final newPath = p.join(projectDir.path, relativePath);

        await File(newPath).create(recursive: true);
        var content = await entity.readAsString();
        content = content.replaceAll('{{project_name}}', projectName);
        await File(newPath).writeAsString(content);
      }
    }

    print('Project `$projectName` created successfully.');
  }
}
