class UsedTradeSeller {
  final int userId;
  final String nickname;
  final String profileImageUrl;
  final String intro;
  final int dealCount;
  final int reviewCount;

  const UsedTradeSeller({
    this.userId = 0,
    required this.nickname,
    required this.profileImageUrl,
    required this.intro,
    required this.dealCount,
    required this.reviewCount,
  });

  factory UsedTradeSeller.fromJson(dynamic json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return UsedTradeSeller(
      userId: _parseInt(map['userId'] ?? map['sellerId'] ?? map['id']),
      nickname: (map['nickname'] ?? map['name'] ?? map['sellerName'] ?? '판매자')
          .toString(),
      profileImageUrl:
          (map['profileImageUrl'] ??
                  map['profileUrl'] ??
                  'https://picsum.photos/seed/used-seller/200/200')
              .toString(),
      intro: (map['intro'] ?? map['bio'] ?? '언제든 쪽지 환영입니다!').toString(),
      dealCount: _parseInt(map['dealCount'] ?? map['tradeCount']),
      reviewCount: _parseInt(map['reviewCount'] ?? map['reviewsCount']),
    );
  }
}

class UsedTradeItem {
  final int id;
  final String type;
  final String title;
  final String description;
  final int price;
  final String createdAtText;
  final int viewCount;
  final int favoriteCount;
  final String status;
  final String condition;
  final String specialType;
  final int categoryId;
  final String deliveryMethod;
  final String purchaseSource;
  final int receiptMediaId;
  final List<String> imageUrls;
  final List<int> imageMediaIds;
  final List<String> tags;
  final UsedTradeSeller seller;
  final bool favorite;

  const UsedTradeItem({
    required this.id,
    this.type = 'USED',
    required this.title,
    required this.description,
    required this.price,
    required this.createdAtText,
    required this.viewCount,
    required this.favoriteCount,
    required this.status,
    required this.condition,
    this.specialType = 'NONE',
    this.categoryId = 0,
    required this.deliveryMethod,
    this.purchaseSource = '',
    this.receiptMediaId = 0,
    required this.imageUrls,
    this.imageMediaIds = const [],
    this.tags = const [],
    required this.seller,
    this.favorite = false,
  });

  factory UsedTradeItem.fromJson(dynamic json) {
    final map = json is Map<String, dynamic>
        ? json
        : Map<String, dynamic>.from(json as Map);
    final images = _parseImages(map);

    return UsedTradeItem(
      id: _parseInt(map['postId'] ?? map['usedPostId'] ?? map['id']),
      type: (map['type'] ?? 'USED').toString(),
      title: (map['title'] ?? map['name'] ?? '중고거래 상품').toString(),
      description: (map['content'] ?? map['description'] ?? '').toString(),
      price: _parseInt(map['price']),
      createdAtText: _formatDateText(map['createdAt'] ?? map['createdAtText']),
      viewCount: _parseInt(map['viewCount']),
      favoriteCount: _parseInt(map['favoriteCount'] ?? map['likeCount']),
      status: (map['status'] ?? map['saleStatus'] ?? '판매중').toString(),
      condition:
          (map['productCondition'] ??
                  map['conditionTxt'] ??
                  map['condition'] ??
                  '미개봉')
              .toString(),
      specialType: (map['specialType'] ?? 'NONE').toString(),
      categoryId: _parseInt(map['categoryId']),
      deliveryMethod: (map['deliveryMethod'] ?? map['tradeMethod'] ?? '택배거래')
          .toString(),
      purchaseSource: (map['purchaseSource'] ?? '').toString(),
      receiptMediaId: _parseInt(map['receiptMediaId']),
      imageUrls: images.isEmpty
          ? const ['https://picsum.photos/seed/used-fallback/600/600']
          : images,
      imageMediaIds: _parseImageMediaIds(map),
      tags: _parseStringList(map['tags'] ?? map['tagNames'] ?? map['hashtags']),
      seller: UsedTradeSeller.fromJson(map['seller'] ?? map['author']),
      favorite: map['favorite'] == true,
    );
  }
}

List<String> _parseImages(Map<String, dynamic> map) {
  final raw = map['images'] ?? map['imageUrls'] ?? map['imageUrl'];
  if (raw is String && raw.isNotEmpty) {
    return [raw];
  }
  if (raw is List) {
    return raw
        .map((image) {
          if (image is String) return image;
          if (image is Map) {
            return (image['imageUrl'] ?? image['url'] ?? '').toString();
          }
          return '';
        })
        .where((url) => url.isNotEmpty)
        .toList();
  }
  final thumbnail = (map['thumbnailUrl'] ?? '').toString();
  return thumbnail.isEmpty ? [] : [thumbnail];
}

List<int> _parseImageMediaIds(Map<String, dynamic> map) {
  final raw = map['images'] ?? map['imageMediaIds'];
  if (raw is List) {
    return raw
        .map((image) {
          if (image is int) return image;
          if (image is num) return image.toInt();
          if (image is Map) return _parseInt(image['mediaId'] ?? image['id']);
          return _parseInt(image);
        })
        .where((id) => id > 0)
        .toList();
  }
  return [];
}

List<String> _parseStringList(dynamic raw) {
  if (raw is List) {
    return raw
        .map((value) => value?.toString() ?? '')
        .where((value) => value.isNotEmpty)
        .toList();
  }
  return [];
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _formatDateText(dynamic value) {
  final raw = value?.toString() ?? '';
  final date = DateTime.tryParse(raw);
  if (date == null) return raw.isEmpty ? '방금 전' : raw;

  final diff = DateTime.now().difference(date.toLocal());
  if (diff.inDays > 0) return '${diff.inDays}일전';
  if (diff.inHours > 0) return '${diff.inHours}시간전';
  if (diff.inMinutes > 0) return '${diff.inMinutes}분전';
  return '방금 전';
}
