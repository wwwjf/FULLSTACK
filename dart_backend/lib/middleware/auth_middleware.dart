import 'package:alfred/alfred.dart';
import '../config/jwt.dart';
import '../utils/result.dart';

class AuthMiddleware {
  static Future<void> handle(HttpRequest req, HttpResponse res, next) async {
    final token = req.headers.value('token');
    if (token == null) {
      res.json(ApiResult.unauthorized());
      return;
    }

    final payload = JwtUtil.verify(token);
    if (payload == null) {
      res.json(ApiResult.unauthorized());
      return;
    }

    req.store.set('userId', payload['userId']);
    req.store.set('username', payload['username']);
    await next();
  }


  Future<void> authMiddleware(req, res) async {
    final token = req.headers.value('token');
    if (token == null || JwtUtil.verify(token) == null) {
      await res.json(ApiResult.unauthorized());
      return;
    }
    await req.next();
  }
}