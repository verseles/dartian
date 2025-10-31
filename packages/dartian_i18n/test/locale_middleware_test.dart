import 'dart:io';
import 'package:dartian_i18n/src/translator.dart';
import 'package:dartian_i18n/src/locale_middleware.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('Locale Middleware', () {
    test('sets locale from query parameter', () async {
      final tempDir = Directory.systemTemp.createTempSync('dartian_i18n_test_');
      final translator = Translator(tempDir.path);
      await _createLangFile(tempDir.path, 'fr', "'hello': 'Bonjour!'");
      await translator.load('fr');

      final middleware = createLocaleMiddleware(translator);
      final handler = middleware((Request request) {
        expect(translator.translate('hello'), 'Bonjour!');
        return Response.ok('');
      });

      final request = Request('GET', Uri.parse('http://localhost/?lang=fr'));
      await handler(request);
    });
  });
}

Future<void> _createLangFile(String basePath, String locale, String content) async {
  final file = File('$basePath/$locale/messages.dart');
  await file.parent.create(recursive: true);
  await file.writeAsString('const messages = {$content};');
}
