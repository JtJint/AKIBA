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

  static Future<AuctionSummary> getPostDetail(int postId) async {
    final response = await AuthHttpClient.get(
      ApiConfig.uri('api/auction/posts/$postId'),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuctionApiException(response.statusCode, response.body);
    }

    return AuctionSummary.fromJson(jsonDecode(response.body));
  }

  static Future<void> bid({required int postId, required int bidAmount}) async {
    final response = await AuthHttpClient.post(
      ApiConfig.uri('api/auction/posts/$postId/bids'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'bidAmount': bidAmount}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuctionApiException(response.statusCode, response.body);
    }
  }

  static Future<void> buyNow({required int postId}) async {
    final response = await AuthHttpClient.post(
      ApiConfig.uri('api/auction/posts/$postId/buy-now'),
      headers: const {'Content-Type': 'application/json'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuctionApiException(response.statusCode, response.body);
    }
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
    required this.content,
    required this.startPrice,
    required this.currentPrice,
    required this.buyNowPrice,
    required this.bidStep,
    required this.bidCount,
    required this.viewCount,
    required this.favoriteCount,
    required this.thumbnailUrl,
    required this.imageUrls,
    required this.productCondition,
    required this.specialType,
    required this.deliveryMethod,
    required this.purchaseSource,
    required this.status,
    required this.sellerNickname,
    required this.sellerUserId,
    required this.sellerProfileImageUrl,
    required this.tags,
    required this.hasBid,
    required this.favorite,
    required this.myPost,
    required this.endsAt,
  });

  final int postId;
  final String title;
  final String content;
  final int startPrice;
  final int currentPrice;
  final int buyNowPrice;
  final int bidStep;
  final int bidCount;
  final int viewCount;
  final int favoriteCount;
  final String thumbnailUrl;
  final List<String> imageUrls;
  final String productCondition;
  final String specialType;
  final String deliveryMethod;
  final String purchaseSource;
  final String status;
  final String sellerNickname;
  final int? sellerUserId;
  final String? sellerProfileImageUrl;
  final List<String> tags;
  final bool hasBid;
  final bool favorite;
  final bool myPost;
  final DateTime? endsAt;

  factory AuctionSummary.fromJson(dynamic json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    final seller = map['seller'] is Map ? Map<String, dynamic>.from(map['seller'] as Map) : <String, dynamic>{};
    final startPrice = _parseInt(map['startPrice'] ?? map['startingPrice']);
    final currentPrice = _parseInt(
      map['currentPrice'] ?? map['currentBidAmount'] ?? map['highestBidAmount'],
    );
    final images = _parseImageUrls(map);
    return AuctionSummary(
      postId: _parseInt(map['postId'] ?? map['id']),
      title: (map['title'] ?? '').toString(),
      content: (map['content'] ?? map['description'] ?? '').toString(),
      startPrice: startPrice,
      currentPrice: currentPrice == 0 ? startPrice : currentPrice,
      buyNowPrice: _parseInt(map['buyNowPrice'] ?? map['instantBuyPrice']),
      bidStep: _parseInt(map['bidStep'] ?? map['bidUnit']),
      bidCount: _parseInt(map['bidCount'] ?? map['bidsCount']),
      viewCount: _parseInt(
        map['viewCount'] ??
            map['views'] ??
            map['viewCnt'] ??
            map['hitCount'] ??
            map['readCount'],
      ),
      favoriteCount: _parseInt(
        map['favoriteCount'] ?? map['favoritesCount'] ?? map['likeCount'],
      ),
      thumbnailUrl: images.isNotEmpty
          ? images.first
          : ApiConfig.resourceUrl(map['thumbnailUrl']?.toString()),
      imageUrls: images,
      productCondition:
          (map['productCondition'] ?? map['conditionTxt'] ?? '').toString(),
      specialType: (map['specialType'] ?? '').toString(),
      deliveryMethod: (map['deliveryMethod'] ?? '').toString(),
      purchaseSource: (map['purchaseSource'] ?? '').toString(),
      status: (map['status'] ?? '').toString(),
      sellerNickname:
          (seller['nickname'] ??
                  seller['sellerNickname'] ??
                  map['sellerNickname'] ??
                  map['sellerName'] ??
                  map['author'] ??
                  map['nickname'] ??
                  '판매자')
              .toString(),
      sellerUserId: _nullableInt(
        seller['userId'] ?? map['sellerUserId'] ?? map['userId'],
      ),
      sellerProfileImageUrl: _nullableString(
        seller['profileImageUrl'] ?? map['sellerProfileImageUrl'],
      ),
      tags: _parseTags(map['tags'] ?? map['tagNames']),
      hasBid: map['hasBid'] == true,
      favorite: map['favorite'] == true || map['isFavorite'] == true,
      myPost: map['myPost'] == true || map['isMine'] == true,
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

int? _nullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

String? _nullableString(dynamic value) {
  final text = value?.toString();
  if (text == null || text.isEmpty || text == 'null') return null;
  return ApiConfig.resourceUrl(text);
}

List<String> _parseTags(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((tag) => tag.toString().trim())
      .where((tag) => tag.isNotEmpty)
      .toList();
}

List<String> _parseImageUrls(Map<String, dynamic> map) {
  final rawImages = map['imageUrls'] ?? map['images'];
  if (rawImages is List) {
    return rawImages
        .map((image) {
          if (image is String) return ApiConfig.resourceUrl(image);
          if (image is Map) {
            return ApiConfig.resourceUrl(
              (image['imageUrl'] ?? image['url'])?.toString(),
            );
          }
          return '';
        })
        .where((url) => url.isNotEmpty)
        .toList();
  }
  final thumbnail = ApiConfig.resourceUrl(map['thumbnailUrl']?.toString());
  return thumbnail.isEmpty ? const [] : [thumbnail];
}
