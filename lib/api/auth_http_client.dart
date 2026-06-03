import 'dart:convert';
import 'dart:html' as html;

import 'package:akiba/config/api_config.dart';
import 'package:http/http.dart' as http;

typedef AccessTokenRefreshListener = void Function(String accessToken);

class AuthHttpClient {
  AuthHttpClient._();

  static bool _isRefreshing = false;
  static final List<AccessTokenRefreshListener> _refreshListeners = [];

  static void addAccessTokenRefreshListener(
    AccessTokenRefreshListener listener,
  ) {
    if (!_refreshListeners.contains(listener)) {
      _refreshListeners.add(listener);
    }
  }

  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    await ensureAccessTokenFresh();
    return _sendWithRefresh(() => http.get(url, headers: authHeaders(headers)));
  }

  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    await ensureAccessTokenFresh();
    return _sendWithRefresh(
      () => http.post(url, headers: authHeaders(headers), body: body),
    );
  }

  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    await ensureAccessTokenFresh();
    return _sendWithRefresh(
      () => http.put(url, headers: authHeaders(headers), body: body),
    );
  }

  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    await ensureAccessTokenFresh();
    return _sendWithRefresh(
      () => http.delete(url, headers: authHeaders(headers)),
    );
  }

  static Future<http.StreamedResponse> sendMultipart(
    http.MultipartRequest request,
  ) async {
    await ensureAccessTokenFresh();
    request.headers.addAll(authHeaders(request.headers));
    return request.send();
  }

  static Future<bool> ensureAccessTokenFresh() async {
    final accessToken = html.window.localStorage['accessToken'];
    if (accessToken == null || accessToken.isEmpty) {
      return false;
    }

    if (!_isAccessTokenExpiringSoon(accessToken)) {
      return true;
    }

    return refreshAccessToken();
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
      for (var attempt = 0; attempt < 20 && _isRefreshing; attempt++) {
        await Future<void>.delayed(const Duration(milliseconds: 150));
      }
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
        ApiConfig.uri('api/users/refresh'),
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
      _notifyAccessTokenRefreshed(accessToken);
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
    _notifyAccessTokenRefreshed('');
  }

  static Map<String, String> authHeaders([Map<String, String>? headers]) {
    final accessToken = html.window.localStorage['accessToken'];
    return {
      ...?headers,
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };
  }

  static bool _isAccessTokenExpiringSoon(String accessToken) {
    final payload = _decodeJwtPayload(accessToken);
    if (payload == null) return false;

    final exp = payload['exp'];
    final expSeconds = exp is num ? exp.toInt() : int.tryParse('$exp');
    if (expSeconds == null) return false;

    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
      expSeconds * 1000,
      isUtc: true,
    );
    return DateTime.now().toUtc().isAfter(
      expiresAt.subtract(const Duration(seconds: 60)),
    );
  }

  static Map<String, dynamic>? _decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;

    try {
      final normalized = base64Url.normalize(parts[1]);
      final payloadText = utf8.decode(base64Url.decode(normalized));
      final decoded = jsonDecode(payloadText);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  static void _notifyAccessTokenRefreshed(String accessToken) {
    for (final listener in List<AccessTokenRefreshListener>.from(
      _refreshListeners,
    )) {
      listener(accessToken);
    }
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
