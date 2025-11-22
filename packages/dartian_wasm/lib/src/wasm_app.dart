/// Base class for Dartian WebAssembly applications
library dartian_wasm.wasm_app;

import 'package:dartian_core/dartian_core.dart';

/// Configuration for WASM application deployment
class WasmConfig {
  final String name;
  final String platform;
  final int port;
  final String host;
  final bool debug;
  final Map<String, String> environment;

  const WasmConfig({
    this.name = 'dartian-app',
    this.platform = 'cloudflare',
    this.port = 8080,
    this.host = 'localhost',
    this.debug = false,
    this.environment = const {},
  });
}

/// Base class for WASM applications
abstract class WasmApp {
  final WasmConfig config;

  WasmApp({WasmConfig? config}) : config = config ?? const WasmConfig();

  /// Initialize the application
  Future<void> init() async {
    TelemetryHooks.triggerRequest({
      'event': 'init',
      'platform': config.platform,
    });
  }

  /// Handle request
  Future<String> handleRequest(
    String method,
    String url,
    Map<String, String> headers,
    String? body,
  ) async {
    final startTime = DateTime.now();
    TelemetryHooks.triggerRequest({'request': url});

    try {
      final response = await onHandleRequest(method, url, headers, body);
      final duration = DateTime.now().difference(startTime);
      TelemetryHooks.triggerResponse({'status': 200, 'url': url}, duration);
      return response;
    } catch (error) {
      final duration = DateTime.now().difference(startTime);
      TelemetryHooks.triggerResponse({
        'status': 500,
        'error': error.toString(),
      }, duration);
      rethrow;
    }
  }

  /// Abstract method to implement request handling
  Future<String> onHandleRequest(
    String method,
    String url,
    Map<String, String> headers,
    String? body,
  );

  /// Cleanup resources
  Future<void> dispose() async {}
}

/// Builder for creating WASM applications
class WasmAppBuilder {
  WasmConfig? _config;

  WasmAppBuilder config(WasmConfig config) {
    _config = config;
    return this;
  }

  WasmApp build(WasmApp Function(WasmConfig) createApp) {
    final config = _config ?? const WasmConfig();
    return createApp(config);
  }
}

/// Cloudflare Worker configuration
class CloudflareWorkerConfig extends WasmConfig {
  const CloudflareWorkerConfig({
    super.name = 'dartian-worker',
    super.debug = false,
    super.environment = const {},
  }) : super(platform: 'cloudflare');
}

/// Application for Cloudflare Workers
class CloudflareWorkerApp extends WasmApp {
  final Future<String> Function(
    String method,
    String url,
    Map<String, String> headers,
    String? body,
  )
  _handler;

  CloudflareWorkerApp(CloudflareWorkerConfig config, this._handler)
    : super(config: config);

  @override
  Future<String> onHandleRequest(
    String method,
    String url,
    Map<String, String> headers,
    String? body,
  ) async {
    return _handler(method, url, headers, body);
  }
}
