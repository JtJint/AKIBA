import 'dart:convert';

import 'package:akiba/api/auth_http_client.dart';
import 'package:akiba/config/api_config.dart';
import 'package:akiba/used/model/used_trade_models.dart';

class UsedTradeApi {
  static Future<List<UsedTradeItem>> getPosts() async {
    final response = await AuthHttpClient.get(ApiConfig.uri('api/used/posts'));

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
      ApiConfig.uri('api/used/$postId'),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw UsedTradeApiException(response.statusCode, response.body);
    }

    final decoded = jsonDecode(response.body);
    final body = decoded is Map<String, dynamic> && decoded['data'] is Map
        ? decoded['data']
        : decoded;
    return UsedTradeItem.fromJson(body);
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
