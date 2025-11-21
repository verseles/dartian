import 'package:dartian_scheduler/src/schedule_manager.dart';
import 'package:dartian_scheduler/src/task.dart';
import 'package:test/test.dart';

void main() {
  group('ScheduleManager', () {
    late ScheduleManager manager;
    late ScheduledTask task1;
    late ScheduledTask task2;
    late ScheduledTask task3;

    setUp(() {
      manager = ScheduleManager();

      task1 = ScheduledTask(
        id: 'task-1',
        name: 'Task 1',
        cronExpression: '* * * * *',
        callback: () {},
        createdAt: DateTime.now(),
      );

      task2 = ScheduledTask(
        id: 'task-2',
        name: 'Task 2',
        cronExpression: '0 * * * *',
        callback: () {},
        createdAt: DateTime.now(),
      );

      task3 = ScheduledTask(
        id: 'task-3',
        name: 'Task 3',
        cronExpression: '0 0 * * *',
        callback: () {},
        createdAt: DateTime.now(),
      );
    });

    test('should create empty manager', () {
      expect(manager.tasks, isEmpty);
    });

    group('addTask', () {
      test('should add a task', () {
        manager.addTask(task1);

        expect(manager.tasks.length, equals(1));
        expect(manager.tasks[0], equals(task1));
      });

      test('should add multiple tasks', () {
        manager.addTask(task1);
        manager.addTask(task2);
        manager.addTask(task3);

        expect(manager.tasks.length, equals(3));
      });

      test('should maintain task order', () {
        manager.addTask(task1);
        manager.addTask(task2);
        manager.addTask(task3);

        expect(manager.tasks[0].id, equals('task-1'));
        expect(manager.tasks[1].id, equals('task-2'));
        expect(manager.tasks[2].id, equals('task-3'));
      });
    });

    group('removeTask', () {
      setUp(() {
        manager.addTask(task1);
        manager.addTask(task2);
        manager.addTask(task3);
      });

      test('should remove a task by ID', () {
        manager.removeTask('task-2');

        expect(manager.tasks.length, equals(2));
        expect(manager.tasks.any((t) => t.id == 'task-2'), isFalse);
      });

      test('should handle removing non-existent task', () {
        manager.removeTask('non-existent');

        expect(manager.tasks.length, equals(3));
      });

      test('should remove all matching tasks', () {
        // Add duplicate (shouldn't happen in practice, but test the behavior)
        manager.addTask(task1);
        expect(manager.tasks.length, equals(4));

        manager.removeTask('task-1');

        expect(manager.tasks.any((t) => t.id == 'task-1'), isFalse);
      });
    });

    group('getTask', () {
      setUp(() {
        manager.addTask(task1);
        manager.addTask(task2);
      });

      test('should get a task by ID', () {
        final task = manager.getTask('task-1');

        expect(task, isNotNull);
        expect(task!.id, equals('task-1'));
        expect(task.name, equals('Task 1'));
      });

      test('should return null for non-existent task', () {
        final task = manager.getTask('non-existent');

        expect(task, isNull);
      });
    });

    group('getTasksForTime', () {
      test('should get tasks scheduled before given time', () {
        final now = DateTime.now();
        final future = now.add(const Duration(hours: 1));

        task1.nextRun = now.subtract(const Duration(minutes: 5));
        task2.nextRun = now.add(const Duration(minutes: 5));
        task3.nextRun = future.add(const Duration(minutes: 5));

        manager.addTask(task1);
        manager.addTask(task2);
        manager.addTask(task3);

        final dueTasks = manager.getTasksForTime(now);

        expect(dueTasks.length, equals(1));
        expect(dueTasks[0].id, equals('task-1'));
      });

      test('should return empty list when no tasks due', () {
        final now = DateTime.now();
        final future = now.add(const Duration(hours: 1));

        task1.nextRun = future;
        task2.nextRun = future.add(const Duration(hours: 1));

        manager.addTask(task1);
        manager.addTask(task2);

        final dueTasks = manager.getTasksForTime(now);

        expect(dueTasks, isEmpty);
      });

      test('should handle tasks without nextRun', () {
        final now = DateTime.now();

        // task1 has no nextRun set
        task2.nextRun = now.subtract(const Duration(minutes: 5));

        manager.addTask(task1);
        manager.addTask(task2);

        final dueTasks = manager.getTasksForTime(now);

        expect(dueTasks.length, equals(1));
        expect(dueTasks[0].id, equals('task-2'));
      });
    });

    group('clear', () {
      test('should clear all tasks', () {
        manager.addTask(task1);
        manager.addTask(task2);
        manager.addTask(task3);

        expect(manager.tasks.length, equals(3));

        manager.clear();

        expect(manager.tasks, isEmpty);
      });

      test('should work on empty manager', () {
        expect(() => manager.clear(), returnsNormally);
        expect(manager.tasks, isEmpty);
      });
    });

    group('getStatistics', () {
      test('should return statistics for all status types', () {
        task1.status = TaskStatus.scheduled;
        task2.status = TaskStatus.running;
        task3.status = TaskStatus.completed;

        manager.addTask(task1);
        manager.addTask(task2);
        manager.addTask(task3);

        final stats = manager.getStatistics();

        expect(stats['scheduled'], equals(1));
        expect(stats['running'], equals(1));
        expect(stats['completed'], equals(1));
        expect(stats['failed'], equals(0));
        expect(stats['cancelled'], equals(0));
      });

      test('should return zero counts for empty manager', () {
        final stats = manager.getStatistics();

        for (final status in TaskStatus.values) {
          expect(stats[status.name], equals(0));
        }
      });

      test('should count multiple tasks with same status', () {
        task1.status = TaskStatus.completed;
        task2.status = TaskStatus.completed;
        task3.status = TaskStatus.failed;

        manager.addTask(task1);
        manager.addTask(task2);
        manager.addTask(task3);

        final stats = manager.getStatistics();

        expect(stats['completed'], equals(2));
        expect(stats['failed'], equals(1));
        expect(stats['scheduled'], equals(0));
      });
    });

    group('tasks getter', () {
      test('should return unmodifiable list', () {
        manager.addTask(task1);

        final tasks = manager.tasks;

        expect(() => tasks.add(task2), throwsUnsupportedError);
      });

      test('should return current state', () {
        expect(manager.tasks, isEmpty);

        manager.addTask(task1);
        expect(manager.tasks.length, equals(1));

        manager.addTask(task2);
        expect(manager.tasks.length, equals(2));

        manager.removeTask('task-1');
        expect(manager.tasks.length, equals(1));
      });
    });
  });
}
