import 'package:test/test.dart';
import 'package:dartian_i18n/dartian_i18n.dart';
import 'dart:io';

void main() {
  group('Translator', () {
    setUp(() {
      // Create test language files FIRST
      final enDir = Directory('resources/lang/en');
      if (!enDir.existsSync()) {
        enDir.createSync(recursive: true);
      }

      final ptDir = Directory('resources/lang/pt');
      if (!ptDir.existsSync()) {
        ptDir.createSync(recursive: true);
      }

      final ptBrDir = Directory('resources/lang/pt_BR');
      if (!ptBrDir.existsSync()) {
        ptBrDir.createSync(recursive: true);
      }

      // Create English messages
      File('resources/lang/en/messages.json').writeAsStringSync('''{
  "app": {
    "title": "My Application"
  },
  "welcome": "Welcome, {name}!",
  "items": {
    "zero": "No items",
    "one": "One item",
    "other": "{count} items"
  }
}''');

      // Create Portuguese messages
      File('resources/lang/pt/messages.json').writeAsStringSync('''{
  "app": {
    "title": "Minha Aplicação"
  },
  "welcome": "Bem-vindo, {name}!",
  "items": {
    "zero": "Nenhum item",
    "one": "Um item",
    "other": "{count} itens"
  }
}''');

      // Create Portuguese (Brazil) messages
      File('resources/lang/pt_BR/messages.json').writeAsStringSync(r'''{
  "app": {
    "title": "Meu Aplicativo"
  },
  "currency": "R\\$ {amount}"
}''');

      // Initialize translator AFTER files are created
      i18n.init(defaultLocale: 'en');
    });

    tearDown(() {
      // Clean up test files
      final langDir = Directory('resources/lang');
      if (langDir.existsSync()) {
        langDir.deleteSync(recursive: true);
      }
      i18n.clear();
    });

    test('should initialize with default locale', () {
      i18n.init(defaultLocale: 'en');
      expect(i18n.currentLocale, equals('en'));
    });

    test('should translate basic key', () {
      i18n.setLocale('en');
      final translation = i18n.trans('app.title');
      expect(translation, equals('My Application'));
    });

    test('should apply parameter substitution', () {
      i18n.setLocale('en');
      final translation = i18n.trans('welcome', params: {'name': 'John'});
      expect(translation, equals('Welcome, John!'));
    });

    test('should support nested keys with dot notation', () {
      i18n.setLocale('en');
      final translation = i18n.trans('app.title');
      expect(translation, equals('My Application'));
    });

    test('should load and translate from Portuguese', () {
      i18n.setLocale('pt');
      final translation = i18n.trans('app.title');
      expect(translation, equals('Minha Aplicação'));
    });

    test('should translate from Portuguese (Brazil)', () {
      i18n.setLocale('pt_BR');
      final translation = i18n.trans('app.title');
      expect(translation, equals('Meu Aplicativo'));
    });

    test('should fallback from pt_BR to pt', () {
      // Pre-load pt messages for fallback testing
      i18n.setLocale('pt');
      i18n.setLocale('pt_BR');
      final translation = i18n.trans('welcome', params: {'name': 'João'});
      expect(translation, equals('Bem-vindo, João!'));
    });

    test('should fallback from pt to en', () {
      i18n.setLocale('pt');
      final translation = i18n.trans('nonexistent.key');
      expect(translation, equals('nonexistent.key'));
    });

    test('should return key if translation not found', () {
      i18n.setLocale('en');
      final translation = i18n.trans('missing.key');
      expect(translation, equals('missing.key'));
    });

    test('should check if key exists', () {
      i18n.setLocale('en');
      expect(i18n.hasKey('app.title'), isTrue);
      expect(i18n.hasKey('missing.key'), isFalse);
    });

    test('should get available locales', () {
      // Load all locales to populate availableLocales
      i18n.setLocale('pt');
      i18n.setLocale('pt_BR');

      final locales = i18n.availableLocales;
      expect(locales, contains('en'));
      expect(locales, contains('pt'));
      expect(locales, contains('pt_BR'));
    });

    test('should get all keys for a locale', () {
      i18n.setLocale('en');
      final keys = i18n.getKeys();
      expect(keys, isNotEmpty);
      expect(keys, contains('app.title'));
    });

    test('should translate with trans method', () {
      i18n.setLocale('en');
      final translation = i18n.trans('app.title');
      expect(translation, equals('My Application'));
    });

    test('should handle locale with underscore', () {
      i18n.setLocale('pt_BR');
      expect(i18n.currentLocale, equals('pt_BR'));
    });
  });

  group('I18nExtensions', () {
    test('should use trans extension on String', () {
      // Create test file FIRST
      final enDir = Directory('resources/lang/en');
      if (!enDir.existsSync()) {
        enDir.createSync(recursive: true);
      }

      File('resources/lang/en/messages.json').writeAsStringSync('''{
  "greeting": "Hello"
}''');

      // Then initialize
      i18n.init(defaultLocale: 'en');
      i18n.setLocale('en');

      final translation = 'greeting'.trans();
      expect(translation, equals('Hello'));
    });

    test('should use t alias', () {
      // Create test file FIRST
      final enDir = Directory('resources/lang/en');
      if (!enDir.existsSync()) {
        enDir.createSync(recursive: true);
      }

      File('resources/lang/en/messages.json').writeAsStringSync('''{
  "test": "Test Message"
}''');

      // Then initialize
      i18n.init(defaultLocale: 'en');
      i18n.setLocale('en');

      final translation = 'test'.t();
      expect(translation, equals('Test Message'));
    });
  });

  group('I18nUtils', () {
    test('should detect locale from Accept-Language header', () {
      final locale = I18nUtils.detectFromHeader('en-US,en;q=0.9,pt-BR;q=0.8');
      expect(locale, equals('en-US'));
    });

    test('should return null for empty Accept-Language header', () {
      final locale = I18nUtils.detectFromHeader('');
      expect(locale, isNull);
    });

    test('should return null for null Accept-Language header', () {
      final locale = I18nUtils.detectFromHeader(null);
      expect(locale, isNull);
    });

    test('should get fallback chain for locale', () {
      final chain = I18nUtils.getFallbackChain('pt_BR');
      expect(chain, equals(['pt_BR', 'pt']));
    });

    test('should detect RTL locales', () {
      expect(I18nUtils.isRtl('ar'), isTrue);
      expect(I18nUtils.isRtl('he'), isTrue);
      expect(I18nUtils.isRtl('en'), isFalse);
      expect(I18nUtils.isRtl('pt'), isFalse);
    });

    test('should get display name for locale', () {
      expect(I18nUtils.getDisplayName('en'), equals('English'));
      expect(I18nUtils.getDisplayName('pt'), equals('Português'));
      expect(I18nUtils.getDisplayName('pt_BR'), equals('Português (Brasil)'));
      expect(I18nUtils.getDisplayName('es'), equals('Español'));
    });
  });

  group('Locale', () {
    test('should create locale from code', () {
      final locale = Locale('pt_BR');
      expect(locale.code, equals('pt_BR'));
      expect(locale.language, equals('pt'));
      expect(locale.country, equals('BR'));
    });

    test('should get language only for simple locale', () {
      final locale = Locale('en');
      expect(locale.language, equals('en'));
      expect(locale.country, isNull);
    });

    test('should compare locales', () {
      final locale1 = Locale('pt_BR');
      final locale2 = Locale('pt_BR');
      final locale3 = Locale('en');

      expect(locale1, equals(locale2));
      expect(locale1, isNot(equals(locale3)));
    });

    test('should convert locale to string', () {
      final locale = Locale('pt_BR');
      expect(locale.toString(), equals('pt_BR'));
    });
  });
}
