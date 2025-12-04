// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:math' as math;
import 'package:intl/intl.dart';

/// Number helper utilities.
class Number {
  Number._();

  static String? _locale;
  static String? _currency;

  /// Set the default locale.
  static void useLocale(String locale) {
    _locale = locale;
  }

  /// Set the default currency.
  static void useCurrency(String currency) {
    _currency = currency;
  }

  /// Execute a callback using the given locale.
  static T withLocale<T>(String locale, T Function() callback) {
    final original = _locale;
    _locale = locale;
    try {
      return callback();
    } finally {
      _locale = original;
    }
  }

  /// Execute a callback using the given currency.
  static T withCurrency<T>(String currency, T Function() callback) {
    final original = _currency;
    _currency = currency;
    try {
      return callback();
    } finally {
      _currency = original;
    }
  }

  /// Abbreviate the given number.
  static String abbreviate(num number, {int precision = 1}) {
    return forHumans(number, maxPrecision: precision, units: true);
  }

  /// Clamp the given number between the given minimum and maximum.
  static num clamp(num number, {required num min, required num max}) {
    return number.clamp(min, max);
  }

  /// Format the given number as a currency.
  static String currency(num number, {String? inCurrency, String? locale}) {
    final c = inCurrency ?? _currency ?? 'USD';
    final l = locale ?? _locale;
    return NumberFormat.simpleCurrency(name: c, locale: l).format(number);
  }

  /// Convert the given number to its file size representation.
  static String fileSize(num bytes, {int precision = 1}) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    if (bytes < 1) return '0 B';
    final i = (math.log(bytes) / math.log(1024)).floor();
    final value = bytes / math.pow(1024, i);
    final f = NumberFormat('###.${'#' * precision}', _locale ?? 'en_US');
    return '${f.format(value)} ${units[i]}';
  }

  /// Convert the number to a human readable format.
  static String forHumans(
    num number, {
    int? precision,
    int? maxPrecision,
    bool units = false,
  }) {
    final effectivePrecision = precision ?? (maxPrecision != null ? null : 0);

    if (!units) {
      return format(number, precision: effectivePrecision, maxPrecision: maxPrecision);
    }

    final abbreviations = {
      1000000000000: 'T',
      1000000000: 'B',
      1000000: 'M',
      1000: 'K',
    };

    for (final entry in abbreviations.entries) {
      if (number.abs() >= entry.key) {
        final value = number / entry.key;
        return '${format(value, precision: effectivePrecision, maxPrecision: maxPrecision)}${entry.value}';
      }
    }

    return format(number, precision: effectivePrecision, maxPrecision: maxPrecision);
  }

  /// Format the given number.
  static String format(num number, {int? precision, String? locale, int? maxPrecision}) {
    final l = locale ?? _locale;
    if (precision != null) {
        // Fixed precision
        final f = NumberFormat.decimalPattern(l);
        f.minimumFractionDigits = precision;
        f.maximumFractionDigits = precision;
        return f.format(number);
    }

    final f = NumberFormat.decimalPattern(l);
    if (maxPrecision != null) {
        f.maximumFractionDigits = maxPrecision;
    }
    return f.format(number);
  }

  /// Get the ordinal value of the number.
  static String ordinal(int number, {String? locale}) {
    final suffix = _ordinalSuffix(number);
    return '$number$suffix';
  }

  static String _ordinalSuffix(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return 'th';
    }
    switch (number % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  /// Parse the given value into an integer.
  static int parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Parse the given value into a float.
  static double parseFloat(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Format the given number as a percentage.
  static String percentage(num number, {int precision = 0, String? locale}) {
    final l = locale ?? _locale;
    final f = NumberFormat.percentPattern(l);
    f.minimumFractionDigits = precision;
    f.maximumFractionDigits = precision;
    return '${format(number, precision: precision, locale: l)}%';
  }

  /// Spell out the given number.
  static String spell(num number, {String? locale}) {
    return _spellNumber(number.toInt());
  }

  static String _spellNumber(int n) {
      if (n < 0) return 'minus ${_spellNumber(-n)}';
      if (n == 0) return 'zero';

      final units = ['','one','two','three','four','five','six','seven','eight','nine','ten','eleven','twelve','thirteen','fourteen','fifteen','sixteen','seventeen','eighteen','nineteen'];
      final tens = ['','','twenty','thirty','forty','fifty','sixty','seventy','eighty','ninety'];

      if (n < 20) return units[n];

      if (n < 100) {
          return '${tens[n ~/ 10]}${(n % 10 != 0) ? '-${units[n % 10]}' : ''}';
      }

      if (n < 1000) {
          return '${units[n ~/ 100]} hundred${(n % 100 != 0) ? ' and ${_spellNumber(n % 100)}' : ''}';
      }

      if (n < 1000000) {
          return '${_spellNumber(n ~/ 1000)} thousand${(n % 1000 != 0) ? ' ${_spellNumber(n % 1000)}' : ''}';
      }

      if (n < 1000000000) {
          return '${_spellNumber(n ~/ 1000000)} million${(n % 1000000 != 0) ? ' ${_spellNumber(n % 1000000)}' : ''}';
      }

      return '${_spellNumber(n ~/ 1000000000)} billion${(n % 1000000000 != 0) ? ' ${_spellNumber(n % 1000000000)}' : ''}';
  }

  /// Spell out the ordinal value of the number.
  static String spellOrdinal(int number, {String? locale}) {
      final text = spell(number, locale: locale);
      return '$text${_ordinalSuffix(number)}';
  }

  /// Remove trailing zeros from the decimal part of the number.
  static String trim(num number) {
      return number.toString().replaceAll(RegExp(r'([.]*0)(?!.*\d)'), '');
  }
}
