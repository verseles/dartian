import 'package:dartian_i18n/src/translator.dart';
import 'package:test/test.dart';
import 'dart:io';

void main() {
  group('Translator', () {
    late Translator translator;

    setUp(() async {
      final tempDir = Directory.systemTemp.createTempSync('dartian_i18n_test_');
      final enDir = await Directory('${tempDir.path}/en').create();
      await File('${enDir.path}/messages.dart').writeAsString('''
        const messages = {
          'welcome': 'Welcome!',
          'greeting': 'Hello, :name!',
          'items': 'There is one item.|There are :count items.',
        };
      ''');
      translator = Translator(tempDir.path);
      await translator.load('en');
    });

    test('loads translations', () {
      expect(translator.translate('welcome'), 'Welcome!');
    });

    test('translates with placeholders', () {
      expect(translator.translate('greeting', {'name': 'World'}), 'Hello, World!');
    });

    test('handles pluralization', () {
      expect(translator.translate('items', {'count': '1'}), 'There is one item.');
      expect(translator.translate('items', {'count': '2'}), 'There are 2 items.');
      expect(translator.translate('items', {'count': '0'}), 'There are 0 items.');
    });

    test('returns key for missing translation', () {
      expect(translator.translate('missing.key'), 'missing.key');
    });
  });
}
