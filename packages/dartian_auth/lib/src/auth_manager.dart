import 'package:dartian_core/dartian_core.dart';
import 'jwt.dart';
import 'password.dart';
import 'session.dart';

/// Authentication manager
class AuthManager {
  final String jwtSecret;
  final Duration sessionDuration;
  final Duration jwtDuration;

  AuthManager({
    required this.jwtSecret,
    this.sessionDuration = const Duration(hours: 24),
    this.jwtDuration = const Duration(hours: 1),
  });

  /// Register a new user
  Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // In a real implementation, this would save to database
      // For now, we'll just validate and return success

      // Validate input
      if (username.isEmpty) {
        return AuthResult.error('Username is required');
      }

      if (email.isEmpty || !email.contains('@')) {
        return AuthResult.error('Valid email is required');
      }

      if (password.length < 8) {
        return AuthResult.error('Password must be at least 8 characters');
      }

      // Hash password
      final hashedPassword = Password.hash(password);

      // Create user data
      final userData = {
        'id': generateId(),
        'username': username,
        'email': email,
        'password': hashedPassword,
        'created_at': DateTime.now().toIso8601String(),
      };

      // In real implementation, save to database here

      return AuthResult.success(
        message: 'User registered successfully',
        user: userData,
      );
    } catch (e) {
      return AuthResult.error('Registration failed: ${e.toString()}');
    }
  }

  /// Login user
  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    try {
      // In a real implementation, this would query the database
      // For now, we'll simulate authentication

      if (username.isEmpty || password.isEmpty) {
        return AuthResult.error('Username and password are required');
      }

      // Simulate user lookup (in real app, this would be a database query)
      final userData = await _findUserByUsername(username);

      if (userData == null) {
        return AuthResult.error('Invalid credentials');
      }

      final storedPassword = userData['password'] as String;

      // Verify password
      if (!Password.verify(password, storedPassword)) {
        return AuthResult.error('Invalid credentials');
      }

      // Create session
      final session = Session.create(userData['id'] as String, sessionDuration);

      // Create JWT token
      final jwt = JWT.create(
        {
          'id': userData['id'],
          'username': userData['username'],
          'email': userData['email'],
        },
        secret: jwtSecret,
        expiresIn: jwtDuration,
      );

      return AuthResult.success(
        message: 'Login successful',
        user: userData,
        session: session,
        token: jwt.token,
      );
    } catch (e) {
      return AuthResult.error('Login failed: ${e.toString()}');
    }
  }

  /// Logout user
  Future<AuthResult> logout(String sessionId) async {
    try {
      // In a real implementation, this would invalidate the session
      // For now, just return success

      return AuthResult.success(message: 'Logout successful');
    } catch (e) {
      return AuthResult.error('Logout failed: ${e.toString()}');
    }
  }

  /// Refresh JWT token
  Future<AuthResult> refreshToken(String token) async {
    try {
      // Verify existing token
      final jwt = JWT.verify(token, secret: jwtSecret);

      if (jwt == null) {
        return AuthResult.error('Invalid token');
      }

      // Create a copy of the payload and remove 'iat' so it gets regenerated
      final payloadCopy = Map<String, dynamic>.from(jwt.payload);
      payloadCopy.remove('iat');

      // Create new token with updated expiration
      final newJwt = JWT.create(
        payloadCopy,
        secret: jwtSecret,
        expiresIn: jwtDuration,
      );

      return AuthResult.success(
        message: 'Token refreshed',
        token: newJwt.token,
      );
    } catch (e) {
      return AuthResult.error('Token refresh failed: ${e.toString()}');
    }
  }

  /// Change password
  Future<AuthResult> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // In a real implementation, this would update the database
      // For now, we'll simulate the process

      if (newPassword.length < 8) {
        return AuthResult.error('New password must be at least 8 characters');
      }

      // Get user data
      final userData = await _findUserById(userId);

      if (userData == null) {
        return AuthResult.error('User not found');
      }

      // Verify current password
      final storedPassword = userData['password'] as String;

      if (!Password.verify(currentPassword, storedPassword)) {
        return AuthResult.error('Current password is incorrect');
      }

      // In real implementation, hash new password and save to database here
      // final newHashedPassword = Password.hash(newPassword);

      // In real implementation, save to database here

      return AuthResult.success(message: 'Password changed successfully');
    } catch (e) {
      return AuthResult.error('Password change failed: ${e.toString()}');
    }
  }

  /// Generate password reset token
  Future<AuthResult> generatePasswordResetToken(String email) async {
    try {
      if (email.isEmpty || !email.contains('@')) {
        return AuthResult.error('Valid email is required');
      }

      // In a real implementation, this would send an email
      // For now, we'll just generate a token

      final resetToken = Password.generate(length: 32);

      return AuthResult.success(
        message: 'Password reset token generated',
        data: {'reset_token': resetToken},
      );
    } catch (e) {
      return AuthResult.error('Token generation failed: ${e.toString()}');
    }
  }

  /// Reset password with token
  Future<AuthResult> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      if (newPassword.length < 8) {
        return AuthResult.error('New password must be at least 8 characters');
      }

      // In a real implementation, this would verify the token and update the password
      // For now, we'll just return success

      return AuthResult.success(message: 'Password reset successful');
    } catch (e) {
      return AuthResult.error('Password reset failed: ${e.toString()}');
    }
  }

  /// Find user by username (simulated)
  Future<Map<String, dynamic>?> _findUserByUsername(String username) async {
    // In a real implementation, this would query the database
    // For now, return a mock user
    return {
      'id': 'user_123',
      'username': username,
      'email': '$username@example.com',
      'password': Password.hash('password123'),
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// Find user by ID (simulated)
  Future<Map<String, dynamic>?> _findUserById(String userId) async {
    // In a real implementation, this would query the database
    // For now, return a mock user
    return {
      'id': userId,
      'username': 'user_$userId',
      'email': 'user$userId@example.com',
      'password': Password.hash('password123'),
      'created_at': DateTime.now().toIso8601String(),
    };
  }
}

/// Authentication result
class AuthResult {
  final bool success;
  final String? message;
  final Map<String, dynamic>? user;
  final Session? session;
  final String? token;
  final Map<String, dynamic>? data;

  AuthResult({
    required this.success,
    this.message,
    this.user,
    this.session,
    this.token,
    this.data,
  });

  factory AuthResult.success({
    String? message,
    Map<String, dynamic>? user,
    Session? session,
    String? token,
    Map<String, dynamic>? data,
  }) {
    return AuthResult(
      success: true,
      message: message,
      user: user,
      session: session,
      token: token,
      data: data,
    );
  }

  factory AuthResult.error(String error) {
    return AuthResult(success: false, message: error);
  }
}
