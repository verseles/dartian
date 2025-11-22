import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dartian_http/dartian_http.dart';
import 'package:hotreloader/hotreloader.dart';
import 'package:shelf/shelf.dart';
import 'package:watcher/watcher.dart';

class ServeCommand {
  static const defaultHost = 'localhost';
  static const defaultPort = 8000;

  final List<String> _watchDirectories = ['lib', 'app', 'routes', 'resources'];

  HttpServer? _server;
  HotReloader? _hotReloader;
  final List<DirectoryWatcher> _watchers = [];
  final List<StreamSubscription> _subscriptions = [];
  bool _isReloading = false;
  DateTime? _lastReload;
  static const _reloadDebounceMs = 500;

  Future<void> run(List<String> arguments) async {
    final parser = ArgParser()
      ..addOption(
        'host',
        abbr: 'h',
        defaultsTo: defaultHost,
        help: 'The host to bind to',
      )
      ..addOption(
        'port',
        abbr: 'p',
        defaultsTo: '$defaultPort',
        help: 'The port to bind to',
      );

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
      // Initialize HotReloader for automatic code reload
      _hotReloader = await HotReloader.create(
        debounceInterval: const Duration(milliseconds: _reloadDebounceMs),
        onAfterReload: (ctx) {
          print('✅ Hot reload completed successfully');
          print('');
        },
      );

      // Create HTTP kernel with basic handler
      final kernel = HttpKernel();

      // Add a simple logging middleware
      kernel.use((Handler handler) {
        return (Request request) async {
          final startTime = DateTime.now();
          final response = await handler(request);
          final duration = DateTime.now().difference(startTime);

          print(
            '[${startTime.toIso8601String()}] ${request.method} ${request.requestedUri.path} - ${response.statusCode} (${duration.inMilliseconds}ms)',
          );

          return response;
        };
      });

      // Set default handler (returns welcome page for all routes)
      // In a real app, this would load routes from routes/ directory
      kernel.setHandler((Request request) {
        return Response.ok(
          '<h1>Dartian Development Server</h1> '
          '<p>Server is running at http://$host:$port</p> '
          '<p>Add your routes in the <code>routes/</code> directory.</p>',
          headers: {'Content-Type': 'text/html'},
        );
      });

      // Start the server
      _server = await kernel.listen(host, port);

      print('✅ Server started successfully');
      print('💡 Ready for connections');
      print('🔥 Hot reload enabled');
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
          _handleFileChange,
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

      // Trigger hot reload via HotReloader
      if (_hotReloader != null) {
        final startTime = DateTime.now();
        await _hotReloader!.reloadCode();
        final duration = DateTime.now().difference(startTime);
        print('✅ Hot reload completed in ${duration.inMilliseconds}ms');
      } else {
        print('⚠️  HotReloader not initialized, skipping reload');
      }

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

    // Stop hot reloader
    if (_hotReloader != null) {
      await _hotReloader!.stop();
      _hotReloader = null;
    }

    // Stop HTTP server
    if (_server != null) {
      await _server!.close(force: true);
      _server = null;
    }

    print('✅ Cleanup completed');
  }
}
