// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:math';
import 'dart:convert';

/// String helper utilities.
class Str {
  Str._();

  /// The cache of snake-cased words.
  static final Map<String, String> _snakeCache = {};

  /// The cache of camel-cased words.
  static final Map<String, String> _camelCache = {};

  /// The cache of studly-cased words.
  static final Map<String, String> _studlyCache = {};

  /// Convert a value to camel case.
  static String camel(String value) {
    if (_camelCache.containsKey(value)) {
      return _camelCache[value]!;
    }

    return _camelCache[value] = lcfirst(studly(value));
  }

  /// Convert a string to snake case.
  static String snake(String value, [String delimiter = '_']) {
    final key = value + delimiter;

    if (_snakeCache.containsKey(key)) {
      return _snakeCache[key]!;
    }

    var result = value.replaceAllMapped(RegExp(r'\s+'), (match) => '');
    result = result.replaceAllMapped(
      RegExp(r'(.)(?=[A-Z])'),
      (match) => '${match.group(1)}$delimiter',
    );

    return _snakeCache[key] = result.toLowerCase();
  }

  /// Convert a value to studly caps case.
  static String studly(String value) {
    if (_studlyCache.containsKey(value)) {
      return _studlyCache[value]!;
    }

    final words = value.replaceAll(RegExp(r'[-_]'), ' ').split(' ');
    final result = words.map((word) => ucfirst(word)).join('');

    return _studlyCache[value] = result;
  }

  /// Convert a value to kebab case.
  static String kebab(String value) {
    return snake(value, '-');
  }

  /// Convert a string to title case.
  static String title(String value) {
    return value
        .replaceAll(RegExp(r'[-_]'), ' ')
        .split(' ')
        .map((w) => ucfirst(w))
        .join(' ');
  }

  /// Make a string's first character uppercase.
  static String ucfirst(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  /// Make a string's first character lowercase.
  static String lcfirst(String value) {
    if (value.isEmpty) return value;
    return value[0].toLowerCase() + value.substring(1);
  }

  /// Limit the number of characters in a string.
  static String limit(String value, [int limit = 100, String end = '...']) {
    if (value.length <= limit) return value;
    return value.substring(0, limit) + end;
  }

  /// Limit the number of words in a string.
  static String words(String value, [int words = 100, String end = '...']) {
    final matches = RegExp(
      r'^\s*(?:\S+\s*){1,' + words.toString() + '}',
    ).firstMatch(value);

    if (matches == null || matches.group(0)!.length == value.length) {
      return value;
    }

    return matches.group(0)!.trimRight() + end;
  }

  /// Generate a more truly "random" alpha-numeric string.
  static String random([int length = 16]) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random.secure();
    return List.generate(
      length,
      (index) => chars[rnd.nextInt(chars.length)],
    ).join();
  }

  /// Generate a UUID (version 4).
  static String uuid() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (i) => rnd.nextInt(256));

    // Set version to 4
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    // Set variant to 10xx
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  /// Generate a URL friendly "slug" from a given string.
  static String slug(String value, [String separator = '-']) {
    var slug = value.trim().toLowerCase();

    // Transliterate simple accents (very basic version)
    slug = slug
        .replaceAll(RegExp(r'[áàâäãå]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôöõ]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll(RegExp(r'[ýÿ]'), 'y')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[ç]'), 'c');

    // Remove all non-word characters
    slug = slug.replaceAll(RegExp(r'[^a-z0-9\s-]'), '');

    // Replace spaces and separators with a single separator
    slug = slug.replaceAll(RegExp(r'[\s-]+'), separator);

    return slug;
  }

  /// Determine if a given string contains a given substring.
  static bool contains(String haystack, dynamic needles) {
    if (needles is String) {
      return haystack.contains(needles);
    }

    if (needles is Iterable) {
      for (final needle in needles) {
        if (haystack.contains(needle.toString())) {
          return true;
        }
      }
    }

    return false;
  }

  /// Determine if a given string contains all array values.
  static bool containsAll(String haystack, Iterable<String> needles) {
    for (final needle in needles) {
      if (!haystack.contains(needle)) {
        return false;
      }
    }
    return true;
  }

  /// Determine if a given string starts with a given substring.
  static bool startsWith(String haystack, dynamic needles) {
    if (needles is String) {
      return haystack.startsWith(needles);
    }

    if (needles is Iterable) {
      for (final needle in needles) {
        if (haystack.startsWith(needle.toString())) {
          return true;
        }
      }
    }

    return false;
  }

  /// Determine if a given string ends with a given substring.
  static bool endsWith(String haystack, dynamic needles) {
    if (needles is String) {
      return haystack.endsWith(needles);
    }

    if (needles is Iterable) {
      for (final needle in needles) {
        if (haystack.endsWith(needle.toString())) {
          return true;
        }
      }
    }

    return false;
  }

  /// Cap a string with a single instance of a given value.
  static String finish(String value, String cap) {
    final quoted = RegExp.escape(cap);
    return value.replaceAll(RegExp('(?:$quoted)+\$'), '') + cap;
  }

  /// Begin a string with a single instance of a given value.
  static String start(String value, String prefix) {
    final quoted = RegExp.escape(prefix);
    return prefix + value.replaceAll(RegExp('^(?:$quoted)+'), '');
  }

  /// Replace a given value in the string sequentially with an array.
  static String replaceArray(
    String subject,
    String search,
    Iterable<String> replace,
  ) {
    var result = subject;
    for (final value in replace) {
      result = result.replaceFirst(search, value);
    }
    return result;
  }

  /// Replace the first occurrence of a given value in the string.
  static String replaceFirst(String search, String replace, String subject) {
    return subject.replaceFirst(search, replace);
  }

  /// Replace the last occurrence of a given value in the string.
  static String replaceLast(String search, String replace, String subject) {
    final index = subject.lastIndexOf(search);
    if (index == -1) return subject;
    return subject.substring(0, index) +
        replace +
        subject.substring(index + search.length);
  }

  /// Get the portion of a string before the first occurrence of a given value.
  static String before(String subject, String search) {
    if (search.isEmpty) return subject;
    final index = subject.indexOf(search);
    if (index == -1) return subject;
    return subject.substring(0, index);
  }

  /// Get the portion of a string before the last occurrence of a given value.
  static String beforeLast(String subject, String search) {
    if (search.isEmpty) return subject;
    final index = subject.lastIndexOf(search);
    if (index == -1) return subject;
    return subject.substring(0, index);
  }

  /// Get the portion of a string after the first occurrence of a given value.
  static String after(String subject, String search) {
    if (search.isEmpty) return subject;
    final index = subject.indexOf(search);
    if (index == -1) return subject;
    return subject.substring(index + search.length);
  }

  /// Get the portion of a string after the last occurrence of a given value.
  static String afterLast(String subject, String search) {
    if (search.isEmpty) return subject;
    final index = subject.lastIndexOf(search);
    if (index == -1) return subject;
    return subject.substring(index + search.length);
  }

  /// Get the portion of a string between two given values.
  static String between(String subject, String from, String to) {
    if (from.isEmpty || to.isEmpty) return subject;
    return before(after(subject, from), to);
  }

  /// Wrap the string with the given strings.
  static String wrap(String value, String start, [String? end]) {
    return start + value + (end ?? start);
  }

  /// Unwrap the string from the given strings.
  static String unwrap(String value, String start, [String? end]) {
    end ??= start;
    if (value.startsWith(start)) {
      value = value.substring(start.length);
    }
    if (value.endsWith(end)) {
      value = value.substring(0, value.length - end.length);
    }
    return value;
  }
}
