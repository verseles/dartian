import 'package:shelf/shelf.dart';
import 'dart:convert';

class DartianResponse extends Response {
  DartianResponse.ok(super.body, {super.headers}) : super.ok();
  DartianResponse.text(String body, {int status = 200}) : super(status, body: body, headers: {'content-type': 'text/plain'});

  static Response json(Map<String, dynamic> data, {int status = 200}) {
    return Response(
      status,
      body: jsonEncode(data),
      headers: {'content-type': 'application/json'},
    );
  }
}
