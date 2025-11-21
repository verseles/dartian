import 'package:redis/redis.dart';
import 'i_redis_client.dart';

/// Redis connection manager for Dartian
class RedisManager {
  static RedisManager? _instance;
  static RedisManager get instance => _instance ??= RedisManager._();

  RedisManager._();

  /// Create a Redis client connection
  RedisClient connect(String host, {int port = 6379, String? password, int database = 0}) {
    return RedisClient(host, port: port, password: password, database: database);
  }
}

/// Redis client wrapper
class RedisClient implements IRedisClient {
  final String _host;
  final int _port;
  final String? _password;
  final int _database;
  late final RedisConnection _connection;
  late final Command _client;

  RedisClient(this._host, {int port = 6379, String? password, int database = 0})
      : _port = port,
        _password = password,
        _database = database;

  /// Connect to Redis
  Future<void> connect() async {
    _connection = RedisConnection();
    _client = await _connection.connect(_host, _port);

    if (_password != null) {
      await _client.send_object(['AUTH', _password!]);
    }

    if (_database != 0) {
      await _client.send_object(['SELECT', _database]);
    }
  }

  /// Get the underlying Redis command client
  Command get client => _client;

  /// Execute a custom command
  Future<dynamic> sendCommand(List<dynamic> command) async {
    return await _client.send_object(command);
  }

  /// Set a key-value pair
  Future<void> set(String key, String value, {Duration? ttl}) async {
    if (ttl != null) {
      await _client.send_object(['SETEX', key, ttl.inSeconds, value]);
    } else {
      await _client.send_object(['SET', key, value]);
    }
  }

  /// Get a value by key
  Future<String?> get(String key) async {
    final result = await _client.send_object(['GET', key]);
    return result as String?;
  }

  /// Delete a key
  Future<int> delete(String key) async {
    final result = await _client.send_object(['DEL', key]);
    return result as int;
  }

  /// Check if key exists
  Future<bool> exists(String key) async {
    final result = await _client.send_object(['EXISTS', key]);
    return (result as int) == 1;
  }

  /// Set expiration for a key
  Future<void> expire(String key, Duration ttl) async {
    await _client.send_object(['EXPIRE', key, ttl.inSeconds]);
  }

  /// Get TTL for a key
  Future<int> ttl(String key) async {
    final result = await _client.send_object(['TTL', key]);
    return result as int;
  }

  /// Close the connection
  Future<void> close() async {
    await _connection.close();
  }
}
