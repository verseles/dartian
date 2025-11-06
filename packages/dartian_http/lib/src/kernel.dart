import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

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
      return Response.internalServerError(
        body: 'No handler registered',
      );
    }

    return await _handler!(request);
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
