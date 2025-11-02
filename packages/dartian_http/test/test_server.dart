import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:dartian_http/dartian_http.dart';

class TestServer {
  HttpServer? _server;
  int? get port => _server?.port;

  Future<void> start(Handler handler) async {
    final kernel = HttpKernel();
    await kernel.start(handler);
    _server = kernel.server;
  }

  Future<void> stop() async {
    await _server?.close(force: true);
  }
}
