import 'dart:convert';
import 'package:shelf/shelf.dart';

/// Create a JSON response
Response jsonResponse(Map<String, dynamic> data, {int status = 200}) {
  return Response(
    status,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
    },
    body: json.encode(data),
  );
}

/// Create an HTML response
Response htmlResponse(String content, {int status = 200}) {
  return Response(
    status,
    headers: {
      'Content-Type': 'text/html; charset=utf-8',
    },
    body: content,
  );
}

/// Create a plain text response
Response textResponse(String content, {int status = 200}) {
  return Response(
    status,
    headers: {
      'Content-Type': 'text/plain; charset=utf-8',
    },
    body: content,
  );
}

/// Create a 404 Not Found response
Response notFound([String? message]) {
  return textResponse(
    message ?? 'Not Found',
    status: 404,
  );
}

/// Create a 500 Internal Server Error response
Response serverError([String? message]) {
  return textResponse(
    message ?? 'Internal Server Error',
    status: 500,
  );
}
