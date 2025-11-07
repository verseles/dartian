/// Hooks for telemetry and observability
/// Each hook is a list of callbacks that can be registered
class TelemetryHooks {
  // Request lifecycle hooks
  static final List<void Function(dynamic request)> _onRequestCallbacks = [];
  static final List<void Function(dynamic response, Duration duration)> _onResponseCallbacks = [];

  // Database hooks
  static final List<void Function(String sql, Duration duration)> _onQueryExecutedCallbacks = [];

  // Queue hooks
  static final List<void Function(dynamic job)> _onJobQueuedCallbacks = [];
  static final List<void Function(dynamic job, Duration duration)> _onJobProcessedCallbacks = [];

  /// Register a callback for request start
  static void onRequest(void Function(dynamic request) callback) {
    _onRequestCallbacks.add(callback);
  }

  /// Register a callback for response complete
  static void onResponse(void Function(dynamic response, Duration duration) callback) {
    _onResponseCallbacks.add(callback);
  }

  /// Register a callback for database query execution
  static void onQueryExecuted(void Function(String sql, Duration duration) callback) {
    _onQueryExecutedCallbacks.add(callback);
  }

  /// Register a callback for job queued
  static void onJobQueued(void Function(dynamic job) callback) {
    _onJobQueuedCallbacks.add(callback);
  }

  /// Register a callback for job processed
  static void onJobProcessed(void Function(dynamic job, Duration duration) callback) {
    _onJobProcessedCallbacks.add(callback);
  }

  /// Trigger request start hooks
  static void triggerRequest(dynamic request) {
    for (final callback in _onRequestCallbacks) {
      try {
        callback(request);
      } catch (e) {
        // Silently ignore hook errors to prevent breaking main flow
      }
    }
  }

  /// Trigger response complete hooks
  static void triggerResponse(dynamic response, Duration duration) {
    for (final callback in _onResponseCallbacks) {
      try {
        callback(response, duration);
      } catch (e) {
        // Silently ignore hook errors
      }
    }
  }

  /// Trigger query executed hooks
  static void triggerQueryExecuted(String sql, Duration duration) {
    for (final callback in _onQueryExecutedCallbacks) {
      try {
        callback(sql, duration);
      } catch (e) {
        // Silently ignore hook errors
      }
    }
  }

  /// Trigger job queued hooks
  static void triggerJobQueued(dynamic job) {
    for (final callback in _onJobQueuedCallbacks) {
      try {
        callback(job);
      } catch (e) {
        // Silently ignore hook errors
      }
    }
  }

  /// Trigger job processed hooks
  static void triggerJobProcessed(dynamic job, Duration duration) {
    for (final callback in _onJobProcessedCallbacks) {
      try {
        callback(job, duration);
      } catch (e) {
        // Silently ignore hook errors
      }
    }
  }

  /// Clear all registered hooks
  static void clear() {
    _onRequestCallbacks.clear();
    _onResponseCallbacks.clear();
    _onQueryExecutedCallbacks.clear();
    _onJobQueuedCallbacks.clear();
    _onJobProcessedCallbacks.clear();
  }

  /// Get count of registered callbacks
  static int get totalCallbacks {
    return _onRequestCallbacks.length +
        _onResponseCallbacks.length +
        _onQueryExecutedCallbacks.length +
        _onJobQueuedCallbacks.length +
        _onJobProcessedCallbacks.length;
  }
}
