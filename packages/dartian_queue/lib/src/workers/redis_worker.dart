import 'dart:async';
import 'dart:convert';
import '../queue.dart';
import '../queue_manager.dart';
import 'package:dartian_redis/dartian_redis.dart';

/// Redis-based queue implementation
class RedisQueue implements Queue {
  final IRedisClient _redis;
  final String _prefix;
  static int _jobCounter = 0;

  RedisQueue(this._redis, {String prefix = 'queue:'}) : _prefix = prefix;

  String _getQueueKey(String queue) => '$_prefix$queue';
  String _getJobKey(String jobId) => '${_prefix}job:$jobId';

  @override
  Future<String> push(String queue, String payload) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final counter = _jobCounter++;
    final jobId = '${timestamp}_$counter';
    final job = Job(
      id: jobId,
      queue: queue,
      payload: payload,
      createdAt: DateTime.now(),
    );

    // Store job
    await _redis.set(_getJobKey(jobId), jsonEncode(job.toJson()));

    // Add to queue
    await _redis.client.send_object(['LPUSH', _getQueueKey(queue), jobId]);

    return jobId;
  }

  @override
  Future<Job?> pop(String queue) async {
    // Pop job ID from queue
    final jobId = await _redis.client.send_object([
      'RPOP',
      _getQueueKey(queue),
    ]);

    if (jobId == null) return null;

    // Get job data
    final jobData = await _redis.get(_getJobKey(jobId as String));
    if (jobData == null) return null;

    return Job.fromJson(jsonDecode(jobData));
  }

  @override
  Future<int> size(String queue) async {
    final result = await _redis.client.send_object([
      'LLEN',
      _getQueueKey(queue),
    ]);
    return result as int;
  }

  @override
  Future<void> clear(String queue) async {
    await _redis.client.send_object(['DEL', _getQueueKey(queue)]);
  }
}

/// Redis queue worker
class RedisQueueWorker implements QueueWorker {
  final IRedisClient _redis;

  RedisQueueWorker(this._redis);

  @override
  Future<void> start() async {
    // Redis worker started
  }

  @override
  Future<void> stop() async {
    // Redis worker stopped
  }

  @override
  Future<void> process(Job job) async {
    // Process job with Redis backend
    job.status = JobStatus.completed;

    // Update job in Redis
    await _redis.set(_getJobKey(job.id), jsonEncode(job.toJson()));
  }

  String _getJobKey(String jobId) => 'queue:job:$jobId';
}
