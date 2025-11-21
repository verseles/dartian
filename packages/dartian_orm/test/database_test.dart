import 'package:test/test.dart';
import 'package:dartian_orm/dartian_orm.dart' hide isNull, isNotNull;

void main() {
  group('DatabaseManager', () {
    test('should create in-memory database', () {
      final dbManager = DatabaseManager.instance;
      final db = dbManager.inMemoryDatabase();

      expect(db, isNotNull);
      expect(db, isA<QueryDatabase>());

      db.close();
    });

    test('should create SQLite database connection', () {
      final dbManager = DatabaseManager.instance;
      // Use a temp directory for testing
      final db = dbManager.sqliteDatabase('test_db');

      expect(db, isNotNull);
      expect(db, isA<QueryDatabase>());

      db.close();
    });
  });

  group('QueryDatabase', () {
    late QueryDatabase db;

    setUp(() {
      db = DatabaseManager.instance.inMemoryDatabase();
      // Create a test table
      db.execute(
        'CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT, email TEXT)',
        [],
      );
    });

    tearDown(() {
      db.close();
    });

    test('should execute SELECT query and return results', () {
      // Insert test data
      db.execute(
        'INSERT INTO users (name, email) VALUES (?, ?)',
        ['John Doe', 'john@example.com'],
      );

      // Query the data
      final results = db.query(
        'SELECT * FROM users WHERE name = ?',
        ['John Doe'],
      );

      expect(results, isNotEmpty);
      expect(results.length, 1);
      expect(results.first['name'], 'John Doe');
      expect(results.first['email'], 'john@example.com');
    });

    test('should execute INSERT/UPDATE/DELETE commands', () {
      // Test INSERT
      final insertResult = db.execute(
        'INSERT INTO users (name, email) VALUES (?, ?)',
        ['Jane Doe', 'jane@example.com'],
      );
      expect(insertResult, greaterThan(0));

      // Test UPDATE
      final updateResult = db.execute(
        'UPDATE users SET email = ? WHERE name = ?',
        ['jane.doe@example.com', 'Jane Doe'],
      );
      expect(updateResult, greaterThan(0));

      // Test DELETE
      final deleteResult = db.execute(
        'DELETE FROM users WHERE name = ?',
        ['Jane Doe'],
      );
      expect(deleteResult, greaterThan(0));
    });

    test('should execute querySingle and return single value', () {
      // Insert test data
      db.execute(
        'INSERT INTO users (name, email) VALUES (?, ?)',
        ['Count Test', 'count@example.com'],
      );

      // Query single value
      final count = db.querySingle<int>(
        'SELECT COUNT(*) FROM users',
        [],
      );

      expect(count, isA<int>());
      expect(count, greaterThan(0));
    });

    test('should throw exception when querySingle finds no results', () {
      expect(
        () => db.querySingle<int>('SELECT * FROM users WHERE id = ?', [9999]),
        throwsA(isA<Exception>()),
      );
    });

    test('should check if table exists', () {
      final exists = db.tableExists('users');
      expect(exists, isTrue);

      final notExists = db.tableExists('nonexistent');
      expect(notExists, isFalse);
    });

    test('should handle parameterized queries safely', () {
      // Test with special characters
      db.execute(
        'INSERT INTO users (name, email) VALUES (?, ?)',
        ['O\'Brien', 'obrien@example.com'],
      );

      final results = db.query(
        'SELECT * FROM users WHERE name = ?',
        ['O\'Brien'],
      );

      expect(results, isNotEmpty);
      expect(results.first['name'], 'O\'Brien');
    });

    test('should query with LIMIT only', () {
      // Insert multiple test records
      for (var i = 1; i <= 5; i++) {
        db.execute(
          'INSERT INTO users (name, email) VALUES (?, ?)',
          ['User$i', 'user$i@example.com'],
        );
      }

      // Query with limit only
      final results = db.query(
        'SELECT * FROM users',
        [],
        limit: 3,
      );

      expect(results.length, 3);
    });

    test('should query with LIMIT and OFFSET', () {
      // Insert multiple test records
      for (var i = 1; i <= 5; i++) {
        db.execute(
          'INSERT INTO users (name, email) VALUES (?, ?)',
          ['Paged$i', 'paged$i@example.com'],
        );
      }

      // Query with limit and offset
      final results = db.query(
        'SELECT * FROM users WHERE name LIKE ?',
        ['Paged%'],
        limit: 2,
        offset: 2,
      );

      expect(results.length, 2);
      // With OFFSET 2, we skip first 2 results
      expect(results.first['name'], 'Paged3');
    });
  });
}
