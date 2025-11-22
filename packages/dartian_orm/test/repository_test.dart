import 'package:test/test.dart';
import 'package:dartian_orm/dartian_orm.dart' hide isNull, isNotNull;

class User {
  final int? id;
  final String name;
  final String email;

  User({this.id, required this.name, required this.email});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as int?,
    name: json['name'] as String,
    email: json['email'] as String,
  );
}

void main() {
  group('GenericRepository', () {
    late QueryDatabase db;
    late GenericRepository<User> repository;

    setUp(() {
      db = DatabaseManager.instance.inMemoryDatabase();
      db.execute(
        'CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, email TEXT)',
        [],
      );

      repository = GenericRepository<User>(
        db,
        'users',
        (user) => user.toJson(),
        (json) => User.fromJson(json),
      );
    });

    tearDown(() {
      db.close();
    });

    test('should insert a user', () {
      final user = User(name: 'John Doe', email: 'john@example.com');
      final result = repository.insert(user);

      expect(result, isNotNull);
      expect(result.name, 'John Doe');
      expect(result.email, 'john@example.com');
    });

    test('should find all users', () {
      // Insert test users
      db.execute('INSERT INTO users (name, email) VALUES (?, ?)', [
        'User 1',
        'user1@example.com',
      ]);
      db.execute('INSERT INTO users (name, email) VALUES (?, ?)', [
        'User 2',
        'user2@example.com',
      ]);

      final users = repository.findAll();

      expect(users, isNotEmpty);
      expect(users.length, 2);
    });

    test('should find user by ID', () {
      // Insert a user
      db.execute('INSERT INTO users (name, email) VALUES (?, ?)', [
        'Find Me',
        'find@example.com',
      ]);
      final results = db.query('SELECT * FROM users', []);
      final userId = results.first['id'] as int;

      final user = repository.findById(userId);

      expect(user, isNotNull);
      expect(user?.name, 'Find Me');
      expect(user?.email, 'find@example.com');
    });

    test('should return null when user not found by ID', () {
      final user = repository.findById(9999);

      expect(user, isNull);
    });

    test('should update a user', () {
      // Insert a user
      db.execute('INSERT INTO users (name, email) VALUES (?, ?)', [
        'Original',
        'original@example.com',
      ]);
      final results = db.query('SELECT * FROM users', []);
      final userId = results.first['id'] as int;

      // Update the user
      final updatedUser = User(
        id: userId,
        name: 'Updated',
        email: 'updated@example.com',
      );
      repository.update(updatedUser);

      // Verify the update
      final user = repository.findById(userId);
      expect(user, isNotNull);
      expect(user?.name, 'Updated');
      expect(user?.email, 'updated@example.com');
    });

    test('should delete a user', () {
      // Insert a user
      db.execute('INSERT INTO users (name, email) VALUES (?, ?)', [
        'To Delete',
        'delete@example.com',
      ]);
      final results = db.query('SELECT * FROM users', []);
      final userId = results.first['id'] as int;

      // Delete the user
      repository.delete(userId);

      // Verify deletion
      final user = repository.findById(userId);
      expect(user, isNull);
    });

    test('should count all users', () {
      // Insert test users
      db.execute('INSERT INTO users (name, email) VALUES (?, ?)', [
        'User 1',
        'user1@example.com',
      ]);
      db.execute('INSERT INTO users (name, email) VALUES (?, ?)', [
        'User 2',
        'user2@example.com',
      ]);
      db.execute('INSERT INTO users (name, email) VALUES (?, ?)', [
        'User 3',
        'user3@example.com',
      ]);

      final count = repository.count();

      expect(count, equals(3));
    });

    test('should return 0 count when table is empty', () {
      final count = repository.count();

      expect(count, equals(0));
    });
  });
}
