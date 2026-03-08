import 'package:alfred/alfred.dart';

class CorsMiddleware {
  static handle(HttpRequest req, HttpResponse res, next) {
    res.headers.add('Access-Control-Allow-Origin', '*');
    res.headers.add('Access-Control-Allow-Methods', 'GET,POST,PUT,DELETE,OPTIONS');
    res.headers.add('Access-Control-Allow-Headers', 'token,Content-Type');
    if (req.method == 'OPTIONS') {
      res.statusCode = 200;
      res.close();
      return;
    }
    next();
  }
}