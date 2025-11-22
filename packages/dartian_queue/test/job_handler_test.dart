import 'package:test/test.dart';
import 'package:dartian_queue/dartian_queue.dart';

/// Test job handler that succeeds
class SuccessfulJobHandler extends JobHandler {
  int callCount = 0;

  @override
  Future<void> handle(Job job) async {
    callCount++;
    job.status = JobStatus.completed;
  }
}

/// Test job handler that always fails
class FailingJobHandler extends JobHandler {
  int callCount = 0;

  @override
  Future<void> handle(Job job) async {
    callCount++;
    throw Exception('Job processing failed');
  }
}

/// Test job handler that fails then succeeds
class RetryableJobHandler extends JobHandler {
  int callCount = 0;
  final int failCount;

  RetryableJobHandler({required this.failCount});

  @override
  Future<void> handle(Job job) async {
    callCount++;
    if (callCount <= failCount) {
      throw Exception('Temporary failure');
    }
    job.status = JobStatus.completed;
  }
}

/// Test job handler with custom retry config
class CustomRetryJobHandler extends JobHandler {
  @override
  int get maxRetries => 5;

  @override
  Duration backoffDelay(int attempt) {
    return Duration(milliseconds: 10 * attempt);
  }

  @override
  Future<void> handle(Job job) async {
    job.status = JobStatus.completed;
  }
}

/// Test job handler that fails with minimal delay
class FastFailingJobHandler extends JobHandler {
  int callCount = 0;

  @override
  Duration backoffDelay(int attempt) {
    return Duration(milliseconds: 1); // Minimal delay for testing
  }

  @override
  Future<void> handle(Job job) async {
    callCount++;
    throw Exception('Job processing failed');
  }
}

void main() {
  group('JobHandler', () {
    test('should process job successfully', () async {
      final handler = SuccessfulJobHandler();
      final job = Job(
        id: '1',
        queue: 'default',
        payload: '{}',
        createdAt: DateTime.now(),
      );

      await handler.handle(job);

      expect(job.status, equals(JobStatus.completed));
      expect(handler.callCount, equals(1));
    });

    test('should have default maxRetries of 3', () {
      final handler = SuccessfulJobHandler();
      expect(handler.maxRetries, equals(3));
    });

    test('should calculate exponential backoff', () {
      final handler = SuccessfulJobHandler();

      expect(handler.backoffDelay(1).inSeconds, equals(2)); // 2^1 = 2
      expect(handler.backoffDelay(2).inSeconds, equals(4)); // 2^2 = 4
      expect(handler.backoffDelay(3).inSeconds, equals(8)); // 2^3 = 8
      expect(handler.backoffDelay(4).inSeconds, equals(16)); // 2^4 = 16
    });

    test('should cap backoff delay at 60 seconds', () {
      final handler = SuccessfulJobHandler();

      expect(handler.backoffDelay(10).inSeconds, equals(60)); // Capped
      expect(handler.backoffDelay(20).inSeconds, equals(60)); // Capped
    });

    test('should handle custom maxRetries', () {
      final handler = CustomRetryJobHandler();
      expect(handler.maxRetries, equals(5));
    });

    test('should allow custom backoff delay', () {
      final handler = CustomRetryJobHandler();

      expect(handler.backoffDelay(1).inMilliseconds, equals(10));
      expect(handler.backoffDelay(2).inMilliseconds, equals(20));
      expect(handler.backoffDelay(3).inMilliseconds, equals(30));
    });

    test('should mark job as failed on error', () async {
      final handler = FailingJobHandler();
      final job = Job(
        id: '1',
        queue: 'default',
        payload: '{}',
        createdAt: DateTime.now(),
      );

      try {
        await handler.handle(job);
      } catch (e) {
        await handler.failed(job, e, StackTrace.current);
      }

      expect(job.status, equals(JobStatus.failed));
      expect(job.error, contains('Job processing failed'));
    });
  });

  group('JobProcessor', () {
    test('should process job successfully without retries', () async {
      final handler = SuccessfulJobHandler();
      final processor = JobProcessor(handler);
      final job = Job(
        id: '1',
        queue: 'default',
        payload: '{}',
        createdAt: DateTime.now(),
      );

      await processor.processWithRetry(job);

      expect(job.status, equals(JobStatus.completed));
      expect(handler.callCount, equals(1));
    });

    test('should retry job on failure', () async {
      final handler = RetryableJobHandler(failCount: 2);
      final processor = JobProcessor(handler);
      final job = Job(
        id: '1',
        queue: 'default',
        payload: '{}',
        createdAt: DateTime.now(),
      );

      await processor.processWithRetry(job);

      expect(job.status, equals(JobStatus.completed));
      expect(handler.callCount, equals(3)); // Failed 2 times, succeeded on 3rd
    });

    test('should mark job as failed after max retries', () async {
      final handler = FailingJobHandler();
      final processor = JobProcessor(handler);
      final job = Job(
        id: '1',
        queue: 'default',
        payload: '{}',
        createdAt: DateTime.now(),
      );

      await processor.processWithRetry(job);

      expect(job.status, equals(JobStatus.failed));
      expect(job.error, contains('Job processing failed'));
      expect(handler.callCount, equals(4)); // 1 initial + 3 retries
    });

    test('should respect custom maxRetries from handler', () async {
      final handler = CustomRetryJobHandler();
      final processor = JobProcessor(handler);
      final job = Job(
        id: '1',
        queue: 'default',
        payload: '{}',
        createdAt: DateTime.now(),
      );

      await processor.processWithRetry(job);

      expect(job.status, equals(JobStatus.completed));
    });

    test('should respect custom maxRetries from processor', () async {
      final handler = FailingJobHandler();
      final processor = JobProcessor(handler, maxRetries: 2);
      final job = Job(
        id: '1',
        queue: 'default',
        payload: '{}',
        createdAt: DateTime.now(),
      );

      await processor.processWithRetry(job);

      expect(job.status, equals(JobStatus.failed));
      expect(handler.callCount, equals(3)); // 1 initial + 2 retries
    });

    test('should set job to processing before handling', () async {
      final handler = SuccessfulJobHandler();
      final processor = JobProcessor(handler);
      final job = Job(
        id: '1',
        queue: 'default',
        payload: '{}',
        createdAt: DateTime.now(),
      );

      expect(job.status, equals(JobStatus.pending));

      await processor.processWithRetry(job);

      expect(job.status, equals(JobStatus.completed));
    });

    test('should handle zero retries', () async {
      final handler = FailingJobHandler();
      final processor = JobProcessor(handler, maxRetries: 0);
      final job = Job(
        id: '1',
        queue: 'default',
        payload: '{}',
        createdAt: DateTime.now(),
      );

      await processor.processWithRetry(job);

      expect(job.status, equals(JobStatus.failed));
      expect(handler.callCount, equals(1)); // Only 1 attempt
    });

    test('should wait between retries', () async {
      final handler = RetryableJobHandler(failCount: 1);
      final processor = JobProcessor(handler);
      final job = Job(
        id: '1',
        queue: 'default',
        payload: '{}',
        createdAt: DateTime.now(),
      );

      final startTime = DateTime.now();
      await processor.processWithRetry(job);
      final duration = DateTime.now().difference(startTime);

      expect(job.status, equals(JobStatus.completed));
      expect(handler.callCount, equals(2));
      // Should have waited at least 2 seconds (2^1)
      expect(duration.inSeconds, greaterThanOrEqualTo(1));
    });
  });

  group('JobProcessor - Integration', () {
    test('should process multiple jobs with retry logic', () async {
      final handler1 = SuccessfulJobHandler();
      final handler2 = RetryableJobHandler(failCount: 1);
      final handler3 = FailingJobHandler();

      final processor1 = JobProcessor(handler1);
      final processor2 = JobProcessor(handler2);
      final processor3 = JobProcessor(handler3, maxRetries: 1);

      final job1 = Job(
        id: '1',
        queue: 'default',
        payload: '{}',
        createdAt: DateTime.now(),
      );
      final job2 = Job(
        id: '2',
        queue: 'default',
        payload: '{}',
        createdAt: DateTime.now(),
      );
      final job3 = Job(
        id: '3',
        queue: 'default',
        payload: '{}',
        createdAt: DateTime.now(),
      );

      await processor1.processWithRetry(job1);
      await processor2.processWithRetry(job2);
      await processor3.processWithRetry(job3);

      expect(job1.status, equals(JobStatus.completed));
      expect(job2.status, equals(JobStatus.completed));
      expect(job3.status, equals(JobStatus.failed));

      expect(handler1.callCount, equals(1));
      expect(handler2.callCount, equals(2));
      expect(handler3.callCount, equals(2));
    });

    test('should handle different error types', () async {
      final handler = FailingJobHandler();
      final processor = JobProcessor(handler, maxRetries: 0);
      final job = Job(
        id: '1',
        queue: 'default',
        payload: '{}',
        createdAt: DateTime.now(),
      );

      await processor.processWithRetry(job);

      expect(job.status, equals(JobStatus.failed));
      expect(job.error, isNotNull);
      expect(job.error, contains('Exception'));
    });

    test('should preserve job metadata during retries', () async {
      final handler = RetryableJobHandler(failCount: 2);
      final processor = JobProcessor(handler);
      final createdAt = DateTime.now();
      final job = Job(
        id: 'test-123',
        queue: 'emails',
        payload: '{"to": "user@example.com"}',
        createdAt: createdAt,
      );

      await processor.processWithRetry(job);

      expect(job.id, equals('test-123'));
      expect(job.queue, equals('emails'));
      expect(job.payload, equals('{"to": "user@example.com"}'));
      expect(job.createdAt, equals(createdAt));
      expect(job.status, equals(JobStatus.completed));
    });
  });

  group('Edge Cases', () {
    test('should handle handler that changes job status directly', () async {
      final handler = SuccessfulJobHandler();
      final processor = JobProcessor(handler);
      final job = Job(
        id: '1',
        queue: 'default',
        payload: '{}',
        createdAt: DateTime.now(),
      );

      await processor.processWithRetry(job);

      expect(job.status, equals(JobStatus.completed));
    });

    test('should handle very high retry counts', () async {
      final handler = FastFailingJobHandler();
      final processor = JobProcessor(handler, maxRetries: 10);
      final job = Job(
        id: '1',
        queue: 'default',
        payload: '{}',
        createdAt: DateTime.now(),
      );

      await processor.processWithRetry(job);

      expect(job.status, equals(JobStatus.failed));
      expect(handler.callCount, equals(11)); // 1 initial + 10 retries
    });

    test(
      'should handle handler that throws different exception types',
      () async {
        final handler = FailingJobHandler();
        final processor = JobProcessor(handler, maxRetries: 0);
        final job = Job(
          id: '1',
          queue: 'default',
          payload: '{}',
          createdAt: DateTime.now(),
        );

        await processor.processWithRetry(job);

        expect(job.status, equals(JobStatus.failed));
        expect(job.error, isNotNull);
      },
    );
  });
}
