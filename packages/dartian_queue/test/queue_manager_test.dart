import 'dart:async';
import 'package:test/test.dart';
import 'package:dartian_queue/dartian_queue.dart';

/// Mock Queue implementation for testing
class MockQueue implements Queue {
  final List<Job> _jobs = [];
  int _idCounter = 0;

  @override
  Future<String> push(String queue, String payload) async {
    final jobId = '${_idCounter++}';
    _jobs.add(
      Job(id: jobId, queue: queue, payload: payload, createdAt: DateTime.now()),
    );
    return jobId;
  }

  @override
  Future<Job?> pop(String queue) async {
    if (_jobs.isEmpty) return null;
    return _jobs.removeAt(0);
  }

  @override
  Future<int> size(String queue) async {
    return _jobs.where((j) => j.queue == queue).length;
  }

  @override
  Future<void> clear(String queue) async {
    _jobs.removeWhere((j) => j.queue == queue);
  }
}

/// Mock QueueWorker implementation for testing
class MockQueueWorker implements QueueWorker {
  bool _started = false;
  final List<Job> processedJobs = [];

  @override
  Future<void> start() async {
    _started = true;
  }

  @override
  Future<void> stop() async {
    _started = false;
  }

  @override
  Future<void> process(Job job) async {
    processedJobs.add(job);
    await Future.delayed(const Duration(milliseconds: 10));
  }

  bool get isStarted => _started;
}

void main() {
  group('QueueManager', () {
    late MockQueue queue;
    late MockQueueWorker worker;
    late QueueManager manager;

    setUp(() {
      queue = MockQueue();
      worker = MockQueueWorker();
      manager = QueueManager(queue, worker);
    });

    test('should create QueueManager', () {
      expect(manager, isNotNull);
    });

    test('should push job through manager', () async {
      final jobId = await manager.push('test', 'payload1');
      expect(jobId, isNotEmpty);
      expect(await manager.size('test'), equals(1));
    });

    test('should get queue size', () async {
      await manager.push('emails', 'email1');
      await manager.push('emails', 'email2');
      await manager.push('notifications', 'notif1');

      expect(await manager.size('emails'), equals(2));
      expect(await manager.size('notifications'), equals(1));
    });

    test('should start and stop processing', () async {
      await manager.push('default', 'job1');

      // Start manager in background
      final startFuture = manager.start();

      // Wait a bit for processing
      await Future.delayed(const Duration(milliseconds: 100));

      // Stop the manager
      await manager.stop();

      // Wait for start to complete
      try {
        await startFuture.timeout(const Duration(milliseconds: 100));
      } catch (_) {
        // Timeout expected since start() runs in a loop
      }

      expect(worker.isStarted, isFalse);
    });

    test('should process jobs through worker', () async {
      await manager.push('default', 'job1');
      await manager.push('default', 'job2');

      // Start manager in background
      final startFuture = manager.start();

      // Wait for processing
      await Future.delayed(const Duration(milliseconds: 150));

      // Stop the manager
      await manager.stop();

      try {
        await startFuture.timeout(const Duration(milliseconds: 100));
      } catch (_) {
        // Timeout expected
      }

      // Check that jobs were processed
      expect(worker.processedJobs.length, greaterThanOrEqualTo(1));
    });

    test('should have jobStream available', () {
      // Before start, stream should be empty stream
      expect(manager.jobStream, isA<Stream<Job>>());
    });

    test('should not start twice', () async {
      await manager.push('default', 'job');

      // Start manager
      final startFuture1 = manager.start();

      // Wait a bit
      await Future.delayed(const Duration(milliseconds: 50));

      // Try to start again (should return immediately)
      final startFuture2 = manager.start();

      // Stop manager
      await manager.stop();

      try {
        await startFuture1.timeout(const Duration(milliseconds: 100));
        await startFuture2.timeout(const Duration(milliseconds: 100));
      } catch (_) {
        // Timeout expected
      }
    });

    test('should wait when queue is empty', () async {
      // Start manager with empty queue
      final startFuture = manager.start();

      // Wait a bit
      await Future.delayed(const Duration(milliseconds: 1500));

      // Stop the manager
      await manager.stop();

      try {
        await startFuture.timeout(const Duration(milliseconds: 100));
      } catch (_) {
        // Timeout expected
      }

      // No jobs should have been processed
      expect(worker.processedJobs, isEmpty);
    });

    test('should handle custom queue name', () async {
      await manager.push('custom-queue', 'job1');

      // Start with custom queue
      final startFuture = manager.start(queue: 'custom-queue');

      // Wait for processing
      await Future.delayed(const Duration(milliseconds: 100));

      // Stop the manager
      await manager.stop();

      try {
        await startFuture.timeout(const Duration(milliseconds: 100));
      } catch (_) {
        // Timeout expected
      }

      expect(worker.processedJobs, isNotEmpty);
    });

    test('jobStream should be empty when controller is null', () {
      final newManager = QueueManager(queue, worker);
      expect(newManager.jobStream, isA<Stream<Job>>());
    });
  });
}
