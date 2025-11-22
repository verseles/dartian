import 'dart:io';
import 'dart:convert';
import 'dart:collection';

/// Translator for internationalization
class Translator {
  static final _instance = Translator._internal();
  factory Translator() => _instance;
  Translator._internal();

  final Map<String, Map<String, String>> _messages = {};
  String _defaultLocale = 'en';
  String? _currentLocale;

  /// Initialize translator with default locale
  void init({String defaultLocale = 'en'}) {
    _defaultLocale = defaultLocale;
    _loadMessages(defaultLocale);
  }

  /// Load messages from resources/lang directory
  void _loadMessages(String locale) {
    final langPath = 'resources/lang/$locale';
    final dir = Directory(langPath);

    if (!dir.existsSync()) {
      return;
    }

    final files = dir.listSync(recursive: true);
    for (final file in files) {
      if (file is File && file.path.endsWith('.json')) {
        _loadJsonFile(file.path, locale);
      }
    }
  }

  /// Load JSON translation file
  void _loadJsonFile(String filePath, String locale) {
    try {
      final content = File(filePath).readAsStringSync();
      final json = jsonDecode(content) as Map<String, dynamic>;

      if (_messages[locale] == null) {
        _messages[locale] = {};
      }

      _mergeMessages(_messages[locale]!, json);
    } catch (e) {
      // Handle error loading translation file
      // In production, you might want to log this
    }
  }

  /// Merge messages into existing map
  void _mergeMessages(Map<String, String> target, Map<String, dynamic> source) {
    for (final entry in source.entries) {
      if (entry.value is String) {
        target[entry.key] = entry.value as String;
      } else if (entry.value is Map<String, dynamic>) {
        // Handle nested keys with dot notation
        _flattenMap(entry.key, entry.value as Map<String, dynamic>, target);
      }
    }
  }

  /// Flatten nested map with dot notation
  void _flattenMap(
    String prefix,
    Map<String, dynamic> map,
    Map<String, String> target,
  ) {
    for (final entry in map.entries) {
      final key = '${prefix}.${entry.key}';
      if (entry.value is String) {
        target[key] = entry.value as String;
      } else if (entry.value is Map<String, dynamic>) {
        _flattenMap(key, entry.value as Map<String, dynamic>, target);
      }
    }
  }

  /// Set current locale
  void setLocale(String locale) {
    _currentLocale = locale;
    // Always load messages for the locale to ensure fresh data
    _loadMessages(locale);
  }

  /// Get current locale
  String? get currentLocale => _currentLocale ?? _defaultLocale;

  /// Translate a key
  String trans(String key, {Map<String, dynamic>? params, String? locale}) {
    // Determine locale to use
    final targetLocale = locale ?? currentLocale ?? _defaultLocale;

    // Try to find translation with fallbacks
    final result = _findTranslation(key, targetLocale);

    // Apply parameter substitution if found
    if (result != null && params != null && params.isNotEmpty) {
      return _applyParams(result, params);
    }

    return result ?? key;
  }

  /// Find translation with locale fallback
  String? _findTranslation(String key, String locale) {
    // Try exact locale
    if (_messages[locale]?[key] != null) {
      return _messages[locale]![key];
    }

    // Try language only (e.g., 'pt_BR' -> 'pt')
    if (locale.contains('_')) {
      final language = locale.split('_').first;
      if (_messages[language]?[key] != null) {
        return _messages[language]![key];
      }
    }

    // Try default locale
    if (locale != _defaultLocale && _messages[_defaultLocale]?[key] != null) {
      return _messages[_defaultLocale]![key];
    }

    // Return null if not found
    return null;
  }

  /// Apply parameter substitution
  String _applyParams(String message, Map<String, dynamic> params) {
    var result = message;

    // Sort parameters by length (longest first) to avoid partial replacements
    final sortedKeys = params.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final key in sortedKeys) {
      final placeholder = '{$key}';
      final value = params[key]?.toString() ?? '';
      result = result.replaceAll(placeholder, value);
    }

    return result;
  }

  /// Check if a key exists
  bool hasKey(String key, {String? locale}) {
    final targetLocale = locale ?? currentLocale ?? _defaultLocale;
    return _findTranslation(key, targetLocale) != null;
  }

  /// Get all available locales
  List<String> get availableLocales =>
      UnmodifiableListView(_messages.keys.toList()..sort());

  /// Get all translation keys for a locale
  List<String> getKeys({String? locale}) {
    final targetLocale = locale ?? currentLocale ?? _defaultLocale;
    return UnmodifiableListView(_messages[targetLocale]?.keys.toList() ?? []);
  }

  /// Clear all messages
  void clear() {
    _messages.clear();
  }
}

/// Global translator instance
final i18n = Translator();
