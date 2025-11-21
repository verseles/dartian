import 'dart:convert';
import 'package:crypto/crypto.dart';

/// JWT token
class JWT {
  final String token;
  final Map<String, dynamic> payload;
  final String? signature;
  final DateTime? issuedAt;
  final DateTime? expiresAt;

  JWT({
    required this.token,
    required this.payload,
    this.signature,
    this.issuedAt,
    this.expiresAt,
  });

  /// Create a JWT token
  static JWT create(Map<String, dynamic> payload, {String? secret, Duration? expiresIn}) {
    final now = DateTime.now();
    final headerMap = {
      'alg': 'HS256',
      'typ': 'JWT',
    };

    // Create a copy of the payload to avoid mutation
    final payloadCopy = Map<String, dynamic>.from(payload);

    // Add issued at
    if (payloadCopy['iat'] == null) {
      payloadCopy['iat'] = (now.millisecondsSinceEpoch / 1000).round();
    }

    // Add expiration
    if (expiresIn != null) {
      payloadCopy['exp'] = (now.add(expiresIn).millisecondsSinceEpoch / 1000).round();
    }

    final headerBase64 = _base64Encode(jsonEncode(headerMap));
    final payloadBase64 = _base64Encode(jsonEncode(payloadCopy));
    final signingInput = '$headerBase64.$payloadBase64';

    String? signature;
    if (secret != null) {
      final key = utf8.encode(secret);
      final bytes = utf8.encode(signingInput);
      final hmac = Hmac(sha256, key);
      final digest = hmac.convert(bytes);
      signature = _base64UrlEncode(digest.bytes);
    }

    final token = '$signingInput.${signature ?? ''}';
    return JWT(
      token: token,
      payload: payloadCopy,
      signature: signature,
      issuedAt: now,
      expiresAt: payloadCopy['exp'] != null ? DateTime.fromMillisecondsSinceEpoch(payloadCopy['exp'] * 1000) : null,
    );
  }

  /// Verify a JWT token
  static JWT? verify(String token, {String? secret}) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // final header = jsonDecode(utf8.decode(_base64Decode(parts[0])));
      final payload = jsonDecode(utf8.decode(_base64Decode(parts[1])));
      final signature = parts[2];

      // Verify signature if secret is provided
      if (secret != null) {
        final signingInput = '${parts[0]}.${parts[1]}';
        final key = utf8.encode(secret);
        final bytes = utf8.encode(signingInput);
        final hmac = Hmac(sha256, key);
        final digest = hmac.convert(bytes);
        final expectedSignature = _base64UrlEncode(digest.bytes);

        if (expectedSignature != signature) {
          return null;
        }
      }

      // Check expiration
      final exp = payload['exp'] as int?;
      if (exp != null) {
        final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        // Use isAfter OR equals for edge case when expiry equals now
        final now = DateTime.now();
        if (now.isAfter(expiry) || now.millisecondsSinceEpoch >= expiry.millisecondsSinceEpoch) {
          return null;
        }
      }

      return JWT(
        token: token,
        payload: payload,
        signature: signature,
        issuedAt: payload['iat'] != null ? DateTime.fromMillisecondsSinceEpoch(payload['iat'] * 1000) : null,
        expiresAt: exp != null ? DateTime.fromMillisecondsSinceEpoch(exp * 1000) : null,
      );
    } catch (e) {
      return null;
    }
  }

  /// Base64 encode
  static String _base64Encode(String input) {
    return base64Encode(utf8.encode(input));
  }

  /// Base64 URL encode
  static String _base64UrlEncode(List<int> input) {
    return base64UrlEncode(input).replaceAll('=', '');
  }

  /// Base64 decode
  static List<int> _base64Decode(String input) {
    // Add padding if needed
    var str = input;
    if (input.length % 4 != 0) {
      str += '=' * (4 - input.length % 4);
    }
    return base64Decode(str);
  }
}
