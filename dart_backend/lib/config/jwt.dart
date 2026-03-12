import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'app_config.dart';

class JwtUtil {
  static String sign(int userId, String username) {
    return JWT({
      'userId': userId,
      'username': username,
      'type': 'access',
      'exp': DateTime.now().add(Duration(seconds: AppConfig.jwtExpires)).millisecondsSinceEpoch ~/ 1000,
    }).sign(SecretKey(AppConfig.jwtSecret));
  }

  static String signRefresh(int userId, String username) {
    return JWT({
      'userId': userId,
      'username': username,
      'type': 'refresh',
      'exp': DateTime.now().add(Duration(seconds: AppConfig.refreshExpires)).millisecondsSinceEpoch ~/ 1000,
    }).sign(SecretKey(AppConfig.jwtSecret));
  }

  static Map? verify(String token) {
    try {
      final d = JWT.verify(token, SecretKey(AppConfig.jwtSecret));
      return d.payload;
    } catch (_) {
      return null;
    }
  }

  static Map? verifyRefresh(String token) {
    try {
      final d = JWT.verify(token, SecretKey(AppConfig.jwtSecret));
      return d.payload;
    } catch (_) {
      return null;
    }
  }
}