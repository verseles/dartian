import 'dart:convert';
import 'dart:math' as math;

import 'arr.dart';

/// Create a new collection.
Collection<T> collect<T>([Iterable<T>? items]) => Collection<T>(items ?? []);

/// Collection class providing a fluent interface for working with arrays.
class Collection<T> extends Iterable<T> {
  final List<T> _items;

  Collection([Iterable<T> items = const []]) : _items = items.toList();

  /// Get the underlying items.
  List<T> get items => _items;

  @override
  Iterator<T> get iterator => _items.iterator;

  /// Get all items.
  List<T> all() => _items;

  /// Get the average value of a given key.
  double avg([dynamic key]) {
    if (_items.isEmpty) return 0;

    final num sumVal = sum(key);
    return sumVal / _items.length;
  }

  /// Get the sum of the given values.
  num sum([dynamic key]) {
    if (_items.isEmpty) return 0;

    num total = 0;
    for (final item in _items) {
      if (key != null) {
        final val = Arr.get(item, key);
        if (val is num) total += val;
      } else if (item is num) {
        total += item;
      }
    }
    return total;
  }

  /// Get the min value of a given key.
  T? min([dynamic key]) {
    if (_items.isEmpty) return null;

    // Simple implementation
    if (key == null) {
      return _items.reduce(
        (a, b) => (a as Comparable).compareTo(b) < 0 ? a : b,
      );
    }

    return _items.reduce((a, b) {
      final valA = Arr.get(a, key);
      final valB = Arr.get(b, key);
      return (valA as Comparable).compareTo(valB) < 0 ? a : b;
    });
  }

  /// Get the max value of a given key.
  T? max([dynamic key]) {
    if (_items.isEmpty) return null;

    if (key == null) {
      return _items.reduce(
        (a, b) => (a as Comparable).compareTo(b) > 0 ? a : b,
      );
    }

    return _items.reduce((a, b) {
      final valA = Arr.get(a, key);
      final valB = Arr.get(b, key);
      return (valA as Comparable).compareTo(valB) > 0 ? a : b;
    });
  }

  /// Get the item at the given index.
  T operator [](int index) => _items[index];

  /// Set the item at the given index.
  void operator []=(int index, T value) => _items[index] = value;

  /// Chunk the collection into chunks of the given size.
  Collection<Collection<T>> chunk(int size) {
    if (size <= 0) return Collection([]);

    final chunks = <Collection<T>>[];
    for (var i = 0; i < _items.length; i += size) {
      final end = (i + size < _items.length) ? i + size : _items.length;
      chunks.add(Collection(_items.sublist(i, end)));
    }
    return Collection(chunks);
  }

  /// Collapse the collection of items into a single collection.
  Collection collapse() {
    return Collection(Arr.collapse(_items as Iterable<Iterable>));
  }

  /// Determine if an item exists in the collection.
  @override
  bool contains(Object? element) {
    // If element is a closure? Dart check:
    if (element is Function && element is! T) {
      // In PHP contains accepts a closure. In Dart `any` does that.
      // We'll stick to standard contains behavior unless it's a key/value check?
      // Laravel: contains($key, $operator, $value) or contains($value) or contains(closure)
      return super.contains(element);
    }
    return super.contains(element);
  }

  /// Determine if an item exists in the collection using a callback.
  bool containsCallback(bool Function(T) callback) {
    return any(callback);
  }

  /// Count the number of items in the collection.
  int count() => length;

  /// Diff the collection with the given items.
  Collection<T> diff(Iterable<T> items) {
    final set = items.toSet();
    return Collection(_items.where((element) => !set.contains(element)));
  }

  /// Execute a callback over each item.
  Collection<T> each(void Function(T) callback) {
    forEach(callback);
    return this;
  }

  /// Filter the collection.
  Collection<T> filter([bool Function(T)? callback]) {
    if (callback == null) {
      return Collection(
        _items.where((e) {
          if (e == null) return false;
          if (e is bool) return e;
          if (e is String) return e.isNotEmpty;
          if (e is num) return e != 0;
          if (e is Iterable) return e.isNotEmpty;
          if (e is Map) return e.isNotEmpty;
          return true;
        }),
      );
    }
    return Collection(_items.where(callback));
  }

  /// Get the first item from the collection matching the given truth test.
  @override
  T firstWhere(bool Function(T) test, {T Function()? orElse}) {
    return _items.firstWhere(test, orElse: orElse);
  }

  /// Get the first item from the collection.
  T? firstWhereOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }

  /// Flatten a multi-dimensional collection into a single level.
  Collection flatten([num depth = double.infinity]) {
    return Collection(Arr.flatten(_items, depth));
  }

  /// Get an item from the collection by index.
  T? get(int index, [T? defaultValue]) {
    if (index >= 0 && index < _items.length) {
      return _items[index];
    }
    return defaultValue;
  }

  /// Group an associative array by a field or using a callback.
  Collection<MapEntry<dynamic, Collection<T>>> groupBy(dynamic groupBy) {
    final results = <dynamic, List<T>>{};

    for (final item in _items) {
      dynamic key;
      if (groupBy is Function) {
        key = groupBy(item);
      } else if (groupBy is String) {
        key = Arr.get(item, groupBy);
      } else {
        key = '';
      }

      if (!results.containsKey(key)) {
        results[key] = [];
      }
      results[key]!.add(item);
    }

    // Convert values to Collections
    final mapped = results.entries.map(
      (e) => MapEntry(e.key, Collection(e.value)),
    );
    return Collection(mapped);
  }

  /// Concatenate values of a given key as a string.
  String implode(String glue, [String? key]) {
    if (key == null) {
      return _items.join(glue);
    }
    return pluck(key).all().join(glue);
  }

  /// Determine if the collection is empty.
  @override
  bool get isEmpty => _items.isEmpty;

  /// Determine if the collection is not empty.
  @override
  bool get isNotEmpty => _items.isNotEmpty;

  /// Key an associative array by a field.
  Map<dynamic, T> keyBy(dynamic keyBy) {
    final results = <dynamic, T>{};

    for (final item in _items) {
      dynamic key;
      if (keyBy is Function) {
        key = keyBy(item);
      } else if (keyBy is String) {
        key = Arr.get(item, keyBy);
      }

      if (key != null) {
        results[key] = item;
      }
    }

    return results;
  }

  /// Run a map over each of the items.
  Collection<R> map<R>(R Function(T) toElement) {
    return Collection(_items.map(toElement));
  }

  /// Run an associative map over each of the items.
  /// This expects the callback to return a MapEntry or Map.
  /// But Collection in Dart is a List. So this should probably return a Map.
  Map<K, V> mapWithKeys<K, V>(MapEntry<K, V> Function(T) callback) {
    final result = <K, V>{};
    for (final item in _items) {
      final entry = callback(item);
      result[entry.key] = entry.value;
    }
    return result;
  }

  /// Merge the collection with the given items.
  Collection<T> merge(Iterable<T> items) {
    return Collection([..._items, ...items]);
  }

  /// Get the values of a given key.
  Collection<dynamic> pluck(String value, [String? key]) {
    return Collection(Arr.pluck(_items, value, key));
  }

  /// Push an item onto the end of the collection.
  Collection<T> push(T value) {
    _items.add(value);
    return this;
  }

  /// Push an item onto the beginning of the collection.
  Collection<T> prepend(T value) {
    _items.insert(0, value);
    return this;
  }

  /// Get and remove the last item from the collection.
  T? pop() {
    if (_items.isEmpty) return null;
    return _items.removeLast();
  }

  /// Get and remove the first item from the collection.
  T? shift() {
    if (_items.isEmpty) return null;
    return _items.removeAt(0);
  }

  /// Get one or a specified number of random items from the collection.
  dynamic random([int? number]) {
    return Arr.random(_items, number);
  }

  /// Reduce the collection to a single value.
  ///
  /// This overrides Iterable.reduce, so it must adhere to the same signature.
  /// For the Laravel-style reduce (with initial value), use [reduceCarry] or [fold].
  @override
  T reduce(T Function(T, T) combine) {
    return _items.reduce(combine);
  }

  S reduceCarry<S>(S initialValue, S Function(S, T) combine) {
    return _items.fold(initialValue, combine);
  }

  /// Create a collection of all elements that do not pass a given truth test.
  Collection<T> reject(bool Function(T) callback) {
    return filter((item) => !callback(item));
  }

  /// Reverse items.
  Collection<T> reverse() {
    return Collection(_items.reversed);
  }

  /// Shuffle the items.
  Collection<T> shuffle() {
    final list = List<T>.from(_items);
    list.shuffle();
    return Collection(list);
  }

  /// Skip the first [count] items.
  @override
  Collection<T> skip(int count) {
    return Collection(_items.skip(count));
  }

  /// Slice the underlying collection array.
  Collection<T> slice(int start, [int? length]) {
    if (length == null) {
      return Collection(_items.sublist(start));
    }
    return Collection(
      _items.sublist(start, math.min(start + length, _items.length)),
    );
  }

  /// Sort through each item with a callback.
  Collection<T> sort([int Function(T, T)? compare]) {
    final list = List<T>.from(_items);
    list.sort(compare);
    return Collection(list);
  }

  /// Sort the collection using the given callback.
  Collection<T> sortBy(dynamic callback, {bool descending = false}) {
    final list = List<T>.from(_items);
    list.sort((a, b) {
      dynamic valA, valB;
      if (callback is Function) {
        valA = callback(a);
        valB = callback(b);
      } else if (callback is String) {
        valA = Arr.get(a, callback);
        valB = Arr.get(b, callback);
      }

      final cmp = (valA as Comparable).compareTo(valB);
      return descending ? -cmp : cmp;
    });
    return Collection(list);
  }

  /// Sort the collection in descending order using the given callback.
  Collection<T> sortByDesc(dynamic callback) {
    return sortBy(callback, descending: true);
  }

  /// Take the first [limit] items.
  @override
  Collection<T> take(int limit) {
    if (limit < 0) {
      // Take from end
      return Collection(_items.sublist(math.max(0, _items.length + limit)));
    }
    return Collection(_items.take(limit));
  }

  /// Pass the collection to the given callback and then return it.
  Collection<T> tap(void Function(Collection<T>) callback) {
    callback(this);
    return this;
  }

  /// Transform the collection using a callback.
  Collection<T> transform(T Function(T) callback) {
    for (var i = 0; i < _items.length; i++) {
      _items[i] = callback(_items[i]);
    }
    return this;
  }

  /// Return only unique items from the collection array.
  Collection<T> unique([dynamic key]) {
    if (key == null) {
      return Collection(_items.toSet());
    }

    final seen = <dynamic>{};
    final result = <T>[];

    for (final item in _items) {
      dynamic id;
      if (key is Function) {
        id = key(item);
      } else {
        id = Arr.get(item, key);
      }

      if (seen.add(id)) {
        result.add(item);
      }
    }

    return Collection(result);
  }

  /// Reset the keys on the underlying array.
  Collection<T> values() {
    return Collection(List<T>.from(_items));
  }

  /// Apply the callback if the value is truthy.
  Collection<T> when(
    bool value,
    void Function(Collection<T>) callback, [
    void Function(Collection<T>)? defaultCallback,
  ]) {
    if (value) {
      callback(this);
    } else if (defaultCallback != null) {
      defaultCallback(this);
    }
    return this;
  }

  /// Filter items by the given key value pair.
  ///
  /// For standard Iterable filtering, use [where] which overrides Iterable.where.
  Collection<T> whereKey(String key, dynamic value, [String operator = '=']) {
    return filter((item) {
      final itemValue = Arr.get(item, key);

      switch (operator) {
        case '=':
        case '==':
          return itemValue == value;
        case '!=':
        case '<>':
          return itemValue != value;
        case '<':
          return (itemValue as Comparable).compareTo(value as Comparable) < 0;
        case '>':
          return (itemValue as Comparable).compareTo(value as Comparable) > 0;
        case '<=':
          return (itemValue as Comparable).compareTo(value as Comparable) <= 0;
        case '>=':
          return (itemValue as Comparable).compareTo(value as Comparable) >= 0;
        case '===':
          return identical(itemValue, value);
        case '!==':
          return !identical(itemValue, value);
        default:
          return false;
      }
    });
  }

  @override
  Collection<T> where(bool Function(T) test) {
    return Collection(_items.where(test));
  }

  /// Filter items where the given key is not null.
  Collection<T> whereNotNull([String? key]) {
    if (key == null) {
      return filter((item) => item != null);
    }
    return filter((item) => Arr.get(item, key) != null);
  }

  /// Filter items where the given key is null.
  Collection<T> whereNull([String? key]) {
    if (key == null) {
      return filter((item) => item == null);
    }
    return filter((item) => Arr.get(item, key) == null);
  }

  /// Filter items by the given key value pair.
  Collection<T> whereIn(String key, Iterable values) {
    return filter((item) => values.contains(Arr.get(item, key)));
  }

  /// Filter items by the given key value pair.
  Collection<T> whereNotIn(String key, Iterable values) {
    return filter((item) => !values.contains(Arr.get(item, key)));
  }

  /// Get the collection of items as a JSON string.
  String toJson() {
    return jsonEncode(_items);
  }

  @override
  String toString() {
    return _items.toString();
  }
}
