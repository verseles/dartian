import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:test/test.dart';
import 'package:dartian_orm/dartian_orm.dart';
import 'test_database.dart';

void main() {
  late TestDatabase db;

  setUp(() async {
    db = TestDatabase();
    await db.customStatement('PRAGMA foreign_keys = ON');
  });

  tearDown(() async {
    await db.close();
  });

  group('ModelRepository - Concrete usage', () {
    test('should create repository instance', () {
      final repo = ModelRepository<Users, User>(db, db.users);
      expect(repo.database, equals(db));
      expect(repo.table, equals(db.users));
    });

    test('all() should return all records', () async {
      // Insert test data
      await db.batch((batch) {
        batch.insertAll(db.users, [
          UsersCompanion.insert(name: 'User 1', email: 'user1@example.com'),
          UsersCompanion.insert(name: 'User 2', email: 'user2@example.com'),
        ]);
      });

      final repo = ModelRepository<Users, User>(db, db.users);
      final users = await repo.all();
      expect(users.length, equals(2));
    });

    test('count() should return total records', () async {
      await db.batch((batch) {
        batch.insertAll(db.users, [
          UsersCompanion.insert(name: 'User 1', email: 'user1@example.com'),
          UsersCompanion.insert(name: 'User 2', email: 'user2@example.com'),
          UsersCompanion.insert(name: 'User 3', email: 'user3@example.com'),
        ]);
      });

      final repo = ModelRepository<Users, User>(db, db.users);
      final count = await repo.count();
      expect(count, equals(3));
    });

    test('count() should return 0 for empty table', () async {
      final repo = ModelRepository<Users, User>(db, db.users);
      final count = await repo.count();
      expect(count, equals(0));
    });

    test('where() should filter records', () async {
      await db.batch((batch) {
        batch.insertAll(db.users, [
          UsersCompanion.insert(name: 'Alice', email: 'alice@example.com'),
          UsersCompanion.insert(name: 'Bob', email: 'bob@example.com'),
        ]);
      });

      final repo = ModelRepository<Users, User>(db, db.users);
      final users = await repo.where((tbl) => tbl.name.equals('Alice'));
      expect(users.length, equals(1));
      expect(users.first.name, equals('Alice'));
    });
  });

  group('ModelQueryExtensions', () {
    setUp(() async {
      await db.batch((batch) {
        batch.insertAll(db.users, [
          UsersCompanion.insert(name: 'Alice', email: 'alice@example.com'),
          UsersCompanion.insert(name: 'Bob', email: 'bob@example.com'),
          UsersCompanion.insert(name: 'Charlie', email: 'charlie@example.com'),
          UsersCompanion.insert(name: 'Dave', email: 'dave@example.com'),
        ]);
      });
    });

    test('whereCondition() should filter results', () async {
      final query = db
          .select(db.users)
          .whereCondition((tbl) => tbl.email.contains('bob'));

      final results = await query.get();
      expect(results.length, equals(1));
      expect(results.first.name, equals('Bob'));
    });

    test('orderByColumn() should sort ascending', () async {
      final query = db
          .select(db.users)
          .orderByColumn((tbl) => tbl.name, mode: OrderingMode.asc);

      final results = await query.get();
      expect(results.first.name, equals('Alice'));
      expect(results.last.name, equals('Dave'));
    });

    test('orderByColumn() should sort descending', () async {
      final query = db
          .select(db.users)
          .orderByColumn((tbl) => tbl.name, mode: OrderingMode.desc);

      final results = await query.get();
      expect(results.first.name, equals('Dave'));
      expect(results.last.name, equals('Alice'));
    });

    test('limitTo() should limit results', () async {
      final query = db.select(db.users).limitTo(2);

      final results = await query.get();
      expect(results.length, equals(2));
    });

    test('offsetBy() should skip and limit results', () async {
      final query = db
          .select(db.users)
          .orderByColumn((tbl) => tbl.id)
          .offsetBy(2);

      final results = await query.get();
      // offsetBy calls limit(count, offset: count)
      // So it will skip 2 and limit to 2
      expect(results.length, equals(2));
    });

    test('should chain extension methods', () async {
      final query = db
          .select(db.users)
          .whereCondition((tbl) => tbl.name.like('%a%'))
          .orderByColumn((tbl) => tbl.name)
          .limitTo(2);

      final results = await query.get();
      expect(results.length, equals(2));
      expect(results[0].name, equals('Alice'));
      expect(results[1].name, equals('Charlie'));
    });
  });
}
