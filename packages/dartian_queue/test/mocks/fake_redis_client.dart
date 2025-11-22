import 'dart:async';
import 'package:dartian_redis/dartian_redis.dart';

/// Fake Redis client for testing queue operations
/// Implements IRedisClient interface
class FakeRedisClient implements IRedisClient {
  final Map<String, String> _storage = {};
  final Map<String, List<String>> _lists = {};
  bool _isConnected = false;

  final String _host;
  final int _port;

  FakeRedisClient(this._host, {int port = 6379}) : _port = port;

  Future<void> connect() async {
    _isConnected = true;
  }

  Future<void> close() async {
    _isConnected = false;
    _storage.clear();
    _lists.clear();
  }

  Future<void> set(String key, String value, {Duration? ttl}) async {
    if (!_isConnected) {
      throw StateError('Not connected to Redis');
    }
    _storage[key] = value;
  }

  Future<String?> get(String key) async {
    if (!_isConnected) {
      throw StateError('Not connected to Redis');
    }
    return _storage[key];
  }

  Future<int> delete(String key) async {
    if (!_isConnected) {
      throw StateError('Not connected to Redis');
    }
    final removed = _storage.remove(key) != null ? 1 : 0;
    _lists.remove(key);
    return removed;
  }

  dynamic get client => FakeRedisLowLevelClient(this);

  // Other RedisClient methods for compatibility
  Future<bool> exists(String key) async =>
      _storage.containsKey(key) || _lists.containsKey(key);

  Future<void> expire(String key, Duration ttl) async {
    // No-op for fake client
  }

  Future<int> ttl(String key) async {
    // Return -1 (no expiration) for fake client
    return -1;
  }

  Future<dynamic> sendCommand(List command) async =>
      _handleListCommand(command[0].toString(), command.skip(1).toList());

  /// Internal method to handle list operations
  Future<dynamic> _handleListCommand(String command, List<dynamic> args) async {
    switch (command) {
      case 'LPUSH':
        final key = args[0] as String;
        final value = args[1] as String;
        _lists.putIfAbsent(key, () => []);
        _lists[key]!.insert(0, value);
        return _lists[key]!.length;

      case 'RPOP':
        final key = args[0] as String;
        final list = _lists[key];
        if (list == null || list.isEmpty) return null;
        return list.removeLast();

      case 'LLEN':
        final key = args[0] as String;
        return _lists[key]?.length ?? 0;

      case 'DEL':
        final key = args[0] as String;
        final hadList = _lists.remove(key) != null;
        final hadKey = _storage.remove(key) != null;
        return (hadList || hadKey) ? 1 : 0;

      default:
        throw UnsupportedError('Command $command not supported in fake Redis');
    }
  }
}

/// Low-level fake Redis client for list operations
class FakeRedisLowLevelClient {
  final FakeRedisClient _parent;

  FakeRedisLowLevelClient(this._parent);

  Future<dynamic> send_object(List<dynamic> command) async {
    if (command.isEmpty) {
      throw ArgumentError('Command cannot be empty');
    }

    final cmd = command[0].toString().toUpperCase();
    final args = command.skip(1).toList();

    return await _parent._handleListCommand(cmd, args);
  }
}
