import 'database.dart';

/// Query builder for building SQL queries in a fluent manner
class QueryBuilder {
  final QueryDatabase _db;
  final String _table;

  QueryBuilder(this._db, this._table);

  /// Select columns from the table
  SelectQuery select(List<String> columns) {
    return SelectQuery(_db, _table, columns);
  }

  /// Insert into the table
  InsertQuery insert(Map<String, dynamic> data) {
    return InsertQuery(_db, _table, data);
  }

  /// Update the table
  UpdateQuery update(Map<String, dynamic> data) {
    return UpdateQuery(_db, _table, data);
  }

  /// Delete from the table
  DeleteQuery delete() {
    return DeleteQuery(_db, _table);
  }
}

class SelectQuery {
  final QueryDatabase _db;
  final String _table;
  final List<String> _columns;
  final List<dynamic> _whereArgs = [];
  String _whereClause = '';
  int? _limit;
  int? _offset;

  SelectQuery(this._db, this._table, this._columns);

  /// Add WHERE condition
  SelectQuery where(String condition, [List<dynamic> args = const []]) {
    if (_whereClause.isEmpty) {
      _whereClause = 'WHERE $condition';
    } else {
      _whereClause += ' AND $condition';
    }
    _whereArgs.addAll(args);
    return this;
  }

  /// Add ORDER BY clause
  SelectQuery orderBy(String column, {bool descending = false}) {
    _whereClause += ' ORDER BY $column${descending ? ' DESC' : ' ASC'}';
    return this;
  }

  /// Add LIMIT
  SelectQuery limit(int count) {
    _limit = count;
    return this;
  }

  /// Add OFFSET
  SelectQuery offset(int count) {
    _offset = count;
    return this;
  }

  /// Execute the query and return results
  List<Map<String, dynamic>> get() {
    final columns = _columns.isEmpty ? '*' : _columns.join(', ');
    String sql = 'SELECT $columns FROM $_table $_whereClause';
    final args = <dynamic>[..._whereArgs];

    // Add LIMIT and OFFSET directly to SQL, not as parameters
    if (_limit != null && _offset != null) {
      sql += ' LIMIT $_limit OFFSET $_offset';
    } else if (_limit != null) {
      sql += ' LIMIT $_limit';
    } else if (_offset != null) {
      // OFFSET without LIMIT - use -1 for no limit
      sql += ' LIMIT -1 OFFSET $_offset';
    }

    final results = _db.query(sql, args);
    return results;
  }
}

class InsertQuery {
  final QueryDatabase _db;
  final String _table;
  final Map<String, dynamic> _data;

  InsertQuery(this._db, this._table, this._data);

  /// Execute the insert and return the result
  int execute() {
    final columns = _data.keys.join(', ');
    final placeholders = _data.keys.map((_) => '?').join(', ');
    final sql = 'INSERT INTO $_table ($columns) VALUES ($placeholders)';
    return _db.execute(sql, _data.values.toList());
  }
}

class UpdateQuery {
  final QueryDatabase _db;
  final String _table;
  final Map<String, dynamic> _data;
  final List<dynamic> _whereArgs = [];
  String _whereClause = '';

  UpdateQuery(this._db, this._table, this._data);

  /// Add WHERE condition
  UpdateQuery where(String condition, [List<dynamic> args = const []]) {
    if (_whereClause.isEmpty) {
      _whereClause = 'WHERE $condition';
    } else {
      _whereClause += ' AND $condition';
    }
    _whereArgs.addAll(args);
    return this;
  }

  /// Execute the update and return the result
  int execute() {
    final setClause = _data.keys.map((k) => '$k = ?').join(', ');
    final sql = 'UPDATE $_table SET $setClause $_whereClause';
    return _db.execute(sql, [..._data.values, ..._whereArgs]);
  }
}

class DeleteQuery {
  final QueryDatabase _db;
  final String _table;
  final List<dynamic> _whereArgs = [];
  String _whereClause = '';

  DeleteQuery(this._db, this._table);

  /// Add WHERE condition
  DeleteQuery where(String condition, [List<dynamic> args = const []]) {
    if (_whereClause.isEmpty) {
      _whereClause = 'WHERE $condition';
    } else {
      _whereClause += ' AND $condition';
    }
    _whereArgs.addAll(args);
    return this;
  }

  /// Execute the delete and return the result
  int execute() {
    final sql = 'DELETE FROM $_table $_whereClause';
    return _db.execute(sql, _whereArgs);
  }
}
