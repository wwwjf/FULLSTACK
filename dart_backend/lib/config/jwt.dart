import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

const jwtSecret = 'dart_backend_2026_secret_key_20260307';
const jwtRefreshSecret = 'dart_refresh_secret_key_20260307';

class JwtUtil {
  // 访问Token 2小时
  static String sign(int userId, String username) {
    final jwt = JWT({
      'userId': userId,
      'username': username,
    });
    return jwt.sign(SecretKey(jwtSecret), expiresIn: Duration(hours: 2));
  }

  // 刷新Token 7天
  static String signRefresh(int userId, String username) {
    final jwt = JWT({
      'userId': userId,
      'username': username,
    });
    return jwt.sign(SecretKey(jwtRefreshSecret), expiresIn: Duration(days: 7));
  }

  static Map<String, dynamic>? verify(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(jwtSecret));
      return jwt.payload;
    } catch (e) {
      return null;
    }
  }

  static Map<String, dynamic>? verifyRefresh(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(jwtRefreshSecret));
      return jwt.payload;
    } catch (e) {
      return null;
    }
  }
}