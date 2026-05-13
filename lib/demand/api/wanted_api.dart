import 'dart:convert';
import 'dart:html' as html;

import 'package:akiba/config/api_config.dart';
import 'package:http/http.dart' as http;

class WantedApi {
  static Future<List<dynamic>> getWantedPosts() async {
    final response = await http.get(ApiConfig.uri('api/wanted/posts'));
    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded;
    }

    if (decoded is Map<String, dynamic>) {
      final candidates = [
        decoded['data'],
        decoded['content'],
        decoded['result'],
        decoded['posts'],
      ];

      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate;
        }
      }
    }

    return [];
  }

  static Future<WantedPostDetail> getWantedPostDetail(int postId) async {
    final response = await http.get(
      ApiConfig.uri('api/wanted/posts/$postId'),
      headers: _authHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw WantedApiException(response.statusCode, response.body);
    }

    return WantedPostDetail.fromJson(jsonDecode(response.body));
  }

  static Future<http.Response> createWantedPost({
    required WantedUpsertPayload payload,
  }) {
    return http.post(
      ApiConfig.uri('api/wanted/posts'),
      headers: _jsonAuthHeaders(),
      body: jsonEncode(payload.toJson()),
    );
  }

  static Future<http.Response> updateWantedPost({
    required int postId,
    required WantedUpsertPayload payload,
  }) {
    return http.put(
      ApiConfig.uri('api/wanted/posts/$postId'),
      headers: _jsonAuthHeaders(),
      body: jsonEncode(payload.toJson()),
    );
  }

  static Future<http.Response> deleteWantedPost(int postId) {
    return http.delete(
      ApiConfig.uri('api/wanted/posts/$postId'),
      headers: _authHeaders(),
    );
  }

  static Map<String, String> _authHeaders() {
    final accessToken = html.window.localStorage['accessToken'];
    return {
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };
  }

  static Map<String, String> _jsonAuthHeaders() {
    return {'Content-Type': 'application/json', ..._authHeaders()};
  }
}

class WantedApiException implements Exception {
  final int statusCode;
  final String body;

  WantedApiException(this.statusCode, this.body);

  @override
  String toString() => 'WantedApiException($statusCode): $body';
}

class WantedUpsertPayload {
  final String title;
  final String content;
  final int price;
  final String specialType;
  final String conditionTxt;
  final String deliveryMethod;
  final List<int> imageMediaIds;
  final List<String> tagNames;

  const WantedUpsertPayload({
    required this.title,
    required this.content,
    required this.price,
    required this.specialType,
    required this.conditionTxt,
    required this.deliveryMethod,
    required this.imageMediaIds,
    required this.tagNames,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'price': price,
      'specialType': specialType,
      'conditionTxt': conditionTxt,
      'deliveryMethod': deliveryMethod,
      'imageMediaIds': imageMediaIds,
      'tagNames': tagNames,
    };
  }
}

class WantedPostDetail {
  final int postId;
  final String title;
  final String content;
  final int price;
  final String conditionTxt;
  final String specialType;
  final String deliveryMethod;
  final String status;
  final int viewCount;
  final int favoriteCount;
  final DateTime? createdAt;
  final List<WantedImage> images;
  final WantedAuthor author;
  final List<WantedSimilarPost> similarPosts;
  final bool favorite;

  const WantedPostDetail({
    required this.postId,
    required this.title,
    required this.content,
    required this.price,
    required this.conditionTxt,
    required this.specialType,
    required this.deliveryMethod,
    required this.status,
    required this.viewCount,
    required this.favoriteCount,
    required this.createdAt,
    required this.images,
    required this.author,
    required this.similarPosts,
    required this.favorite,
  });

  factory WantedPostDetail.fromJson(dynamic raw) {
    final map = raw is Map<String, dynamic>
        ? raw
        : raw is Map
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};

    return WantedPostDetail(
      postId: _toInt(map['postId'] ?? map['id']),
      title: (map['title'] ?? '').toString(),
      content: (map['content'] ?? '').toString(),
      price: _toInt(map['price']),
      conditionTxt: (map['conditionTxt'] ?? '').toString(),
      specialType: (map['specialType'] ?? 'NONE').toString(),
      deliveryMethod: (map['deliveryMethod'] ?? '').toString(),
      status: (map['status'] ?? '').toString(),
      viewCount: _toInt(map['viewCount']),
      favoriteCount: _toInt(map['favoriteCount']),
      createdAt: _parseDateTime(map['createdAt']),
      images: ((map['images'] as List?) ?? const [])
          .map((item) => WantedImage.fromJson(item))
          .toList(),
      author: WantedAuthor.fromJson(map['author']),
      similarPosts: ((map['similarPosts'] as List?) ?? const [])
          .map((item) => WantedSimilarPost.fromJson(item))
          .toList(),
      favorite: map['favorite'] == true,
    );
  }

  List<int> get imageMediaIds => images.map((image) => image.mediaId).toList();

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toLocal();
  }
}

class WantedImage {
  final int mediaId;
  final String imageUrl;
  final int sortOrder;

  const WantedImage({
    required this.mediaId,
    required this.imageUrl,
    required this.sortOrder,
  });

  factory WantedImage.fromJson(dynamic raw) {
    final map = raw is Map<String, dynamic>
        ? raw
        : raw is Map
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};

    return WantedImage(
      mediaId: WantedPostDetail._toInt(map['mediaId']),
      imageUrl: (map['imageUrl'] ?? '').toString(),
      sortOrder: WantedPostDetail._toInt(map['sortOrder']),
    );
  }
}

class WantedAuthor {
  final int userId;
  final String nickname;
  final String profileImageUrl;

  const WantedAuthor({
    required this.userId,
    required this.nickname,
    required this.profileImageUrl,
  });

  factory WantedAuthor.fromJson(dynamic raw) {
    final map = raw is Map<String, dynamic>
        ? raw
        : raw is Map
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};

    return WantedAuthor(
      userId: WantedPostDetail._toInt(map['userId']),
      nickname: (map['nickname'] ?? '작성자').toString(),
      profileImageUrl: (map['profileImageUrl'] ?? '').toString(),
    );
  }
}

class WantedSimilarPost {
  final int postId;
  final String title;
  final String conditionTxt;
  final DateTime? createdAt;

  const WantedSimilarPost({
    required this.postId,
    required this.title,
    required this.conditionTxt,
    required this.createdAt,
  });

  factory WantedSimilarPost.fromJson(dynamic raw) {
    final map = raw is Map<String, dynamic>
        ? raw
        : raw is Map
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};

    return WantedSimilarPost(
      postId: WantedPostDetail._toInt(map['postId']),
      title: (map['title'] ?? '').toString(),
      conditionTxt: (map['conditionTxt'] ?? '').toString(),
      createdAt: WantedPostDetail._parseDateTime(map['createdAt']),
    );
  }
}
