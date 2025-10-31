import 'dart:convert';
import 'package:dartian_redis/dartian_redis.dart';
import '../queue.dart';
import 'driver.dart';

class RedisQueue implements QueueDriver {
  final RedisClient _client;

  RedisQueue(this._client);

  @override
  Future<void> push(Job job, {String queue = 'default'}) async {
    final payload = jsonEncode({
      'type': job.runtimeType.toString(),
      'data': job.toJson(),
    });
    await _client.command!.send_object(['LPUSH', queue, payload]);
  }

  @override
  Future<Job?> pop(String queue) async {
    final result = await _client.command!.send_object(['BRPOP', queue, '0']);
    if (result == null || result.isEmpty) {
      return null;
    }
    final payload = jsonDecode(result[1]);
    return _createJobInstance(payload['type'], payload['data']);
  }

  @override
  Future<void> ack(Job job) async {
    // No-op
  }

  Job? _createJobInstance(String type, Map<String, dynamic> data) {
    // This is a simplified implementation. A real implementation would need
    // a more robust way to map the type string to the actual class.
    // For the MVP, we will assume a simple mapping.
    return null;
  }
}

extension on Job {
  Map<String, dynamic> toJson() {
    // This would be implemented by each job class.
    return {};
  }
}
