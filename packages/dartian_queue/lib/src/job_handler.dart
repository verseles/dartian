import 'dart:async';
import 'queue.dart';

/// Abstract job handler interface
abstract class JobHandler {
  /// Handle the job execution
  Future<void> handle(Job job);

  /// Handle failed job
  Future<void> failed(Job job, dynamic error, StackTrace stackTrace) async {
    job.status = JobStatus.failed;
    job.error = error.toString();
  }

  /// Maximum number of retry attempts (default: 3)
  int get maxRetries => 3;

  /// Backoff delay calculation (exponential backoff)
  Duration backoffDelay(int attempt) {
    // Exponential backoff: 2^attempt seconds
    final seconds = (1 << attempt).clamp(1, 60);
    return Duration(seconds: seconds);
  }
}

/// Job processor with retry logic
class JobProcessor {
  final JobHandler handler;
  final int maxRetries;

  JobProcessor(this.handler, {int? maxRetries})
      : maxRetries = maxRetries ?? handler.maxRetries;

  /// Process a job with retry logic
  Future<void> processWithRetry(Job job) async {
    int attempt = 0;

    while (attempt <= maxRetries) {
      try {
        job.status = JobStatus.processing;
        await handler.handle(job);
        job.status = JobStatus.completed;
        return;
      } catch (error, stackTrace) {
        attempt++;

        if (attempt > maxRetries) {
          // Max retries reached, mark as failed
          await handler.failed(job, error, stackTrace);
          return;
        }

        // Wait before retrying (exponential backoff)
        final delay = handler.backoffDelay(attempt);
        await Future.delayed(delay);
      }
    }
  }
}
