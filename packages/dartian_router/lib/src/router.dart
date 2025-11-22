import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart' as shelf_router;

/// A fluent DSL for building routes
class Router {
  final shelf_router.Router _router;
  final String? _prefix;
  final Map<String, String> _namedRoutes = {};

  Router({String? prefix}) : _router = shelf_router.Router(), _prefix = prefix;

  /// Add a GET route
  Router get(String pattern, Handler handler, {String? name}) {
    final fullPattern = _prefix != null ? '$_prefix$pattern' : pattern;
    _router.get(pattern, handler);
    if (name != null) {
      _namedRoutes[name] = fullPattern;
    }
    return this;
  }

  /// Add a POST route
  Router post(String pattern, Handler handler, {String? name}) {
    final fullPattern = _prefix != null ? '$_prefix$pattern' : pattern;
    _router.post(pattern, handler);
    if (name != null) {
      _namedRoutes[name] = fullPattern;
    }
    return this;
  }

  /// Add a PUT route
  Router put(String pattern, Handler handler, {String? name}) {
    final fullPattern = _prefix != null ? '$_prefix$pattern' : pattern;
    _router.put(pattern, handler);
    if (name != null) {
      _namedRoutes[name] = fullPattern;
    }
    return this;
  }

  /// Add a DELETE route
  Router delete(String pattern, Handler handler, {String? name}) {
    final fullPattern = _prefix != null ? '$_prefix$pattern' : pattern;
    _router.delete(pattern, handler);
    if (name != null) {
      _namedRoutes[name] = fullPattern;
    }
    return this;
  }

  /// Create a route group with a common prefix
  Router group(String pattern, void Function(Router router) callback) {
    final subRouter = Router(
      prefix: _prefix != null ? '$_prefix$pattern' : pattern,
    );
    callback(subRouter);
    _mergeRouter(subRouter);
    return this;
  }

  /// Get the underlying shelf Router
  shelf_router.Router get shelfRouter => _router;

  /// Get a named route pattern
  String? getRoute(String name) {
    return _namedRoutes[name];
  }

  void _mergeRouter(Router other) {
    // Named routes are already merged during route registration
  }
}
