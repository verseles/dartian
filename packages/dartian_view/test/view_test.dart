import 'package:test/test.dart';
import 'package:dartian_view/dartian_view.dart';
import 'dart:io';

void main() {
  group('View', () {
    setUp(() {
      // Create test directories
      final viewsDir = Directory('resources/views');
      if (!viewsDir.existsSync()) {
        viewsDir.createSync(recursive: true);
      }
      // Create layouts directory
      final layoutsDir = Directory('resources/views/layouts');
      if (!layoutsDir.existsSync()) {
        layoutsDir.createSync(recursive: true);
      }
    });

    tearDown(() {
      // Clean up test files
      final viewsDir = Directory('resources/views');
      if (viewsDir.existsSync()) {
        viewsDir.deleteSync(recursive: true);
      }
    });

    test('should render basic template with variables', () {
      // Create a test template
      File('resources/views/test.mustache')
        ..writeAsStringSync('<h1>{{title}}</h1><p>{{message}}</p>');

      final view = View(
        templatePath: 'test',
        data: {'title': 'Hello', 'message': 'World'},
      );

      final result = view.render();

      expect(result, contains('<h1>Hello</h1>'));
      expect(result, contains('<p>World</p>'));
    });

    test('should escape HTML by default', () {
      // Create a test template
      File('resources/views/escape.mustache')
        ..writeAsStringSync('<p>{{content}}</p>');

      final view = View(
        templatePath: 'escape',
        data: {'content': '<script>alert("XSS")</script>'},
      );

      final result = view.render();

      expect(result, contains('&lt;script&gt;'));
      expect(result, isNot(contains('<script>')));
    });

    test('should handle lists', () {
      // Create a test template
      File('resources/views/list.mustache')..writeAsStringSync('''<ul>
{{#items}}
  <li>{{.}}</li>
{{/items}}
</ul>''');

      final view = View(
        templatePath: 'list',
        data: {
          'items': ['Item 1', 'Item 2', 'Item 3'],
        },
      );

      final result = view.render();

      expect(result, contains('Item 1'));
      expect(result, contains('Item 2'));
      expect(result, contains('Item 3'));
    });

    test('should handle conditionals', () {
      // Create a test template
      File('resources/views/conditional.mustache')
        ..writeAsStringSync('''{{#show}}
<p>Visible</p>
{{/show}}
{{^show}}
<p>Hidden</p>
{{/show}}''');

      final view = View(templatePath: 'conditional', data: {'show': true});

      final result = view.render();

      expect(result, contains('Visible'));
      expect(result, isNot(contains('Hidden')));
    });

    test('should support layouts', () {
      // Create a layout template
      File('resources/views/layouts/main.mustache')
        ..writeAsStringSync('''<!DOCTYPE html>
<html>
<head>
  <title>{{title}}</title>
</head>
<body>
  <div id="content">
    {{{content}}}
  </div>
</body>
</html>''');

      // Create a content template
      File('resources/views/home.mustache')
        ..writeAsStringSync('<h1>Welcome</h1><p>Home page</p>');

      final view = View(
        templatePath: 'home',
        data: {'title': 'Home Page'},
        layout: 'layouts/main',
      );

      final result = view.render();

      expect(result, contains('<title>Home Page</title>'));
      expect(result, contains('<h1>Welcome</h1>'));
      expect(result, contains('<p>Home page</p>'));
      expect(result, contains('<div id="content">'));
    });

    test('should throw exception when template not found', () {
      final view = View(templatePath: 'nonexistent', data: {});

      expect(() => view.render(), throwsA(isA<TemplateNotFoundException>()));
    });

    test('should support template path with .mustache extension', () {
      // Create a test template
      File('resources/views/explicit.mustache')
        ..writeAsStringSync('<p>{{text}}</p>');

      final view = View(
        templatePath: 'explicit.mustache',
        data: {'text': 'Explicit extension'},
      );

      final result = view.render();

      expect(result, contains('Explicit extension'));
    });

    test('should support i18n translation through data', () {
      // Create a test template
      File('resources/views/i18n_test.mustache')
        ..writeAsStringSync('<p>{{welcome_message}}</p>');

      final view = View(
        templatePath: 'i18n_test',
        data: {
          'welcome_message':
              'Welcome', // In real usage, this would come from i18n
        },
      );

      final result = view.render();

      expect(result, contains('Welcome'));
    });

    test('should render to response with status 200', () {
      // Create a test template
      File('resources/views/response.mustache')
        ..writeAsStringSync('<p>{{message}}</p>');

      final view = View(templatePath: 'response', data: {'message': 'Test'});

      final response = view.toResponse();

      expect(response.statusCode, equals(200));
      expect(response.headers['Content-Type'], contains('text/html'));
    });

    test('should render to response with custom status', () {
      // Create a test template
      File('resources/views/error.mustache')..writeAsStringSync('<p>Error</p>');

      final view = View(templatePath: 'error', data: {});

      final response = view.toResponse(status: 404);

      expect(response.statusCode, equals(404));
    });
  });

  group('Response helpers', () {
    setUp(() {
      // Create test directories
      final viewsDir = Directory('resources/views');
      if (!viewsDir.existsSync()) {
        viewsDir.createSync(recursive: true);
      }
    });

    tearDown(() {
      final viewsDir = Directory('resources/views');
      if (viewsDir.existsSync()) {
        viewsDir.deleteSync(recursive: true);
      }
    });

    test('should create HTML response from view', () {
      // Create a test template
      File('resources/views/index.mustache')
        ..writeAsStringSync('<h1>{{title}}</h1>');

      final response = viewResponse('index', data: {'title': 'Home'});

      expect(response.statusCode, equals(200));
      expect(response.headers['Content-Type'], contains('text/html'));
    });

    test('should create JSON response', () {
      final response = jsonResponse({
        'status': 'success',
        'data': {'id': 1, 'name': 'Test'},
      });

      expect(response.statusCode, equals(200));
      expect(response.headers['Content-Type'], contains('application/json'));
    });

    test('should create text response', () {
      final response = textResponse('Plain text response');

      expect(response.statusCode, equals(200));
      expect(response.headers['Content-Type'], contains('text/plain'));
    });

    test('should create JSON response with custom status', () {
      final response = jsonResponse({'error': 'Not found'}, status: 404);

      expect(response.statusCode, equals(404));
    });

    test('should use render helper function', () {
      // Create a test template
      File('resources/views/render_helper.mustache')
        ..writeAsStringSync('<p>{{message}}</p>');

      final view = View(
        templatePath: 'render_helper',
        data: {'message': 'Using render helper'},
      );

      final response = render(view);

      expect(response.statusCode, equals(200));
      expect(response.headers['Content-Type'], contains('text/html'));
    });

    test('should use render helper with custom status', () {
      // Create a test template
      File('resources/views/render_error.mustache')
        ..writeAsStringSync('<p>Error</p>');

      final view = View(templatePath: 'render_error', data: {});

      final response = render(view, status: 500);

      expect(response.statusCode, equals(500));
    });
  });

  group('TemplateNotFoundException', () {
    test('should have correct message', () {
      final exception = TemplateNotFoundException('Test template');
      expect(exception.message, equals('Test template'));
      expect(exception.toString(), contains('TemplateNotFoundException'));
    });
  });
}
