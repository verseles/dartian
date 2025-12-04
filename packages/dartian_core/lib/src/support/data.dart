// ignore_for_file: non_constant_identifier_names

import 'arr.dart';

/// Fill in data in a target array or object.
dynamic data_fill(dynamic target, String key, dynamic value) {
  return data_set(target, key, value, false);
}

/// Get an item from an array or object using "dot" notation.
dynamic data_get(dynamic target, String? key, [dynamic defaultValue]) {
  if (key == null) return target;

  if (target is Map) {
    return Arr.get(target, key, defaultValue);
  }

  if (target is List) {
    // Handle list access? e.g. "0.name"
    // Arr.get supports dot notation for Maps.
    // We can extend Arr.get to support lists if keys are integers.
    // For now, delegate to Arr.get logic if feasible or reimplement.
    // Arr.get checks for Map.
  }

  // Simplified:
  return Arr.get(target, key, defaultValue);
}

/// Set an item on an array or object using dot notation.
dynamic data_set(dynamic target, String key, dynamic value, [bool overwrite = true]) {
  if (target is Map) {
    if (!overwrite && data_get(target, key) != null) {
      return target;
    }
    return Arr.set(target, key, value);
  }
  return target;
}

/// Remove an item from an array or object using dot notation.
void data_forget(dynamic target, dynamic key) {
  if (target is Map) {
    Arr.forget(target, key);
  }
}

/// Get the first element of an array.
T? head<T>(Iterable<T> array) {
  if (array.isEmpty) return null;
  return array.first;
}

/// Get the last element of an array.
T? last<T>(Iterable<T> array) {
  if (array.isEmpty) return null;
  return array.last;
}
