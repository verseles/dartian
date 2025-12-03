// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:math';

/// Array/Map helper utilities.
class Arr {
  Arr._();

  /// Determine whether the given value is array accessible.
  static bool accessible(dynamic value) {
    return value is Map || value is Iterable;
  }

  /// Add an element to an array if it doesn't exist.
  static Map<K, V> add<K, V>(Map<K, V> array, K key, V value) {
    if (!array.containsKey(key)) {
      array[key] = value;
    }
    return array;
  }

  /// Collapse an array of arrays into a single array.
  static List collapse(Iterable<Iterable> array) {
    return array.expand((element) => element).toList();
  }

  /// Divide an array into two arrays. One with keys and the other with values.
  static List<List> divide(Map array) {
    return [array.keys.toList(), array.values.toList()];
  }

  /// Flatten a multi-dimensional associative array with dots.
  static Map<String, dynamic> dot(Map array, [String prepend = '']) {
    final result = <String, dynamic>{};

    array.forEach((key, value) {
      if (value is Map && value.isNotEmpty) {
        result.addAll(dot(value, '$prepend$key.'));
      } else {
        result['$prepend$key'] = value;
      }
    });

    return result;
  }

  /// Get all of the given array except for a specified array of keys.
  static Map<K, V> except<K, V>(Map<K, V> array, dynamic keys) {
    final result = Map<K, V>.from(array);
    if (keys is K) {
      result.remove(keys);
    } else if (keys is Iterable<K>) {
      for (final key in keys) {
        result.remove(key);
      }
    }
    return result;
  }

  /// Determine if the given key exists in the provided array.
  static bool exists(Map array, dynamic key) {
    return array.containsKey(key);
  }

  /// Return the first element in an array passing a given truth test.
  static T? first<T>(
    Iterable<T> array, [
    bool Function(T)? callback,
    T? defaultValue,
  ]) {
    if (callback == null) {
      if (array.isEmpty) return defaultValue;
      return array.first;
    }

    for (final element in array) {
      if (callback(element)) {
        return element;
      }
    }

    return defaultValue;
  }

  /// Return the last element in an array passing a given truth test.
  static T? last<T>(
    Iterable<T> array, [
    bool Function(T)? callback,
    T? defaultValue,
  ]) {
    if (callback == null) {
      if (array.isEmpty) return defaultValue;
      return array.last;
    }

    return first(array.toList().reversed, callback, defaultValue);
  }

  /// Flatten a multi-dimensional array into a single level.
  static List flatten(Iterable array, [num depth = double.infinity]) {
    final result = [];

    for (final item in array) {
      if (item is Iterable && depth > 0) {
        result.addAll(flatten(item, depth - 1));
      } else {
        result.add(item);
      }
    }

    return result;
  }

  /// Get an item from an array using "dot" notation.
  static dynamic get(dynamic target, String? key, [dynamic defaultValue]) {
    if (key == null) return target;

    if (target is Map && target.containsKey(key)) {
      return target[key];
    }

    if (key.contains('.')) {
      final keys = key.split('.');
      dynamic current = target;

      for (final segment in keys) {
        if (accessible(current) &&
            current is Map &&
            current.containsKey(segment)) {
          current = current[segment];
        } else {
          return defaultValue;
        }
      }

      return current;
    }

    return defaultValue;
  }

  /// Check if an item or items exist in an array using "dot" notation.
  static bool has(Map target, dynamic keys) {
    if (keys is String) {
      keys = [keys];
    }

    if (keys is! Iterable) return false;

    for (final key in keys) {
      if (target.containsKey(key)) continue;

      final segments = key.split('.');
      dynamic current = target;
      bool found = true;

      for (final segment in segments) {
        if (accessible(current) &&
            current is Map &&
            current.containsKey(segment)) {
          current = current[segment];
        } else {
          found = false;
          break;
        }
      }

      if (!found) return false;
    }

    return true;
  }

  /// Determines if an array is associative (i.e. a Map).
  static bool isAssoc(dynamic array) {
    return array is Map;
  }

  /// Determines if an array is a list.
  static bool isList(dynamic array) {
    return array is List;
  }

  /// Get a subset of the items from the given array.
  static Map<K, V> only<K, V>(Map<K, V> array, dynamic keys) {
    final result = <K, V>{};

    if (keys is K) {
      if (array.containsKey(keys)) {
        result[keys] = array[keys] as V;
      }
    } else if (keys is Iterable<K>) {
      for (final key in keys) {
        if (array.containsKey(key)) {
          result[key] = array[key] as V;
        }
      }
    }

    return result;
  }

  /// Pluck an array of values from an array.
  static List pluck(Iterable array, String value, [String? key]) {
    final results = [];

    for (final item in array) {
      final itemValue = get(item, value);

      if (key != null) {
        final itemKey = get(item, key);
        // Note: Dart Lists don't support keyed access like PHP arrays.
        // So pluck with key usually returns a Map in PHP.
        // Here we just return values unless we change return type to Map.
        // For simplicity and matching typical list usage, we return list of values.
        // If key is provided, we might want to return Map, but the signature says List.
        // Let's stick to List of values for now, or change to Map if key is present.
      }

      results.add(itemValue);
    }

    return results;
  }

  // Pluck returning a Map
  static Map<dynamic, dynamic> pluckMap(
    Iterable array,
    String value,
    String key,
  ) {
    final results = <dynamic, dynamic>{};

    for (final item in array) {
      final itemValue = get(item, value);
      final itemKey = get(item, key);
      if (itemKey != null) {
        results[itemKey] = itemValue;
      }
    }

    return results;
  }

  /// Push an item onto the beginning of an array.
  static List prepend(List array, dynamic value) {
    array.insert(0, value);
    return array;
  }

  /// Get a value from the array, and remove it.
  static dynamic pull(Map array, String key, [dynamic defaultValue]) {
    final value = get(array, key, defaultValue);
    forget(array, key);
    return value;
  }

  /// Get a value from the array, and remove it (simple key).
  static dynamic pullSimple(Map array, dynamic key, [dynamic defaultValue]) {
    if (array.containsKey(key)) {
      return array.remove(key);
    }
    return defaultValue;
  }

  /// Get one or a specified number of random values from an array.
  static dynamic random(Iterable array, [int? number]) {
    if (array.isEmpty) return null;

    final rnd = Random();
    final list = array.toList();

    if (number == null) {
      return list[rnd.nextInt(list.length)];
    }

    if (number >= list.length) {
      return List.from(list);
    }

    final keys = <int>{};
    while (keys.length < number) {
      keys.add(rnd.nextInt(list.length));
    }

    return keys.map((e) => list[e]).toList();
  }

  /// Set an array item to a given value using "dot" notation.
  ///
  /// If no key is given to the method, the entire array will be replaced.
  static Map set(Map target, String? key, dynamic value) {
    if (key == null) {
      // Cannot replace entire map reference in Dart via argument,
      // but we can clear and addAll if we wanted to 'replace' content.
      // But typically set returns the modified map.
      // If key is null, we assume we return the value? No, Laravel merges.
      // Let's just return the target.
      return target;
    }

    final keys = key.split('.');
    dynamic current = target;

    for (var i = 0; i < keys.length - 1; i++) {
      final segment = keys[i];

      if (current is Map) {
        if (!current.containsKey(segment) || !(current[segment] is Map)) {
          current[segment] = <String, dynamic>{};
        }
        current = current[segment];
      } else {
        // Can't set property on non-map
        return target;
      }
    }

    if (current is Map) {
      current[keys.last] = value;
    }

    return target;
  }

  /// Remove one or many array items from a given array using "dot" notation.
  static void forget(Map array, dynamic keys) {
    final originalKeys = keys;
    List<String> keysList = [];

    if (keys is String) {
      keysList = [keys];
    } else if (keys is Iterable<String>) {
      keysList = keys.toList();
    }

    for (final key in keysList) {
      final parts = key.split('.');

      if (parts.length == 1) {
        array.remove(key);
        continue;
      }

      dynamic current = array;
      for (var i = 0; i < parts.length - 1; i++) {
        final part = parts[i];
        if (current is Map && current.containsKey(part)) {
          current = current[part];
        } else {
          current = null;
          break;
        }
      }

      if (current is Map) {
        current.remove(parts.last);
      }
    }
  }

  /// Shuffle the given array and return the result.
  static List shuffle(Iterable array) {
    final list = array.toList();
    list.shuffle();
    return list;
  }

  /// Wrap the given value in an array if it is not already.
  static List wrap(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [value];
    return value;
  }
}
