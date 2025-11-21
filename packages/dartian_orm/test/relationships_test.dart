import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:test/test.dart';
import 'package:dartian_orm/dartian_orm.dart' hide isNull, isNotNull;
import 'test_database.dart';

/// Concrete HasMany implementation for testing
class UserPostsRelation extends HasMany<Post> {
  UserPostsRelation({
    required super.database,
    required super.table,
    required super.foreignKey,
    required super.localKey,
  });

  @override
  Expression<bool> _buildForeignKeyCondition(dynamic tbl) {
    return (tbl as Posts).userId.equals(localKey as int);
  }
}

/// Concrete BelongsTo implementation for testing
class PostUserRelation extends BelongsTo<User> {
  PostUserRelation({
    required super.database,
    required super.table,
    required super.foreignKey,
  });

  @override
  Expression<bool> _buildPrimaryKeyCondition(dynamic tbl) {
    return (tbl as Users).id.equals(foreignKey as int);
  }
}

/// Concrete HasOne implementation for testing
class UserProfileRelation extends HasOne<Profile> {
  UserProfileRelation({
    required super.database,
    required super.table,
    required super.foreignKey,
    required super.localKey,
  });

  @override
  Expression<bool> _buildForeignKeyCondition(dynamic tbl) {
    return (tbl as Profiles).userId.equals(localKey as int);
  }
}

/// Concrete BelongsToMany implementation for testing
class UserRolesRelation extends BelongsToMany<Role> {
  UserRolesRelation({
    required super.database,
    required super.relatedTable,
    required super.pivotTable,
    required super.foreignPivotKey,
    required super.relatedPivotKey,
    required super.localKey,
  });

  @override
  Expression<bool> _buildPivotCondition(dynamic tbl) {
    return (tbl as UserRoles).userId.equals(localKey as int);
  }

  @override
  Expression<bool> _buildRelatedIdsCondition(dynamic tbl, List ids) {
    return (tbl as Roles).id.isIn(ids.cast<int>());
  }

  @override
  dynamic _extractRelatedId(dynamic record) {
    return (record as UserRole).roleId;
  }

  @override
  UpdateCompanion _buildPivotCompanion(dynamic localId, dynamic relatedId) {
    return UserRolesCompanion.insert(
      userId: localId as int,
      roleId: relatedId as int,
    );
  }

  @override
  Expression<bool> _buildPivotDeleteCondition(
      dynamic tbl, dynamic localId, dynamic relatedId) {
    final t = tbl as UserRoles;
    return t.userId.equals(localId as int) & t.roleId.equals(relatedId as int);
  }
}

void main() {
  late TestDatabase db;

  setUp(() async {
    db = TestDatabase();
    await db.customStatement('PRAGMA foreign_keys = ON');
  });

  tearDown(() async {
    await db.close();
  });

  group('HasMany - One-to-many relationship', () {
    test('should get all related records', () async {
      // Insert user
      final userId = await db.into(db.users).insert(
            UsersCompanion.insert(name: 'John', email: 'john@example.com'),
          );

      // Insert posts for user
      await db.batch((batch) {
        batch.insertAll(db.posts, [
          PostsCompanion.insert(
              userId: userId, title: 'Post 1', content: 'Content 1'),
          PostsCompanion.insert(
              userId: userId, title: 'Post 2', content: 'Content 2'),
          PostsCompanion.insert(
              userId: userId, title: 'Post 3', content: 'Content 3'),
        ]);
      });

      final relation = UserPostsRelation(
        database: db,
        table: db.posts,
        foreignKey: 'userId',
        localKey: userId,
      );

      final posts = await relation.get();
      expect(posts.length, equals(3));
      expect(posts[0].title, equals('Post 1'));
      expect(posts[1].title, equals('Post 2'));
      expect(posts[2].title, equals('Post 3'));
    });

    test('should return empty list when no related records', () async {
      final userId = await db.into(db.users).insert(
            UsersCompanion.insert(name: 'Jane', email: 'jane@example.com'),
          );

      final relation = UserPostsRelation(
        database: db,
        table: db.posts,
        foreignKey: 'userId',
        localKey: userId,
      );

      final posts = await relation.get();
      expect(posts.isEmpty, isTrue);
    });
  });

  group('BelongsTo - Many-to-one relationship', () {
    test('should get related record', () async {
      // Insert user
      final userId = await db.into(db.users).insert(
            UsersCompanion.insert(name: 'Author', email: 'author@example.com'),
          );

      // Insert post
      await db.into(db.posts).insert(
            PostsCompanion.insert(
                userId: userId, title: 'My Post', content: 'Content'),
          );

      final relation = PostUserRelation(
        database: db,
        table: db.users,
        foreignKey: userId,
      );

      final user = await relation.get();
      expect(user, isNotNull);
      expect(user!.name, equals('Author'));
      expect(user.email, equals('author@example.com'));
    });

    test('should return null when foreign key is null', () async {
      final relation = PostUserRelation(
        database: db,
        table: db.users,
        foreignKey: null,
      );

      final user = await relation.get();
      expect(user, isNull);
    });

    test('should return null when related record does not exist', () async {
      final relation = PostUserRelation(
        database: db,
        table: db.users,
        foreignKey: 9999,
      );

      final user = await relation.get();
      expect(user, isNull);
    });
  });

  group('HasOne - One-to-one relationship', () {
    test('should get related record', () async {
      // Insert user
      final userId = await db.into(db.users).insert(
            UsersCompanion.insert(name: 'User', email: 'user@example.com'),
          );

      // Insert profile
      await db.into(db.profiles).insert(
            ProfilesCompanion.insert(
              userId: userId,
              bio: Value('Bio text'),
              avatar: Value('avatar.jpg'),
            ),
          );

      final relation = UserProfileRelation(
        database: db,
        table: db.profiles,
        foreignKey: 'userId',
        localKey: userId,
      );

      final profile = await relation.get();
      expect(profile, isNotNull);
      expect(profile!.userId, equals(userId));
      expect(profile.bio, equals('Bio text'));
      expect(profile.avatar, equals('avatar.jpg'));
    });

    test('should return null when no related record', () async {
      final userId = await db.into(db.users).insert(
            UsersCompanion.insert(
                name: 'No Profile', email: 'noprofile@example.com'),
          );

      final relation = UserProfileRelation(
        database: db,
        table: db.profiles,
        foreignKey: 'userId',
        localKey: userId,
      );

      final profile = await relation.get();
      expect(profile, isNull);
    });
  });

  group('BelongsToMany - Many-to-many relationship', () {
    test('should get all related records through pivot', () async {
      // Insert user
      final userId = await db.into(db.users).insert(
            UsersCompanion.insert(name: 'User', email: 'user@example.com'),
          );

      // Insert roles
      final adminRoleId = await db.into(db.roles).insert(
            RolesCompanion.insert(name: 'admin'),
          );
      final editorRoleId = await db.into(db.roles).insert(
            RolesCompanion.insert(name: 'editor'),
          );

      // Create pivot records
      await db.batch((batch) {
        batch.insertAll(db.userRoles, [
          UserRolesCompanion.insert(userId: userId, roleId: adminRoleId),
          UserRolesCompanion.insert(userId: userId, roleId: editorRoleId),
        ]);
      });

      final relation = UserRolesRelation(
        database: db,
        relatedTable: db.roles,
        pivotTable: db.userRoles,
        foreignPivotKey: 'userId',
        relatedPivotKey: 'roleId',
        localKey: userId,
      );

      final roles = await relation.get();
      expect(roles.length, equals(2));
      final roleNames = roles.map((r) => r.name).toList();
      expect(roleNames, containsAll(['admin', 'editor']));
    });

    test('should return empty list when no related records', () async {
      final userId = await db.into(db.users).insert(
            UsersCompanion.insert(
                name: 'No Roles', email: 'noroles@example.com'),
          );

      final relation = UserRolesRelation(
        database: db,
        relatedTable: db.roles,
        pivotTable: db.userRoles,
        foreignPivotKey: 'userId',
        relatedPivotKey: 'roleId',
        localKey: userId,
      );

      final roles = await relation.get();
      expect(roles.isEmpty, isTrue);
    });

    test('attach() should create pivot record', () async {
      final userId = await db.into(db.users).insert(
            UsersCompanion.insert(name: 'User', email: 'user@example.com'),
          );
      final roleId = await db.into(db.roles).insert(
            RolesCompanion.insert(name: 'moderator'),
          );

      final relation = UserRolesRelation(
        database: db,
        relatedTable: db.roles,
        pivotTable: db.userRoles,
        foreignPivotKey: 'userId',
        relatedPivotKey: 'roleId',
        localKey: userId,
      );

      await relation.attach(roleId);

      final pivotRecords = await db.select(db.userRoles).get();
      expect(pivotRecords.length, equals(1));
      expect(pivotRecords.first.userId, equals(userId));
      expect(pivotRecords.first.roleId, equals(roleId));
    });

    test('detach() should delete pivot record', () async {
      final userId = await db.into(db.users).insert(
            UsersCompanion.insert(name: 'User', email: 'user@example.com'),
          );
      final roleId = await db.into(db.roles).insert(
            RolesCompanion.insert(name: 'guest'),
          );

      // Create pivot record
      await db.into(db.userRoles).insert(
            UserRolesCompanion.insert(userId: userId, roleId: roleId),
          );

      final relation = UserRolesRelation(
        database: db,
        relatedTable: db.roles,
        pivotTable: db.userRoles,
        foreignPivotKey: 'userId',
        relatedPivotKey: 'roleId',
        localKey: userId,
      );

      await relation.detach(roleId);

      final pivotRecords = await db.select(db.userRoles).get();
      expect(pivotRecords.isEmpty, isTrue);
    });

    test('sync() should replace all pivot records', () async {
      final userId = await db.into(db.users).insert(
            UsersCompanion.insert(name: 'User', email: 'user@example.com'),
          );

      // Create initial roles
      final role1 = await db.into(db.roles).insert(
            RolesCompanion.insert(name: 'role1'),
          );
      final role2 = await db.into(db.roles).insert(
            RolesCompanion.insert(name: 'role2'),
          );
      final role3 = await db.into(db.roles).insert(
            RolesCompanion.insert(name: 'role3'),
          );

      // Create initial pivot records
      await db.batch((batch) {
        batch.insertAll(db.userRoles, [
          UserRolesCompanion.insert(userId: userId, roleId: role1),
          UserRolesCompanion.insert(userId: userId, roleId: role2),
        ]);
      });

      final relation = UserRolesRelation(
        database: db,
        relatedTable: db.roles,
        pivotTable: db.userRoles,
        foreignPivotKey: 'userId',
        relatedPivotKey: 'roleId',
        localKey: userId,
      );

      // Sync to new roles (role2 and role3)
      await relation.sync([role2, role3]);

      final roles = await relation.get();
      expect(roles.length, equals(2));
      final roleNames = roles.map((r) => r.name).toList();
      expect(roleNames, containsAll(['role2', 'role3']));
      expect(roleNames, isNot(contains('role1')));
    });
  });
}
