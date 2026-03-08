class AppConfig {
  static const String appName = 'DartBackend';
  static const int port = 3000;
  static const bool isProduction = false;

  // CORS
  static const List<String> allowOrigins = [
    'http://localhost:8080',
    'http://localhost:5173',
    '*'
  ];
}