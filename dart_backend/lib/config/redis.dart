import 'package:redis/redis.dart';

class RedisConfig {
  static Future<Command> connect() async {
    final conn = await RedisConnection().connect('127.0.0.1', 6379);
    final Command cmd = Command(conn);
    return cmd;
  }
}