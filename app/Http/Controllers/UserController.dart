import 'package:shelf/shelf.dart';

class UserController {
  /// Handle incoming request
  Future<Response> index(Request request) async {
    return Response.ok('Welcome to UserController');
  }

  /// Show a specific resource
  Future<Response> show(Request request, String id) async {
    return Response.ok('Showing resource: $id');
  }

  /// Create a new resource
  Future<Response> store(Request request) async {
    return Response.ok('Resource created');
  }

  /// Update an existing resource
  Future<Response> update(Request request, String id) async {
    return Response.ok('Resource $id updated');
  }

  /// Delete a resource
  Future<Response> destroy(Request request, String id) async {
    return Response.ok('Resource $id deleted');
  }
}
