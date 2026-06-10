import 'package:akiba/app_router.dart';
import 'package:akiba/Carousel/AutionCareven.dart';
import 'package:akiba/Carousel/careven.dart';
import 'package:akiba/Carousel/ItemCareven.dart';
import 'package:akiba/Cards/category.dart';
import 'package:akiba/limited/api/limited_api.dart';
import 'package:akiba/limited/limited_widgets.dart';
import 'package:akiba/limited/model/limited_models.dart';
import 'package:akiba/search/api/market_search_api.dart';
import 'package:akiba/used/api/used_trade_api.dart';
import 'package:akiba/used/model/used_trade_models.dart';
import 'package:akiba/used/widgets/used_trade_widgets.dart';
import 'package:akiba/utils/responsive.dart';
import 'package:akiba/widgets/akiba_shell.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MarketSearchPost> _marketPopularItems = const [];
  List<UsedTradeItem> _usedPopularItems = const [];
  List<LimitedItem> _limitedPopularItems = const [];
  bool _isMarketPopularLoading = true;
  bool _isUsedPopularLoading = true;
  bool _isLimitedPopularLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPopularItems();
  }

  Future<void> _fetchPopularItems() async {
    _fetchMarketPopularItems();
    _fetchUsedPopularItems();
    _fetchLimitedPopularItems();
  }

  Future<void> _fetchMarketPopularItems() async {
    try {
      final items = await MarketSearchApi.getPopularPosts(
        type: 'USED',
        limit: 3,
      );
      if (!mounted) return;
      setState(() {
        _marketPopularItems = items;
        _isMarketPopularLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _marketPopularItems = const [];
        _isMarketPopularLoading = false;
      });
      debugPrint('home market popular fetch error: $error');
    }
  }

  Future<void> _fetchUsedPopularItems() async {
    try {
      final items = await UsedTradeApi.getPopularPosts(limit: 10);
      if (!mounted) return;
      setState(() {
        _usedPopularItems = items;
        _isUsedPopularLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _usedPopularItems = const [];
        _isUsedPopularLoading = false;
      });
      debugPrint('home used popular fetch error: $error');
    }
  }

  Future<void> _fetchLimitedPopularItems() async {
    try {
      final items = await LimitedApi.getPopularPosts(limit: 10);
      if (!mounted) return;
      setState(() {
        _limitedPopularItems = items;
        _isLimitedPopularLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _limitedPopularItems = const [];
        _isLimitedPopularLoading = false;
      });
      debugPrint('home limited popular fetch error: $error');
    }
  }

  List<PopularCarouselItem> _buildUsedPopularCarouselItems() {
    return _usedPopularItems.map((item) {
      return PopularCarouselItem(
        imageUrl: item.imageUrls.first,
        title: item.title,
        priceText: formatUsedTradePrice(item.price),
        onTap: () async {
          final deleted = await Navigator.of(context).pushNamed(
            AppRouter.usedDetail,
            arguments: UsedTradeDetailRouteArgs(postId: item.id, item: item),
          );
          if (deleted == true && mounted) _fetchPopularItems();
        },
      );
    }).toList();
  }

  List<PopularCarouselItem> _buildLimitedPopularCarouselItems() {
    return _limitedPopularItems.map((item) {
      return PopularCarouselItem(
        imageUrl: item.imageUrl,
        title: item.title,
        priceText: formatLimitedPrice(item.price),
        onTap: () async {
          final deleted = await Navigator.of(
            context,
          ).pushNamed(AppRouter.limitedDetailPath(item.id));
          if (deleted == true && mounted) _fetchPopularItems();
        },
      );
    }).toList();
  }

  List<CarevenItem> _buildMarketPopularCarouselItems() {
    return _marketPopularItems.map((item) {
      return CarevenItem(
        imageUrl: item.thumbnailUrl.isEmpty
            ? 'https://picsum.photos/seed/market-${item.postId}/600/600'
            : item.thumbnailUrl,
        title: item.title,
        description: _formatMarketPopularDescription(item),
        tags: [_marketTypeLabel(item.type)],
        onTap: () => _openMarketPost(item),
      );
    }).toList();
  }

  Future<void> _openMarketPost(MarketSearchPost item) async {
    final type = item.type.toUpperCase();
    Object? deleted;
    if (type.contains('AUCTION')) {
      deleted = await Navigator.of(
        context,
      ).pushNamed(AppRouter.auctionDetailPath(item.postId));
      if (deleted == true && mounted) _fetchPopularItems();
      return;
    }
    if (type.contains('WANTED') || type.contains('REQUEST')) {
      deleted = await Navigator.of(
        context,
      ).pushNamed(AppRouter.wantedDetailPath(item.postId));
      if (deleted == true && mounted) _fetchPopularItems();
      return;
    }
    if (type.contains('LIMITED')) {
      deleted = await Navigator.of(
        context,
      ).pushNamed(AppRouter.limitedDetailPath(item.postId));
      if (deleted == true && mounted) _fetchPopularItems();
      return;
    }

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
    if (deleted == true && mounted) _fetchPopularItems();
  }

  String _formatMarketPopularDescription(MarketSearchPost item) {
    final price = item.price <= 0
        ? '가격문의'
        : '${item.price.toString().replaceAllMapped(
            RegExp(r'\B(?=(\d{3})+(?!\d))'),
            (match) => ',',
          )}원';
    final createdAt = item.createdAtText.isEmpty ? '' : item.createdAtText;
    return [price, createdAt].where((text) => text.isNotEmpty).join(' · ');
  }

  String _marketTypeLabel(String type) {
    final normalized = type.toUpperCase();
    if (normalized.contains('AUCTION')) return '경매';
    if (normalized.contains('WANTED') || normalized.contains('REQUEST')) {
      return '구해요';
    }
    if (normalized.contains('LIMITED')) return '특전/한정';
    return '중고거래';
  }

  int getSelectedIndexFromRoute(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;

    switch (routeName) {
      case AppRouter.main:
        return 0;
      case AppRouter.write:
        return 1;
      case AppRouter.community:
        return 2;
      case AppRouter.chat:
        return 3;
      case AppRouter.mypage:
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AkibaShell(
        selectedIndex: getSelectedIndexFromRoute(context),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: Responsive.ref(context) * 0.02),
              Careven(
                items: _buildMarketPopularCarouselItems(),
                isLoading: _isMarketPopularLoading,
              ),
              SizedBox(height: Responsive.ref(context) * 0.02),
              category(),
              SizedBox(height: Responsive.ref(context) * 0.02),
              _HomeSectionHeader(
                title: '중고거래 인기매물',
                onMoreTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.used),
              ),
              SizedBox(height: Responsive.ref(context) * 0.02),
              Itemcareven(
                items: _buildUsedPopularCarouselItems(),
                isLoading: _isUsedPopularLoading,
              ),
              SizedBox(height: Responsive.ref(context) * 0.02),
              SizedBox(height: Responsive.ref(context) * 0.02),
              SizedBox(height: Responsive.ref(context) * 0.02),
              _HomeSectionHeader(
                title: '특전/한정판 인기매물',
                onMoreTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.limited),
              ),
              SizedBox(height: Responsive.ref(context) * 0.02),
              Itemcareven(
                items: _buildLimitedPopularCarouselItems(),
                isLoading: _isLimitedPopularLoading,
              ),
              SizedBox(height: Responsive.ref(context) * 0.06),
              _HomeSectionHeader(
                title: '곧 입찰이 끝나요!',
                onMoreTap: () async {
                  final changed = await Navigator.of(
                    context,
                  ).pushNamed(AppRouter.auctionEndingSoon);
                  if (changed == true && mounted) _fetchPopularItems();
                },
              ),
              SizedBox(height: Responsive.ref(context) * 0.02),
              const Autioncareven(),
              SizedBox(height: Responsive.ref(context) * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeSectionHeader extends StatelessWidget {
  const _HomeSectionHeader({required this.title, required this.onMoreTap});

  final String title;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: Responsive.ref(context) * 0.03),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: Responsive.ref(context) * 0.03,
            ),
          ),
        ),
        Row(
          children: [
            Text(
              '더보기',
              style: TextStyle(
                color: Colors.white54,
                fontSize: Responsive.ref(context) * 0.025,
              ),
            ),
            IconButton(
              onPressed: onMoreTap,
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              color: Colors.white54,
            ),
          ],
        ),
      ],
    );
  }
}

class myListTile extends StatelessWidget {
  final String label;
  const myListTile({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(label));
  }
}
