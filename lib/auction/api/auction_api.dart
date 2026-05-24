import 'dart:convert';

import 'package:akiba/api/auth_http_client.dart';
import 'package:akiba/config/api_config.dart';

class AuctionApi {
  static Future<List<AuctionSummary>> getPosts({
    String? status,
    String sort = 'latest',
    int page = 0,
    int size = 20,
  }) async {
    final response = await AuthHttpClient.get(
      ApiConfig.uri('api/auction/posts').replace(
        queryParameters: {
          if (status != null && status.trim().isNotEmpty)
            'status': status.trim(),
          'sort': sort,
          'page': page.toString(),
          'size': size.toString(),
        },
      ),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuctionApiException(response.statusCode, response.body);
    }

    final decoded = jsonDecode(response.body);
    return _extractList(decoded)
        .map((item) => AuctionSummary.fromJson(item))
        .where((item) => item.postId != 0 || item.title.isNotEmpty)
        .toList();
  }

  static Future<List<AuctionSummary>> getEndingSoon({int limit = 10}) async {
    final response = await AuthHttpClient.get(
      ApiConfig.uri(
        'api/auction/posts/ending-soon',
      ).replace(queryParameters: {'limit': limit.toString()}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuctionApiException(response.statusCode, response.body);
    }

    final decoded = jsonDecode(response.body);
    return _extractList(decoded)
        .map((item) => AuctionSummary.fromJson(item))
        .where((item) => item.postId != 0 || item.title.isNotEmpty)
        .toList();
  }

  static List<dynamic> _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      for (final key in ['posts', 'data', 'content', 'result', 'items']) {
        final value = decoded[key];
        if (value is List) return value;
      }
    }
    return [];
  }
}

class AuctionSummary {
  const AuctionSummary({
    required this.postId,
    required this.title,
    required this.startPrice,
    required this.currentPrice,
    required this.bidCount,
    required this.thumbnailUrl,
    required this.endsAt,
  });

  final int postId;
  final String title;
  final int startPrice;
  final int currentPrice;
  final int bidCount;
  final String thumbnailUrl;
  final DateTime? endsAt;

  factory AuctionSummary.fromJson(dynamic json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    final startPrice = _parseInt(map['startPrice']);
    final currentPrice = _parseInt(map['currentPrice']);
    return AuctionSummary(
      postId: _parseInt(map['postId'] ?? map['id']),
      title: (map['title'] ?? '').toString(),
      startPrice: startPrice,
      currentPrice: currentPrice == 0 ? startPrice : currentPrice,
      bidCount: _parseInt(map['bidCount']),
      thumbnailUrl: ApiConfig.resourceUrl(map['thumbnailUrl']?.toString()),
      endsAt: DateTime.tryParse(map['endsAt']?.toString() ?? ''),
    );
  }
}

class AuctionApiException implements Exception {
  const AuctionApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'AuctionApiException($statusCode): $body';
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
