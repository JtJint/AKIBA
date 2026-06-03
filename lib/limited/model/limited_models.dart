import 'package:akiba/config/api_config.dart';

class LimitedItem {
  const LimitedItem({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.status,
    required this.condition,
    required this.createdAtText,
    required this.imageUrl,
    required this.description,
  });

  final int id;
  final String title;
  final int price;
  final String category;
  final String status;
  final String condition;
  final String createdAtText;
  final String imageUrl;
  final String description;

  factory LimitedItem.fromJson(dynamic json) {
    final map = json is Map<String, dynamic>
        ? json
        : Map<String, dynamic>.from(json as Map);
    return LimitedItem(
      id: _parseInt(map['postId'] ?? map['limitedPostId'] ?? map['id']),
      title: (map['title'] ?? map['name'] ?? '특전/한정판 상품').toString(),
      price: _parseInt(map['price']),
      category: _mapCategory(map['category'] ?? map['postType'] ?? map['type']),
      status: (map['status'] ?? map['saleStatus'] ?? '판매중').toString(),
      condition: (map['conditionTxt'] ?? map['condition'] ?? '미개봉').toString(),
      createdAtText: _formatDateText(map['createdAt'] ?? map['createdAtText']),
      imageUrl: _parseImageUrl(map),
      description: (map['content'] ?? map['description'] ?? '').toString(),
    );
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _parseImageUrl(Map<String, dynamic> map) {
  final raw = map['imageUrl'] ?? map['thumbnailUrl'];
  if (raw is String && raw.isNotEmpty) return ApiConfig.resourceUrl(raw);

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
  return 'https://picsum.photos/seed/limited-fallback/600/600';
}

String _mapCategory(dynamic value) {
  final raw = value?.toString().toUpperCase() ?? '';
  if (raw.contains('WANTED') || raw.contains('REQUEST') || raw.contains('구해')) {
    return '구해요';
  }
  if (raw.contains('AUCTION') || raw.contains('경매')) {
    return '경매';
  }
  if (raw.contains('AUTH') || raw.contains('정품')) {
    return '정품 감정';
  }
  return '중고거래';
}

String _formatDateText(dynamic value) {
  final raw = value?.toString() ?? '';
  final date = DateTime.tryParse(raw);
  if (date == null) return raw.isEmpty ? '1일전' : raw;

  final diff = DateTime.now().difference(date.toLocal());
  if (diff.inDays > 0) return '${diff.inDays}일전';
  if (diff.inHours > 0) return '${diff.inHours}시간전';
  if (diff.inMinutes > 0) return '${diff.inMinutes}분전';
  return '방금 전';
}
