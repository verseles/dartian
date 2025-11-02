import 'package:dartian_redis/dartian_redis.dart';

// This example requires a running Redis server on localhost:6379.
void main() async {
  final client = RedisClient();
  await client.connect();

  await client.set('mykey', 'myvalue');
  final value = await client.get('mykey');
  print('Got value from Redis: $value');

  await client.disconnect();
}
