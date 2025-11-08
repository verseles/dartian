import 'dart:convert';
import 'package:test/test.dart';
import 'package:dartian_queue/dartian_queue.dart';
import 'mocks/fake_redis_client.dart';

void main() {
  group('RedisQueue', () {
    late FakeRedisClient redis;
    late RedisQueue queue;

    setUp(() async {
      redis = FakeRedisClient('localhost');
      await redis.connect();
      queue = RedisQueue(redis);
    });

    tearDown(() async {
      await redis.close();
    });

    test('should create RedisQueue', () {
      expect(queue, isNotNull);
      expect(queue, isA<Queue>());
    });

    test('should push job to Redis queue', () async {
      final jobId = await queue.push('default', '{"test": "data"}');

      expect(jobId, isNotEmpty);
      expect(jobId, isA<String>());
    });

    test('should pop job from Redis queue', () async {
      await queue.push('default', '{"test": "data"}');
      final job = await queue.pop('default');

      expect(job, isNotNull);
      expect(job!.queue, equals('default'));
      expect(job.payload, equals('{"test": "data"}'));
      expect(job.status, equals(JobStatus.pending));
    });

    test('should return null when popping from empty queue', () async {
      final job = await queue.pop('default');
      expect(job, isNull);
    });

    test('should maintain FIFO order', () async {
      await queue.push('default', 'first');
      await queue.push('default', 'second');
      await queue.push('default', 'third');

      final job1 = await queue.pop('default');
      final job2 = await queue.pop('default');
      final job3 = await queue.pop('default');

      expect(job1!.payload, equals('first'));
      expect(job2!.payload, equals('second'));
      expect(job3!.payload, equals('third'));
    });

    test('should get queue size', () async {
      expect(await queue.size('default'), equals(0));

      await queue.push('default', 'job1');
      expect(await queue.size('default'), equals(1));

      await queue.push('default', 'job2');
      expect(await queue.size('default'), equals(2));

      await queue.pop('default');
      expect(await queue.size('default'), equals(1));
    });

    test('should handle multiple named queues', () async {
      await queue.push('emails', 'email1');
      await queue.push('notifications', 'notif1');
      await queue.push('emails', 'email2');

      expect(await queue.size('emails'), equals(2));
      expect(await queue.size('notifications'), equals(1));

      final emailJob = await queue.pop('emails');
      expect(emailJob!.payload, equals('email1'));
      expect(emailJob.queue, equals('emails'));

      final notifJob = await queue.pop('notifications');
      expect(notifJob!.payload, equals('notif1'));
      expect(notifJob.queue, equals('notifications'));
    });

    test('should clear queue', () async {
      await queue.push('default', 'job1');
      await queue.push('default', 'job2');
      await queue.push('default', 'job3');

      expect(await queue.size('default'), equals(3));

      await queue.clear('default');

      expect(await queue.size('default'), equals(0));
      expect(await queue.pop('default'), isNull);
    });

    test('should not affect other queues when clearing', () async {
      await queue.push('queue1', 'job1');
      await queue.push('queue2', 'job2');
      await queue.push('queue1', 'job3');

      await queue.clear('queue1');

      expect(await queue.size('queue1'), equals(0));
      expect(await queue.size('queue2'), equals(1));
    });

    test('should use custom prefix', () async {
      final customQueue = RedisQueue(redis, prefix: 'myapp:');

      final jobId = await customQueue.push('default', 'test');
      expect(jobId, isNotEmpty);

      final job = await customQueue.pop('default');
      expect(job, isNotNull);
      expect(job!.payload, equals('test'));
    });

    test('should handle empty payload', () async {
      final jobId = await queue.push('default', '');

      expect(jobId, isNotEmpty);
      final job = await queue.pop('default');
      expect(job!.payload, isEmpty);
    });

    test('should handle large payloads', () async {
      final largePayload = 'x' * 10000;
      final jobId = await queue.push('default', largePayload);

      expect(jobId, isNotEmpty);
      final job = await queue.pop('default');
      expect(job!.payload.length, equals(10000));
    });

    test('should store and retrieve job metadata correctly', () async {
      final jobId = await queue.push('default', '{"userId": 123}');
      final job = await queue.pop('default');

      expect(job, isNotNull);
      expect(job!.id, equals(jobId));
      expect(job.queue, equals('default'));
      expect(job.payload, contains('userId'));
      expect(job.status, equals(JobStatus.pending));
      expect(job.createdAt, isA<DateTime>());
    });

    test('should handle JSON serialization/deserialization', () async {
      final jobId = await queue.push('default', jsonEncode({'action': 'send_email', 'to': 'user@example.com'}));

      final job = await queue.pop('default');
      expect(job, isNotNull);

      final payload = jsonDecode(job!.payload);
      expect(payload['action'], equals('send_email'));
      expect(payload['to'], equals('user@example.com'));
    });
  });

  group('RedisQueueWorker', () {
    late FakeRedisClient redis;
    late RedisQueueWorker worker;

    setUp(() async {
      redis = FakeRedisClient('localhost');
      await redis.connect();
      worker = RedisQueueWorker(redis);
    });

    tearDown(() async {
      await redis.close();
    });

    test('should create RedisQueueWorker', () {
      expect(worker, isNotNull);
      expect(worker, isA<QueueWorker>());
    });

    test('should start worker', () async {
      await worker.start();
      expect(worker, isNotNull);
    });

    test('should stop worker', () async {
      await worker.start();
      await worker.stop();
      expect(worker, isNotNull);
    });

    test('should process job successfully', () async {
      final job = Job(
        id: '1',
        queue: 'default',
        payload: '{"test": "data"}',
        createdAt: DateTime.now(),
      );

      await worker.start();
      await worker.process(job);

      expect(job.status, equals(JobStatus.completed));
      expect(job.error, isNull);
    });

    test('should handle multiple job processing', () async {
      final job1 = Job(
        id: '1',
        queue: 'default',
        payload: 'job1',
        createdAt: DateTime.now(),
      );
      final job2 = Job(
        id: '2',
        queue: 'default',
        payload: 'job2',
        createdAt: DateTime.now(),
      );

      await worker.start();
      await worker.process(job1);
      await worker.process(job2);

      expect(job1.status, equals(JobStatus.completed));
      expect(job2.status, equals(JobStatus.completed));
    });

    test('should update job status in Redis', () async {
      final job = Job(
        id: '1',
        queue: 'default',
        payload: '{"test": "data"}',
        createdAt: DateTime.now(),
      );

      await worker.start();
      await worker.process(job);

      // Verify job was stored in Redis
      final jobKey = 'queue:job:${job.id}';
      final storedJob = await redis.get(jobKey);

      expect(storedJob, isNotNull);

      final jobData = jsonDecode(storedJob!);
      expect(jobData['status'], equals('completed'));
    });
  });

  group('Integration - RedisQueue + RedisQueueWorker', () {
    late FakeRedisClient redis;
    late RedisQueue queue;
    late RedisQueueWorker worker;
    late QueueManager manager;

    setUp(() async {
      redis = FakeRedisClient('localhost');
      await redis.connect();
      queue = RedisQueue(redis);
      worker = RedisQueueWorker(redis);
      manager = QueueManager(queue, worker);
    });

    tearDown() async {
      await manager.stop();
      await redis.close();
    });

    test('should process jobs end-to-end with Redis', () async {
      await manager.push('default', 'job1');
      await manager.push('default', 'job2');

      expect(await manager.size('default'), equals(2));
    });

    test('should handle job lifecycle', () async {
      final jobId = await queue.push('default', '{"action": "send_notification"}');
      expect(jobId, isNotEmpty);

      final job = await queue.pop('default');
      expect(job, isNotNull);
      expect(job!.id, equals(jobId));

      await worker.start();
      await worker.process(job);

      expect(job.status, equals(JobStatus.completed));

      await worker.stop();
    });

    test('should handle multiple queues concurrently', () async {
      await manager.push('emails', 'email_job');
      await manager.push('notifications', 'notification_job');
      await manager.push('reports', 'report_job');

      expect(await manager.size('emails'), equals(1));
      expect(await manager.size('notifications'), equals(1));
      expect(await manager.size('reports'), equals(1));
    });

    test('should maintain data integrity', () async {
      final payload = jsonEncode({
        'userId': 12345,
        'action': 'process_payment',
        'amount': 99.99,
      });

      final jobId = await manager.push('payments', payload);
      final job = await queue.pop('payments');

      expect(job, isNotNull);
      expect(job!.id, equals(jobId));

      final parsedPayload = jsonDecode(job.payload);
      expect(parsedPayload['userId'], equals(12345));
      expect(parsedPayload['action'], equals('process_payment'));
      expect(parsedPayload['amount'], equals(99.99));
    });
  });
}
