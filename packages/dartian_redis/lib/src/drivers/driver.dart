abstract class CacheDriver {
  Future<dynamic> get(String key);
  Future<void> set(String key, dynamic value, {Duration? expire});
  Future<void> del(String key);
  Future<void> flush();
}
