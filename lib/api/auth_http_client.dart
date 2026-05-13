import 'dart:convert';
import 'dart:html' as html;

import 'package:akiba/config/api_config.dart';
import 'package:http/http.dart' as http;

class AuthHttpClient {
  AuthHttpClient._();

  static bool _isRefreshing = false;

  static Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    return _sendWithRefresh(() => http.get(url, headers: authHeaders(headers)));
  }

  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _sendWithRefresh(
      () => http.post(url, headers: authHeaders(headers), body: body),
    );
  }

  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _sendWithRefresh(
      () => http.put(url, headers: authHeaders(headers), body: body),
    );
  }

  static Future<http.Response> delete(Uri url, {Map<String, String>? headers}) {
    return _sendWithRefresh(
      () => http.delete(url, headers: authHeaders(headers)),
    );
  }

  static Future<http.StreamedResponse> sendMultipart(
    http.MultipartRequest request,
  ) async {
    request.headers.addAll(authHeaders(request.headers));
    return request.send();
  }

  static Future<http.Response> _sendWithRefresh(
    Future<http.Response> Function() request,
  ) async {
    final response = await request();
    if (response.statusCode != 401) return response;

    final refreshed = await refreshAccessToken();
    if (!refreshed) return response;

    return request();
  }

  static Future<bool> refreshAccessToken() async {
    if (_isRefreshing) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return (html.window.localStorage['accessToken'] ?? '').isNotEmpty;
    }

    final refreshToken = html.window.localStorage['refreshToken'];
    if (refreshToken == null || refreshToken.isEmpty) {
      await clearSession();
      return false;
    }

    _isRefreshing = true;
    try {
      final response = await http.post(
        ApiConfig.uri('api/users/reissue'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        await clearSession();
        return false;
      }

      final decoded = jsonDecode(response.body);
      final accessToken = _extractToken(decoded, 'accessToken');
      final newRefreshToken = _extractToken(decoded, 'refreshToken');

      if (accessToken == null || accessToken.isEmpty) {
        await clearSession();
        return false;
      }

      html.window.localStorage['accessToken'] = accessToken;
      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        html.window.localStorage['refreshToken'] = newRefreshToken;
      }
      return true;
    } catch (error) {
      await clearSession();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  static Future<void> clearSession() async {
    html.window.localStorage.remove('accessToken');
    html.window.localStorage.remove('refreshToken');
    html.window.localStorage.remove('userId');
  }

  static Map<String, String> authHeaders([Map<String, String>? headers]) {
    final accessToken = html.window.localStorage['accessToken'];
    return {
      ...?headers,
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };
  }

  static String? _extractToken(dynamic decoded, String key) {
    if (decoded is! Map<String, dynamic>) return null;
    final direct = decoded[key]?.toString();
    if (direct != null && direct != 'null') return direct;

    final data = decoded['data'];
    if (data is Map) {
      final nested = data[key]?.toString();
      if (nested != null && nested != 'null') return nested;
    }
    final result = decoded['result'];
    if (result is Map) {
      final nested = result[key]?.toString();
      if (nested != null && nested != 'null') return nested;
    }
    return null;
  }
}
