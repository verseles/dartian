import 'package:dartian_redis/dartian_redis.dart';
import 'package:test/test.dart';

void main() {
  group('MemoryCache', () {
    late MemoryCache cache;

    setUp(() {
      cache = MemoryCache();
    });

    test('can set and get a value', () async {
      await cache.set('foo', 'bar');
      final value = await cache.get('foo');
      expect(value, 'bar');
    });

    test('can delete a value', () async {
      await cache.set('foo', 'bar');
      await cache.del('foo');
      final value = await cache.get('foo');
      expect(value, isNull);
    });

    test('can flush all values', () async {
      await cache.set('foo', 'bar');
      await cache.flush();
      final value = await cache.get('foo');
      expect(value, isNull);
    });
  });
}
