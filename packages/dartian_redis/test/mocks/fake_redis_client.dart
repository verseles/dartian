import 'package:dartian_redis/src/redis_client.dart';
import 'fake_redis.dart';

/// Testable Redis client that uses FakeRedis
class FakeRedisClient extends RedisClient {
  final FakeRedis _fakeRedis;
  bool _isConnected = false;
  final String? _testPassword;
  final int _testDatabase;

  FakeRedisClient(
    String host, {
    int port = 6379,
    String? password,
    int database = 0,
  })  : _fakeRedis = FakeRedis(),
        _testPassword = password,
        _testDatabase = database,
        super(host, port: port, password: password, database: database);

  /// Override connect to use fake Redis
  @override
  Future<void> connect() async {
    // Simulate connection
    if (_testPassword != null) {
      await _fakeRedis.sendCommand(['AUTH', _testPassword!]);
    }
    if (_testDatabase != 0) {
      await _fakeRedis.sendCommand(['SELECT', _testDatabase]);
    }
    _isConnected = true;
  }

  /// Override sendCommand to use fake Redis
  @override
  Future<dynamic> sendCommand(List<dynamic> command) async {
    if (!_isConnected) {
      throw StateError('Not connected to Redis');
    }
    return await _fakeRedis.sendCommand(command);
  }

  /// Override set
  @override
  Future<void> set(String key, String value, {Duration? ttl}) async {
    if (!_isConnected) {
      throw StateError('Not connected to Redis');
    }
    if (ttl != null) {
      await _fakeRedis.sendCommand(['SETEX', key, ttl.inSeconds, value]);
    } else {
      await _fakeRedis.sendCommand(['SET', key, value]);
    }
  }

  /// Override get
  @override
  Future<String?> get(String key) async {
    if (!_isConnected) {
      throw StateError('Not connected to Redis');
    }
    final result = await _fakeRedis.sendCommand(['GET', key]);
    return result as String?;
  }

  /// Override delete
  @override
  Future<int> delete(String key) async {
    if (!_isConnected) {
      throw StateError('Not connected to Redis');
    }
    final result = await _fakeRedis.sendCommand(['DEL', key]);
    return result as int;
  }

  /// Override exists
  @override
  Future<bool> exists(String key) async {
    if (!_isConnected) {
      throw StateError('Not connected to Redis');
    }
    final result = await _fakeRedis.sendCommand(['EXISTS', key]);
    return (result as int) == 1;
  }

  /// Override expire
  @override
  Future<void> expire(String key, Duration ttl) async {
    if (!_isConnected) {
      throw StateError('Not connected to Redis');
    }
    await _fakeRedis.sendCommand(['EXPIRE', key, ttl.inSeconds]);
  }

  /// Override ttl
  @override
  Future<int> ttl(String key) async {
    if (!_isConnected) {
      throw StateError('Not connected to Redis');
    }
    final result = await _fakeRedis.sendCommand(['TTL', key]);
    return result as int;
  }

  /// Override close
  @override
  Future<void> close() async {
    _isConnected = false;
    await _fakeRedis.close();
  }

  /// Get the underlying fake Redis (for testing)
  FakeRedis get fakeRedis => _fakeRedis;

  /// Check if connected
  bool get isConnected => _isConnected;

  // Add missing increment/decrement methods
  Future<int> incr(String key) async {
    if (!_isConnected) {
      throw StateError('Not connected to Redis');
    }
    final result = await _fakeRedis.sendCommand(['INCR', key]);
    return result as int;
  }

  Future<int> decr(String key) async {
    if (!_isConnected) {
      throw StateError('Not connected to Redis');
    }
    final result = await _fakeRedis.sendCommand(['DECR', key]);
    return result as int;
  }

  Future<int> incrBy(String key, int increment) async {
    if (!_isConnected) {
      throw StateError('Not connected to Redis');
    }
    final result = await _fakeRedis.sendCommand(['INCRBY', key, increment]);
    return result as int;
  }

  Future<int> decrBy(String key, int decrement) async {
    if (!_isConnected) {
      throw StateError('Not connected to Redis');
    }
    final result = await _fakeRedis.sendCommand(['DECRBY', key, decrement]);
    return result as int;
  }
}
