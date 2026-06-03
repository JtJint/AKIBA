import 'dart:convert';

import 'package:akiba/api/auth_http_client.dart';
import 'package:akiba/config/api_config.dart';

class BoardApi {
  static Future<List<BoardSummary>> getBoards() async {
    final response = await AuthHttpClient.get(ApiConfig.uri('api/boards'));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BoardApiException(response.statusCode, response.body);
    }

    final decoded = jsonDecode(response.body);
    return _extractList(decoded)
        .map((item) => BoardSummary.fromJson(item))
        .where((item) => item.boardCode.isNotEmpty)
        .toList();
  }

  static Future<List<BoardPostSummary>> getPopularPosts() async {
    final response = await AuthHttpClient.get(
      ApiConfig.uri('api/boards/popular/posts'),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BoardApiException(response.statusCode, response.body);
    }

    final decoded = jsonDecode(response.body);
    return _extractList(decoded)
        .map((item) => BoardPostSummary.fromJson(item))
        .where((item) => item.postId != 0 || item.title.isNotEmpty)
        .toList();
  }

  static Future<List<BoardPostSummary>> getPosts({
    required String boardCode,
    String sort = 'latest',
    int page = 0,
    int size = 20,
  }) async {
    final response = await AuthHttpClient.get(
      ApiConfig.uri('api/boards/$boardCode/posts').replace(
        queryParameters: {
          'sort': sort,
          'page': page.toString(),
          'size': size.toString(),
        },
      ),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BoardApiException(response.statusCode, response.body);
    }

    final decoded = jsonDecode(response.body);
    return _extractList(decoded)
        .map(
          (item) => BoardPostSummary.fromJson(item, fallbackBoard: boardCode),
        )
        .where((item) => item.postId != 0 || item.title.isNotEmpty)
        .toList();
  }

  static Future<BoardPostSummary> getPostDetail({
    required String boardCode,
    required int postId,
  }) async {
    final response = await AuthHttpClient.get(
      ApiConfig.uri('api/boards/$boardCode/posts/$postId'),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BoardApiException(response.statusCode, response.body);
    }

    return BoardPostSummary.fromJson(jsonDecode(response.body));
  }

  static Future<List<BoardComment>> getComments({
    required String boardCode,
    required int postId,
  }) async {
    final response = await AuthHttpClient.get(
      ApiConfig.uri('api/boards/$boardCode/posts/$postId/comments'),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BoardApiException(response.statusCode, response.body);
    }

    final decoded = jsonDecode(response.body);
    return _extractList(decoded)
        .map((item) => BoardComment.fromJson(item))
        .where((item) => item.commentId != 0 || item.content.isNotEmpty)
        .toList();
  }

  static Future<void> createPost({
    required String boardCode,
    required BoardPostCreatePayload payload,
  }) async {
    final response = await AuthHttpClient.post(
      ApiConfig.uri('api/boards/$boardCode/posts'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload.toJson()),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BoardApiException(response.statusCode, response.body);
    }
  }

  static Future<void> createComment({
    required String boardCode,
    required int postId,
    required BoardCommentCreatePayload payload,
  }) async {
    final response = await AuthHttpClient.post(
      ApiConfig.uri('api/boards/$boardCode/posts/$postId/comments'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload.toJson()),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BoardApiException(response.statusCode, response.body);
    }
  }

  static List<dynamic> _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      for (final key in [
        'data',
        'content',
        'result',
        'posts',
        'comments',
        'items',
      ]) {
        final value = decoded[key];
        if (value is List) return value;
        if (value is Map<String, dynamic>) {
          final nested = _extractList(value);
          if (nested.isNotEmpty) return nested;
        }
      }
    }
    return [];
  }
}

class BoardSummary {
  const BoardSummary({
    required this.boardId,
    required this.boardCode,
    required this.boardName,
    required this.description,
  });

  final int boardId;
  final String boardCode;
  final String boardName;
  final String description;

  factory BoardSummary.fromJson(dynamic json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return BoardSummary(
      boardId: _parseInt(map['boardId']),
      boardCode: (map['boardCode'] ?? '').toString(),
      boardName: (map['boardName'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
    );
  }
}

class BoardPostSummary {
  const BoardPostSummary({
    required this.postId,
    required this.userId,
    required this.boardCode,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    required this.bookmarkCount,
    required this.imageUrls,
    required this.hashtags,
    required this.saleOrAuctionLink,
    required this.authenticVoteCount,
    required this.fakeVoteCount,
  });

  final int postId;
  final int userId;
  final String boardCode;
  final String title;
  final String content;
  final String author;
  final DateTime? createdAt;
  final int likeCount;
  final int commentCount;
  final int bookmarkCount;
  final List<String> imageUrls;
  final List<String> hashtags;
  final String saleOrAuctionLink;
  final int authenticVoteCount;
  final int fakeVoteCount;

  factory BoardPostSummary.fromJson(dynamic json, {String? fallbackBoard}) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return BoardPostSummary(
      postId: _parseInt(map['postId'] ?? map['id']),
      userId: _parseInt(map['userId'] ?? map['authorId']),
      boardCode: (map['boardCode'] ?? fallbackBoard ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      content: (map['content'] ?? '').toString(),
      author:
          (map['author'] ??
                  map['nickname'] ??
                  map['authorName'] ??
                  map['writer'] ??
                  '익명')
              .toString(),
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? ''),
      likeCount: _parseInt(map['likeCount'] ?? map['likes']),
      commentCount: _parseInt(map['commentCount'] ?? map['commentsCount']),
      bookmarkCount: _parseInt(map['bookmarkCount'] ?? map['scrapCount']),
      imageUrls: _parseStringList(map['imageUrls'] ?? map['images']),
      hashtags: _parseHashtags(map['hashtags']),
      saleOrAuctionLink: (map['saleOrAuctionLink'] ?? '').toString(),
      authenticVoteCount: _parseInt(map['authenticVoteCount']),
      fakeVoteCount: _parseInt(map['fakeVoteCount']),
    );
  }
}

class BoardComment {
  const BoardComment({
    required this.commentId,
    required this.parentId,
    required this.author,
    required this.content,
    required this.createdAt,
    required this.likeCount,
  });

  final int commentId;
  final int? parentId;
  final String author;
  final String content;
  final DateTime? createdAt;
  final int likeCount;

  factory BoardComment.fromJson(dynamic json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    final parent = map['parentId'];
    return BoardComment(
      commentId: _parseInt(map['commentId'] ?? map['id']),
      parentId: parent == null ? null : _parseInt(parent),
      author:
          (map['author'] ??
                  map['nickname'] ??
                  map['authorName'] ??
                  map['writer'] ??
                  '익명')
              .toString(),
      content: (map['content'] ?? '').toString(),
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? ''),
      likeCount: _parseInt(map['likeCount'] ?? map['likes']),
    );
  }
}

class BoardPostCreatePayload {
  const BoardPostCreatePayload({
    required this.userId,
    required this.title,
    required this.content,
    required this.imageUrls,
    required this.hashtags,
    this.saleOrAuctionLink,
  });

  final int userId;
  final String title;
  final String content;
  final List<String> imageUrls;
  final List<String> hashtags;
  final String? saleOrAuctionLink;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'imageUrls': imageUrls,
      if (saleOrAuctionLink != null && saleOrAuctionLink!.trim().isNotEmpty)
        'saleOrAuctionLink': saleOrAuctionLink!.trim(),
      'hashtags': hashtags,
    };
  }
}

class BoardCommentCreatePayload {
  const BoardCommentCreatePayload({
    required this.userId,
    required this.content,
    this.parentId,
  });

  final int userId;
  final String content;
  final int? parentId;

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'parentId': parentId, 'content': content};
  }
}

class BoardApiException implements Exception {
  const BoardApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'BoardApiException($statusCode): $body';
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

List<String> _parseStringList(dynamic value) {
  if (value is List) {
    return value
        .map((item) => item?.toString() ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
  }
  return [];
}

List<String> _parseHashtags(dynamic value) {
  return _parseStringList(value)
      .map((tag) => tag.trim())
      .map((tag) => tag.startsWith('#') ? tag.substring(1) : tag)
      .where((tag) => tag.isNotEmpty)
      .toList();
}
