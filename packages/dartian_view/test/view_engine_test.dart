import 'dart:io';
import 'package:dartian_view/dartian_view.dart';
import 'package:test/test.dart';

void main() {
  group('ViewEngine', () {
    late ViewEngine engine;
    final testViewsPath = 'test/views';

    setUp(() {
      engine = ViewEngine(testViewsPath);
      Directory(testViewsPath).createSync(recursive: true);
    });

    tearDown(() {
      final dir = Directory(testViewsPath);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    });

    test('renders a simple template', () {
      _createTemplate('simple', 'Hello, {{name}}!');
      final result = engine.render('simple', {'name': 'World'});
      expect(result, 'Hello, World!');
    });

    test('caches templates', () {
      _createTemplate('cached', 'This is a cached template.');
      engine.render('cached', {});
      File('$testViewsPath/cached.mustache').deleteSync();
      final result = engine.render('cached', {});
      expect(result, 'This is a cached template.');
    });

    test('renders templates with partials', () {
      _createTemplate('main', '<h1>{{> partial}}</h1>');
      _createTemplate('partials/partial', 'Partial Content');
      final result = engine.render('main', {});
      expect(result, '<h1>Partial Content</h1>');
    });

    test('throws exception for missing template', () {
      expect(
        () => engine.render('non_existent', {}),
        throwsA(isA<Exception>()),
      );
    });
  });
}

void _createTemplate(String name, String content) {
  final file = File('test/views/$name.mustache');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(content);
}
