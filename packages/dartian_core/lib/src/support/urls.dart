// ignore_for_file: non_constant_identifier_names, avoid_classes_with_only_static_members, avoid_positional_boolean_parameters

class UrlGenerator {
  static String Function(String path, [List<dynamic>? parameters, bool? secure])? toCallback;
  static String Function(String name, [Map<String, dynamic>? parameters, bool? absolute])? routeCallback;
  static String Function(String path, [bool? secure])? assetCallback;
}

/// Generate the URL to a controller action.
String action(String action, [Map<String, dynamic>? parameters, bool? absolute]) {
  // Simplified: treat action as route name or handle via route
  return route(action, parameters, absolute);
}

/// Generate an asset path for the application.
String asset(String path, [bool? secure]) {
  return UrlGenerator.assetCallback?.call(path, secure) ?? path;
}

/// Generate the URL to a named route.
String route(String name, [Map<String, dynamic>? parameters, bool? absolute]) {
  return UrlGenerator.routeCallback?.call(name, parameters, absolute) ?? name;
}

/// Generate a secure asset path for the application.
String secure_asset(String path) {
  return asset(path, true);
}

/// Generate a secure url for the application.
String secure_url(String path, [List<dynamic>? parameters]) {
  return url(path, parameters, true);
}

/// Generate a url for the application.
String url(String path, [List<dynamic>? parameters, bool? secure]) {
  return UrlGenerator.toCallback?.call(path, parameters, secure) ?? path;
}

// Aliases or stubs
String to_route(String name, [Map<String, dynamic>? parameters, bool? absolute]) => route(name, parameters, absolute);
// to_action...
