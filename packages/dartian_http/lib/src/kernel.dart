import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:dartian_core/dartian_core.dart';

/// HTTP Kernel for handling HTTP requests
class HttpKernel {
  final List<Middleware> _middleware = [];
  Handler? _handler;

  /// Add middleware to the pipeline
  void use(Middleware middleware) {
    _middleware.add(middleware);
  }

  /// Handle a request and return a response
  Future<Response> handle(Request request) async {
    if (_handler == null) {
      return Response.internalServerError(body: 'No handler registered');
    }

    // Trigger request start hooks
    TelemetryHooks.triggerRequest(request);

    // Track response time
    final startTime = DateTime.now();

    try {
      final response = await _handler!(request);

      // Calculate duration
      final duration = DateTime.now().difference(startTime);

      // Trigger response complete hooks
      TelemetryHooks.triggerResponse(response, duration);

      return response;
    } catch (error) {
      // Calculate duration even for errors
      final duration = DateTime.now().difference(startTime);

      // Trigger response complete hooks for error responses
      final errorResponse = Response.internalServerError(
        body: 'Internal Server Error',
      );
      TelemetryHooks.triggerResponse(errorResponse, duration);

      rethrow;
    }
  }

  /// Set the request handler
  void setHandler(Handler handler) {
    // Apply all middleware to the handler
    var currentHandler = handler;
    for (var middleware in _middleware.reversed) {
      currentHandler = middleware(currentHandler);
    }
    _handler = currentHandler;
  }

  /// Start the HTTP server
  Future<HttpServer> listen(String host, int port) async {
    if (_handler == null) {
      throw StateError('No handler registered. Call setHandler() first.');
    }

    final server = await serve(_handler!, host, port);
    print('Server listening on http://$host:$port');
    return server;
  }
}
