import 'dart:convert';

import 'package:akiba/api/auth_http_client.dart';
import 'package:akiba/config/api_config.dart';
import 'package:akiba/limited/model/limited_models.dart';

class LimitedApi {
  static Future<List<LimitedItem>> getItems({String? keyword}) async {
    final uri = ApiConfig.uri('api/limited/posts').replace(
      queryParameters: {
        if (keyword != null && keyword.trim().isNotEmpty)
          'keyword': keyword.trim(),
      },
    );
    final response = await AuthHttpClient.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LimitedApiException(response.statusCode, response.body);
    }

    final decoded = jsonDecode(response.body);
    return _extractList(decoded)
        .map((item) => LimitedItem.fromJson(item))
        .where((item) => item.id != 0 || item.title.isNotEmpty)
        .toList();
  }

  static Future<List<LimitedItem>> getPopularPosts({int limit = 10}) async {
    final response = await AuthHttpClient.get(
      ApiConfig.uri(
        'api/limited/posts/popular',
      ).replace(queryParameters: {'limit': limit.toString()}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LimitedApiException(response.statusCode, response.body);
    }

    final decoded = jsonDecode(response.body);
    return _extractList(decoded)
        .map((item) => LimitedItem.fromJson(item))
        .where((item) => item.id != 0 || item.title.isNotEmpty)
        .toList();
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
