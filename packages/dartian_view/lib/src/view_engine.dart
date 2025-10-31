import 'dart:io';
import 'package:mustache_template/mustache_template.dart';
import 'package:path/path.dart' as p;
import 'package:dartian_http/dartian_http.dart';

class ViewEngine {
  final String _viewsPath;
  final String _partialsPath;
  final Map<String, Template> _cache = {};

  ViewEngine(String viewsPath)
      : _viewsPath = viewsPath,
        _partialsPath = p.join(viewsPath, 'partials');

  String render(String templateName, Map<String, dynamic> data) {
    final template = _loadTemplate(templateName);
    return template.renderString(data);
  }

  Template _loadTemplate(String name, {bool isPartial = false}) {
    if (_cache.containsKey(name)) {
      return _cache[name]!;
    }

    final basePath = isPartial ? _partialsPath : _viewsPath;
    final path = p.join(basePath, '$name.mustache');
    final file = File(path);

    if (!file.existsSync()) {
      throw Exception('View template not found: $path');
    }

    final content = file.readAsStringSync();
    final template = Template(content, name: name, partialResolver: _partialResolver);
    _cache[name] = template;
    return template;
  }

  Template? _partialResolver(String name) {
    try {
      return _loadTemplate(name, isPartial: true);
    } catch (_) {
      return null;
    }
  }
}

extension ViewResponse on DartianResponse {
  static DartianResponse view(
    ViewEngine engine,
    String templateName,
    Map<String, dynamic> data,
  ) {
    final content = engine.render(templateName, data);
    return DartianResponse.ok(content)..headers['content-type'] = 'text/html';
  }
}
