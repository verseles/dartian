import 'dart:io';
import 'dart:convert';
import 'package:mustache_template/mustache.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:dartian_i18n/dartian_i18n.dart';

/// View class for rendering mustache templates
class View {
  final String templatePath;
  final Map<String, dynamic> data;
  final String? layout;

  View({
    required this.templatePath,
    required this.data,
    this.layout,
  });

  /// Render the view with mustache
  String render() {
    // Read the main template
    final templateContent = _readTemplate(templatePath);
    final template = Template(templateContent, name: templatePath);

    // Prepare data with i18n helpers
    final viewData = Map<String, dynamic>.from(data);

    // Add i18n helpers to template data
    viewData['__'] = (String key, [Map<String, dynamic>? params]) {
      return i18n.trans(key, params: params);
    };

    // Render the main template
    final rendered = template.renderString(viewData);

    // If layout is specified, wrap the rendered content
    if (layout != null) {
      final layoutContent = _readTemplate(layout!);
      final layoutTemplate = Template(layoutContent, name: layout!);
      final layoutData = Map<String, dynamic>.from(data);
      layoutData['content'] = rendered;
      layoutData['__'] = viewData['__'];
      return layoutTemplate.renderString(layoutData);
    }

    return rendered;
  }

  /// Render and return a Shelf Response
  shelf.Response toResponse({int status = 200}) {
    final html = render();
    return shelf.Response(
      status,
      headers: {'Content-Type': 'text/html; charset=utf-8'},
      body: html,
    );
  }

  /// Read template file
  String _readTemplate(String path) {
    // Convert path to file path (e.g., 'users/list' -> 'resources/views/users/list.mustache')
    final filePath = _resolvePath(path);

    final file = File(filePath);
    if (!file.existsSync()) {
      throw TemplateNotFoundException('Template not found: $path ($filePath)');
    }

    return file.readAsStringSync();
  }

  /// Resolve template path
  String _resolvePath(String path) {
    // Handle different path formats
    if (path.endsWith('.mustache')) {
      return 'resources/views/$path';
    } else {
      return 'resources/views/$path.mustache';
    }
  }
}

/// Helper function to create a View and render to Shelf Response
shelf.Response render(View view, {int status = 200}) {
  return view.toResponse(status: status);
}

/// Helper function for HTTP kernel integration
shelf.Response viewResponse(
  String template, {
  required Map<String, dynamic> data,
  String? layout,
  int status = 200,
}) {
  return View(
    templatePath: template,
    data: data,
    layout: layout,
  ).toResponse(status: status);
}

/// JSON response helper
shelf.Response jsonResponse(
  Map<String, dynamic> data, {
  int status = 200,
}) {
  return shelf.Response(
    status,
    headers: {'Content-Type': 'application/json; charset=utf-8'},
    body: jsonEncode(data),
  );
}

/// Text response helper
shelf.Response textResponse(
  String text, {
  int status = 200,
}) {
  return shelf.Response(
    status,
    headers: {'Content-Type': 'text/plain; charset=utf-8'},
    body: text,
  );
}

/// Exception for template not found
class TemplateNotFoundException implements Exception {
  final String message;
  TemplateNotFoundException(this.message);

  @override
  String toString() => 'TemplateNotFoundException: $message';
}
