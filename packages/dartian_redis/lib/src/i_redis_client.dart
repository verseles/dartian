/// Abstract interface for Redis clients
/// Allows for both real and fake implementations
abstract class IRedisClient {
  /// Connect to Redis
  Future<void> connect();

  /// Close the connection
  Future<void> close();

  /// Set a key-value pair
  Future<void> set(String key, String value, {Duration? ttl});

  /// Get a value by key
  Future<String?> get(String key);

  /// Delete a key
  Future<int> delete(String key);

  /// Check if key exists
  Future<bool> exists(String key);

  /// Set expiration for a key
  Future<void> expire(String key, Duration ttl);

  /// Get TTL for a key
  Future<int> ttl(String key);

  /// Execute a custom command
  Future<dynamic> sendCommand(List<dynamic> command);

  /// Get the underlying Redis command client
  dynamic get client;
}
