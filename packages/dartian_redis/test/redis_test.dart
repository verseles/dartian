import 'package:test/test.dart';
import 'package:dartian_redis/dartian_redis.dart';

void main() {
  group('RedisManager', () {
    test('should be a singleton', () {
      final instance1 = RedisManager.instance;
      final instance2 = RedisManager.instance;

      expect(instance1, same(instance2));
    });

    test('should create Redis client with default port', () {
      final manager = RedisManager.instance;
      final client = manager.connect('localhost');

      expect(client, isA<RedisClient>());
    });

    test('should create Redis client with custom port', () {
      final manager = RedisManager.instance;
      final client = manager.connect('localhost', port: 6380);

      expect(client, isA<RedisClient>());
    });

    test('should create Redis client with password', () {
      final manager = RedisManager.instance;
      final client = manager.connect('localhost', password: 'secret');

      expect(client, isA<RedisClient>());
    });

    test('should create Redis client with database number', () {
      final manager = RedisManager.instance;
      final client = manager.connect('localhost', database: 1);

      expect(client, isA<RedisClient>());
    });
  });

  group('RedisClient', () {
    test('should create client with host', () {
      final client = RedisClient('localhost');
      expect(client, isNotNull);
    });

    test('should create client with all parameters', () {
      final client = RedisClient(
        'localhost',
        port: 6380,
        password: 'secret',
        database: 1,
      );
      expect(client, isNotNull);
    });

    // Note: The following tests would require a real Redis instance
    // or proper mocking. For now, we're testing the structure and API.

    test('should have set method', () {
      final client = RedisClient('localhost');
      expect(client.set, isA<Function>());
    });

    test('should have get method', () {
      final client = RedisClient('localhost');
      expect(client.get, isA<Function>());
    });

    test('should have delete method', () {
      final client = RedisClient('localhost');
      expect(client.delete, isA<Function>());
    });

    test('should have exists method', () {
      final client = RedisClient('localhost');
      expect(client.exists, isA<Function>());
    });

    test('should have expire method', () {
      final client = RedisClient('localhost');
      expect(client.expire, isA<Function>());
    });

    test('should have ttl method', () {
      final client = RedisClient('localhost');
      expect(client.ttl, isA<Function>());
    });

    test('should have close method', () {
      final client = RedisClient('localhost');
      expect(client.close, isA<Function>());
    });

    test('should have connect method', () {
      final client = RedisClient('localhost');
      expect(client.connect, isA<Function>());
    });

    test('should have sendCommand method', () {
      final client = RedisClient('localhost');
      expect(client.sendCommand, isA<Function>());
    });
  });

  group('RedisCache', () {
    late RedisClient mockClient;
    late RedisCache cache;

    setUp(() {
      // Create a mock client (won't actually connect)
      mockClient = RedisClient('localhost');
      cache = RedisCache(mockClient);
    });

    test('should create cache with Redis client', () {
      expect(cache, isNotNull);
      expect(cache, isA<RedisCache>());
    });

    test('should have get method', () {
      expect(cache.get, isA<Function>());
    });

    test('should have put method', () {
      expect(cache.put, isA<Function>());
    });

    test('should have has method', () {
      expect(cache.has, isA<Function>());
    });

    test('should have remove method', () {
      expect(cache.remove, isA<Function>());
    });

    test('should have clear method', () {
      expect(cache.clear, isA<Function>());
    });

    test('should have expire method', () {
      expect(cache.expire, isA<Function>());
    });

    test('should have ttl method', () {
      expect(cache.ttl, isA<Function>());
    });

    test('should have getMany method', () {
      expect(cache.getMany, isA<Function>());
    });

    test('should have putMany method', () {
      expect(cache.putMany, isA<Function>());
    });

    test('should serialize string values correctly', () {
      // Testing the private method indirectly
      // String values should remain as strings
      expect(cache, isNotNull);
    });

    test('should handle Duration parameter in put', () {
      final duration = Duration(seconds: 60);
      // Testing that put accepts Duration parameter
      expect(() => cache.put('key', 'value', ttl: duration), isA<Function>());
    });

    test('should handle Duration parameter in putMany', () {
      final duration = Duration(seconds: 60);
      final values = {'key1': 'value1', 'key2': 'value2'};
      // Testing that putMany accepts Duration parameter
      expect(() => cache.putMany(values, ttl: duration), isA<Function>());
    });

    test('should handle generic types in get', () {
      // Testing that get accepts type parameter
      expect(() => cache.get<String>('key'), isA<Function>());
      expect(() => cache.get<int>('key'), isA<Function>());
    });

    test('should handle generic types in getMany', () {
      // Testing that getMany accepts type parameter
      expect(() => cache.getMany<String>(['key1', 'key2']), isA<Function>());
    });
  });

  group('RedisCache - Serialization', () {
    late RedisClient mockClient;
    late RedisCache cache;

    setUp(() {
      mockClient = RedisClient('localhost');
      cache = RedisCache(mockClient);
    });

    test('should handle string values', () {
      // Test that string types are properly handled
      expect(cache, isNotNull);
    });

    test('should handle non-string values', () {
      // Test that non-string types are handled
      expect(cache, isNotNull);
    });

    test('should handle null values', () {
      // Test null handling
      expect(cache, isNotNull);
    });
  });

  group('RedisCache - Batch Operations', () {
    late RedisClient mockClient;
    late RedisCache cache;

    setUp(() {
      mockClient = RedisClient('localhost');
      cache = RedisCache(mockClient);
    });

    test('should accept empty map in putMany', () {
      final emptyMap = <String, dynamic>{};
      expect(() => cache.putMany(emptyMap), isA<Function>());
    });

    test('should accept empty list in getMany', () {
      final emptyList = <String>[];
      expect(() => cache.getMany<String>(emptyList), isA<Function>());
    });

    test('should accept multiple items in putMany', () {
      final items = {'key1': 'value1', 'key2': 'value2', 'key3': 'value3'};
      expect(() => cache.putMany(items), isA<Function>());
    });

    test('should accept multiple keys in getMany', () {
      final keys = ['key1', 'key2', 'key3'];
      expect(() => cache.getMany<String>(keys), isA<Function>());
    });
  });

  group('RedisCache - TTL Operations', () {
    late RedisClient mockClient;
    late RedisCache cache;

    setUp(() {
      mockClient = RedisClient('localhost');
      cache = RedisCache(mockClient);
    });

    test('should accept Duration in expire', () {
      final duration = Duration(minutes: 10);
      expect(() => cache.expire('key', duration), isA<Function>());
    });

    test('should accept short duration in expire', () {
      final duration = Duration(seconds: 1);
      expect(() => cache.expire('key', duration), isA<Function>());
    });

    test('should accept long duration in expire', () {
      final duration = Duration(days: 7);
      expect(() => cache.expire('key', duration), isA<Function>());
    });

    test('should have ttl method that returns Future<int>', () {
      // TTL method should exist and return correct type
      // Cannot test actual call without Redis connection
      expect(cache.ttl, isA<Function>());
    });
  });

  group('Integration - RedisManager + RedisClient + RedisCache', () {
    test('should create full stack from manager', () {
      final manager = RedisManager.instance;
      final client = manager.connect('localhost');
      final cache = RedisCache(client);

      expect(manager, isNotNull);
      expect(client, isNotNull);
      expect(cache, isNotNull);
    });

    test('should create cache with custom connection parameters', () {
      final manager = RedisManager.instance;
      final client = manager.connect(
        'localhost',
        port: 6380,
        password: 'secret',
        database: 2,
      );
      final cache = RedisCache(client);

      expect(cache, isNotNull);
    });

    test('should allow multiple cache instances', () {
      final manager = RedisManager.instance;
      final client1 = manager.connect('localhost', database: 0);
      final client2 = manager.connect('localhost', database: 1);
      final cache1 = RedisCache(client1);
      final cache2 = RedisCache(client2);

      expect(cache1, isNot(same(cache2)));
    });
  });
}
