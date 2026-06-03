import 'dart:convert';

import 'package:akiba/api/auth_http_client.dart';
import 'package:akiba/config/api_config.dart';
import 'package:akiba/market/api/market_post_api.dart';
import 'package:akiba/used/model/used_trade_models.dart';
import 'package:http/http.dart' as http;

class UsedTradeApi {
  static Future<List<UsedTradeItem>> getPosts({
    int? categoryId,
    String? status,
    String sort = 'latest',
    int page = 0,
    int size = 20,
  }) async {
    final response = await AuthHttpClient.get(
      ApiConfig.uri('api/used/posts').replace(
        queryParameters: {
          if (categoryId != null) 'categoryId': categoryId.toString(),
          if (status != null && status.trim().isNotEmpty)
            'status': status.trim(),
          'sort': sort,
          'page': page.toString(),
          'size': size.toString(),
        },
      ),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw UsedTradeApiException(response.statusCode, response.body);
    }

    final decoded = jsonDecode(response.body);
    return _extractList(decoded)
        .map((item) => UsedTradeItem.fromJson(item))
        .where((item) => item.id != 0 || item.title.isNotEmpty)
        .toList();
  }

  static Future<UsedTradeItem> getPostDetail(int postId) async {
    final response = await AuthHttpClient.get(
      ApiConfig.uri('api/used/posts/$postId'),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw UsedTradeApiException(response.statusCode, response.body);
    }

    final decoded = jsonDecode(response.body);
    final body = decoded is Map<String, dynamic>
        ? decoded['data'] is Map
              ? decoded['data']
              : decoded['result'] is Map
              ? decoded['result']
              : decoded
        : decoded;
    return UsedTradeItem.fromJson(body);
  }

  static Future<List<UsedTradeItem>> getPopularPosts({int limit = 10}) async {
    final response = await AuthHttpClient.get(
      ApiConfig.uri(
        'api/used/posts/popular',
      ).replace(queryParameters: {'limit': limit.toString()}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw UsedTradeApiException(response.statusCode, response.body);
    }

    final decoded = jsonDecode(response.body);
    return _extractList(decoded)
        .map((item) => UsedTradeItem.fromJson(item))
        .where((item) => item.id != 0 || item.title.isNotEmpty)
        .toList();
  }

  static Future<List<UsedTradeItem>> getSimilarPosts({
    required int postId,
    int limit = 10,
  }) async {
    final response = await AuthHttpClient.get(
      ApiConfig.uri(
        'api/market/posts/$postId/similar',
      ).replace(queryParameters: {'limit': limit.toString()}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw UsedTradeApiException(response.statusCode, response.body);
    }

    final decoded = jsonDecode(response.body);
    return _extractList(decoded)
        .map((item) => UsedTradeItem.fromJson(item))
        .where((item) => item.id != 0 || item.title.isNotEmpty)
        .toList();
  }

  static Future<http.Response> updatePost({
    required int postId,
    required UsedPostPayload payload,
  }) {
    return AuthHttpClient.put(
      ApiConfig.uri('api/used/posts/$postId'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload.toJson()),
    );
  }

  static Future<http.Response> deletePost(int postId) {
    return AuthHttpClient.delete(ApiConfig.uri('api/used/posts/$postId'));
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

class UsedTradeApiException implements Exception {
  const UsedTradeApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'UsedTradeApiException($statusCode): $body';
}
