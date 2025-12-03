import 'dart:async';
import 'dart:io';

import 'arr.dart';

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

/// Get the value of an environment variable.
T env<T>(String key, [T? defaultValue]) {
  final valueStr = Platform.environment[key];

  if (valueStr == null) {
    return defaultValue as T;
  }

  final lower = valueStr.toLowerCase();

  if (lower == 'true' || lower == '(true)') return true as T;
  if (lower == 'false' || lower == '(false)') return false as T;
  if (lower == 'empty' || lower == '(empty)') return '' as T;
  if (lower == 'null' || lower == '(null)') return null as T;

  // Try integer
  final intVal = int.tryParse(valueStr);
  if (intVal != null && intVal.toString() == valueStr) {
    return intVal as T;
  }

  // Try double
  final doubleVal = double.tryParse(valueStr);
  if (doubleVal != null && doubleVal.toString() == valueStr) {
    return doubleVal as T;
  }

  return valueStr as T;
}

/// Throw an exception if the given condition is true.
void throwIf(bool condition, Object exception) {
  if (condition) {
    throw exception;
  }
}

/// Throw an exception unless the given condition is true.
void throwUnless(bool condition, Object exception) {
  if (!condition) {
    throw exception;
  }
}

/// Get an item from an array or object using "dot" notation.
dynamic dataGet(dynamic target, dynamic key, [dynamic defaultValue]) {
  return Arr.get(target, key.toString(), defaultValue);
}

/// Set an item on an array or object using dot notation.
dynamic dataSet(
  dynamic target,
  dynamic key,
  dynamic value, [
  bool overwrite = true,
]) {
  if (!overwrite && Arr.get(target, key.toString()) != null) {
    return target;
  }
  if (target is Map) {
    return Arr.set(target, key.toString(), value);
  }
  return target;
}

/// Fill an item on an array or object using dot notation if it's missing.
dynamic dataFill(dynamic target, dynamic key, dynamic value) {
  return dataSet(target, key, value, false);
}

/// Get the first element of an array.
T? head<T>(Iterable<T> array) {
  return array.isNotEmpty ? array.first : null;
}

/// Get the last element of an array.
T? last<T>(Iterable<T> array) {
  return array.isNotEmpty ? array.last : null;
}
