import 'database.dart';

/// Base repository class for data access
abstract class Repository<T> {
  final QueryDatabase _db;

  Repository(this._db);

  /// Find all records
  List<T> findAll();

  /// Find a record by ID
  T? findById(dynamic id);

  /// Insert a record
  T insert(T record);

  /// Update a record
  T update(T record);

  /// Delete a record
  void delete(dynamic id);

  /// Count all records
  int count();
}

/// Generic repository implementation
class GenericRepository<T> extends Repository<T> {
  final String _tableName;
  final Map<String, dynamic> Function(T) _toJson;
  final T Function(Map<String, dynamic>) _fromJson;

  GenericRepository(
    QueryDatabase db,
    this._tableName,
    this._toJson,
    this._fromJson,
  ) : super(db);

  @override
  List<T> findAll() {
    final sql = 'SELECT * FROM $_tableName';
    final results = _db.query(sql, []);
    return results.map((row) => _fromJson(row)).toList();
  }

  @override
  T? findById(dynamic id) {
    final sql = 'SELECT * FROM $_tableName WHERE id = ?';
    final results = _db.query(sql, [id]);
    if (results.isEmpty) return null;
    return _fromJson(results.first);
  }

  @override
  T insert(T record) {
    final data = _toJson(record);
    final columns = data.keys.join(', ');
    final placeholders = data.keys.map((_) => '?').join(', ');
    final sql = 'INSERT INTO $_tableName ($columns) VALUES ($placeholders)';
    _db.execute(sql, data.values.toList());
    return record;
  }

  @override
  T update(T record) {
    final data = _toJson(record);
    final id = data.remove('id');
    final setClause = data.keys.map((k) => '$k = ?').join(', ');
    final sql = 'UPDATE $_tableName SET $setClause WHERE id = ?';
    _db.execute(sql, [...data.values, id]);
    return record;
  }

  @override
  void delete(dynamic id) {
    final sql = 'DELETE FROM $_tableName WHERE id = ?';
    _db.execute(sql, [id]);
  }

  @override
  int count() {
    final sql = 'SELECT COUNT(*) FROM $_tableName';
    return _db.querySingle<int>(sql, []);
  }
}
