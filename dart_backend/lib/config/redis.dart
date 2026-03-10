import 'package:redis/redis.dart';

class RedisConfig {
  static Future<Command> connect() async {
    return await RedisConnection().connect('127.0.0.1', 6379);
  }
}