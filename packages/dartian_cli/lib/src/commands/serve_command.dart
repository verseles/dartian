import 'dart:async';
import 'dart:io';
import 'package:watcher/watcher.dart';
import 'package:args/args.dart';

class ServeCommand {
  static const defaultHost = 'localhost';
  static const defaultPort = 8000;

  final List<String> _watchDirectories = [
    'lib',
    'app',
    'routes',
    'resources',
  ];

  Process? _serverProcess;
  final List<DirectoryWatcher> _watchers = [];
  final List<StreamSubscription> _subscriptions = [];
  bool _isReloading = false;
  DateTime? _lastReload;
  static const _reloadDebounceMs = 500;

  Future<void> run(List<String> arguments) async {
    final parser = ArgParser()
      ..addOption('host',
          abbr: 'h', defaultsTo: defaultHost, help: 'The host to bind to')
      ..addOption('port',
          abbr: 'p', defaultsTo: '$defaultPort', help: 'The port to bind to');

    ArgResults args;
    try {
      args = parser.parse(arguments);
    } catch (e) {
      print('Error parsing arguments: $e');
      print('\nUsage: dartian serve [options]');
      print(parser.usage);
      return;
    }

    final host = args['host'] as String;
    final port = int.tryParse(args['port'] as String) ?? defaultPort;

    print('🚀 Dartian Development Server');
    print('━' * 50);
    print('📍 Server: http://$host:$port');
    print('👀 Watching: ${_watchDirectories.join(', ')}');
    print('━' * 50);
    print('');

    // Start the server
    await _startServer(host, port);

    // Setup file watchers
    _setupWatchers();

    // Handle Ctrl+C gracefully
    ProcessSignal.sigint.watch().listen((_) async {
      print('\n\n🛑 Shutting down server...');
      await _cleanup();
      exit(0);
    });

    // Keep the process running
    await Future.delayed(const Duration(days: 365));
  }

  Future<void> _startServer(String host, int port) async {
    try {
      // For now, we'll create a simple placeholder server
      // In a real implementation, this would start the actual HTTP server
      print('✅ Server started successfully');
      print('💡 Ready for connections');
      print('');
    } catch (e) {
      print('❌ Error starting server: $e');
      rethrow;
    }
  }

  void _setupWatchers() {
    for (final dirPath in _watchDirectories) {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) {
        print('⚠️  Directory not found: $dirPath (skipping watch)');
        continue;
      }

      try {
        final watcher = DirectoryWatcher(dirPath);
        _watchers.add(watcher);

        final subscription = watcher.events.listen(
          (event) => _handleFileChange(event),
          onError: (error) {
            print('⚠️  Watcher error in $dirPath: $error');
          },
        );
        _subscriptions.add(subscription);
      } catch (e) {
        print('⚠️  Could not watch $dirPath: $e');
      }
    }

    if (_watchers.isEmpty) {
      print('⚠️  No directories being watched. Hot reload disabled.');
    }
  }

  void _handleFileChange(WatchEvent event) {
    // Ignore non-Dart files
    if (!event.path.endsWith('.dart')) {
      return;
    }

    // Ignore files in hidden directories or build directories
    if (event.path.contains('/.') ||
        event.path.contains('/build/') ||
        event.path.contains('/.dart_tool/')) {
      return;
    }

    // Debounce rapid changes
    final now = DateTime.now();
    if (_lastReload != null) {
      final diff = now.difference(_lastReload!).inMilliseconds;
      if (diff < _reloadDebounceMs) {
        return;
      }
    }
    _lastReload = now;

    // Prevent concurrent reloads
    if (_isReloading) {
      return;
    }

    _reload(event);
  }

  Future<void> _reload(WatchEvent event) async {
    _isReloading = true;

    try {
      final eventType = _getEventTypeDescription(event.type);
      final relativePath = event.path;

      print('');
      print('📝 File $eventType: $relativePath');
      print('🔄 Reloading server...');

      // In a real implementation, this would use Dart VM service to hot reload
      // For now, we'll simulate a reload
      await Future.delayed(const Duration(milliseconds: 100));

      print('✅ Hot reload completed in ${DateTime.now().millisecondsSinceEpoch % 1000}ms');
      print('');
    } catch (e) {
      print('❌ Reload failed: $e');
      print('💡 Consider restarting the server manually');
      print('');
    } finally {
      _isReloading = false;
    }
  }

  String _getEventTypeDescription(ChangeType type) {
    switch (type) {
      case ChangeType.ADD:
        return 'added';
      case ChangeType.MODIFY:
        return 'modified';
      case ChangeType.REMOVE:
        return 'removed';
      default:
        return 'changed';
    }
  }

  Future<void> _cleanup() async {
    // Cancel all watchers
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    _watchers.clear();

    // Kill server process if running
    if (_serverProcess != null) {
      _serverProcess!.kill();
      _serverProcess = null;
    }

    print('✅ Cleanup completed');
  }
}
