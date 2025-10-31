import 'package:dartian_redis/dartian_redis.dart';
import 'package:dartian_redis/src/drivers/redis_cache.dart';
import 'package:test/test.dart';

void main() {
  group('Redis', () {
    late RedisClient client;

    setUp(() async {
      client = RedisClient();
      await client.connect();
      await client.flushall();
    });

    tearDown(() async {
      await client.disconnect();
    });

    test('RedisClient can set and get a value', () async {
      await client.set('foo', 'bar');
      final value = await client.get('foo');
      expect(value, 'bar');
    });

    test('RedisCache implements the CacheDriver interface', () async {
      final cache = RedisCache(client);
      await cache.set('foo', 'bar');
      final value = await cache.get('foo');
      expect(value, 'bar');

      await cache.del('foo');
      final deletedValue = await cache.get('foo');
      expect(deletedValue, isNull);
    });
  }, skip: 'Requires a running Redis server');
}
