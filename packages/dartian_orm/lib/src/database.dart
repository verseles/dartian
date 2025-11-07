import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart' as p;

/// Database connection manager for Dartian ORM
class DatabaseManager {
  static DatabaseManager? _instance;
  static DatabaseManager get instance => _instance ??= DatabaseManager._();

  DatabaseManager._();

  /// Create an in-memory database
  QueryDatabase inMemoryDatabase() {
    final db = sqlite3.openInMemory();
    return QueryDatabase(db);
  }

  /// Create a SQLite database
  /// [dbName] - Name of the database file (without extension)
  /// [directory] - Directory to store the database file (defaults to current directory)
  QueryDatabase sqliteDatabase(String dbName, {String? directory}) {
    final path = p.join(directory ?? '.', '$dbName.db');
    final db = sqlite3.open(path);
    return QueryDatabase(db);
  }
}

/// Database class that wraps a sqlite3 database connection
class QueryDatabase {
  final Database _database;

  QueryDatabase(this._database);

  /// Execute a query
  List<Map<String, dynamic>> query(
    String sql,
    List<dynamic> args, {
    int? limit,
    int? offset,
  }) {
    // Add LIMIT and OFFSET if specified
    String finalSql = sql;
    if (offset != null && limit != null) {
      finalSql += ' LIMIT $limit OFFSET $offset';
    } else if (limit != null) {
      finalSql += ' LIMIT $limit';
    }

    final ResultSet result = _database.select(finalSql, args);
    // Row already implements Map<String, dynamic>
    return result.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  /// Execute a command (INSERT, UPDATE, DELETE)
  int execute(String sql, List<dynamic> args) {
    _database.execute(sql, args);
    // Get the number of rows affected
    return _database.updatedRows;
  }

  /// Execute a query that returns a single value
  T querySingle<T>(
    String sql,
    List<dynamic> args,
  ) {
    final ResultSet result = _database.select(sql, args);
    if (result.isEmpty) {
      throw Exception('No results found');
    }
    return result.first.values.first as T;
  }

  /// Check if a table exists
  bool tableExists(String tableName) {
    final result = _database.select(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  /// Close the database
  void close() {
    _database.dispose();
  }
}
