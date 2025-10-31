import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

class HttpKernel {
  HttpServer? _server;
  HttpServer? get server => _server;

  Future<void> start(Handler handler, {int port = 8080}) async {
    _server = await io.serve(handler, '0.0.0.0', port);
    print('Server listening on port ${_server!.port}');
  }

  Future<void> stop() async {
    await _server?.close();
  }
}
