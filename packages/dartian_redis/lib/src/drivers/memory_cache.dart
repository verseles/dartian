import 'driver.dart';

class MemoryCache implements CacheDriver {
  final Map<String, dynamic> _cache = {};

  @override
  Future<dynamic> get(String key) async {
    return _cache[key];
  }

  @override
  Future<void> set(String key, dynamic value, {Duration? expire}) async {
    _cache[key] = value;
  }

  @override
  Future<void> del(String key) async {
    _cache.remove(key);
  }

  @override
  Future<void> flush() async {
    _cache.clear();
  }
}
