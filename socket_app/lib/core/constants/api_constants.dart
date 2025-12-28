class ApiConstants {
  ApiConstants._();

  static const String wsUrl = 'wss://echo.websocket.org';
  static const String baseUrl = "https:google.com";

  static const Duration reconnectDelay = Duration(seconds: 5);
  static const int maxReconnectAttempts = 5;
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration pingInterval = Duration(seconds: 30);
}
