import 'dart:async';
import 'dart:isolate';
import 'package:dartian_queue/dartian_queue.dart';
import 'package:dartian_queue/src/drivers/driver.dart';
import 'package:dartian_queue/src/drivers/sync_queue.dart';
import 'package:dartian_queue/src/drivers/isolate_queue.dart';
import 'package:test/test.dart';

void _testIsolateHandler(SendPort port) {
  port.send(true);
}

void main() {
  group('SyncQueue', () {
    test('executes jobs immediately', () async {
      final queue = SyncQueue();
      final completer = Completer<bool>();
      final job = TestJob(completer);
      await queue.push(job);
      expect(await completer.future, isTrue);
    });
  });

  group('IsolateQueue', () {
    test('executes jobs in an isolate', () async {
      final queue = IsolateQueue();
      final receivePort = ReceivePort();

      await queue.push(IsolateJob(_testIsolateHandler, receivePort.sendPort));

      final result = await receivePort.first;
      expect(result, isTrue);

      queue.dispose();
    });
  });

  group('Worker', () {
    test('processes jobs from a queue', () async {
      final queue = TestQueue();
      final worker = Worker(queue);
      final completer = Completer<bool>();
      final job = TestJob(completer);
      await queue.push(job);

      final workerFuture = worker.run();
      await completer.future;
      worker.stop();
      await workerFuture;

      expect(queue.acked, isTrue);
    });
  });
}

class TestJob implements Job {
  final Completer<bool> completer;
  @override
  SendPort? sendPort;

  TestJob(this.completer);

  @override
  Future<void> handle() async {
    completer.complete(true);
  }
}

class TestQueue implements QueueDriver {
  Job? _job;
  bool acked = false;

  @override
  Future<void> push(Job job) async {
    _job = job;
  }

  @override
  Future<Job?> pop(String queue) async {
    final job = _job;
    _job = null;
    return job;
  }

  Future<void> ack(Job job) async {
    acked = true;
  }

  Future<void> fail(Job job) async {}
}
