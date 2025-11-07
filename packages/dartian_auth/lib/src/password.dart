import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Password utilities
class Password {
  /// Hash a password using SHA-256
  static String hash(String password, {String? salt}) {
    final saltStr = salt ?? _generateSalt();
    final bytes = utf8.encode(password + saltStr);
    final digest = sha256.convert(bytes);
    return '$saltStr:${digest.toString()}';
  }

  /// Verify a password
  static bool verify(String password, String hashedPassword) {
    final parts = hashedPassword.split(':');
    if (parts.length != 2) return false;

    final salt = parts[0];
    final hash = parts[1];

    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    final computedHash = digest.toString();

    return hash == computedHash;
  }

  /// Generate a random salt
  static String _generateSalt([int length = 32]) {
    final random = Random.secure();
    final values = Uint8List.fromList(List<int>.generate(length, (index) => random.nextInt(256)));
    return base64Encode(values);
  }

  /// Generate a random password
  static String generate({int length = 12}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable<int>.generate(length, (index) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
}
