import 'package:akiba/app_router.dart';
import 'package:akiba/config/api_config.dart';
import 'package:akiba/demand/api/wanted_api.dart';
import 'package:akiba/limited/api/limited_api.dart';
import 'package:akiba/limited/limited_widgets.dart';
import 'package:akiba/limited/model/limited_models.dart';
import 'package:akiba/used/api/used_trade_api.dart';
import 'package:akiba/used/model/used_trade_models.dart';
import 'package:akiba/used/widgets/used_trade_widgets.dart';
import 'package:akiba/utils/headerFiles.dart';
import 'package:akiba/widgets/akiba_shell.dart';
import 'package:akiba/widgets/market_list_tile.dart';
import 'package:flutter/material.dart';

enum MarketListType {
  usedPopular,
  usedLatest,
  limitedPopular,
  limitedLatest,
  wantedLatest,
}

class MarketListScreen extends StatefulWidget {
  const MarketListScreen({super.key, required this.type});

  final MarketListType type;

  @override
  State<MarketListScreen> createState() => _MarketListScreenState();
}

class _MarketListScreenState extends State<MarketListScreen> {
  late Future<List<_MarketListItem>> _items;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _items = _fetchItems();
  }

  Future<List<_MarketListItem>> _fetchItems() async {
    return switch (widget.type) {
      MarketListType.usedPopular => (await UsedTradeApi.getPopularPosts(
        limit: 40,
      )).map(_MarketListItem.fromUsed).toList(),
      MarketListType.usedLatest => (await UsedTradeApi.getPosts(
        size: 40,
      )).map(_MarketListItem.fromUsed).toList(),
      MarketListType.limitedPopular => (await LimitedApi.getPopularPosts(
        limit: 40,
      )).map(_MarketListItem.fromLimited).toList(),
      MarketListType.limitedLatest =>
        (await LimitedApi.getItems()).map(_MarketListItem.fromLimited).toList(),
      MarketListType.wantedLatest =>
        (await WantedApi.getWantedPosts())
            .map(_MarketListItem.fromWanted)
            .where((item) => item.id > 0 || item.title.isNotEmpty)
            .toList(),
    };
  }

  String get _title {
    return switch (widget.type) {
      MarketListType.usedPopular => '중고거래 인기매물',
      MarketListType.usedLatest => '중고거래 전체보기',
      MarketListType.limitedPopular => '특전/한정판 인기매물',
      MarketListType.limitedLatest => '특전/한정판 전체보기',
      MarketListType.wantedLatest => '구해요 전체보기',
    };
  }

  @override
  Widget build(BuildContext context) {
    return AkibaShell(
      selectedIndex: 0,
      showAppBar: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: TopBar(
              title: _title,
              onBack: () => Navigator.of(context).pop(_changed ? true : null),
            ),
          ),
          FutureBuilder<List<_MarketListItem>>(
            future: _items,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final items = snapshot.data ?? const <_MarketListItem>[];
              if (items.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      '표시할 글이 없습니다.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = items[index];
                    return MarketListTile(
                      title: item.title,
                      priceText: item.priceText,
                      imageUrl: item.imageUrl,
                      badgeText: item.badgeText,
                      metaText: item.metaText,
                      onTap: () => _openDetail(item),
                    );
                  }, childCount: items.length),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openDetail(_MarketListItem item) async {
    Object? deleted;
    switch (item.kind) {
      case _MarketListKind.used:
        deleted = await Navigator.of(context).pushNamed(
          AppRouter.usedDetail,
          arguments: UsedTradeDetailRouteArgs(
            postId: item.id,
            item: item.rawUsed,
          ),
        );
      case _MarketListKind.limited:
        deleted = await Navigator.of(
          context,
        ).pushNamed(AppRouter.limitedDetailPath(item.id));
      case _MarketListKind.wanted:
        deleted = await Navigator.of(
          context,
        ).pushNamed(AppRouter.wantedDetailPath(item.id));
    }

    if (!mounted || deleted != true) return;
    setState(() {
      _changed = true;
      _items = _fetchItems();
    });
  }
}

enum _MarketListKind { used, limited, wanted }

class _MarketListItem {
  const _MarketListItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.priceText,
    required this.imageUrl,
    required this.badgeText,
    required this.metaText,
    this.rawUsed,
  });

  final int id;
  final _MarketListKind kind;
  final String title;
  final String priceText;
  final String imageUrl;
  final String badgeText;
  final String metaText;
  final UsedTradeItem? rawUsed;

  factory _MarketListItem.fromUsed(UsedTradeItem item) {
    return _MarketListItem(
      id: item.id,
      kind: _MarketListKind.used,
      title: item.title,
      priceText: formatUsedTradePrice(item.price),
      imageUrl: item.imageUrls.isEmpty ? '' : item.imageUrls.first,
      badgeText: '중고거래',
      metaText: [
        item.condition,
        item.createdAtText,
        '관심 ${item.favoriteCount}',
      ].where((text) => text.isNotEmpty).join(' · '),
      rawUsed: item,
    );
  }

  factory _MarketListItem.fromLimited(LimitedItem item) {
    return _MarketListItem(
      id: item.id,
      kind: _MarketListKind.limited,
      title: item.title,
      priceText: formatLimitedPrice(item.price),
      imageUrl: item.imageUrl,
      badgeText: '특전/한정',
      metaText: [
        item.condition,
        item.createdAtText,
        item.status,
      ].where((text) => text.isNotEmpty).join(' · '),
    );
  }

  factory _MarketListItem.fromWanted(dynamic raw) {
    final map = raw is Map<String, dynamic>
        ? raw
        : raw is Map
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};
    return _MarketListItem(
      id: _parseInt(map['postId'] ?? map['wantedPostId'] ?? map['id']),
      kind: _MarketListKind.wanted,
      title: (map['title'] ?? '').toString(),
      priceText: formatUsedTradePrice(_parseInt(map['price'])),
      imageUrl: _parseWantedImageUrl(map),
      badgeText: '구해요',
      metaText: [
        (map['conditionTxt'] ?? map['productCondition'] ?? '').toString(),
        _formatDateText(map['createdAt'] ?? map['createdAtText']),
      ].where((text) => text.isNotEmpty).join(' · '),
    );
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _parseWantedImageUrl(Map<String, dynamic> map) {
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
        (first['imageUrl'] ?? first['url'] ?? '').toString(),
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
