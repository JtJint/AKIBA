import 'dart:convert';
import 'dart:html' as html;

import 'package:akiba/config/api_config.dart';
import 'package:akiba/limited/model/limited_models.dart';
import 'package:http/http.dart' as http;

class LimitedApi {
  static Future<List<LimitedItem>> getItems({String? keyword}) async {
    final uri = ApiConfig.uri('api/limited').replace(
      queryParameters: {
        if (keyword != null && keyword.trim().isNotEmpty)
          'keyword': keyword.trim(),
      },
    );
    final response = await http.get(uri, headers: _authHeaders());

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LimitedApiException(response.statusCode, response.body);
    }

    final decoded = jsonDecode(response.body);
    return _extractList(decoded)
        .map((item) => LimitedItem.fromJson(item))
        .where((item) => item.id != 0 || item.title.isNotEmpty)
        .toList();
  }

  static Map<String, String> _authHeaders() {
    final accessToken = html.window.localStorage['accessToken'];
    return {
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };
  }

  static List<dynamic> _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      final candidates = [
        decoded['data'],
        decoded['content'],
        decoded['result'],
        decoded['posts'],
        decoded['items'],
      ];
      for (final candidate in candidates) {
        if (candidate is List) return candidate;
        if (candidate is Map<String, dynamic>) {
          final nested = candidate['content'] ?? candidate['items'];
          if (nested is List) return nested;
        }
      }
    }
    return [];
  }
}

class LimitedApiException implements Exception {
  const LimitedApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'LimitedApiException($statusCode): $body';
}
