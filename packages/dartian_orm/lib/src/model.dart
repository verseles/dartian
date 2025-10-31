import 'package:dartian_orm/database.dart';
import 'package:drift/drift.dart';

abstract class Model<T extends DataClass, D extends Table> {
  final AppDatabase database;
  final TableInfo<D, T> table;

  Model(this.database, this.table);

  Future<List<T>> all() {
    return (database.select(table)).get();
  }

  Future<T?> find(int id) {
    return (database.select(table)..where((tbl) => (tbl as dynamic).id.equals(id))).getSingleOrNull();
  }

  Future<int> create(Insertable<T> entry) {
    return database.into(table).insert(entry);
  }

  Future<bool> update(Insertable<T> entry) {
    return database.update(table).replace(entry);
  }

  Future<int> delete(Insertable<T> entry) {
    return database.delete(table).delete(entry);
  }
}
