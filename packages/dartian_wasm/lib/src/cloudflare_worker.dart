/// Cloudflare Workers integration for Dartian WASM
library dartian_wasm.cloudflare_worker;

import 'dart:async';
import 'package:dartian_core/dartian_core.dart';

/// Cloudflare Worker event handler
typedef WorkerHandler = Future<String> Function(String method, String url, Map<String, String> headers, String? body);

/// Cloudflare Worker utility class
class CloudflareWorker {
  final WorkerHandler handler;

  CloudflareWorker(this.handler);

  /// Handle fetch event (called from JavaScript)
  static void handleFetch(Object event) {
    try {
      final eventObj = event as dynamic;
      final request = eventObj.request;
      final worker = _currentWorker;
      if (worker != null) {
        worker._handleRequest(request);
      }
    } catch (e) {
      // Silent fail in non-JS context
    }
  }

  static CloudflareWorker? _currentWorker;

  void _handleRequest(Object request) async {
    try {
      final response = await handler('GET', '/', {}, null);
      // Response handling would be done in JavaScript
    } catch (e) {
      // Silent fail in non-JS context
    }
  }

  /// Set this worker as the current instance
  void setAsCurrent() {
    _currentWorker = this;
  }
}

/// Utility for extracting request info
class WorkerRequestExtractor {
  /// Extract request method
  static String getMethod(Object request) {
    try {
      final method = (request as dynamic).method;
      if (method is String) return method;
    } catch (e) {
      // Silent fail
    }
    return 'GET';
  }

  /// Extract request URL
  static String getUrl(Object request) {
    try {
      final url = (request as dynamic).url;
      if (url is String) return url;
    } catch (e) {
      // Silent fail
    }
    return '';
  }

  /// Extract request headers
  static Map<String, String> getHeaders(Object request) {
    try {
      final headers = (request as dynamic).headers;
      if (headers is Map) {
        return Map<String, String>.from(headers);
      }
    } catch (e) {
      // Silent fail
    }
    return {};
  }

  /// Check if request is GET
  static bool isGet(Object request) => getMethod(request) == 'GET';

  /// Check if request is POST
  static bool isPost(Object request) => getMethod(request) == 'POST';

  /// Check if request is PUT
  static bool isPut(Object request) => getMethod(request) == 'PUT';

  /// Check if request is DELETE
  static bool isDelete(Object request) => getMethod(request) == 'DELETE';
}

/// Cloudflare Worker middleware system
abstract class WorkerMiddleware {
  Future<String> call(String method, String url, Map<String, String> headers, String? body, NextFunction next);
}

/// Next function in middleware chain
typedef NextFunction = Future<String> Function(String method, String url, Map<String, String> headers, String? body);

/// Middleware pipeline
class MiddlewarePipeline {
  final List<WorkerMiddleware> _middlewares = [];

  /// Add middleware to pipeline
  void use(WorkerMiddleware middleware) {
    _middlewares.add(middleware);
  }

  /// Execute pipeline
  Future<String> execute(String method, String url, Map<String, String> headers, String? body, WorkerHandler handler) async {
    NextFunction lastHandler = (m, u, h, b) async => handler(m, u, h, b);

    // Build middleware chain
    for (var i = _middlewares.length - 1; i >= 0; i--) {
      final middleware = _middlewares[i];
      final nextHandler = lastHandler;
      lastHandler = (m, u, h, b) => middleware.call(m, u, h, b, nextHandler);
    }

    return lastHandler(method, url, headers, body);
  }
}

/// CORS middleware for Workers
class CorsMiddleware implements WorkerMiddleware {
  @override
  Future<String> call(String method, String url, Map<String, String> headers, String? body, NextFunction next) async {
    if (method == 'OPTIONS') {
      return 'OK';
    }
    return next(method, url, headers, body);
  }
}

/// Logging middleware
class LoggingMiddleware implements WorkerMiddleware {
  @override
  Future<String> call(String method, String url, Map<String, String> headers, String? body, NextFunction next) async {
    // Log the request (would use telemetry in real implementation)
    return next(method, url, headers, body);
  }
}
