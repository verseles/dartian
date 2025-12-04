// ignore_for_file: non_constant_identifier_names, avoid_classes_with_only_static_members

class Paths {
  static String _basePath = '';

  static void setBasePath(String path) {
    _basePath = path;
  }

  static String get basePath => _basePath;
}

String _joinPaths(String base, String path) {
  if (path.isEmpty) return base;
  if (base.endsWith('/')) return '$base$path';
  if (path.startsWith('/')) return '$base$path';
  return '$base/$path';
}

/// Get the path to the application folder.
String app_path([String path = '']) {
  return _joinPaths(_joinPaths(Paths.basePath, 'app'), path);
}

/// Get the path to the base of the install.
String base_path([String path = '']) {
  return _joinPaths(Paths.basePath, path);
}

/// Get the path to the config folder.
String config_path([String path = '']) {
  return _joinPaths(_joinPaths(Paths.basePath, 'config'), path);
}

/// Get the path to the database folder.
String database_path([String path = '']) {
  return _joinPaths(_joinPaths(Paths.basePath, 'database'), path);
}

/// Get the path to the language folder.
String lang_path([String path = '']) {
  return _joinPaths(_joinPaths(Paths.basePath, 'lang'), path);
}

/// Get the path to the public folder.
String public_path([String path = '']) {
  return _joinPaths(_joinPaths(Paths.basePath, 'public'), path);
}

/// Get the path to the resources folder.
String resource_path([String path = '']) {
  return _joinPaths(_joinPaths(Paths.basePath, 'resources'), path);
}

/// Get the path to the storage folder.
String storage_path([String path = '']) {
  return _joinPaths(_joinPaths(Paths.basePath, 'storage'), path);
}
