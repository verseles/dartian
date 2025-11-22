import 'dart:math';
import 'package:bcrypt/bcrypt.dart';

/// Password utilities using bcrypt for secure password hashing
///
/// Bcrypt is a password hashing function designed to be slow and computationally
/// expensive, making it resistant to brute-force attacks. It automatically handles
/// salting and uses adaptive hashing to stay secure over time.
class Password {
  /// Default cost factor for bcrypt (10 = 2^10 = 1024 iterations)
  /// Higher values increase security but also computation time
  /// Recommended: 10-12 for production
  static const int defaultCost = 10;

  /// Hash a password using bcrypt
  ///
  /// [password] - The plain text password to hash
  /// [cost] - The cost factor (default: 10). Higher = more secure but slower.
  ///          Recommended range: 10-12 for production
  ///
  /// Returns a bcrypt hash string that includes the salt and cost factor
  static String hash(String password, {int cost = defaultCost}) {
    if (password.isEmpty) {
      throw ArgumentError('Password cannot be empty');
    }

    if (cost < 4 || cost > 31) {
      throw ArgumentError('Cost must be between 4 and 31');
    }

    return BCrypt.hashpw(password, BCrypt.gensalt(logRounds: cost));
  }

  /// Verify a password against a bcrypt hash
  ///
  /// [password] - The plain text password to verify
  /// [hashedPassword] - The bcrypt hash to verify against
  ///
  /// Returns true if the password matches the hash, false otherwise
  ///
  /// Uses constant-time comparison internally to prevent timing attacks
  static bool verify(String password, String hashedPassword) {
    if (password.isEmpty || hashedPassword.isEmpty) {
      return false;
    }

    try {
      return BCrypt.checkpw(password, hashedPassword);
    } catch (e) {
      // Invalid hash format or other bcrypt error
      return false;
    }
  }

  /// Check if a hash needs to be rehashed (cost factor changed)
  ///
  /// This is useful for upgrading password security when increasing the cost factor
  ///
  /// [hashedPassword] - The bcrypt hash to check
  /// [targetCost] - The desired cost factor
  ///
  /// Returns true if the hash should be regenerated with the new cost
  static bool needsRehash(
    String hashedPassword, {
    int targetCost = defaultCost,
  }) {
    try {
      // Bcrypt hash format: $2a$10$...
      // Extract cost from hash
      final parts = hashedPassword.split('\$');
      if (parts.length < 3) return true;

      final currentCost = int.tryParse(parts[2]);
      if (currentCost == null) return true;

      return currentCost != targetCost;
    } catch (e) {
      return true;
    }
  }

  /// Generate a random secure password
  ///
  /// [length] - Length of the generated password (default: 16)
  /// [includeSymbols] - Whether to include special characters (default: true)
  ///
  /// Returns a cryptographically secure random password
  static String generate({int length = 16, bool includeSymbols = true}) {
    if (length < 8) {
      throw ArgumentError('Password length must be at least 8 characters');
    }

    final chars = includeSymbols
        ? 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()-_=+[]{}|;:,.<>?'
        : 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    final random = Random.secure();
    return String.fromCharCodes(
      Iterable<int>.generate(
        length,
        (index) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }
}
