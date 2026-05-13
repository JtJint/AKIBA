class UsedTradeSeller {
  final String nickname;
  final String profileImageUrl;
  final String intro;
  final int dealCount;
  final int reviewCount;

  const UsedTradeSeller({
    required this.nickname,
    required this.profileImageUrl,
    required this.intro,
    required this.dealCount,
    required this.reviewCount,
  });

  factory UsedTradeSeller.fromJson(dynamic json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return UsedTradeSeller(
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
  final String title;
  final String description;
  final int price;
  final String createdAtText;
  final int viewCount;
  final int favoriteCount;
  final String status;
  final String condition;
  final String deliveryMethod;
  final List<String> imageUrls;
  final UsedTradeSeller seller;

  const UsedTradeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.createdAtText,
    required this.viewCount,
    required this.favoriteCount,
    required this.status,
    required this.condition,
    required this.deliveryMethod,
    required this.imageUrls,
    required this.seller,
  });

  factory UsedTradeItem.fromJson(dynamic json) {
    final map = json is Map<String, dynamic>
        ? json
        : Map<String, dynamic>.from(json as Map);
    final images = _parseImages(map);

    return UsedTradeItem(
      id: _parseInt(map['postId'] ?? map['usedPostId'] ?? map['id']),
      title: (map['title'] ?? map['name'] ?? '중고거래 상품').toString(),
      description: (map['content'] ?? map['description'] ?? '').toString(),
      price: _parseInt(map['price']),
      createdAtText: _formatDateText(map['createdAt'] ?? map['createdAtText']),
      viewCount: _parseInt(map['viewCount']),
      favoriteCount: _parseInt(map['favoriteCount'] ?? map['likeCount']),
      status: (map['status'] ?? map['saleStatus'] ?? '판매중').toString(),
      condition: (map['conditionTxt'] ?? map['condition'] ?? '미개봉').toString(),
      deliveryMethod: (map['deliveryMethod'] ?? map['tradeMethod'] ?? '택배거래')
          .toString(),
      imageUrls: images.isEmpty
          ? const ['https://picsum.photos/seed/used-fallback/600/600']
          : images,
      seller: UsedTradeSeller.fromJson(map['seller'] ?? map['author']),
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
