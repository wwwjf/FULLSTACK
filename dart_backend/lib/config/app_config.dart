class AppConfig {
  static const String host = '0.0.0.0';
  static const int port = 8080;

  static const String jwtSecret = 'dart_admin_secret_2026';
  static const int jwtExpires = 7200;
  static const int refreshExpires = 604800;

  static const String redisHost = 'localhost';
  static const int redisPort = 6379;
  static const String redisPassword = '';
  static const int redisDb = 0;

  static const int maxUploadSize = 10 * 1024 * 1024;
  static const List<String> allowedExt = ['.png', '.jpg', '.jpeg', '.gif', '.webp'];
}