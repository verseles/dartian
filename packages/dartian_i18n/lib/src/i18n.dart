import 'translator.dart';

/// Extension for easy access to translation methods
extension I18nExtensions on String {
  /// Translate the string with optional parameters
  String trans({Map<String, dynamic>? params, String? locale}) {
    return i18n.trans(this, params: params, locale: locale);
  }

  /// Short alias for trans
  String t({Map<String, dynamic>? params, String? locale}) {
    return trans(params: params, locale: locale);
  }
}

/// Extension for I18n on various objects
extension I18nHelper on Translator {
  /// Short alias for trans - available for use
  /// This is a public API method, ignore unused warning
  // ignore: unused_element
  String __(String key, {Map<String, dynamic>? params, String? locale}) {
    return trans(key, params: params, locale: locale);
  }
}

/// Class for managing locales
class Locale {
  final String _code;

  const Locale(this._code);

  String get code => _code;

  String get language => _code.split('_').first;

  String? get country => _code.contains('_') ? _code.split('_').last : null;

  @override
  String toString() => _code;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Locale && other._code == _code;
  }

  @override
  int get hashCode => _code.hashCode;
}

/// Helper functions
class I18nUtils {
  /// Parse locale from Accept-Language header
  static String? detectFromHeader(String? acceptLanguage) {
    if (acceptLanguage == null || acceptLanguage.isEmpty) {
      return null;
    }

    // Parse the Accept-Language header
    final languages = acceptLanguage.split(',');
    for (final language in languages) {
      final parts = language.split(';');
      final locale = parts[0].trim();
      if (locale.isNotEmpty) {
        return locale;
      }
    }

    return null;
  }

  /// Get fallback chain for a locale
  static List<String> getFallbackChain(String locale) {
    final chain = <String>[];

    // Add exact locale
    chain.add(locale);

    // Add language only (e.g., 'pt_BR' -> 'pt')
    if (locale.contains('_')) {
      final language = locale.split('_').first;
      chain.add(language);
    }

    return chain;
  }

  /// Check if locale is RTL (right-to-left)
  static bool isRtl(String locale) {
    const rtlLocales = [
      'ar', 'ar_EG', 'ar_SA', 'ar_AE',
      'he', 'he_IL',
      'fa', 'fa_IR',
      'ur', 'ur_PK',
    ];

    return rtlLocales.contains(locale) || rtlLocales.contains(locale.split('_').first);
  }

  /// Get locale display name
  static String getDisplayName(String locale) {
    const displayNames = {
      'en': 'English',
      'pt': 'Português',
      'pt_BR': 'Português (Brasil)',
      'es': 'Español',
      'fr': 'Français',
      'de': 'Deutsch',
      'it': 'Italiano',
      'ru': 'Русский',
      'ja': '日本語',
      'zh_CN': '中文 (简体)',
      'zh_TW': '中文 (繁體)',
    };

    return displayNames[locale] ?? locale;
  }
}
