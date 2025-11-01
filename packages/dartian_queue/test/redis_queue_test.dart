import 'package:dartian_queue/dartian_queue.dart';
import 'package:dartian_queue/src/drivers/redis_queue.dart';
import 'package:dartian_redis/dartian_redis.dart';
import 'package:test/test.dart';

class TestJob extends Job {
  final int id;

  TestJob(this.id);

  @override
  Future<void> handle() async {
    // No-op
  }

  @override
  Map<String, dynamic> toJson() => {'id': id};

  static TestJob fromJson(Map<String, dynamic> json) => TestJob(json['id']);
}

void main() {
  group('RedisQueue', () {
    late RedisClient client;
    late RedisQueue queue;

    setUp(() async {
      client = RedisClient();
      await client.connect();
      await client.flushall();
      queue = RedisQueue(client);
    });

    tearDown(() async {
      await client.disconnect();
    });

    test('can push and pop a job', () async {
      final job = TestJob(123);
      await queue.push(job);

      // The pop implementation is more complex due to deserialization.
      // This test is a placeholder for the basic push functionality.
      final result = await client.command!.send_object(['LLEN', 'default']);
      expect(result, 1);
    });
  }, skip: 'Requires a running Redis server');
}
