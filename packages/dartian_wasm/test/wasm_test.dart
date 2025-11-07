/// Tests for dartian_wasm package
library dartian_wasm.test;

import 'package:test/test.dart';
import 'package:dartian_wasm/dartian_wasm.dart';
import 'dart:typed_data';

void main() {
  group('WasmConfig', () {
    test('should create default config', () {
      final config = WasmConfig();
      expect(config.name, equals('dartian-app'));
      expect(config.platform, equals('cloudflare'));
      expect(config.port, equals(8080));
      expect(config.debug, isFalse);
    });

    test('should create custom config', () {
      final config = WasmConfig(
        name: 'test-app',
        platform: 'browser',
        port: 3000,
        debug: true,
      );
      expect(config.name, equals('test-app'));
      expect(config.platform, equals('browser'));
      expect(config.port, equals(3000));
      expect(config.debug, isTrue);
    });
  });

  group('WasmApp', () {
    test('should initialize app', () async {
      final app = TestWasmApp();
      await app.init();
      expect(app.initialized, isTrue);
    });

    test('should handle request', () async {
      final app = TestWasmApp();
      final response = await app.handleRequest('GET', '/', {}, null);
      expect(response, equals('OK'));
    });
  });

  group('CloudflareWorkerConfig', () {
    test('should create cloudflare config', () {
      final config = CloudflareWorkerConfig();
      expect(config.platform, equals('cloudflare'));
    });
  });

  group('CloudflareWorkerApp', () {
    test('should create worker app', () {
      final config = CloudflareWorkerConfig();
      final handler = (String method, String url, Map<String, String> headers, String? body) async => 'Worker response';
      final app = CloudflareWorkerApp(config, handler);
      expect(app, isNotNull);
    });

    test('should handle request', () async {
      final config = CloudflareWorkerConfig();
      final response = 'Hello Worker';
      final handler = (String method, String url, Map<String, String> headers, String? body) async => response;
      final app = CloudflareWorkerApp(config, handler);
      
      await app.init();
      final result = await app.onHandleRequest('GET', '/', {}, null);
      expect(result, equals(response));
    });
  });

  group('WasmRuntime', () {
    test('should check if WASM is supported', () {
      final supported = WasmRuntime.isSupported();
      expect(supported, isA<bool>());
    });

    test('should get supported features', () {
      final features = WasmRuntime.getSupportedFeatures();
      expect(features, isA<Map<String, bool>>());
      expect(features.containsKey('wasm_gc'), isTrue);
    });

    test('should validate WASM bytes', () {
      final bytes = Uint8List.fromList([0, 1, 2, 3]);
      final valid = WasmRuntime.validate(bytes);
      expect(valid, isTrue);
    });

    test('should compile WASM module', () async {
      final bytes = Uint8List.fromList([0, 1, 2, 3]);
      final runtime = WasmRuntime();
      final module = await runtime.compile(bytes);
      expect(module, isNotNull);
      expect(module, isA<WasmModuleProxy>());
    });
  });

  group('WasmModuleProxy', () {
    test('should create module proxy', () {
      final bytes = Uint8List.fromList([0, 1, 2, 3]);
      final module = WasmModuleProxy(bytes);
      expect(module, isNotNull);
    });

    test('should get exports', () {
      final bytes = Uint8List.fromList([0, 1, 2, 3]);
      final module = WasmModuleProxy(bytes);
      final exports = module.exports;
      expect(exports, isA<Map<String, Object>>());
    });

    test('should get function', () {
      final bytes = Uint8List.fromList([0, 1, 2, 3]);
      final module = WasmModuleProxy(bytes);
      final func = module.getFunction('test');
      expect(func, isNull); // No real function in placeholder
    });

    test('should throw when calling unimplemented function', () {
      final bytes = Uint8List.fromList([0, 1, 2, 3]);
      final module = WasmModuleProxy(bytes);
      expect(() => module.call<String>('test'), throwsA(isA<UnimplementedError>()));
    });
  });

  group('WasmWorker', () {
    test('should create worker', () {
      final handler = (WorkerMessage message) async => {'status': 'ok'};
      final worker = WasmWorker(name: 'test-worker', handler: handler);
      expect(worker, isNotNull);
      expect(worker.name, equals('test-worker'));
    });

    test('should initialize worker', () async {
      final handler = (WorkerMessage message) async => {'status': 'ok'};
      final worker = WasmWorker(name: 'test-worker', handler: handler);
      await worker.init(); // Should not throw
    });

    test('should send message', () async {
      final handler = (WorkerMessage message) async => {'result': 'ok'};
      final worker = WasmWorker(name: 'test-worker', handler: handler);
      await worker.init();

      final message = WorkerMessage(
        type: WorkerMessageType.request,
        data: {'url': '/'},
      );

      final response = await worker.sendMessage(message);
      expect(response, isNotNull);
      // Response returns message.data which is a map
      expect(response.containsKey('url'), isTrue);
    });
  });

  group('WorkerManager', () {
    test('should create manager', () {
      final manager = WorkerManager();
      expect(manager, isNotNull);
    });

    test('should get worker', () async {
      final manager = WorkerManager();
      final handler = (WorkerMessage message) async => {'status': 'ok'};
      
      final worker = await manager.getWorker('test-worker', handler);
      expect(worker, isNotNull);
      expect(worker.name, equals('test-worker'));
    });

    test('should terminate all workers', () {
      final manager = WorkerManager();
      manager.terminateAll(); // Should not throw
    });
  });

  group('MiddlewarePipeline', () {
    test('should create pipeline', () {
      final pipeline = MiddlewarePipeline();
      expect(pipeline, isNotNull);
    });

    test('should add middleware', () {
      final pipeline = MiddlewarePipeline();
      pipeline.use(TestMiddleware());
      expect(pipeline, isNotNull);
    });

    test('should execute pipeline', () async {
      final pipeline = MiddlewarePipeline();
      pipeline.use(TestMiddleware());
      
      final handler = (String method, String url, Map<String, String> headers, String? body) async => 'Response';
      final result = await pipeline.execute('GET', '/', {}, null, handler);
      expect(result, equals('Response'));
    });
  });

  group('CorsMiddleware', () {
    test('should create CORS middleware', () {
      final middleware = CorsMiddleware();
      expect(middleware, isNotNull);
    });

    test('should handle OPTIONS request', () async {
      final middleware = CorsMiddleware();
      final next = (String method, String url, Map<String, String> headers, String? body) async => 'OK';
      final result = await middleware.call('OPTIONS', '/', {}, null, next);
      expect(result, equals('OK'));
    });
  });
}

/// Test WasmApp implementation
class TestWasmApp extends WasmApp {
  bool initialized = false;

  TestWasmApp() : super();

  @override
  Future<String> onHandleRequest(String method, String url, Map<String, String> headers, String? body) async {
    return 'OK';
  }

  @override
  Future<void> init() async {
    await super.init();
    initialized = true;
  }
}

/// Test middleware implementation
class TestMiddleware implements WorkerMiddleware {
  @override
  Future<String> call(String method, String url, Map<String, String> headers, String? body, NextFunction next) async {
    return next(method, url, headers, body);
  }
}
