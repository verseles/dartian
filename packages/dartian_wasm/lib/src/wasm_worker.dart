/// Web Worker integration for WASM
library dartian_wasm.wasm_worker;

import 'dart:async';

/// Web Worker message types
class WorkerMessageType {
  static const String init = 'init';
  static const String request = 'request';
  static const String response = 'response';
  static const String error = 'error';
}

/// Message sent to/from worker
class WorkerMessage {
  final String type;
  final Map<String, Object> data;
  final String? id;

  WorkerMessage({
    required this.type,
    required this.data,
    this.id,
  });
}

/// Worker message handler
typedef WorkerMessageHandler = Future<Map<String, Object>> Function(WorkerMessage message);

/// Web Worker for background processing
class WasmWorker {
  final String name;
  final WorkerMessageHandler handler;
  final Map<String, Completer<Map<String, Object>>> _pending = {};
  int _messageId = 0;

  WasmWorker({required this.name, required this.handler});

  /// Initialize worker
  Future<void> init() async {
    // Placeholder - would initialize Worker in JS context
  }

  /// Send message to worker
  Future<Map<String, Object>> sendMessage(WorkerMessage message) {
    final completer = Completer<Map<String, Object>>();
    final id = message.id ?? 'msg_${_messageId++}';

    _pending[id] = completer;

    // Placeholder - would post to Worker in JS context
    Future.delayed(const Duration(milliseconds: 10), () {
      if (!completer.isCompleted) {
        completer.complete(message.data);
      }
    });

    return completer.future;
  }

  /// Terminate worker
  void terminate() {
    // Placeholder
  }
}

/// Worker manager for multiple workers
class WorkerManager {
  final Map<String, WasmWorker> _workers = {};
  final int maxWorkers;

  WorkerManager({this.maxWorkers = 4});

  /// Create or get worker
  Future<WasmWorker> getWorker(String name, WorkerMessageHandler handler) async {
    if (_workers.containsKey(name)) {
      return _workers[name]!;
    }

    if (_workers.length >= maxWorkers) {
      // Remove oldest worker
      final oldest = _workers.keys.first;
      _workers.remove(oldest);
    }

    final worker = WasmWorker(name: name, handler: handler);
    await worker.init();
    _workers[name] = worker;

    return worker;
  }

  /// Terminate all workers
  void terminateAll() {
    for (final worker in _workers.values) {
      worker.terminate();
    }
    _workers.clear();
  }
}
