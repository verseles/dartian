import 'dart:async';
import 'task.dart';
import 'cron_expression.dart';
import 'schedule_manager.dart';

/// Cron-based scheduler for Dartian
///
/// Supports standard cron expressions:
/// - * * * * * (every minute)
/// - 0 * * * * (every hour)
/// - 0 0 * * * (every day at midnight)
/// - */5 * * * * (every 5 minutes)
/// - 0 9-17 * * 1-5 (every hour from 9 AM to 5 PM on weekdays)
class RealCronScheduler {
  final ScheduleManager _manager;
  final Map<String, ScheduledTask> _tasks = {};
  final Map<String, CronExpression> _cronExpressions = {};
  Timer? _checkTimer;
  bool _isRunning = false;

  RealCronScheduler() : _manager = ScheduleManager();

  /// Get the schedule manager
  ScheduleManager get manager => _manager;

  /// Schedule a task with a cron expression
  ///
  /// [name] - Task name
  /// [cronExpression] - Standard cron expression (minute hour day month dayOfWeek)
  /// [callback] - Function to execute when task is due
  ///
  /// Returns task ID
  ///
  /// Examples:
  /// - "* * * * *" - every minute
  /// - "0 * * * *" - every hour
  /// - "0 0 * * *" - every day at midnight
  /// - "0 9 * * 1-5" - 9 AM on weekdays
  /// - "*/5 * * * *" - every 5 minutes
  /// - "0 0 1 * *" - first day of every month
  Future<String> schedule(
    String name,
    String cronExpression,
    Function() callback,
  ) async {
    // Parse and validate cron expression
    final cron = CronExpression.parse(cronExpression);

    final task = ScheduledTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      cronExpression: cronExpression,
      callback: callback,
      createdAt: DateTime.now(),
    );

    // Calculate next run
    final nextRun = cron.getNextRun(DateTime.now());
    task.nextRun = nextRun;

    _tasks[task.id] = task;
    _cronExpressions[task.id] = cron;

    _manager.addTask(task);
    return task.id;
  }

  /// Schedule a task to run every N minutes
  Future<String> everyMinutes(
    String name,
    int minutes,
    Function() callback,
  ) async {
    return schedule(name, '*/$minutes * * * *', callback);
  }

  /// Schedule a task to run every hour
  Future<String> hourly(String name, Function() callback) async {
    return schedule(name, '0 * * * *', callback);
  }

  /// Schedule a task to run daily at a specific time
  Future<String> daily(
    String name,
    int hour,
    int minute,
    Function() callback,
  ) async {
    return schedule(name, '$minute $hour * * *', callback);
  }

  /// Schedule a task to run weekly on specific days
  Future<String> weekly(
    String name,
    List<int> daysOfWeek,
    int hour,
    int minute,
    Function() callback,
  ) async {
    final days = daysOfWeek.join(',');
    return schedule(name, '$minute $hour * * $days', callback);
  }

  /// Schedule a task to run monthly on a specific day
  Future<String> monthly(
    String name,
    int day,
    int hour,
    int minute,
    Function() callback,
  ) async {
    return schedule(name, '$minute $hour $day * *', callback);
  }

  /// Unschedule a task
  Future<void> unschedule(String taskId) async {
    final task = _tasks[taskId];
    if (task == null) return;

    task.status = TaskStatus.cancelled;
    _tasks.remove(taskId);
    _cronExpressions.remove(taskId);
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

    // Check for due tasks every minute
    _checkTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkDueTasks();
    });

    // Also check immediately
    _checkDueTasks();
  }

  /// Check for tasks that are due to run
  void _checkDueTasks() {
    if (!_isRunning) return;

    final now = DateTime.now();

    for (final entry in _tasks.entries) {
      final taskId = entry.key;
      final task = entry.value;
      final cron = _cronExpressions[taskId];

      if (cron == null) continue;

      // Check if task is due
      if (task.nextRun != null && now.isAfter(task.nextRun!)) {
        _runTask(task, cron);
      }
    }
  }

  /// Run a task
  Future<void> _runTask(ScheduledTask task, CronExpression cron) async {
    task.status = TaskStatus.running;
    task.lastRun = DateTime.now();

    try {
      task.callback();
      task.status = TaskStatus.completed;
    } catch (e) {
      task.status = TaskStatus.failed;
      task.error = e.toString();
    }

    // Calculate next run
    final nextRun = cron.getNextRun(DateTime.now());
    task.nextRun = nextRun;

    // Reset status to scheduled for recurring tasks
    if (nextRun != null) {
      task.status = TaskStatus.scheduled;
    }
  }

  /// Stop the scheduler
  Future<void> stop() async {
    _isRunning = false;
    _checkTimer?.cancel();
    _checkTimer = null;
  }

  /// Close all resources
  Future<void> close() async {
    await stop();
    _tasks.clear();
    _cronExpressions.clear();
    _manager.clear();
  }
}
