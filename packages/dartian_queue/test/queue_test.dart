import 'package:test/test.dart';
import 'package:dartian_queue/dartian_queue.dart';

void main() {
  group('Job', () {
    test('should create job with pending status', () {
      final job = Job(
        id: '1',
        queue: 'default',
        payload: '{"test": "data"}',
        createdAt: DateTime.now(),
      );

      expect(job.id, equals('1'));
      expect(job.queue, equals('default'));
      expect(job.payload, equals('{"test": "data"}'));
      expect(job.status, equals(JobStatus.pending));
      expect(job.error, isNull);
    });

    test('should convert job to JSON', () {
      final now = DateTime.now();
      final job = Job(
        id: '1',
        queue: 'default',
        payload: '{"test": "data"}',
        createdAt: now,
      );

      final json = job.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json['id'], equals('1'));
      expect(json['queue'], equals('default'));
      expect(json['payload'], equals('{"test": "data"}'));
      expect(json['createdAt'], equals(now.toIso8601String()));
      expect(json['status'], equals('pending'));
      expect(json['error'], isNull);
    });

    test('should create job from JSON', () {
      final now = DateTime.now();
      final json = {
        'id': '1',
        'queue': 'default',
        'payload': '{"test": "data"}',
        'createdAt': now.toIso8601String(),
        'status': 'pending',
        'error': null,
      };

      final job = Job.fromJson(json);

      expect(job.id, equals('1'));
      expect(job.queue, equals('default'));
      expect(job.payload, equals('{"test": "data"}'));
      expect(job.status, equals(JobStatus.pending));
      expect(job.error, isNull);
    });

    test('should preserve error in JSON serialization', () {
      final job = Job(
        id: '1',
        queue: 'default',
        payload: '{"test": "data"}',
        createdAt: DateTime.now(),
      );
      job.status = JobStatus.failed;
      job.error = 'Test error';

      final json = job.toJson();
      final restored = Job.fromJson(json);

      expect(restored.status, equals(JobStatus.failed));
      expect(restored.error, equals('Test error'));
    });

    test('should handle all job statuses', () {
      final job = Job(
        id: '1',
        queue: 'default',
        payload: '{}',
        createdAt: DateTime.now(),
      );

      expect(job.status, equals(JobStatus.pending));

      job.status = JobStatus.processing;
      expect(job.status, equals(JobStatus.processing));

      job.status = JobStatus.completed;
      expect(job.status, equals(JobStatus.completed));

      job.status = JobStatus.failed;
      expect(job.status, equals(JobStatus.failed));
    });
  });

  group('SyncQueue', () {
    late SyncQueue queue;

    setUp(() {
      queue = SyncQueue();
    });

    test('should push job to queue', () async {
      final jobId = await queue.push('default', '{"test": "data"}');

      expect(jobId, isNotEmpty);
      expect(jobId, isA<String>());
    });

    test('should pop job from queue', () async {
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

    test('should handle clearing non-existent queue', () async {
      await queue.clear('nonexistent');
      expect(await queue.size('nonexistent'), equals(0));
    });
  });

  group('SyncQueueWorker', () {
    late SyncQueueWorker worker;

    setUp(() {
      worker = SyncQueueWorker();
    });

    test('should start worker', () async {
      await worker.start();
      // Worker should be in running state (no exception thrown)
      expect(worker, isNotNull);
    });

    test('should stop worker', () async {
      await worker.start();
      await worker.stop();
      // Worker should be stopped (no exception thrown)
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
  });

  group('QueueManager', () {
    late SyncQueue queue;
    late SyncQueueWorker worker;
    late QueueManager manager;

    setUp(() {
      queue = SyncQueue();
      worker = SyncQueueWorker();
      manager = QueueManager(queue, worker);
    });

    tearDown(() async {
      try {
        await manager.stop();
      } catch (_) {
        // Ignore if already stopped
      }
    });

    test('should create queue manager', () {
      expect(manager, isNotNull);
      expect(manager, isA<QueueManager>());
    });

    test('should push job through manager', () async {
      final jobId = await manager.push('default', '{"test": "data"}');

      expect(jobId, isNotEmpty);
      expect(await manager.size('default'), equals(1));
    });

    test('should get queue size through manager', () async {
      await manager.push('default', 'job1');
      await manager.push('default', 'job2');

      final size = await manager.size('default');

      expect(size, equals(2));
    });

    test('should provide job stream', () {
      final stream = manager.jobStream;

      expect(stream, isA<Stream<Job>>());
    });

    test('should stop manager gracefully', () async {
      await manager.stop();
      // Should not throw exception
      expect(manager, isNotNull);
    });

    test('should allow pushing jobs after creation', () async {
      await manager.push('default', 'job1');
      await manager.push('default', 'job2');
      await manager.push('default', 'job3');

      expect(await manager.size('default'), equals(3));
    });

    test('should handle multiple queues', () async {
      await manager.push('emails', 'email1');
      await manager.push('notifications', 'notif1');
      await manager.push('emails', 'email2');

      expect(await manager.size('emails'), equals(2));
      expect(await manager.size('notifications'), equals(1));
    });

    test('should work with empty queue', () async {
      expect(await manager.size('default'), equals(0));
    });
  });

  group('Integration - QueueManager + SyncQueue + SyncWorker', () {
    test('should process jobs end-to-end', () async {
      final queue = SyncQueue();
      final worker = SyncQueueWorker();
      final manager = QueueManager(queue, worker);

      // Push jobs
      await manager.push('default', 'job1');
      await manager.push('default', 'job2');

      expect(await manager.size('default'), equals(2));

      await manager.stop();
    });

    test('should handle different queue types', () async {
      final queue = SyncQueue();
      final worker = SyncQueueWorker();
      final manager = QueueManager(queue, worker);

      await manager.push('emails', 'email_job');
      await manager.push('notifications', 'notification_job');
      await manager.push('reports', 'report_job');

      expect(await manager.size('emails'), equals(1));
      expect(await manager.size('notifications'), equals(1));
      expect(await manager.size('reports'), equals(1));

      await manager.stop();
    });

    test('should maintain job integrity through system', () async {
      final queue = SyncQueue();
      final worker = SyncQueueWorker();
      final manager = QueueManager(queue, worker);

      final jobId = await manager.push('default', '{"userId": 123, "action": "send_email"}');
      expect(jobId, isNotEmpty);

      final job = await queue.pop('default');
      expect(job, isNotNull);
      expect(job!.id, equals(jobId));
      expect(job.payload, contains('userId'));
      expect(job.payload, contains('send_email'));

      await worker.process(job);
      expect(job.status, equals(JobStatus.completed));

      await manager.stop();
    });
  });

  group('Job Status Transitions', () {
    test('should transition from pending to processing', () {
      final job = Job(
        id: '1',
        queue: 'default',
        payload: '{}',
        createdAt: DateTime.now(),
      );

      expect(job.status, equals(JobStatus.pending));
      job.status = JobStatus.processing;
      expect(job.status, equals(JobStatus.processing));
    });

    test('should transition from processing to completed', () {
      final job = Job(
        id: '1',
        queue: 'default',
        payload: '{}',
        createdAt: DateTime.now(),
      );

      job.status = JobStatus.processing;
      job.status = JobStatus.completed;
      expect(job.status, equals(JobStatus.completed));
    });

    test('should transition from processing to failed with error', () {
      final job = Job(
        id: '1',
        queue: 'default',
        payload: '{}',
        createdAt: DateTime.now(),
      );

      job.status = JobStatus.processing;
      job.status = JobStatus.failed;
      job.error = 'Connection timeout';

      expect(job.status, equals(JobStatus.failed));
      expect(job.error, equals('Connection timeout'));
    });
  });

  group('Edge Cases', () {
    test('should handle empty payload', () async {
      final queue = SyncQueue();
      final jobId = await queue.push('default', '');

      expect(jobId, isNotEmpty);
      final job = await queue.pop('default');
      expect(job!.payload, isEmpty);
    });

    test('should handle large payloads', () async {
      final queue = SyncQueue();
      final largePayload = 'x' * 10000;
      final jobId = await queue.push('default', largePayload);

      expect(jobId, isNotEmpty);
      final job = await queue.pop('default');
      expect(job!.payload.length, equals(10000));
    });

    test('should handle special characters in queue name', () async {
      final queue = SyncQueue();
      await queue.push('queue-with-dashes', 'job1');
      await queue.push('queue_with_underscores', 'job2');
      await queue.push('queue.with.dots', 'job3');

      expect(await queue.size('queue-with-dashes'), equals(1));
      expect(await queue.size('queue_with_underscores'), equals(1));
      expect(await queue.size('queue.with.dots'), equals(1));
    });

    test('should handle rapid push/pop operations', () async {
      final queue = SyncQueue();

      for (int i = 0; i < 100; i++) {
        await queue.push('default', 'job_$i');
      }

      expect(await queue.size('default'), equals(100));

      for (int i = 0; i < 100; i++) {
        final job = await queue.pop('default');
        expect(job, isNotNull);
        expect(job!.payload, equals('job_$i'));
      }

      expect(await queue.size('default'), equals(0));
    });
  });
}
