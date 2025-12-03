import 'dart:async';

/// Return the given value, optionally passed through the given callback.
T withValue<T>(T value, [Function(T)? callback]) {
  if (callback != null) {
    callback(value);
  }
  return value;
}

/// Call the given closure with the given value then return the value.
T tap<T>(T value, void Function(T) callback) {
  callback(value);
  return value;
}

/// Return the default value of the given value.
T value<T>(dynamic value) {
  if (value is Function) {
    return value();
  }
  return value;
}

/// Determine if the given value is "blank".
bool blank(dynamic value) {
  if (value == null) return true;

  if (value is String) return value.trim().isEmpty;
  if (value is num) return false;
  if (value is bool) return false;
  if (value is Iterable) return value.isEmpty;
  if (value is Map) return value.isEmpty;

  return false;
}

/// Determine if the given value is not "blank".
bool filled(dynamic value) {
  return !blank(value);
}

/// Retry an operation a given number of times.
Future<T> retry<T>(
  int times,
  Future<T> Function() callback, {
  Duration delay = const Duration(milliseconds: 100),
  bool Function(dynamic)? when,
}) async {
  int attempts = 0;

  while (true) {
    attempts++;

    try {
      return await callback();
    } catch (e) {
      if (attempts >= times) {
        rethrow;
      }

      if (when != null && !when(e)) {
        rethrow;
      }

      await Future.delayed(delay);
    }
  }
}
