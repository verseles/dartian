import 'dart:async';

abstract class CacheDriver {
  Future<void> set(String key, String value, {Duration? expire});
  Future<String?> get(String key);
  Future<void> delete(String key);
  Future<void> flush();
}

class MemoryCache implements CacheDriver {
  final Map<String, String> _cache = {};

  @override
  Future<void> set(String key, String value, {Duration? expire}) async {
    _cache[key] = value;
    if (expire != null) {
      Timer(expire, () => _cache.remove(key));
    }
  }

  @override
  Future<String?> get(String key) async => _cache[key];

  @override
  Future<void> delete(String key) async => _cache.remove(key);

  @override
  Future<void> flush() async => _cache.clear();
}
