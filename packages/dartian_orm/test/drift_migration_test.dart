import 'package:test/test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:dartian_orm/dartian_orm.dart' hide isNull, isNotNull;

part 'drift_migration_test.g.dart';

// Test tables for migration testing
class TestTableV1 extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}

@DriftDatabase(tables: [TestTableV1])
class TestDatabaseV1 extends _$TestDatabaseV1 {
  TestDatabaseV1() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return DriftMigrationHelper.simple((m) async {
      await m.createAll();
    });
  }
}

// Migration example
class TestMigrationV2 extends DriftMigration {
  @override
  int get version => 2;

  @override
  Future<void> up(Migrator m, QueryExecutor executor) async {
    final ops = MigrationOperations(m, executor);
    await ops.addColumn('test_table_v1', 'email TEXT');
  }
}

class TestMigrationV3 extends DriftMigration {
  @override
  int get version => 3;

  @override
  Future<void> up(Migrator m, QueryExecutor executor) async {
    final ops = MigrationOperations(m, executor);
    await ops.createIndex('idx_name', 'test_table_v1', ['name']);
  }

  @override
  Future<void> down(Migrator m, QueryExecutor executor) async {
    final ops = MigrationOperations(m, executor);
    await ops.dropIndex('idx_name');
  }
}

void main() {
  group('DriftMigration', () {
    test('migration has version', () {
      final migration = TestMigrationV2();
      expect(migration.version, 2);
    });

    test('migration down throws by default if not implemented', () async {
      final migration = TestMigrationV2();
      final db = TestDatabaseV1();
      expect(
        migration.down(db.createMigrator(), db.executor),
        throwsUnimplementedError,
      );
      await db.close();
    });
  });

  group('DriftMigrationHelper', () {
    test('builds simple migration strategy', () {
      final strategy = DriftMigrationHelper.simple((m) async {
        await m.createAll();
      });

      expect(strategy, isNotNull);
      expect(strategy.onCreate, isNotNull);
    });
  });

  group('MigrationOperations', () {
    late TestDatabaseV1 db;
    late QueryExecutor executor;
    late MigrationOperations ops;

    setUp(() async {
      db = TestDatabaseV1();
      executor = db.executor;
      ops = MigrationOperations(db.createMigrator(), executor);
      // Force database to open by executing a simple query
      await db.customSelect('SELECT 1').get();
    });

    tearDown(() async {
      await db.close();
    });

    test('executes raw SQL', () async {
      await ops.raw('CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT)');

      final result = await executor.runSelect(
        'SELECT name FROM sqlite_master WHERE type="table" AND name="test"',
        [],
      );
      expect(result.length, 1);
    });

    test('creates index', () async {
      await ops.raw('CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)');
      await ops.createIndex('idx_users_name', 'users', ['name']);

      final result = await executor.runSelect(
        'SELECT name FROM sqlite_master WHERE type="index" AND name="idx_users_name"',
        [],
      );
      expect(result.length, 1);
    });

    test('creates unique index', () async {
      await ops.raw('CREATE TABLE users (id INTEGER PRIMARY KEY, email TEXT)');
      await ops.createIndex('idx_users_email', 'users', ['email'],
          unique: true);

      final result = await executor.runSelect(
        'SELECT sql FROM sqlite_master WHERE type="index" AND name="idx_users_email"',
        [],
      );
      expect(result.length, 1);
      expect(result.first['sql'].toString().contains('UNIQUE'), true);
    });

    test('drops index', () async {
      await ops.raw('CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)');
      await ops.createIndex('idx_test', 'users', ['name']);
      await ops.dropIndex('idx_test');

      final result = await executor.runSelect(
        'SELECT name FROM sqlite_master WHERE type="index" AND name="idx_test"',
        [],
      );
      expect(result.length, 0);
    });

    test('adds column', () async {
      await ops.raw('CREATE TABLE users (id INTEGER PRIMARY KEY)');
      await ops.addColumn('users', 'name TEXT');

      final result = await executor.runSelect('PRAGMA table_info(users)', []);
      expect(result.length, 2);
      expect(result.any((col) => col['name'] == 'name'), true);
    });

    test('renames column', () async {
      await ops.raw('CREATE TABLE users (id INTEGER PRIMARY KEY, old_name TEXT)');
      await ops.renameColumn('users', 'old_name', 'new_name');

      final result = await executor.runSelect('PRAGMA table_info(users)', []);
      expect(result.any((col) => col['name'] == 'new_name'), true);
      expect(result.any((col) => col['name'] == 'old_name'), false);
    });

    test('drops column', () async {
      await ops.raw('CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, email TEXT)');
      await ops.dropColumn('users', 'email');

      final result = await executor.runSelect('PRAGMA table_info(users)', []);
      expect(result.length, 2);
      expect(result.any((col) => col['name'] == 'email'), false);
    });
  });

  group('TestDatabase', () {
    late TestDatabaseV1 db;

    setUp(() {
      db = TestDatabaseV1();
    });

    tearDown(() async {
      await db.close();
    });

    test('creates tables on initialization', () async {
      // Insert a record to verify table exists
      await db.into(db.testTableV1).insert(
            TestTableV1Companion.insert(name: 'Test'),
          );

      final records = await db.select(db.testTableV1).get();
      expect(records.length, 1);
      expect(records.first.name, 'Test');
    });

    test('migration strategy is applied', () {
      expect(db.migration, isNotNull);
      expect(db.migration.onCreate, isNotNull);
    });
  });
}
