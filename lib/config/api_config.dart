import 'dart:html' as html;

class ApiConfig {
  static const String backendBaseUrl = 'http://3.38.67.165:8081/';
  static const String webSocketUrl = 'ws://3.38.67.165:8081/ws/chat/websocket';

  static String get baseUrl {
    final host = html.window.location.hostname;
    final isLocal = host == 'localhost' || host == '127.0.0.1';
    return isLocal ? backendBaseUrl : '/';
  }

  static Uri uri(String path) {
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('$baseUrl$normalizedPath');
  }
}
