import 'dart:io';
import 'package:alfred/alfred.dart';
import '../utils/log_util.dart';

class LogMiddleware {
  static Future handle(HttpRequest req, HttpResponse res, next) async {
    final time = DateTime.now();
    final ip = req.connectionInfo?.remoteAddress.address ?? 'unknown';
    final method = req.method;
    final uri = req.uri.toString();

    await next();

    final cost = DateTime.now().difference(time).inMilliseconds;
    final log = '[${time.toString()}] $ip | $method | $uri | ${res.statusCode} | ${cost}ms';
    LogUtil.info(log);
    print(log);
  }
}