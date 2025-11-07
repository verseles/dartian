import 'redis_client.dart';

/// Redis-based cache implementation
class RedisCache {
  final RedisClient _client;

  RedisCache(this._client);

  /// Get a value from cache
  Future<T?> get<T>(String key) async {
    final value = await _client.get(key);
    if (value == null) return null;

    // Try to deserialize JSON
    try {
      return _deserialize<T>(value);
    } catch (e) {
      return value as T?;
    }
  }

  /// Set a value in cache
  Future<void> put(String key, dynamic value, {Duration? ttl}) async {
    final serialized = _serialize(value);
    await _client.set(key, serialized, ttl: ttl);
  }

  /// Check if key exists
  Future<bool> has(String key) async {
    return await _client.exists(key);
  }

  /// Remove a key from cache
  Future<void> remove(String key) async {
    await _client.delete(key);
  }

  /// Clear all cache (use with caution!)
  Future<void> clear() async {
    await _client.sendCommand(['FLUSHDB']);
  }

  /// Set expiration for a key
  Future<void> expire(String key, Duration ttl) async {
    await _client.expire(key, ttl);
  }

  /// Get TTL for a key
  Future<int> ttl(String key) async {
    return await _client.ttl(key);
  }

  /// Get multiple values
  Future<Map<String, T?>> getMany<T>(List<String> keys) async {
    final results = <String, T?>{};
    for (final key in keys) {
      results[key] = await get<T>(key);
    }
    return results;
  }

  /// Set multiple values
  Future<void> putMany(Map<String, dynamic> values, {Duration? ttl}) async {
    for (final entry in values.entries) {
      await put(entry.key, entry.value, ttl: ttl);
    }
  }

  /// Serialize value to JSON string
  String _serialize(dynamic value) {
    if (value is String) return value;
    return value.toString();
  }

  /// Deserialize value from string
  T? _deserialize<T>(String value) {
    if (T == String) return value as T;
    // For other types, just return the string
    // In a real implementation, you'd use json.decode here
    return value as T?;
  }
}
