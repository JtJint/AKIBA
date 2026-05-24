import 'dart:convert';

import 'package:akiba/api/auth_http_client.dart';
import 'package:akiba/config/api_config.dart';

class MarketSearchApi {
  static Future<List<String>> getRecommendedTags({
    String? type,
    int limit = 10,
  }) async {
    final response = await AuthHttpClient.get(
      ApiConfig.uri('api/market/tags/recommended').replace(
        queryParameters: {
          if (type != null && type.trim().isNotEmpty) 'type': type.trim(),
          'limit': limit.toString(),
        },
      ),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MarketSearchApiException(response.statusCode, response.body);
    }

    final decoded = jsonDecode(response.body);
    return _extractList(decoded, 'tags')
        .map((item) {
          if (item is String) return item;
          if (item is Map) {
            return (item['tagName'] ?? item['name'] ?? '').toString();
          }
          return '';
        })
        .where((tag) => tag.isNotEmpty && tag.toLowerCase() != 'string')
        .toList();
  }

  static Future<List<PopularKeyword>> getPopularKeywords({
    int limit = 10,
  }) async {
    final response = await AuthHttpClient.get(
      ApiConfig.uri(
        'api/market/search/popular',
      ).replace(queryParameters: {'limit': limit.toString()}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MarketSearchApiException(response.statusCode, response.body);
    }

    final decoded = jsonDecode(response.body);
    return _extractList(decoded, 'keywords')
        .map((item) => PopularKeyword.fromJson(item))
        .where((item) => item.keyword.isNotEmpty)
        .toList();
  }

  static Future<List<MarketSearchPost>> searchPosts({
    required String keyword,
    String? type,
    int page = 0,
    int size = 20,
  }) async {
    final response = await AuthHttpClient.get(
      ApiConfig.uri('api/market/search').replace(
        queryParameters: {
          'keyword': keyword,
          if (type != null && type.trim().isNotEmpty) 'type': type.trim(),
          'page': page.toString(),
          'size': size.toString(),
        },
      ),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MarketSearchApiException(response.statusCode, response.body);
    }

    final decoded = jsonDecode(response.body);
    return _extractList(decoded, 'posts')
        .map((item) => MarketSearchPost.fromJson(item))
        .where((item) => item.postId != 0 || item.title.isNotEmpty)
        .toList();
  }

  static List<dynamic> _extractList(dynamic decoded, String preferredKey) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      final preferred = decoded[preferredKey];
      if (preferred is List) return preferred;
      for (final key in ['data', 'content', 'result', 'posts', 'items']) {
        final value = decoded[key];
        if (value is List) return value;
        if (value is Map<String, dynamic>) {
          final nested =
              value[preferredKey] ?? value['content'] ?? value['items'];
          if (nested is List) return nested;
        }
      }
    }
    return [];
  }
}

class PopularKeyword {
  const PopularKeyword({required this.rank, required this.keyword});

  final int rank;
  final String keyword;

  factory PopularKeyword.fromJson(dynamic json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return PopularKeyword(
      rank: _parseInt(map['rank']),
      keyword: (map['keyword'] ?? '').toString(),
    );
  }
}

class MarketSearchPost {
  const MarketSearchPost({
    required this.postId,
    required this.title,
    required this.price,
    required this.thumbnailUrl,
  });

  final int postId;
  final String title;
  final int price;
  final String thumbnailUrl;

  factory MarketSearchPost.fromJson(dynamic json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return MarketSearchPost(
      postId: _parseInt(map['postId'] ?? map['id']),
      title: (map['title'] ?? map['name'] ?? '').toString(),
      price: _parseInt(
        map['price'] ?? map['currentPrice'] ?? map['startPrice'],
      ),
      thumbnailUrl: (map['thumbnailUrl'] ?? map['imageUrl'] ?? '').toString(),
    );
  }
}

class MarketSearchApiException implements Exception {
  const MarketSearchApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'MarketSearchApiException($statusCode): $body';
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
