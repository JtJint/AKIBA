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
    bool? onlyActive,
    bool? unOpenedOnly,
    String? sort,
    int? page,
    int? size,
  }) async {
    final response = await AuthHttpClient.get(
      ApiConfig.uri('api/market/search').replace(
        queryParameters: {
          'keyword': keyword,
          if (type != null && type.trim().isNotEmpty) 'type': type.trim(),
          if (onlyActive != null) 'onlyActive': onlyActive.toString(),
          if (unOpenedOnly != null) 'unOpenedOnly': unOpenedOnly.toString(),
          if (sort != null && sort.trim().isNotEmpty) 'sort': sort.trim(),
          if (page != null) 'page': page.toString(),
          if (size != null) 'size': size.toString(),
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

  static Future<List<MarketSearchPost>> getPopularPosts({
    required String type,
    int limit = 3,
  }) async {
    final response = await AuthHttpClient.get(
      ApiConfig.uri(
        'api/market/posts/popular',
      ).replace(queryParameters: {'type': type, 'limit': limit.toString()}),
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
  const PopularKeyword({
    required this.rank,
    required this.keyword,
    required this.trend,
  });

  final int rank;
  final String keyword;
  final String trend;

  factory PopularKeyword.fromJson(dynamic json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return PopularKeyword(
      rank: _parseInt(map['rank']),
      keyword: (map['keyword'] ?? '').toString(),
      trend: (map['trend'] ?? 'SAME').toString(),
    );
  }
}

class MarketSearchPost {
  const MarketSearchPost({
    required this.postId,
    required this.title,
    required this.price,
    required this.thumbnailUrl,
    required this.type,
    required this.createdAtText,
  });

  final int postId;
  final String title;
  final int price;
  final String thumbnailUrl;
  final String type;
  final String createdAtText;

  factory MarketSearchPost.fromJson(dynamic json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return MarketSearchPost(
      postId: _parseInt(map['postId'] ?? map['id']),
      title: (map['title'] ?? map['name'] ?? '').toString(),
      price: _parseInt(
        map['price'] ?? map['currentPrice'] ?? map['startPrice'],
      ),
      thumbnailUrl: _parseThumbnailUrl(map),
      type: (map['type'] ?? map['postType'] ?? map['marketType'] ?? 'USED')
          .toString(),
      createdAtText: _formatDateText(map['createdAt'] ?? map['createdAtText']),
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

String _parseThumbnailUrl(Map<String, dynamic> map) {
  final direct = map['thumbnailUrl'] ?? map['imageUrl'];
  if (direct is String && direct.isNotEmpty) {
    return ApiConfig.resourceUrl(direct);
  }

  final images = map['images'] ?? map['imageUrls'];
  if (images is List && images.isNotEmpty) {
    final first = images.first;
    if (first is String) return ApiConfig.resourceUrl(first);
    if (first is Map) {
      return ApiConfig.resourceUrl(
        (first['imageUrl'] ?? first['url'])?.toString(),
      );
    }
  }

  return '';
}

String _formatDateText(dynamic value) {
  final raw = value?.toString() ?? '';
  final date = DateTime.tryParse(raw);
  if (date == null) return raw;

  final diff = DateTime.now().difference(date.toLocal());
  if (diff.inDays > 0) return '${diff.inDays}일전';
  if (diff.inHours > 0) return '${diff.inHours}시간전';
  if (diff.inMinutes > 0) return '${diff.inMinutes}분전';
  return '방금 전';
}
