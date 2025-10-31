import 'dart:async';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:dartian_http/dartian_http.dart';
import 'package:dartian_di/dartian_di.dart';

class Router {
  final shelf_router.Router _router;
  final Container? _container;
  final Map<String, String> _namedRoutes = {};
  List<Middleware> _middlewares = [];

  Router({List<Middleware> middlewares = const [], Container? container})
      : _router = shelf_router.Router(),
        _container = container {
    _middlewares = middlewares;
  }

  void get<T extends Object>(String path, Function handler, {String? name}) {
    _addRoute<T>('GET', path, handler, name: name);
  }

  void post<T extends Object>(String path, Function handler, {String? name}) {
    _addRoute<T>('POST', path, handler, name: name);
  }

  void put<T extends Object>(String path, Function handler, {String? name}) {
    _addRoute<T>('PUT', path, handler, name: name);
  }

  void delete<T extends Object>(String path, Function handler, {String? name}) {
    _addRoute<T>('DELETE', path, handler, name: name);
  }

  void group(String prefix, Function(Router) callback) {
    final groupRouter = Router(middlewares: _middlewares, container: _container);
    callback(groupRouter);
    _router.mount(prefix, groupRouter.handler);
    groupRouter._namedRoutes.forEach((name, path) {
      _namedRoutes[name] = '$prefix$path';
    });
  }

  String? route(String name, [Map<String, String> params = const {}]) {
    var path = _namedRoutes[name];
    if (path == null) return null;
    params.forEach((key, value) {
      path = path!.replaceAll('<$key>', value);
    });
    return path;
  }

  void _addRoute<T extends Object>(String method, String path, Function handler, {String? name}) {
    if (name != null) {
      _namedRoutes[name] = path;
    }

    var pipeline = Pipeline();
    for (var middleware in _middlewares) {
      pipeline = pipeline.addMiddleware(middleware);
    }

    final routeHandler = (Request request) {
      dynamic response;
      if (handler is Function(Request)) {
        response = handler(request);
      } else if (_container != null) {
        final controller = _container!.resolve<T>();
        response = (handler(controller) as Function(Request))(request);
      } else {
        throw Exception('Invalid handler type');
      }
      return response as FutureOr<Response>;
    };

    _router.add(method, path, pipeline.addHandler(routeHandler));
  }

  Handler get handler => _router;
}
