import 'dart:io';
import 'package:path/path.dart' as p;

class Translator {
  final String _langPath;
  final Map<String, Map<String, String>> _translations = {};
  String _locale = 'en';

  Translator(String langPath) : _langPath = langPath;

  void setLocale(String locale) {
    _locale = locale;
  }

  Future<void> load(String locale) async {
    if (_translations.containsKey(locale)) return;

    final path = p.join(_langPath, locale, 'messages.dart');
    final file = File(path);

    if (!await file.exists()) {
      throw Exception('Language file not found: $path');
    }

    final content = await file.readAsString();
    final translations = _parseTranslations(content);
    _translations[locale] = translations;
  }

  String translate(String key, [Map<String, String> placeholders = const {}]) {
    var message = _translations[_locale]?[key] ?? key;

    if (placeholders.containsKey('count')) {
      final count = int.tryParse(placeholders['count']!) ?? 0;
      final parts = message.split('|');
      message = (count == 1) ? parts[0] : parts.length > 1 ? parts[1] : parts[0];
    }

    return _replacePlaceholders(message, placeholders);
  }

  String _replacePlaceholders(String message, Map<String, String> placeholders) {
    var result = message;
    placeholders.forEach((key, value) {
      result = result.replaceAll(':$key', value);
    });
    return result;
  }

  Map<String, String> _parseTranslations(String content) {
    final translations = <String, String>{};
    final regExp = RegExp(r"'([^']*)'\s*:\s*'([^']*)'");
    final matches = regExp.allMatches(content);
    for (final match in matches) {
      translations[match.group(1)!] = match.group(2)!;
    }
    return translations;
  }
}
