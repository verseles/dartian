import 'package:uuid/uuid.dart';

class Session {
  final String id;
  final Map<String, dynamic> _data = {};

  Session(this.id);

  void set(String key, dynamic value) {
    _data[key] = value;
  }

  dynamic get(String key) {
    return _data[key];
  }

  bool has(String key) {
    return _data.containsKey(key);
  }

  void remove(String key) {
    _data.remove(key);
  }

  void clear() {
    _data.clear();
  }
}

class SessionManager {
  final Map<String, Session> _sessions = {};
  final Uuid _uuid = Uuid();

  Session startSession([String? sessionId]) {
    if (sessionId != null && _sessions.containsKey(sessionId)) {
      return _sessions[sessionId]!;
    }
    final newSessionId = _uuid.v4();
    final session = Session(newSessionId);
    _sessions[newSessionId] = session;
    return session;
  }

  Session? getSession(String sessionId) {
    return _sessions[sessionId];
  }

  void destroySession(String sessionId) {
    _sessions.remove(sessionId);
  }
}
