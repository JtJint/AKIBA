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
  if (raw is String && raw.isNotEmpty) return raw;

  final images = map['images'] ?? map['imageUrls'];
  if (images is List && images.isNotEmpty) {
    final first = images.first;
    if (first is String) return first;
    if (first is Map) {
      return (first['imageUrl'] ?? first['url'] ?? '').toString();
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

final List<LimitedItem> limitedDummyItems = [
  const LimitedItem(
    id: 1,
    title: '우사기 굿즈 세트',
    price: 100000,
    category: '중고거래',
    status: '판매중',
    condition: '미개봉',
    createdAtText: '1일전',
    imageUrl:
        'https://images.unsplash.com/photo-1618331835717-801e976710b2?auto=format&fit=crop&w=900&q=80',
    description: '귀여운 우사기 한정 굿즈 세트입니다.',
  ),
  const LimitedItem(
    id: 2,
    title: '하이큐 굿즈',
    price: 100000,
    category: '중고거래',
    status: '판매중',
    condition: '미개봉',
    createdAtText: '1일전',
    imageUrl:
        'https://images.unsplash.com/photo-1511512578047-dfb367046420?auto=format&fit=crop&w=900&q=80',
    description: '하이큐 한정판 피규어와 소품 묶음입니다.',
  ),
  const LimitedItem(
    id: 3,
    title: '주술회전 머그컵',
    price: 15000,
    category: '중고거래',
    status: '판매중',
    condition: '개봉',
    createdAtText: '1일전',
    imageUrl:
        'https://images.unsplash.com/photo-1608889825103-eb5ed706fc64?auto=format&fit=crop&w=900&q=80',
    description: '주술회전 한정 머그컵입니다.',
  ),
  const LimitedItem(
    id: 4,
    title: '짱구 보관함',
    price: 5000,
    category: '중고거래',
    status: '판매중',
    condition: '미개봉',
    createdAtText: '1일전',
    imageUrl:
        'https://images.unsplash.com/photo-1523413651479-597eb2da0ad6?auto=format&fit=crop&w=900&q=80',
    description: '짱구 특전 보관함입니다.',
  ),
  const LimitedItem(
    id: 5,
    title: '반프레스토 나루토 점프 우즈마키 피규어',
    price: 48500,
    category: '중고거래',
    status: '판매중',
    condition: '미개봉',
    createdAtText: '1일전',
    imageUrl:
        'https://images.unsplash.com/photo-1578632767115-351597cf2477?auto=format&fit=crop&w=900&q=80',
    description: '나루토 점프 특전 피규어입니다.',
  ),
  const LimitedItem(
    id: 6,
    title: '나루토 콤비네이션 배틀 우즈마키',
    price: 42700,
    category: '중고거래',
    status: '판매중',
    condition: '미개봉',
    createdAtText: '1일전',
    imageUrl:
        'https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&w=900&q=80',
    description: '나루토 콤비네이션 배틀 한정판입니다.',
  ),
];
