import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:watcher/watcher.dart';

class ServeCommand extends Command {
  @override
  final name = 'serve';
  @override
  final description = 'Serve the Dartian application.';

  ServeCommand() {
    argParser.addFlag('hot-reload', defaultsTo: true);
    argParser.addFlag('test-mode', hide: true);
  }

  @override
  void run() async {
    if (argResults?['hot-reload'] == true) {
      print('Starting server with hot reload...');
      _startWatcher();
    } else {
      print('Starting server...');
      _startServer();
    }
    if (argResults?['test-mode'] == false) {
      await stdin.first;
    }
  }

  void _startWatcher() {
    final watcher = Watcher('lib');
    watcher.events.listen((event) {
      print('File changed: ${event.path}. Reloading...');
      _restartServer();
    });
    if (argResults?['test-mode'] == true) {
      print('Watcher ready');
    }
  }

  void _startServer() {
    // In a real application, this would start the HTTP server.
    print('Server started.');
  }

  void _restartServer() {
    // In a real application, this would gracefully restart the server.
    print('Server restarted.');
  }
}
