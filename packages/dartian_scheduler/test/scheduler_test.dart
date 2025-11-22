import 'dart:async';

import 'package:dartian_scheduler/dartian_scheduler.dart';
import 'package:test/test.dart';

void main() {
  group('SimpleScheduler', () {
    late SimpleScheduler scheduler;

    setUp(() {
      scheduler = SimpleScheduler();
    });

    tearDown(() async {
      await scheduler.close();
    });

    test('should create scheduler instance', () {
      expect(scheduler, isNotNull);
      expect(scheduler.manager, isNotNull);
    });

    group('scheduleInterval', () {
      test('should schedule interval task', () async {
        int callCount = 0;

        await scheduler.start();
        final taskId = await scheduler.scheduleInterval(
          'test-task',
          const Duration(milliseconds: 50),
          () => callCount++,
        );

        expect(taskId, isNotEmpty);

        final task = scheduler.getTask(taskId);
        expect(task, isNotNull);
        expect(task!.name, equals('test-task'));
        expect(task.status, equals(TaskStatus.scheduled));

        // Wait for task to run a few times
        await Future.delayed(const Duration(milliseconds: 200));

        expect(callCount, greaterThan(0));
      });

      test('should add task to task list', () async {
        await scheduler.start();
        final taskId = await scheduler.scheduleInterval(
          'test-task',
          const Duration(seconds: 1),
          () {},
        );

        final tasks = scheduler.getTasks();
        expect(tasks.length, equals(1));
        expect(tasks[0].id, equals(taskId));
      });

      test('should not run task if scheduler not started', () async {
        int callCount = 0;

        await scheduler.scheduleInterval(
          'test-task',
          const Duration(milliseconds: 50),
          () => callCount++,
        );

        await Future.delayed(const Duration(milliseconds: 200));

        expect(callCount, equals(0));
      });

      test('should handle task errors', () async {
        await scheduler.start();
        final taskId = await scheduler.scheduleInterval(
          'failing-task',
          const Duration(milliseconds: 50),
          () => throw Exception('Task failed'),
        );

        await Future.delayed(const Duration(milliseconds: 100));

        final task = scheduler.getTask(taskId);
        expect(task!.status, equals(TaskStatus.failed));
        expect(task.error, contains('Task failed'));
      });

      test('should update task status when running', () async {
        bool isRunning = false;

        await scheduler.start();
        await scheduler.scheduleInterval(
          'test-task',
          const Duration(milliseconds: 100),
          () {
            isRunning = true;
          },
        );

        // Wait for first execution
        await Future.delayed(const Duration(milliseconds: 150));

        expect(isRunning, isTrue);
      });
    });

    group('scheduleOnce', () {
      test('should schedule one-time task', () async {
        int callCount = 0;

        await scheduler.start();
        final taskId = await scheduler.scheduleOnce(
          'once-task',
          const Duration(milliseconds: 50),
          () => callCount++,
        );

        expect(taskId, isNotEmpty);

        // Wait for task to execute
        await Future.delayed(const Duration(milliseconds: 100));

        expect(callCount, equals(1));

        // Wait more to ensure it doesn't run again
        await Future.delayed(const Duration(milliseconds: 100));
        expect(callCount, equals(1));
      });

      test('should mark task as completed after execution', () async {
        await scheduler.start();
        final taskId = await scheduler.scheduleOnce(
          'once-task',
          const Duration(milliseconds: 50),
          () {},
        );

        await Future.delayed(const Duration(milliseconds: 100));

        final task = scheduler.getTask(taskId);
        expect(task!.status, equals(TaskStatus.completed));
      });

      test('should handle errors in one-time task', () async {
        await scheduler.start();
        final taskId = await scheduler.scheduleOnce(
          'failing-once-task',
          const Duration(milliseconds: 50),
          () => throw Exception('Once task failed'),
        );

        await Future.delayed(const Duration(milliseconds: 100));

        final task = scheduler.getTask(taskId);
        expect(task!.status, equals(TaskStatus.failed));
        expect(task.error, contains('Once task failed'));
      });
    });

    group('unschedule', () {
      test('should unschedule a task', () async {
        await scheduler.start();
        final taskId = await scheduler.scheduleInterval(
          'test-task',
          const Duration(seconds: 1),
          () {},
        );

        expect(scheduler.getTask(taskId), isNotNull);

        await scheduler.unschedule(taskId);

        expect(scheduler.getTask(taskId), isNull);
        expect(scheduler.getTasks().length, equals(0));
      });

      test('should mark unscheduled task as cancelled', () async {
        await scheduler.start();
        final taskId = await scheduler.scheduleInterval(
          'test-task',
          const Duration(seconds: 1),
          () {},
        );

        final task = scheduler.getTask(taskId);
        await scheduler.unschedule(taskId);

        expect(task!.status, equals(TaskStatus.cancelled));
      });

      test('should handle unscheduling non-existent task', () async {
        await expectLater(scheduler.unschedule('non-existent'), completes);
      });

      test('should stop task execution after unscheduling', () async {
        int callCount = 0;

        await scheduler.start();
        final taskId = await scheduler.scheduleInterval(
          'test-task',
          const Duration(milliseconds: 50),
          () => callCount++,
        );

        await Future.delayed(const Duration(milliseconds: 100));
        final countBeforeUnschedule = callCount;

        await scheduler.unschedule(taskId);
        await Future.delayed(const Duration(milliseconds: 100));

        // Task should not run after being unscheduled
        expect(callCount, equals(countBeforeUnschedule));
      });
    });

    group('getTasks', () {
      test('should return all tasks', () async {
        await scheduler.start();
        await scheduler.scheduleInterval(
          'task1',
          const Duration(seconds: 1),
          () {},
        );
        await Future.delayed(const Duration(milliseconds: 10));
        await scheduler.scheduleInterval(
          'task2',
          const Duration(seconds: 1),
          () {},
        );
        await Future.delayed(const Duration(milliseconds: 10));
        await scheduler.scheduleOnce(
          'task3',
          const Duration(seconds: 1),
          () {},
        );

        final tasks = scheduler.getTasks();
        expect(tasks.length, equals(3));
      });

      test('should return empty list when no tasks', () {
        final tasks = scheduler.getTasks();
        expect(tasks, isEmpty);
      });
    });

    group('getTasksByStatus', () {
      test('should return tasks by status', () async {
        await scheduler.scheduleInterval(
          'task1',
          const Duration(seconds: 10),
          () {},
        );
        // Small delay to ensure tasks have different IDs
        await Future.delayed(const Duration(milliseconds: 10));
        await scheduler.scheduleInterval(
          'task2',
          const Duration(seconds: 10),
          () {},
        );

        final scheduledTasks = scheduler.getTasksByStatus(TaskStatus.scheduled);
        expect(scheduledTasks.length, equals(2));
      });

      test('should return empty list when no tasks with status', () {
        final runningTasks = scheduler.getTasksByStatus(TaskStatus.running);
        expect(runningTasks, isEmpty);
      });

      test('should filter failed tasks', () async {
        await scheduler.start();

        bool exceptionThrown = false;
        final failingTaskId = await scheduler.scheduleOnce(
          'failing-task',
          const Duration(milliseconds: 50),
          () {
            exceptionThrown = true;
            throw Exception('Failed');
          },
        );

        // Wait for task to execute and fail
        await Future.delayed(const Duration(milliseconds: 200));

        // Verify the exception was thrown
        expect(exceptionThrown, isTrue);

        // Verify the failing task exists and has failed status
        final failingTask = scheduler.getTask(failingTaskId);
        expect(failingTask, isNotNull);
        expect(failingTask!.status, equals(TaskStatus.failed));

        final failedTasks = scheduler.getTasksByStatus(TaskStatus.failed);
        expect(failedTasks.length, greaterThanOrEqualTo(1));
        expect(failedTasks.any((t) => t.name == 'failing-task'), isTrue);
      });
    });

    group('start and stop', () {
      test('should start scheduler', () async {
        await scheduler.start();
        // Scheduler should be running (no direct way to check, but test via task execution)
        int callCount = 0;

        await scheduler.scheduleInterval(
          'test',
          const Duration(milliseconds: 50),
          () => callCount++,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        expect(callCount, greaterThan(0));
      });

      test('should stop scheduler', () async {
        int callCount = 0;

        await scheduler.start();
        await scheduler.scheduleInterval(
          'test',
          const Duration(milliseconds: 50),
          () => callCount++,
        );

        await Future.delayed(const Duration(milliseconds: 100));
        final countBeforeStop = callCount;

        await scheduler.stop();
        await Future.delayed(const Duration(milliseconds: 100));

        // Task should not run after scheduler stopped
        expect(callCount, equals(countBeforeStop));
      });
    });

    group('close', () {
      test('should close and cleanup all resources', () async {
        await scheduler.start();
        await scheduler.scheduleInterval(
          'task1',
          const Duration(seconds: 1),
          () {},
        );
        await scheduler.scheduleInterval(
          'task2',
          const Duration(seconds: 1),
          () {},
        );

        await scheduler.close();

        expect(scheduler.getTasks(), isEmpty);
      });

      test('should stop all tasks when closing', () async {
        int callCount = 0;

        await scheduler.start();
        await scheduler.scheduleInterval(
          'test',
          const Duration(milliseconds: 50),
          () => callCount++,
        );

        await Future.delayed(const Duration(milliseconds: 100));
        await scheduler.close();

        final countBeforeClose = callCount;
        await Future.delayed(const Duration(milliseconds: 100));

        expect(callCount, equals(countBeforeClose));
      });
    });
  });

  group('CronScheduler alias', () {
    test('should be an alias for SimpleScheduler', () {
      final scheduler = CronScheduler();
      expect(scheduler, isA<SimpleScheduler>());
    });
  });
}
