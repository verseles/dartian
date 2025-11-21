import 'package:test/test.dart';
import 'package:dartian_orm/dartian_orm.dart' hide isNull, isNotNull;
import 'test_database.dart';

void main() {
  group('DartianDatabase', () {
    late TestDatabase db;

    tearDown(() async {
      await db.close();
    });

    test('creates in-memory database', () {
      db = TestDatabase();
      expect(db, isNotNull);
      expect(db.schemaVersion, 1);
    });

    test('opens with memory config', () {
      final config = DatabaseConfig.memory();
      expect(config.type, DatabaseType.memory);
      expect(config.path, isNull);
      expect(config.postgresConfig, isNull);

      // Just verify we can create a database with memory config
      db = TestDatabase();
      expect(db, isNotNull);
    });

    test('creates SQLite config with path', () {
      final config = DatabaseConfig.sqlite('/tmp/test.db');
      expect(config.type, DatabaseType.sqlite);
      expect(config.path, '/tmp/test.db');
      expect(config.postgresConfig, isNull);
    });

    test('creates PostgreSQL config', () {
      final pgConfig = PostgresConfig(
        host: 'localhost',
        port: 5432,
        database: 'testdb',
        username: 'user',
        password: 'pass',
      );
      final config = DatabaseConfig.postgres(pgConfig);

      expect(config.type, DatabaseType.postgres);
      expect(config.path, isNull);
      expect(config.postgresConfig, isNotNull);
      expect(config.postgresConfig!.host, 'localhost');
      expect(config.postgresConfig!.port, 5432);
      expect(config.postgresConfig!.database, 'testdb');
      expect(config.postgresConfig!.username, 'user');
      expect(config.postgresConfig!.password, 'pass');
    });

    test('performs basic CRUD operations', () async {
      db = TestDatabase();

      // Create
      final userId = await db.into(db.users).insert(UsersCompanion.insert(
            name: 'John Doe',
            email: 'john@example.com',
          ));
      expect(userId, greaterThan(0));

      // Read
      final users = await db.select(db.users).get();
      expect(users.length, 1);
      expect(users.first.name, 'John Doe');
      expect(users.first.email, 'john@example.com');

      // Update
      await (db.update(db.users)..where((u) => u.id.equals(userId)))
          .write(UsersCompanion(name: Value('Jane Doe')));

      final updatedUser =
          await (db.select(db.users)..where((u) => u.id.equals(userId)))
              .getSingle();
      expect(updatedUser.name, 'Jane Doe');

      // Delete
      await (db.delete(db.users)..where((u) => u.id.equals(userId))).go();
      final remainingUsers = await db.select(db.users).get();
      expect(remainingUsers.length, 0);
    });

    test('handles multiple records', () async {
      db = TestDatabase();

      // Insert multiple users
      await db.batch((batch) {
        batch.insertAll(db.users, [
          UsersCompanion.insert(name: 'User 1', email: 'user1@example.com'),
          UsersCompanion.insert(name: 'User 2', email: 'user2@example.com'),
          UsersCompanion.insert(name: 'User 3', email: 'user3@example.com'),
        ]);
      });

      final users = await db.select(db.users).get();
      expect(users.length, 3);
    });

    test('supports WHERE clauses', () async {
      db = TestDatabase();

      await db.batch((batch) {
        batch.insertAll(db.users, [
          UsersCompanion.insert(name: 'Alice', email: 'alice@example.com'),
          UsersCompanion.insert(name: 'Bob', email: 'bob@example.com'),
          UsersCompanion.insert(name: 'Charlie', email: 'charlie@example.com'),
        ]);
      });

      final alice = await (db.select(db.users)
            ..where((u) => u.name.equals('Alice')))
          .getSingle();
      expect(alice.name, 'Alice');
      expect(alice.email, 'alice@example.com');
    });

    test('supports ORDER BY', () async {
      db = TestDatabase();

      await db.batch((batch) {
        batch.insertAll(db.users, [
          UsersCompanion.insert(name: 'Charlie', email: 'charlie@example.com'),
          UsersCompanion.insert(name: 'Alice', email: 'alice@example.com'),
          UsersCompanion.insert(name: 'Bob', email: 'bob@example.com'),
        ]);
      });

      final users = await (db.select(db.users)
            ..orderBy([(u) => OrderingTerm.asc(u.name)]))
          .get();
      expect(users[0].name, 'Alice');
      expect(users[1].name, 'Bob');
      expect(users[2].name, 'Charlie');
    });

    test('supports LIMIT and OFFSET', () async {
      db = TestDatabase();

      await db.batch((batch) {
        batch.insertAll(db.users, [
          UsersCompanion.insert(name: 'User 1', email: 'user1@example.com'),
          UsersCompanion.insert(name: 'User 2', email: 'user2@example.com'),
          UsersCompanion.insert(name: 'User 3', email: 'user3@example.com'),
          UsersCompanion.insert(name: 'User 4', email: 'user4@example.com'),
        ]);
      });

      final limited = await (db.select(db.users)..limit(2)).get();
      expect(limited.length, 2);

      final offset = await (db.select(db.users)
            ..limit(2, offset: 2))
          .get();
      expect(offset.length, 2);
      expect(offset[0].name, 'User 3');
    });

    test('supports JOIN operations', () async {
      db = TestDatabase();

      // Insert user
      final userId = await db.into(db.users).insert(UsersCompanion.insert(
            name: 'John Doe',
            email: 'john@example.com',
          ));

      // Insert posts
      await db.batch((batch) {
        batch.insertAll(db.posts, [
          PostsCompanion.insert(
            userId: userId,
            title: 'Post 1',
            content: 'Content 1',
          ),
          PostsCompanion.insert(
            userId: userId,
            title: 'Post 2',
            content: 'Content 2',
          ),
        ]);
      });

      // Join query
      final query = db.select(db.posts).join([
        innerJoin(db.users, db.users.id.equalsExp(db.posts.userId)),
      ]);

      final results = await query.get();
      expect(results.length, 2);

      for (final row in results) {
        final post = row.readTable(db.posts);
        final user = row.readTable(db.users);
        expect(post.userId, userId);
        expect(user.name, 'John Doe');
      }
    });

    test('enforces unique constraints', () async {
      db = TestDatabase();

      await db.into(db.users).insert(UsersCompanion.insert(
            name: 'John Doe',
            email: 'john@example.com',
          ));

      // Try to insert duplicate email
      expect(
        () => db.into(db.users).insert(UsersCompanion.insert(
              name: 'Jane Doe',
              email: 'john@example.com',
            )),
        throwsA(anything),
      );
    });

    // Note: SQLite doesn't enforce FK constraints by default in memory databases
    // Would need to enable with PRAGMA foreign_keys = ON

    test('can close database connection', () async {
      db = TestDatabase();
      // Should be able to close without errors
      await db.close();
    });
  });

  group('DatabaseConfig', () {
    test('memory config has correct defaults', () {
      final config = DatabaseConfig.memory();
      expect(config.type, DatabaseType.memory);
      expect(config.path, isNull);
      expect(config.postgresConfig, isNull);
    });

    test('sqlite config requires path', () {
      final config = DatabaseConfig.sqlite('/tmp/test.db');
      expect(config.type, DatabaseType.sqlite);
      expect(config.path, '/tmp/test.db');
    });

    test('postgres config requires all fields', () {
      final pgConfig = PostgresConfig(
        host: 'db.example.com',
        port: 5432,
        database: 'myapp',
        username: 'admin',
        password: 'secret',
      );

      expect(pgConfig.host, 'db.example.com');
      expect(pgConfig.port, 5432);
      expect(pgConfig.database, 'myapp');
      expect(pgConfig.username, 'admin');
      expect(pgConfig.password, 'secret');
    });
  });
}
