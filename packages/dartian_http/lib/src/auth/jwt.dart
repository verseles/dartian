import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JsonWebToken {
  final String _secret;

  JsonWebToken(this._secret);

  String generate(Map<String, dynamic> payload, {Duration? expiresIn}) {
    final jwt = JWT(payload);
    return jwt.sign(SecretKey(_secret), expiresIn: expiresIn);
  }

  Map<String, dynamic>? verify(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_secret));
      return jwt.payload as Map<String, dynamic>;
    } on JWTExpiredException {
      // Handle expired token
      return null;
    } on JWTException catch (e) {
      // Handle other JWT errors
      print(e.message);
      return null;
    }
  }
}
