// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'collection.dart';

// Hooks
class App {
  static dynamic Function(String? abstract, [List? parameters])? make;
  static void Function(dynamic error)? report;
}

class Auth {
  static dynamic Function()? user;
  static dynamic Function(String? guard)? guard;
}

class Config {
    static dynamic Function(String key, [dynamic defaultValue])? get;
}

/// Throw an HttpException with the given data.
void abort(int code, [String message = '', Map<String, dynamic> headers = const {}]) {
  throw HttpException('$code: $message');
}

/// Throw an HttpException with the given data if the given boolean is true.
void abort_if(bool condition, int code, [String message = '', Map<String, dynamic> headers = const {}]) {
  if (condition) abort(code, message, headers);
}

/// Throw an HttpException with the given data unless the given boolean is true.
void abort_unless(bool condition, int code, [String message = '', Map<String, dynamic> headers = const {}]) {
  if (!condition) abort(code, message, headers);
}

/// Get the available container instance.
dynamic app([String? abstract, List? parameters]) {
    if (abstract == null) return App.make?.call('app');
    return App.make?.call(abstract, parameters);
}

/// Get the available auth instance.
dynamic auth([String? guard]) {
    return Auth.guard?.call(guard);
}

/// Create a new redirect response to the previous location.
dynamic back([int status = 302, Map<String, dynamic> headers = const {}, dynamic fallback]) {
    // Hook
    return null;
}

/// Hash the given value.
String bcrypt(String value, [Map<String, dynamic>? options]) {
    // Placeholder. Needs dependency.
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

/// Get / set the specified configuration value.
dynamic config(String key, [dynamic defaultValue]) {
    return Config.get?.call(key, defaultValue);
}

/// Dump the given vars and end the script.
void dd(dynamic x) {
    print(x);
    exit(1);
}

/// Get the value of an environment variable.
String? env(String key, [String? defaultValue]) {
    return Platform.environment[key] ?? defaultValue;
}

/// Determine if the given value is not "blank".
bool filled(dynamic value) {
  return !blank(value);
}

/// Create a new Date object for the current time.
DateTime now() {
    return DateTime.now();
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

/// Call the given closure with the given value then return the value.
T tap<T>(T value, void Function(T) callback) {
  callback(value);
  return value;
}

/// Create a new Date object for today.
DateTime today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
}

/// Return the default value of the given value.
T value<T>(dynamic value) {
  if (value is Function) {
    return value();
  }
  return value;
}

/// Throw the given exception if the given condition is true.
void throw_if(bool condition, Object exception) {
  if (condition) {
    throw exception;
  }
}

/// Throw the given exception unless the given condition is true.
void throw_unless(bool condition, Object exception) {
  if (!condition) {
    throw exception;
  }
}

/// Catch a potential exception and return a default value.
dynamic rescue(Function callback, [Function(Object e)? rescue, bool report = true]) {
  try {
    return callback();
  } catch (e) {
    if (report) {
       App.report?.call(e);
    }
    return rescue != null ? rescue(e) : null;
  }
}

/// Transform the given value if it is present.
dynamic transform(dynamic value, Function(dynamic) callback, [dynamic defaultValue]) {
  if (value != null) {
    return callback(value);
  }
  if (defaultValue is Function) return defaultValue();
  return defaultValue;
}

/// Execute a callback only once.
T Function() once<T>(T Function() callback) {
  bool executed = false;
  late T result;
  return () {
    if (!executed) {
      result = callback();
      executed = true;
    }
    return result;
  };
}

/// Return the given value, optionally passed through the given callback.
T withValue<T>(T value, [Function(T)? callback]) {
  if (callback != null) {
    callback(value);
  }
  return value;
}
