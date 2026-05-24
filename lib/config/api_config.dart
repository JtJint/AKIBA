import 'dart:html' as html;

class ApiConfig {
  static const String backendBaseUrl = 'https://api.dev.akiba-shop.com/';
  static const String webSocketUrl =
      'wss://api.dev.akiba-shop.com/ws/chat/websocket';

  static String get baseUrl {
    final host = html.window.location.hostname;
    final isLocal = host == 'localhost' || host == '127.0.0.1';
    return isLocal ? backendBaseUrl : '/';
  }

  static Uri uri(String path) {
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('$baseUrl$normalizedPath');
  }

  static String resourceUrl(String? path) {
    final raw = path?.trim() ?? '';
    if (raw.isEmpty) return '';
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    return uri(raw).toString();
  }
}
