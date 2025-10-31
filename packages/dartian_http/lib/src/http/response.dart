import 'package:shelf/shelf.dart';
import 'dart:convert';

class DartianResponse extends Response {
  DartianResponse.ok(body, {Map<String, String>? headers}) : super.ok(body, headers: headers);
  DartianResponse.text(String body, {int status = 200}) : super(status, body: body, headers: {'content-type': 'text/plain'});

  static Response json(Map<String, dynamic> data, {int status = 200}) {
    return Response(
      status,
      body: jsonEncode(data),
      headers: {'content-type': 'application/json'},
    );
  }
}
