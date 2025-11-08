import 'package:test/test.dart';
import 'package:dartian_redis/dartian_redis.dart';
import 'mocks/fake_redis_client.dart';

void main() {
  group('RedisClient - Functional Tests', () {
    late FakeRedisClient client;

    setUp(() async {
      client = FakeRedisClient('localhost');
      await client.connect();
    });

    tearDown(() async {
      await client.close();
    });

    group('Connection', () {
      test('should connect successfully', () async {
        final newClient = FakeRedisClient('localhost');
        await newClient.connect();
        expect(newClient.isConnected, isTrue);
        await newClient.close();
      });

      test('should connect with password', () async {
        final newClient = FakeRedisClient('localhost', password: 'secret');
        await newClient.connect();
        expect(newClient.isConnected, isTrue);
        await newClient.close();
      });

      test('should connect to specific database', () async {
        final newClient = FakeRedisClient('localhost', database: 2);
        await newClient.connect();
        expect(newClient.isConnected, isTrue);
        await newClient.close();
      });

      test('should throw error when calling methods without connection', () async {
        final newClient = FakeRedisClient('localhost');
        expect(
          () => newClient.set('key', 'value'),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('Basic Operations', () {
      test('should set and get value', () async {
        await client.set('test_key', 'test_value');
        final value = await client.get('test_key');
        expect(value, equals('test_value'));
      });

      test('should return null for non-existent key', () async {
        final value = await client.get('non_existent');
        expect(value, isNull);
      });

      test('should delete key', () async {
        await client.set('test_key', 'test_value');
        final deleted = await client.delete('test_key');
        expect(deleted, equals(1));
        final value = await client.get('test_key');
        expect(value, isNull);
      });

      test('should return 0 when deleting non-existent key', () async {
        final deleted = await client.delete('non_existent');
        expect(deleted, equals(0));
      });

      test('should check if key exists', () async {
        await client.set('test_key', 'test_value');
        final exists = await client.exists('test_key');
        expect(exists, isTrue);
      });

      test('should return false for non-existent key', () async {
        final exists = await client.exists('non_existent');
        expect(exists, isFalse);
      });
    });

    group('TTL Operations', () {
      test('should set value with TTL', () async {
        await client.set('test_key', 'test_value', ttl: Duration(seconds: 60));
        final value = await client.get('test_key');
        expect(value, equals('test_value'));
      });

      test('should get TTL for key', () async {
        await client.set('test_key', 'test_value', ttl: Duration(seconds: 60));
        final ttl = await client.ttl('test_key');
        expect(ttl, greaterThan(0));
        expect(ttl, lessThanOrEqualTo(60));
      });

      test('should return -1 for key without expiration', () async {
        await client.set('test_key', 'test_value');
        final ttl = await client.ttl('test_key');
        expect(ttl, equals(-1));
      });

      test('should return -2 for non-existent key', () async {
        final ttl = await client.ttl('non_existent');
        expect(ttl, equals(-2));
      });

      test('should set expiration on existing key', () async {
        await client.set('test_key', 'test_value');
        await client.expire('test_key', Duration(seconds: 30));
        final ttl = await client.ttl('test_key');
        expect(ttl, greaterThan(0));
        expect(ttl, lessThanOrEqualTo(30));
      });

      test('should expire key after TTL', () async {
        await client.set('test_key', 'test_value', ttl: Duration(milliseconds: 100));
        await Future.delayed(Duration(milliseconds: 150));
        final value = await client.get('test_key');
        expect(value, isNull);
      });
    });

    group('Increment/Decrement', () {
      test('should increment value', () async {
        final result = await client.incr('counter');
        expect(result, equals(1));
      });

      test('should increment existing value', () async {
        await client.set('counter', '5');
        final result = await client.incr('counter');
        expect(result, equals(6));
      });

      test('should decrement value', () async {
        await client.set('counter', '10');
        final result = await client.decr('counter');
        expect(result, equals(9));
      });

      test('should decrement from zero', () async {
        final result = await client.decr('counter');
        expect(result, equals(-1));
      });

      test('should increment by specific amount', () async {
        await client.set('counter', '10');
        final result = await client.incrBy('counter', 5);
        expect(result, equals(15));
      });

      test('should decrement by specific amount', () async {
        await client.set('counter', '10');
        final result = await client.decrBy('counter', 3);
        expect(result, equals(7));
      });

      test('should handle multiple increments', () async {
        await client.incr('counter');
        await client.incr('counter');
        final result = await client.incr('counter');
        expect(result, equals(3));
      });
    });

    group('Error Handling', () {
      test('should throw on empty command', () async {
        expect(
          () => client.sendCommand([]),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should handle connection close gracefully', () async {
        await client.set('test_key', 'test_value');
        await client.close();
        expect(
          () => client.get('test_key'),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('Pub/Sub Operations', () {
      test('should subscribe to channel', () async {
        await client.sendCommand(['SUBSCRIBE', 'test_channel']);
        // Subscription command should succeed
        expect(client.isConnected, isTrue);
      });

      test('should unsubscribe from channel', () async {
        await client.sendCommand(['SUBSCRIBE', 'test_channel']);
        await client.sendCommand(['UNSUBSCRIBE', 'test_channel']);
        // Unsubscription command should succeed
        expect(client.isConnected, isTrue);
      });

      test('should publish message', () async {
        await client.sendCommand(['SUBSCRIBE', 'test_channel']);
        final result = await client.sendCommand(['PUBLISH', 'test_channel', 'hello']);
        expect(result, isA<int>());
      });
    });

    group('Bulk Operations', () {
      test('should handle multiple set operations', () async {
        await client.set('key1', 'value1');
        await client.set('key2', 'value2');
        await client.set('key3', 'value3');

        final value1 = await client.get('key1');
        final value2 = await client.get('key2');
        final value3 = await client.get('key3');

        expect(value1, equals('value1'));
        expect(value2, equals('value2'));
        expect(value3, equals('value3'));
      });

      test('should clear all data with FLUSHDB', () async {
        await client.set('key1', 'value1');
        await client.set('key2', 'value2');
        await client.sendCommand(['FLUSHDB']);

        final value1 = await client.get('key1');
        final value2 = await client.get('key2');

        expect(value1, isNull);
        expect(value2, isNull);
      });
    });
  });

  group('RedisCache - Functional Tests', () {
    late FakeRedisClient client;
    late RedisCache cache;

    setUp(() async {
      client = FakeRedisClient('localhost');
      await client.connect();
      cache = RedisCache(client);
    });

    tearDown(() async {
      await client.close();
    });

    group('Basic Cache Operations', () {
      test('should put and get string value', () async {
        await cache.put('test_key', 'test_value');
        final value = await cache.get<String>('test_key');
        expect(value, equals('test_value'));
      });

      test('should return null for non-existent key', () async {
        final value = await cache.get<String>('non_existent');
        expect(value, isNull);
      });

      test('should check if key exists', () async {
        await cache.put('test_key', 'test_value');
        final has = await cache.has('test_key');
        expect(has, isTrue);
      });

      test('should remove key', () async {
        await cache.put('test_key', 'test_value');
        await cache.remove('test_key');
        final has = await cache.has('test_key');
        expect(has, isFalse);
      });

      test('should clear all cache', () async {
        await cache.put('key1', 'value1');
        await cache.put('key2', 'value2');
        await cache.clear();

        final has1 = await cache.has('key1');
        final has2 = await cache.has('key2');

        expect(has1, isFalse);
        expect(has2, isFalse);
      });
    });

    group('Cache TTL Operations', () {
      test('should put value with TTL', () async {
        await cache.put('test_key', 'test_value', ttl: Duration(seconds: 60));
        final value = await cache.get<String>('test_key');
        expect(value, equals('test_value'));
      });

      test('should get TTL for cached item', () async {
        await cache.put('test_key', 'test_value', ttl: Duration(seconds: 60));
        final ttl = await cache.ttl('test_key');
        expect(ttl, greaterThan(0));
      });

      test('should set expiration on cached item', () async {
        await cache.put('test_key', 'test_value');
        await cache.expire('test_key', Duration(seconds: 30));
        final ttl = await cache.ttl('test_key');
        expect(ttl, greaterThan(0));
      });
    });

    group('Batch Cache Operations', () {
      test('should get many values', () async {
        await cache.put('key1', 'value1');
        await cache.put('key2', 'value2');
        await cache.put('key3', 'value3');

        final results = await cache.getMany<String>(['key1', 'key2', 'key3']);

        expect(results['key1'], equals('value1'));
        expect(results['key2'], equals('value2'));
        expect(results['key3'], equals('value3'));
      });

      test('should handle missing keys in getMany', () async {
        await cache.put('key1', 'value1');

        final results = await cache.getMany<String>(['key1', 'missing', 'key2']);

        expect(results['key1'], equals('value1'));
        expect(results['missing'], isNull);
        expect(results['key2'], isNull);
      });

      test('should put many values', () async {
        final values = {
          'key1': 'value1',
          'key2': 'value2',
          'key3': 'value3',
        };

        await cache.putMany(values);

        final value1 = await cache.get<String>('key1');
        final value2 = await cache.get<String>('key2');
        final value3 = await cache.get<String>('key3');

        expect(value1, equals('value1'));
        expect(value2, equals('value2'));
        expect(value3, equals('value3'));
      });

      test('should put many values with TTL', () async {
        final values = {
          'key1': 'value1',
          'key2': 'value2',
        };

        await cache.putMany(values, ttl: Duration(seconds: 60));

        final ttl1 = await cache.ttl('key1');
        final ttl2 = await cache.ttl('key2');

        expect(ttl1, greaterThan(0));
        expect(ttl2, greaterThan(0));
      });

      test('should handle empty map in putMany', () async {
        await cache.putMany({});
        // Should not throw
        expect(true, isTrue);
      });

      test('should handle empty list in getMany', () async {
        final results = await cache.getMany<String>([]);
        expect(results, isEmpty);
      });
    });

    group('Cache Serialization', () {
      test('should handle string values', () async {
        await cache.put('string_key', 'string_value');
        final value = await cache.get<String>('string_key');
        expect(value, equals('string_value'));
      });

      test('should handle integer values as strings', () async {
        await cache.put('int_key', 42);
        final value = await cache.get<String>('int_key');
        expect(value, equals('42'));
      });

      test('should handle empty string', () async {
        await cache.put('empty_key', '');
        final value = await cache.get<String>('empty_key');
        expect(value, equals(''));
      });

      test('should handle special characters', () async {
        await cache.put('special_key', 'value with spaces and !@#\$%');
        final value = await cache.get<String>('special_key');
        expect(value, equals('value with spaces and !@#\$%'));
      });
    });
  });

  group('PubSubManager - Functional Tests', () {
    late FakeRedisClient client;
    late PubSubManager pubsub;

    setUp(() async {
      client = FakeRedisClient('localhost');
      await client.connect();
      pubsub = PubSubManager(client);
    });

    tearDown(() async {
      await pubsub.close();
      await client.close();
    });

    test('should create PubSubManager', () {
      expect(pubsub, isNotNull);
      expect(pubsub, isA<PubSubManager>());
    });

    test('should have messages stream', () {
      expect(pubsub.messages, isA<Stream<PubSubMessage>>());
    });

    test('should subscribe to channel', () async {
      await pubsub.subscribe('test_channel');
      // Should not throw
      expect(true, isTrue);
    });

    test('should unsubscribe from channel', () async {
      await pubsub.subscribe('test_channel');
      await pubsub.unsubscribe('test_channel');
      // Should not throw
      expect(true, isTrue);
    });

    test('should publish message', () async {
      await pubsub.subscribe('test_channel');
      final result = await pubsub.publish('test_channel', 'test message');
      expect(result, isA<int>());
    });

    test('should handle multiple subscriptions', () async {
      await pubsub.subscribe('channel1');
      await pubsub.subscribe('channel2');
      await pubsub.subscribe('channel3');
      // Should not throw
      expect(true, isTrue);
    });

    test('should close gracefully', () async {
      await pubsub.subscribe('test_channel');
      await pubsub.close();
      // Should not throw
      expect(true, isTrue);
    });
  });

  group('Integration Tests', () {
    test('should work end-to-end', () async {
      final client = FakeRedisClient('localhost');
      await client.connect();

      final cache = RedisCache(client);

      // Set some values
      await cache.put('user:1:name', 'John Doe');
      await cache.put('user:1:email', 'john@example.com');
      await cache.put('user:1:age', '30');

      // Get values back
      final name = await cache.get<String>('user:1:name');
      final email = await cache.get<String>('user:1:email');
      final age = await cache.get<String>('user:1:age');

      expect(name, equals('John Doe'));
      expect(email, equals('john@example.com'));
      expect(age, equals('30'));

      // Clean up
      await cache.remove('user:1:name');
      await cache.remove('user:1:email');
      await cache.remove('user:1:age');

      await client.close();
    });

    test('should handle concurrent operations', () async {
      final client = FakeRedisClient('localhost');
      await client.connect();

      final cache = RedisCache(client);

      // Concurrent writes
      await Future.wait([
        cache.put('key1', 'value1'),
        cache.put('key2', 'value2'),
        cache.put('key3', 'value3'),
      ]);

      // Concurrent reads
      final results = await Future.wait([
        cache.get<String>('key1'),
        cache.get<String>('key2'),
        cache.get<String>('key3'),
      ]);

      expect(results[0], equals('value1'));
      expect(results[1], equals('value2'));
      expect(results[2], equals('value3'));

      await client.close();
    });
  });
}
