import 'dart:convert';

/// Generate a random ID
String generateId() {
  return DateTime.now().millisecondsSinceEpoch.toString() + _randomString(8);
}

String _randomString(int length) {
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = DateTime.now().microsecondsSinceEpoch;
  String result = '';
  for (var i = 0; i < length; i++) {
    result += chars[random % chars.length];
  }
  return result;
}

/// Safe JSON decode
T? safeJsonDecode<T>(String? json, T Function(Map<String, dynamic>) fromJson) {
  if (json == null || json.isEmpty) return null;
  try {
    final decoded = jsonDecode(json);
    if (decoded is Map<String, dynamic>) {
      return fromJson(decoded);
    }
    return null;
  } catch (e) {
    return null;
  }
}

/// Time utilities
class TimeUtils {
  /// Get current timestamp in milliseconds
  static int nowMillis() => DateTime.now().millisecondsSinceEpoch;

  /// Get current timestamp in microseconds
  static int nowMicros() => DateTime.now().microsecondsSinceEpoch;

  /// Convert milliseconds to Duration
  static Duration millis(int millis) => Duration(milliseconds: millis);

  /// Convert seconds to Duration
  static Duration seconds(int seconds) => Duration(seconds: seconds);

  /// Convert minutes to Duration
  static Duration minutes(int minutes) => Duration(minutes: minutes);
}
