import 'task.dart';

/// Schedule management
class ScheduleManager {
  final List<ScheduledTask> _scheduledTasks = [];

  /// Add a task to be managed
  void addTask(ScheduledTask task) {
    _scheduledTasks.add(task);
  }

  /// Remove a task
  void removeTask(String taskId) {
    _scheduledTasks.removeWhere((task) => task.id == taskId);
  }

  /// Get all scheduled tasks
  List<ScheduledTask> get tasks => List.unmodifiable(_scheduledTasks);

  /// Get a task by ID
  ScheduledTask? getTask(String taskId) {
    try {
      return _scheduledTasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  /// Get tasks scheduled for a specific time
  List<ScheduledTask> getTasksForTime(DateTime time) {
    return _scheduledTasks.where((task) {
      // In a real implementation, you'd parse the cron expression
      // and check if the time matches
      return task.nextRun?.isBefore(time) ?? false;
    }).toList();
  }

  /// Clear all tasks
  void clear() {
    _scheduledTasks.clear();
  }

  /// Get task statistics
  Map<String, int> getStatistics() {
    final stats = <String, int>{};
    for (final status in TaskStatus.values) {
      stats[status.name] = _scheduledTasks
          .where((task) => task.status == status)
          .length;
    }
    return stats;
  }
}
