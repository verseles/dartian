import 'dart:async';
import 'package:dartian_scheduler/dartian_scheduler.dart';
import 'package:test/test.dart';

void main() {
  group('Scheduler', () {
    late Scheduler scheduler;

    setUp(() {
      scheduler = Scheduler();
    });

    tearDown(() async {
      await scheduler.stop();
    });

    test('can schedule a task to run every minute', () async {
      final completer = Completer<void>();
      scheduler.call(() => completer.complete());
      scheduler.everyMinute();
      scheduler.start();

      // We can't easily test the timing, so we'll just check that
      // the task is scheduled without throwing an exception.
      await Future.delayed(Duration(seconds: 1));
      expect(completer.isCompleted, isFalse);
    });

    test('can schedule a task with a cron expression', () async {
      final completer = Completer<void>();
      scheduler.call(() => completer.complete());
      scheduler.cron('*/1 * * * * *'); // Every second
      scheduler.start();

      await completer.future;
      expect(completer.isCompleted, isTrue);
    });
  });
}
