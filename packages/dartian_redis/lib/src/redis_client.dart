import 'package:redis/redis.dart';

class RedisClient {
  final RedisConnection _connection;
  Command? _command;

  RedisClient() : _connection = RedisConnection();

  Future<void> connect({
    String host = '127.0.0.1',
    int port = 6379,
    String? password,
  }) async {
    _command = await _connection.connect(host, port);
    if (password != null) {
      await _command!.send_object(['AUTH', password]);
    }
  }

  Future<void> disconnect() async {
    await _connection.close();
    _command = null;
  }

  Future<dynamic> get(String key) async {
    return await _command?.get(key);
  }

  Future<void> set(String key, dynamic value, {Duration? expire}) async {
    if (expire != null) {
      await _command?.send_object(['SET', key, value, 'EX', expire.inSeconds]);
    } else {
      await _command?.set(key, value);
    }
  }

  Future<void> del(String key) async {
    await _command?.send_object(['DEL', key]);
  }

  Future<void> flushall() async {
    await _command?.send_object(['FLUSHALL']);
  }

  Command? get command => _command;
}
