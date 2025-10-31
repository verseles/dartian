import '../redis_client.dart';
import 'driver.dart';

class RedisCache implements CacheDriver {
  final RedisClient _client;

  RedisCache(this._client);

  @override
  Future<dynamic> get(String key) async {
    return await _client.get(key);
  }

  @override
  Future<void> set(String key, dynamic value, {Duration? expire}) async {
    await _client.set(key, value, expire: expire);
  }

  @override
  Future<void> del(String key) async {
    await _client.del(key);
  }

  @override
  Future<void> flush() async {
    await _client.flushall();
  }
}
