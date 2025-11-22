import 'dart:async';
import 'task.dart';
import 'schedule_manager.dart';

/// Simple interval-based scheduler for Dartian
class SimpleScheduler {
  final ScheduleManager _manager;
  final Map<String, ScheduledTask> _tasks = {};
  final Map<String, Timer> _timers = {};
  bool _isRunning = false;

  SimpleScheduler() : _manager = ScheduleManager();

  /// Get the schedule manager
  ScheduleManager get manager => _manager;

  /// Schedule a new task to run at intervals
  Future<String> scheduleInterval(
    String name,
    Duration interval,
    Function() callback,
  ) async {
    final task = ScheduledTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      cronExpression: 'every ${interval.inSeconds} seconds',
      callback: callback,
      createdAt: DateTime.now(),
    );

    // Create timer for the interval
    final timer = Timer.periodic(interval, (timer) async {
      if (!_isRunning) return;

      task.status = TaskStatus.running;
      task.lastRun = DateTime.now();
      task.nextRun = DateTime.now().add(interval);

      try {
        callback();
        task.status = TaskStatus.completed;
      } catch (e) {
        task.status = TaskStatus.failed;
        task.error = e.toString();
      }
    });

    _tasks[task.id] = task;
    _timers[task.id] = timer;

    _manager.addTask(task);
    return task.id;
  }

  /// Schedule a one-time task
  Future<String> scheduleOnce(
    String name,
    Duration delay,
    Function() callback,
  ) async {
    final task = ScheduledTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      cronExpression: 'once after ${delay.inSeconds} seconds',
      callback: callback,
      createdAt: DateTime.now(),
    );

    final timer = Timer(delay, () async {
      if (!_isRunning) return;

      task.status = TaskStatus.running;
      task.lastRun = DateTime.now();

      try {
        callback();
        task.status = TaskStatus.completed;
      } catch (e) {
        task.status = TaskStatus.failed;
        task.error = e.toString();
      }
    });

    _tasks[task.id] = task;
    _timers[task.id] = timer;

    _manager.addTask(task);
    return task.id;
  }

  /// Unschedule a task
  Future<void> unschedule(String taskId) async {
    final task = _tasks[taskId];
    if (task == null) return;

    task.status = TaskStatus.cancelled;
    _timers[taskId]?.cancel();
    _timers.remove(taskId);
    _tasks.remove(taskId);
    _manager.removeTask(taskId);
  }

  /// Get a task by ID
  ScheduledTask? getTask(String taskId) => _tasks[taskId];

  /// Get all tasks
  List<ScheduledTask> getTasks() => _tasks.values.toList();

  /// Get tasks by status
  List<ScheduledTask> getTasksByStatus(TaskStatus status) {
    return _tasks.values.where((task) => task.status == status).toList();
  }

  /// Start the scheduler
  Future<void> start() async {
    _isRunning = true;
  }

  /// Stop the scheduler
  Future<void> stop() async {
    _isRunning = false;
  }

  /// Close all resources
  Future<void> close() async {
    stop();

    // Cancel all timers
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _tasks.clear();
    _manager.clear();
  }
}

/// Alias for SimpleScheduler for backward compatibility
typedef CronScheduler = SimpleScheduler;
