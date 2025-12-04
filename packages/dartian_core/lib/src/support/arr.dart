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

  /// Convert the value to a boolean.
  static bool boolean(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final v = value.toLowerCase();
      return v == 'true' || v == '1' || v == 'on' || v == 'yes';
    }
    return false;
  }

  /// Collapse an array of arrays into a single array.
  static List collapse(Iterable<Iterable> array) {
    return array.expand((element) => element).toList();
  }

  /// Cross join the given arrays, returning all possible permutations.
  static List<List> crossJoin(List<List> arrays) {
    if (arrays.isEmpty) return [];
    var result = arrays.first.map((e) => [e]).toList();
    for (var i = 1; i < arrays.length; i++) {
      final next = <List>[];
      for (final item in result) {
        for (final element in arrays[i]) {
          next.add([...item, element]);
        }
      }
      result = next;
    }
    return result;
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

  /// Determine if all items pass the given truth test.
  static bool every(Iterable array, bool Function(dynamic) callback) {
    return array.every(callback);
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

  /// Convert the given value to a float.
  static double float(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Create a new array from the given value.
  static List from(dynamic value) {
    if (value is Iterable) return value.toList();
    if (value == null) return [];
    return [value];
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
        } else if (current is List && int.tryParse(segment) != null) {
          final index = int.parse(segment);
          if (index >= 0 && index < current.length) {
            current = current[index];
          } else {
            return defaultValue;
          }
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

  /// Determine if all of the given keys exist in the provided array.
  static bool hasAll(Map target, dynamic keys) {
    return has(target, keys);
  }

  /// Determine if any of the given keys exist in the provided array.
  static bool hasAny(Map target, dynamic keys) {
    if (keys is String) keys = [keys];
    if (keys is Iterable) {
      for (final key in keys) {
        if (has(target, key)) return true;
      }
    }
    return false;
  }

  /// Convert the given value to an integer.
  static int integer(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Determines if an array is associative (i.e. a Map).
  static bool isAssoc(dynamic array) {
    return array is Map;
  }

  /// Determines if an array is a list.
  static bool isList(dynamic array) {
    return array is List;
  }

  /// Join all items from the array using a string.
  static String join(Iterable array, String glue, [String? finalGlue]) {
    if (finalGlue == null) {
      return array.join(glue);
    }
    final list = array.toList();
    if (list.isEmpty) return '';
    if (list.length == 1) return list.first.toString();

    final lastItem = list.removeLast();
    return '${list.join(glue)}$finalGlue$lastItem';
  }

  /// Key an associative array by a field.
  static Map<dynamic, dynamic> keyBy(Iterable array, dynamic keyBy) {
    final result = <dynamic, dynamic>{};
    for (final item in array) {
      dynamic key;
      if (keyBy is Function) {
        key = keyBy(item);
      } else if (keyBy is String) {
        key = get(item, keyBy);
      }
      if (key != null) {
        result[key] = item;
      }
    }
    return result;
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

  /// Run a map over each of the items in the array.
  static List map(Iterable array, Function(dynamic) callback) {
    return array.map(callback).toList();
  }

  /// Map a collection and flatten the result by a single level.
  static List mapSpread(Iterable array, Function(dynamic) callback) {
    return array.expand((e) {
      final res = callback(e);
      if (res is Iterable) return res;
      return [res];
    }).toList();
  }

  /// Map an array with keys.
  static Map mapWithKeys(Iterable array, MapEntry Function(dynamic) callback) {
    final result = <dynamic, dynamic>{};
    for (final item in array) {
      final entry = callback(item);
      result[entry.key] = entry.value;
    }
    return result;
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

  /// Partition the array into two arrays.
  static List<List> partition(Iterable array, bool Function(dynamic) callback) {
    final passed = [];
    final failed = [];
    for (final item in array) {
      if (callback(item)) {
        passed.add(item);
      } else {
        failed.add(item);
      }
    }
    return [passed, failed];
  }

  /// Pluck an array of values from an array.
  static List pluck(Iterable array, String value, [String? key]) {
    final results = [];

    for (final item in array) {
      final itemValue = get(item, value);
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

  /// Prepend the key names of an associative array.
  static Map<String, dynamic> prependKeysWith(
    Map<String, dynamic> array,
    String prepend,
  ) {
    return array.map((key, value) => MapEntry('$prepend$key', value));
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

  /// Push an item onto the end of an array.
  static List push(List array, dynamic value) {
    array.add(value);
    return array;
  }

  /// Convert the array to a query string.
  static String query(Map<String, dynamic> array) {
    final params = <String, dynamic>{};
    array.forEach((key, value) {
      if (value is Iterable) {
        params[key] = value.map((e) => e.toString()).toList();
      } else {
        params[key] = value.toString();
      }
    });
    return Uri(queryParameters: params).query;
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

  /// Filter the array using the given callback.
  static List reject(Iterable array, bool Function(dynamic) callback) {
    return array.where((e) => !callback(e)).toList();
  }

  /// Select specific keys from the array (alias to only).
  static Map<K, V> select<K, V>(Map<K, V> array, dynamic keys) {
    return only(array, keys);
  }

  /// Set an array item to a given value using "dot" notation.
  static Map set(Map target, String? key, dynamic value) {
    if (key == null) {
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
        return target;
      }
    }

    if (current is Map) {
      current[keys.last] = value;
    }

    return target;
  }

  /// Shuffle the given array and return the result.
  static List shuffle(Iterable array) {
    final list = array.toList();
    list.shuffle();
    return list;
  }

  /// Get the first element in the array, but only if exactly one exists.
  static T sole<T>(Iterable<T> array, [bool Function(T)? callback]) {
    Iterable<T> items = array;
    if (callback != null) {
      items = array.where(callback);
    }

    if (items.isEmpty) throw Exception('No items found.');
    if (items.length > 1) throw Exception('Multiple items found.');

    return items.first;
  }

  /// Determine if some items pass the given truth test.
  static bool some(Iterable array, bool Function(dynamic) callback) {
    return array.any(callback);
  }

  /// Sort the array.
  static List sort(Iterable array, [int Function(dynamic, dynamic)? compare]) {
    final list = array.toList();
    if (compare != null) {
      list.sort(compare);
    } else {
      list.sort();
    }
    return list;
  }

  /// Sort the array in descending order.
  static List sortDesc(Iterable array) {
    final list = array.toList();
    list.sort((a, b) => Comparable.compare(b, a));
    return list;
  }

  /// Sort the array recursively.
  static dynamic sortRecursive(dynamic array, [bool descending = false]) {
    if (array is List) {
      final list = array.map((e) => sortRecursive(e, descending)).toList();
      if (descending) {
        list.sort((a, b) {
          if (a is Comparable && b is Comparable) {
            return b.compareTo(a);
          }
          return 0;
        });
      } else {
        list.sort((a, b) {
          if (a is Comparable && b is Comparable) {
            return a.compareTo(b);
          }
          return 0;
        });
      }
      return list;
    }
    if (array is Map) {
      final keys = array.keys.toList();
      if (descending) {
        keys.sort((a, b) => b.compareTo(a));
      } else {
        keys.sort();
      }
      final result = {};
      for (final key in keys) {
        result[key] = sortRecursive(array[key], descending);
      }
      return result;
    }
    return array;
  }

  /// Convert the value to a string.
  static String string(dynamic value) {
    return value.toString();
  }

  /// Take the first or last {limit} items.
  static List take(Iterable array, int limit) {
    if (limit < 0) {
      return array.toList().sublist(max(0, array.length + limit));
    }
    return array.take(limit).toList();
  }

  /// Conditionally compile classes.
  static String toCssClasses(dynamic array) {
    final classes = <String>[];
    if (array is List) {
      for (final item in array) {
        if (item is String && item.isNotEmpty) classes.add(item);
        if (item is Map) {
          item.forEach((key, value) {
            if (boolean(value)) classes.add(key);
          });
        }
      }
    } else if (array is Map) {
      array.forEach((key, value) {
        if (boolean(value)) classes.add(key);
      });
    } else if (array is String) {
      classes.add(array);
    }
    return classes.join(' ');
  }

  /// Conditionally compile styles.
  static String toCssStyles(Map<String, dynamic> array) {
    final styles = <String>[];
    array.forEach((key, value) {
      if (value != null) {
        styles.add('$key: $value');
      }
    });
    return styles.join('; ');
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

  /// Expand a flattened array with dots.
  static Map<String, dynamic> undot(Map<String, dynamic> array) {
    final result = <String, dynamic>{};
    array.forEach((key, value) {
      set(result, key, value);
    });
    return result;
  }

  /// Filter the array using the given callback.
  static List where(Iterable array, bool Function(dynamic) callback) {
    return array.where(callback).toList();
  }

  /// Filter items where the given key is not null.
  static List whereNotNull(Iterable array) {
    return array.where((e) => e != null).toList();
  }

  /// Wrap the given value in an array if it is not already.
  static List wrap(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [value];
    return value;
  }
}
