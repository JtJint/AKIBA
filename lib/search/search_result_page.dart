import 'package:akiba/app_router.dart';
import 'package:akiba/colors.dart';
import 'package:akiba/search/api/market_search_api.dart';
import 'package:akiba/used/model/used_trade_models.dart';
import 'package:akiba/utils/responsive.dart';
import 'package:akiba/widgets/market_list_tile.dart';
import 'package:flutter/material.dart';

class SearchResultPage extends StatefulWidget {
  const SearchResultPage({
    super.key,
    required this.query,
    this.type,
    this.onlyActive,
    this.unOpenedOnly,
    this.sort,
  });

  final String query;
  final String? type;
  final bool? onlyActive;
  final bool? unOpenedOnly;
  final String? sort;

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  late Future<List<MarketSearchPost>> _items;

  @override
  void initState() {
    super.initState();
    _items = _fetchItems();
  }

  Future<List<MarketSearchPost>> _fetchItems() {
    return MarketSearchApi.searchPosts(
      keyword: widget.query,
      type: widget.type,
      onlyActive: widget.onlyActive,
      unOpenedOnly: widget.unOpenedOnly,
      sort: widget.sort,
      page: 0,
      size: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(360.0, 800.0);

    return Center(
      child: SizedBox(
        width: contentWidth,
        child: Scaffold(
          backgroundColor: BackGroundColor,
          appBar: AppBar(
            backgroundColor: BackGroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: Responsive.ref(context) * 0.04,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              '"${widget.query}" 검색 결과',
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.ref(context) * 0.035,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: FutureBuilder<List<MarketSearchPost>>(
            future: _items,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              final items = snapshot.data ?? const <MarketSearchPost>[];
              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.search_off,
                        size: 64,
                        color: Color(0xff838383),
                      ),
                      SizedBox(height: Responsive.ref(context) * 0.02),
                      Text(
                        '검색 결과가 없습니다',
                        style: TextStyle(
                          color: const Color(0xff838383),
                          fontSize: Responsive.ref(context) * 0.035,
                        ),
                      ),
                      SizedBox(height: Responsive.ref(context) * 0.02),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('돌아가기', style: TextStyle(color: PointColor)),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _SearchResultTile(
                    item: item,
                    onDeleted: () {
                      setState(() {
                        _items = _fetchItems();
                      });
                    },
                  );
                },
                itemCount: items.length,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.item, required this.onDeleted});

  final MarketSearchPost item;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return MarketListTile(
      title: item.title,
      priceText: _formatPrice(item.price),
      imageUrl: item.thumbnailUrl,
      badgeText: _typeLabel(item.type),
      metaText: item.createdAtText,
      onTap: () => _openDetail(context),
    );
  }

  Future<void> _openDetail(BuildContext context) async {
    final type = item.type.toUpperCase();
    Object? deleted;
    if (type.contains('WANTED')) {
      deleted = await Navigator.of(
        context,
      ).pushNamed(AppRouter.wantedDetailPath(item.postId));
      if (deleted == true) onDeleted();
      return;
    }

    if (type.contains('LIMITED')) {
      deleted = await Navigator.of(
        context,
      ).pushNamed(AppRouter.limitedDetailPath(item.postId));
      if (deleted == true) onDeleted();
      return;
    }

    if (type.contains('USED')) {
      deleted = await Navigator.of(context).pushNamed(
        AppRouter.usedDetail,
        arguments: UsedTradeDetailRouteArgs(
          postId: item.postId,
          item: UsedTradeItem.fromJson({
            'postId': item.postId,
            'title': item.title,
            'price': item.price,
            'thumbnailUrl': item.thumbnailUrl,
            'type': item.type,
          }),
        ),
      );
      if (deleted == true) onDeleted();
      return;
    }

    if (type.contains('AUCTION')) {
      deleted = await Navigator.of(
        context,
      ).pushNamed(AppRouter.auctionDetailPath(item.postId));
      if (deleted == true) onDeleted();
    }
  }

  String _typeLabel(String type) {
    final normalized = type.toUpperCase();
    if (normalized.contains('AUCTION')) return '경매';
    if (normalized.contains('WANTED')) return '구해요';
    if (normalized.contains('LIMITED')) return '특전/한정';
    return '중고거래';
  }

  String _formatPrice(int price) {
    if (price <= 0) return '가격문의';
    final formatted = price.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    return '$formatted원';
  }
}
