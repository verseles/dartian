import 'package:test/test.dart';
import 'package:dartian_queue/dartian_queue.dart';

void main() {
  group('IsolateQueue', () {
    late IsolateQueue queue;

    setUp(() {
      queue = IsolateQueue();
    });

    test('should create IsolateQueue', () {
      expect(queue, isNotNull);
      expect(queue, isA<Queue>());
    });

    test('should push job to isolate queue', () async {
      final jobId = await queue.push('default', '{"test": "data"}');

      expect(jobId, isNotEmpty);
      expect(jobId, isA<String>());
    });

    test('should pop job from isolate queue', () async {
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
  });

  group('IsolateQueueWorker', () {
    test('should create IsolateQueueWorker with SendPort', () async {
      final worker = await spawnIsolateWorker();

      expect(worker, isNotNull);
      expect(worker, isA<QueueWorker>());

      await worker.stop();
    });

    test('should start and stop worker', () async {
      final worker = await spawnIsolateWorker();

      await worker.start();
      await worker.stop();

      // Should not throw
      expect(worker, isNotNull);
    });

    test('should process job in isolate', () async {
      final worker = await spawnIsolateWorker();
      await worker.start();

      final job = Job(
        id: '1',
        queue: 'default',
        payload: '{"test": "data"}',
        createdAt: DateTime.now(),
      );

      await worker.process(job);

      expect(job.status, equals(JobStatus.completed));

      await worker.stop();
    });

    test('should handle multiple jobs', () async {
      final worker = await spawnIsolateWorker();
      await worker.start();

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

      await worker.process(job1);
      await worker.process(job2);

      expect(job1.status, equals(JobStatus.completed));
      expect(job2.status, equals(JobStatus.completed));

      await worker.stop();
    });

    test('should not start worker twice', () async {
      final worker = await spawnIsolateWorker();

      await worker.start();
      await worker.start(); // Should be idempotent

      expect(worker, isNotNull);

      await worker.stop();
    });
  });

  group('Integration - IsolateQueue + IsolateQueueWorker', () {
    test('should process jobs end-to-end with isolates', () async {
      final queue = IsolateQueue();
      final worker = await spawnIsolateWorker();
      final manager = QueueManager(queue, worker);

      await manager.push('default', 'job1');
      await manager.push('default', 'job2');

      expect(await manager.size('default'), equals(2));

      await manager.stop();
    });

    test('should handle job processing with isolate worker', () async {
      final queue = IsolateQueue();
      final worker = await spawnIsolateWorker();

      final jobId = await queue.push('default', '{"action": "send_email"}');
      expect(jobId, isNotEmpty);

      final job = await queue.pop('default');
      expect(job, isNotNull);

      await worker.start();
      await worker.process(job!);

      expect(job.status, equals(JobStatus.completed));

      await worker.stop();
    });

    test('should handle concurrent job processing', () async {
      final queue = IsolateQueue();
      final worker = await spawnIsolateWorker();
      await worker.start();

      // Create multiple jobs
      final jobs = List.generate(
        5,
        (i) => Job(
          id: i.toString(),
          queue: 'default',
          payload: 'job_$i',
          createdAt: DateTime.now(),
        ),
      );

      // Process all jobs
      await Future.wait(jobs.map((job) => worker.process(job)));

      // All should be completed
      for (final job in jobs) {
        expect(job.status, equals(JobStatus.completed));
      }

      await worker.stop();
    });
  });
}
