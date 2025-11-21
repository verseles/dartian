import 'package:test/test.dart';
import 'package:dartian_auth/dartian_auth.dart';

void main() {
  group('Password', () {
    test('should hash password with bcrypt', () {
      final password = 'mypassword123';
      final hashed = Password.hash(password);

      expect(hashed, isNotEmpty);
      // Bcrypt format: $2a$10$...
      expect(hashed, startsWith('\$2a\$'));
      expect(hashed.length, greaterThan(50));
    });

    test('should verify correct password', () {
      const password = 'mypassword123';
      final hashed = Password.hash(password);

      final result = Password.verify(password, hashed);

      expect(result, isTrue);
    });

    test('should reject wrong password', () {
      const correctPassword = 'mypassword123';
      const wrongPassword = 'wrongpassword';
      final hashed = Password.hash(correctPassword);

      final result = Password.verify(wrongPassword, hashed);

      expect(result, isFalse);
    });

    test('should generate random password', () {
      final password1 = Password.generate();
      final password2 = Password.generate();

      expect(password1, isNotEmpty);
      expect(password2, isNotEmpty);
      expect(password1, isNot(equals(password2)));
      expect(password1.length, equals(16)); // Changed default from 12 to 16
    });

    test('should generate password with custom length', () {
      final password = Password.generate(length: 20);

      expect(password.length, equals(20));
    });

    test('should detect if hash needs rehashing', () {
      const password = 'testpassword';
      final hash10 = Password.hash(password, cost: 10);
      final hash12 = Password.hash(password, cost: 12);

      expect(Password.needsRehash(hash10, targetCost: 12), isTrue);
      expect(Password.needsRehash(hash12, targetCost: 12), isFalse);
    });

    test('should throw on empty password', () {
      expect(() => Password.hash(''), throwsArgumentError);
    });

    test('should throw on invalid cost', () {
      expect(() => Password.hash('test', cost: 3), throwsArgumentError);
      expect(() => Password.hash('test', cost: 32), throwsArgumentError);
    });
  });

  group('JWT', () {
    test('should create JWT token', () {
      const secret = 'mysecret';
      final payload = {'id': 'user1', 'username': 'testuser'};

      final jwt = JWT.create(payload, secret: secret);

      expect(jwt.token, isNotEmpty);
      expect(jwt.payload['id'], equals('user1'));
      expect(jwt.payload['username'], equals('testuser'));
      expect(jwt.payload['iat'], isNotNull);
      expect(jwt.signature, isNotNull);
    });

    test('should verify valid JWT token', () {
      const secret = 'mysecret';
      final payload = {'id': 'user1', 'username': 'testuser'};

      final jwt = JWT.create(payload, secret: secret);
      final result = JWT.verify(jwt.token, secret: secret);

      expect(result, isNotNull);
      expect(result!.payload['id'], equals('user1'));
      expect(result.payload['username'], equals('testuser'));
    });

    test('should reject invalid JWT token', () {
      const secret1 = 'secret1';
      const secret2 = 'secret2';
      final payload = {'id': 'user1'};

      final jwt = JWT.create(payload, secret: secret1);
      final result = JWT.verify(jwt.token, secret: secret2);

      expect(result, isNull);
    });

    test('should reject expired JWT token', () {
      const secret = 'mysecret';
      final payload = {'id': 'user1'};

      // Use a duration that is definitely in the past (1 day)
      final jwt = JWT.create(payload, secret: secret, expiresIn: Duration(days: -1));
      final result = JWT.verify(jwt.token, secret: secret);

      expect(result, isNull);
    });

    test('should decode JWT without signature', () {
      final payload = {'id': 'user1', 'username': 'testuser'};

      final jwt = JWT.create(payload);
      final result = JWT.verify(jwt.token);

      expect(result, isNotNull);
      expect(result!.payload['id'], equals('user1'));
      expect(result.payload['username'], equals('testuser'));
    });
  });

  group('Session', () {
    test('should create session', () {
      const userId = 'user1';
      const duration = Duration(hours: 1);

      final session = Session.create(userId, duration);

      expect(session.id, isNotEmpty);
      expect(session.userId, equals(userId));
      expect(session.isExpired, isFalse);
    });

    test('should detect expired session', () {
      const userId = 'user1';
      const duration = Duration(milliseconds: -100);

      final session = Session.create(userId, duration);

      expect(session.isExpired, isTrue);
    });

    test('should get remaining time', () {
      const userId = 'user1';
      const duration = Duration(hours: 1);

      final session = Session.create(userId, duration);
      final remaining = session.remainingTime;

      expect(remaining, isA<Duration>());
      // Check that remaining time is approximately 1 hour (allowing for a small delay)
      expect(remaining.inHours, greaterThanOrEqualTo(0));
      expect(remaining.inHours, lessThanOrEqualTo(1));
    });

    test('should convert to JSON', () {
      final session = Session.create('user1', Duration(hours: 1));
      final json = session.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json['id'], isNotNull);
      expect(json['userId'], equals('user1'));
      expect(json['createdAt'], isNotNull);
      expect(json['expiresAt'], isNotNull);
    });

    test('should create from JSON', () {
      final now = DateTime.now();
      final json = {
        'id': 'session1',
        'userId': 'user1',
        'createdAt': now.toIso8601String(),
        'expiresAt': now.add(Duration(hours: 1)).toIso8601String(),
        'data': {},
      };

      final session = Session.fromJson(json);

      expect(session.id, equals('session1'));
      expect(session.userId, equals('user1'));
    });
  });

  group('AuthManager', () {
    late AuthManager authManager;

    setUp(() {
      authManager = AuthManager(
        jwtSecret: 'testsecret',
        sessionDuration: Duration(hours: 24),
        jwtDuration: Duration(hours: 1),
      );
    });

    test('should register user successfully', () async {
      final result = await authManager.register(
        username: 'testuser',
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result.success, isTrue);
      expect(result.message, equals('User registered successfully'));
      expect(result.user, isNotNull);
      expect(result.user!['username'], equals('testuser'));
    });

    test('should reject registration with empty username', () async {
      final result = await authManager.register(
        username: '',
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result.success, isFalse);
      expect(result.message, contains('Username is required'));
    });

    test('should reject registration with invalid email', () async {
      final result = await authManager.register(
        username: 'testuser',
        email: 'invalidemail',
        password: 'password123',
      );

      expect(result.success, isFalse);
      expect(result.message, contains('Valid email is required'));
    });

    test('should reject registration with weak password', () async {
      final result = await authManager.register(
        username: 'testuser',
        email: 'test@example.com',
        password: 'short',
      );

      expect(result.success, isFalse);
      expect(result.message, contains('Password must be at least 8 characters'));
    });

    test('should login user successfully', () async {
      final result = await authManager.login(
        username: 'testuser',
        password: 'password123',
      );

      expect(result.success, isTrue);
      expect(result.message, equals('Login successful'));
      expect(result.session, isNotNull);
      expect(result.token, isNotNull);
    });

    test('should reject login with empty credentials', () async {
      final result = await authManager.login(
        username: '',
        password: '',
      );

      expect(result.success, isFalse);
      expect(result.message, contains('Username and password are required'));
    });

    test('should reject login with invalid credentials', () async {
      final result = await authManager.login(
        username: 'wronguser',
        password: 'wrongpassword',
      );

      expect(result.success, isFalse);
      expect(result.message, contains('Invalid credentials'));
    });

    test('should logout user', () async {
      final result = await authManager.logout('session1');

      expect(result.success, isTrue);
      expect(result.message, equals('Logout successful'));
    });

    test('should refresh token', () async {
      // First, create a token
      final loginResult = await authManager.login(
        username: 'testuser',
        password: 'password123',
      );

      expect(loginResult.success, isTrue);

      // Wait a tiny bit to ensure different timestamps
      await Future.delayed(Duration(milliseconds: 10));

      // Then refresh it
      final result = await authManager.refreshToken(loginResult.token!);

      expect(result.success, isTrue);
      expect(result.message, equals('Token refreshed'));
      expect(result.token, isNotNull);
      expect(result.token, isNot(equals(loginResult.token)));

      // Verify the new token is valid
      final newJwt = JWT.verify(result.token!, secret: 'testsecret');
      expect(newJwt, isNotNull);
    });

    test('should change password', () async {
      final result = await authManager.changePassword(
        userId: 'user1',
        currentPassword: 'password123',
        newPassword: 'newpassword123',
      );

      expect(result.success, isTrue);
      expect(result.message, equals('Password changed successfully'));
    });

    test('should reject password change with weak new password', () async {
      final result = await authManager.changePassword(
        userId: 'user1',
        currentPassword: 'password123',
        newPassword: 'short',
      );

      expect(result.success, isFalse);
      expect(result.message, contains('New password must be at least 8 characters'));
    });

    test('should reject password change with wrong current password', () async {
      final result = await authManager.changePassword(
        userId: 'user1',
        currentPassword: 'wrongpassword',
        newPassword: 'newpassword123',
      );

      expect(result.success, isFalse);
      expect(result.message, contains('Current password is incorrect'));
    });

    test('should generate password reset token', () async {
      final result = await authManager.generatePasswordResetToken('test@example.com');

      expect(result.success, isTrue);
      expect(result.message, contains('Password reset token generated'));
      expect(result.data, isNotNull);
      expect(result.data!['reset_token'], isNotNull);
    });

    test('should reject password reset token for invalid email', () async {
      final result = await authManager.generatePasswordResetToken('invalidemail');

      expect(result.success, isFalse);
      expect(result.message, contains('Valid email is required'));
    });

    test('should reject refresh with invalid token', () async {
      final result = await authManager.refreshToken('invalid-token');

      expect(result.success, isFalse);
      expect(result.message, contains('Invalid token'));
    });

    test('should reset password', () async {
      final result = await authManager.resetPassword(
        email: 'test@example.com',
        resetToken: 'reset123',
        newPassword: 'newpassword123',
      );

      expect(result.success, isTrue);
      expect(result.message, equals('Password reset successful'));
    });

    test('should reject reset password with weak password', () async {
      final result = await authManager.resetPassword(
        email: 'test@example.com',
        resetToken: 'reset123',
        newPassword: 'short',
      );

      expect(result.success, isFalse);
      expect(result.message, contains('New password must be at least 8 characters'));
    });
  });

  group('AuthResult', () {
    test('should create success result', () {
      final result = AuthResult.success(
        message: 'Test message',
        user: {'id': 'user1'},
        token: 'token123',
      );

      expect(result.success, isTrue);
      expect(result.message, equals('Test message'));
      expect(result.user, isNotNull);
      expect(result.token, equals('token123'));
    });

    test('should create error result', () {
      final result = AuthResult.error('Error message');

      expect(result.success, isFalse);
      expect(result.message, equals('Error message'));
    });
  });
}
