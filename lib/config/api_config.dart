class ApiConfig {
  static const String baseUrl = 'http://3.38.67.165:8081/';
  static const String webSocketUrl = 'ws://3.38.67.165:8081/ws/chat/websocket';

  static Uri uri(String path) {
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('$baseUrl$normalizedPath');
  }
}
