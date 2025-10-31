import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'tables/users.dart';
import 'tables/posts.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Users, Posts])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
  );

  static AppDatabase connect({bool inMemory = false}) {
    if (inMemory) {
      return AppDatabase(NativeDatabase.memory());
    }
    final dbFolder = Directory('database');
    if (!dbFolder.existsSync()) {
      dbFolder.createSync(recursive: true);
    }
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return AppDatabase(NativeDatabase(file));
  }
}
