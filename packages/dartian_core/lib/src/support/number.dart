// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:math';

/// Number helper utilities.
class Number {
  Number._();

  /// Abbreviate the given number (e.g. 1K, 1M).
  static String abbreviate(num number, {int precision = 1}) {
    if (number < 1000) {
      return number.toString();
    }

    final suffixes = ['', 'K', 'M', 'B', 'T', 'Q'];
    final suffixNum = (log(number) / log(1000)).floor();

    if (suffixNum >= suffixes.length) {
      return number.toStringAsFixed(precision); // Fallback
    }

    final shortValue = number / pow(1000, suffixNum);

    // Remove trailing .0 or .00 if integer
    String result = shortValue.toStringAsFixed(precision);
    if (result.endsWith('.0')) result = result.substring(0, result.length - 2);
    if (result.endsWith('.00')) result = result.substring(0, result.length - 3);

    return '$result${suffixes[suffixNum]}';
  }

  /// Clamp the given number between the given minimum and maximum.
  static num clamp(num number, num min, num max) {
    return number.clamp(min, max);
  }

  /// Format the given number as a file size.
  static String fileSize(num bytes, {int precision = 1}) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];

    if (bytes == 0) return '0 B';

    final i = (log(bytes) / log(1024)).floor();

    if (i >= units.length) return '${bytes} B';

    final val = bytes / pow(1024, i);

    String result = val.toStringAsFixed(precision);
    // Remove .0
    if (result.endsWith('.0')) result = result.substring(0, result.length - 2);

    return '$result ${units[i]}';
  }

  /// Convert the number to a human readable format.
  /// This can be an alias for abbreviate or do something else.
  /// Laravel's forHumans usually refers to diffForHumans (time) or similar.
  /// But Number::forHumans might be abbreviate.
  static String forHumans(num number, {int precision = 1}) {
    return abbreviate(number, precision: precision);
  }

  /// Format the given number as a percentage.
  static String percentage(num number, {int precision = 0, num max = 100}) {
    // If number is 0.5 and max is 100, is it 50%?
    // Usually percentage(0.5) -> 50%.
    // Or percentage(50, max: 100) -> 50%?
    // Laravel Number::percentage(10, precision: 2) -> "10.00%"
    // It assumes the number is already the percentage value.

    String result = number.toStringAsFixed(precision);
    if (result.endsWith('.0')) result = result.substring(0, result.length - 2);
    return '$result%';
  }

  /// Get the ordinal form of an integer.
  static String ordinal(int number) {
    final suffix = _ordinalSuffix(number);
    return '$number$suffix';
  }

  static String _ordinalSuffix(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return 'th';
    }

    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
