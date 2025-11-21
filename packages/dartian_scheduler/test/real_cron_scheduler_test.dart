import 'dart:async';

import 'package:dartian_scheduler/src/cron_scheduler.dart';
import 'package:dartian_scheduler/src/task.dart';
import 'package:test/test.dart';

void main() {
  group('RealCronScheduler', () {
    late RealCronScheduler scheduler;

    setUp(() {
      scheduler = RealCronScheduler();
    });

    tearDown(() async {
      await scheduler.close();
    });

    test('should create scheduler instance', () {
      expect(scheduler, isNotNull);
      expect(scheduler.manager, isNotNull);
    });

    group('schedule', () {
      test('should schedule task with cron expression', () async {
        final taskId = await scheduler.schedule(
          'test-task',
          '* * * * *',
          () {},
        );

        expect(taskId, isNotEmpty);

        final task = scheduler.getTask(taskId);
        expect(task, isNotNull);
        expect(task!.name, equals('test-task'));
        expect(task.cronExpression, equals('* * * * *'));
        expect(task.status, equals(TaskStatus.scheduled));
        expect(task.nextRun, isNotNull);
      });

      test('should throw on invalid cron expression', () {
        expect(
          () => scheduler.schedule('invalid-task', 'invalid', () {}),
          throwsArgumentError,
        );
      });

      test('should calculate next run time', () async {
        final taskId = await scheduler.schedule(
          'test-task',
          '0 9 * * *', // Daily at 9 AM
          () {},
        );

        final task = scheduler.getTask(taskId);
        expect(task, isNotNull);
        expect(task!.nextRun, isNotNull);
        expect(task.nextRun!.hour, equals(9));
        expect(task.nextRun!.minute, equals(0));
      });
    });

    group('convenience methods', () {
      test('everyMinutes should schedule task every N minutes', () async {
        final taskId = await scheduler.everyMinutes('test', 5, () {});

        final task = scheduler.getTask(taskId);
        expect(task, isNotNull);
        expect(task!.cronExpression, equals('*/5 * * * *'));
      });

      test('hourly should schedule task every hour', () async {
        final taskId = await scheduler.hourly('test', () {});

        final task = scheduler.getTask(taskId);
        expect(task, isNotNull);
        expect(task!.cronExpression, equals('0 * * * *'));
      });

      test('daily should schedule task daily at specific time', () async {
        final taskId = await scheduler.daily('test', 9, 30, () {});

        final task = scheduler.getTask(taskId);
        expect(task, isNotNull);
        expect(task!.cronExpression, equals('30 9 * * *'));
      });

      test('weekly should schedule task on specific days', () async {
        final taskId = await scheduler.weekly('test', [1, 3, 5], 14, 0, () {});

        final task = scheduler.getTask(taskId);
        expect(task, isNotNull);
        expect(task!.cronExpression, equals('0 14 * * 1,3,5'));
      });

      test('monthly should schedule task on specific day of month', () async {
        final taskId = await scheduler.monthly('test', 15, 12, 0, () {});

        final task = scheduler.getTask(taskId);
        expect(task, isNotNull);
        expect(task!.cronExpression, equals('0 12 15 * *'));
      });
    });

    group('unschedule', () {
      test('should unschedule a task', () async {
        final taskId = await scheduler.schedule('test', '* * * * *', () {});

        expect(scheduler.getTask(taskId), isNotNull);

        await scheduler.unschedule(taskId);

        expect(scheduler.getTask(taskId), isNull);
      });

      test('should mark unscheduled task as cancelled', () async {
        final taskId = await scheduler.schedule('test', '* * * * *', () {});

        final task = scheduler.getTask(taskId);
        await scheduler.unschedule(taskId);

        expect(task!.status, equals(TaskStatus.cancelled));
      });

      test('should handle unscheduling non-existent task', () async {
        await expectLater(
          scheduler.unschedule('non-existent'),
          completes,
        );
      });
    });

    group('getTasks', () {
      test('should return all tasks', () async {
        await scheduler.schedule('task1', '* * * * *', () {});
        await Future.delayed(const Duration(milliseconds: 10));
        await scheduler.schedule('task2', '0 * * * *', () {});
        await Future.delayed(const Duration(milliseconds: 10));
        await scheduler.schedule('task3', '0 0 * * *', () {});

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
        await scheduler.schedule('task1', '* * * * *', () {});
        await Future.delayed(const Duration(milliseconds: 10));
        await scheduler.schedule('task2', '* * * * *', () {});

        final scheduledTasks = scheduler.getTasksByStatus(TaskStatus.scheduled);
        expect(scheduledTasks.length, equals(2));
      });

      test('should return empty list when no tasks with status', () {
        final runningTasks = scheduler.getTasksByStatus(TaskStatus.running);
        expect(runningTasks, isEmpty);
      });
    });

    group('start and stop', () {
      test('should start scheduler', () async {
        await scheduler.start();
        // Scheduler should be running (check via internal state)
        // Cannot directly test _isRunning, but we can verify it doesn't throw
        expect(scheduler, isNotNull);
      });

      test('should stop scheduler', () async {
        await scheduler.start();
        await scheduler.stop();
        // Scheduler should be stopped
        expect(scheduler, isNotNull);
      });
    });

    group('close', () {
      test('should close and cleanup all resources', () async {
        await scheduler.schedule('task1', '* * * * *', () {});
        await scheduler.schedule('task2', '* * * * *', () {});

        await scheduler.close();

        expect(scheduler.getTasks(), isEmpty);
      });
    });

  });
}
