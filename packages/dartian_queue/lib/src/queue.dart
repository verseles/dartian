/// Job status
enum JobStatus { pending, processing, completed, failed }

/// A job to be processed by a queue
class Job {
  final String id;
  final String queue;
  final String payload;
  final DateTime createdAt;
  JobStatus status;
  String? error;

  Job({
    required this.id,
    required this.queue,
    required this.payload,
    required this.createdAt,
  }) : status = JobStatus.pending,
       error = null;

  /// Convert job to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'queue': queue,
    'payload': payload,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
    'error': error,
  };

  /// Create job from JSON
  factory Job.fromJson(Map<String, dynamic> json) => Job(
    id: json['id'] as String,
    queue: json['queue'] as String,
    payload: json['payload'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  )..status = JobStatus.values.byName(json['status'] as String)
   ..error = json['error'] as String?;
}

/// Queue interface
abstract class Queue {
  /// Push a job to the queue
  Future<String> push(String queue, String payload);

  /// Pop a job from the queue
  Future<Job?> pop(String queue);

  /// Get the number of pending jobs in a queue
  Future<int> size(String queue);

  /// Clear all jobs from a queue
  Future<void> clear(String queue);
}
