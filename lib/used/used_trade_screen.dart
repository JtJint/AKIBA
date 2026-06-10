import 'package:akiba/Carousel/recommendCaroulsel.dart';
import 'package:akiba/app_router.dart';
import 'package:akiba/market/market_list_screen.dart';
import 'package:akiba/used/api/used_trade_api.dart';
import 'package:akiba/used/model/used_trade_models.dart';
import 'package:akiba/used/widgets/used_trade_widgets.dart';
import 'package:akiba/utils/headerFiles.dart';
import 'package:akiba/widgets/akiba_shell.dart';
import 'package:flutter/material.dart';

class UsedTradeScreen extends StatefulWidget {
  const UsedTradeScreen({super.key});

  @override
  State<UsedTradeScreen> createState() => _UsedTradeScreenState();
}

class _UsedTradeScreenState extends State<UsedTradeScreen> {
  List<UsedTradeItem> _items = const [];
  List<UsedTradeItem> _popularItems = const [];
  bool _isLoading = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final results = await Future.wait([
        UsedTradeApi.getPosts(),
        UsedTradeApi.getPopularPosts(limit: 10),
      ]);
      if (!mounted) return;
      setState(() {
        _items = results[0];
        _popularItems = results[1];
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _items = const [];
        _popularItems = const [];
        _isLoading = false;
        _errorText = '중고거래 글을 불러오지 못했습니다.';
      });
      debugPrint('used posts fetch error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hotItems = (_popularItems.isEmpty ? _items : _popularItems)
        .take(6)
        .toList();
    final recentItems = _items.reversed.take(6).toList();
    final recommendItems = buildRecommendItemsFromUsed(_items);

    return AkibaShell(
      selectedIndex: 0,
      showAppBar: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: TopBar(
              title: '중고거래',
              onBack: () => Navigator.of(context).pop(),
            ),
          ),
          const SliverToBoxAdapter(
            child: UsedTradeSearchBar(hintText: '중고거래 내에서 검색하세요'),
          ),
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          if (_errorText != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _errorText!,
                  style: const TextStyle(color: Colors.white54),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 22)),
          SliverToBoxAdapter(
            child: UsedTradeHorizontalSection(
              title: '지금 가장 핫한 매물!',
              items: hotItems,
              onMore: () => _openList(MarketListType.usedPopular),
              onTapItem: (item) {
                Navigator.of(context).pushNamed(
                  AppRouter.usedDetail,
                  arguments: UsedTradeDetailRouteArgs(
                    postId: item.id,
                    item: item,
                  ),
                );
              },
            ),
          ),
          if (recommendItems.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: '이런 굿즈는 어때요?',
                onMore: () => _openList(MarketListType.usedLatest),
              ),
            ),
            SliverToBoxAdapter(
              child: RecommendCarousel(
                items: recommendItems,
                onTapItem: (item) {
                  final match = _items.firstWhere(
                    (element) => element.title == item.title,
                    orElse: () => _items.first,
                  );
                  Navigator.of(context).pushNamed(
                    AppRouter.usedDetail,
                    arguments: UsedTradeDetailRouteArgs(
                      postId: match.id,
                      item: match,
                    ),
                  );
                },
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
          SliverToBoxAdapter(
            child: UsedTradeHorizontalSection(
              title: '최근 본 상품',
              items: recentItems,
              onMore: () => _openList(MarketListType.usedLatest),
              onTapItem: (item) {
                Navigator.of(context).pushNamed(
                  AppRouter.usedDetail,
                  arguments: UsedTradeDetailRouteArgs(
                    postId: item.id,
                    item: item,
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  void _openList(MarketListType type) {
    Navigator.of(context).pushNamed(
      AppRouter.marketList,
      arguments: MarketListRouteArgs(type: type),
    );
  }
}

const UsedTradeSeller _narutoSeller = UsedTradeSeller(
  nickname: '나루토짱',
  profileImageUrl: 'https://picsum.photos/seed/naruto-seller/200/200',
  intro: '언제든 쪽지 환영입니다!',
  dealCount: 4,
  reviewCount: 3,
);

final List<UsedTradeItem> usedTradeDummyItems = [
  UsedTradeItem(
    id: 1,
    title: '우사기 굿즈 세트',
    description: '귀여운 우사기 굿즈를 한 번에 정리합니다. 상태 좋고 구성도 알찹니다.',
    price: 100000,
    createdAtText: '1일전',
    viewCount: 45,
    favoriteCount: 5,
    status: '판매중',
    condition: '미개봉',
    deliveryMethod: '택배거래',
    imageUrls: const [
      'https://images.unsplash.com/photo-1618331835717-801e976710b2?auto=format&fit=crop&w=1200&q=80',
    ],
    seller: _narutoSeller,
  ),
  UsedTradeItem(
    id: 2,
    title: '하이큐 굿즈',
    description: '하이큐 아크릴과 소품 묶음 판매합니다. 미개봉 제품 위주입니다.',
    price: 20000,
    createdAtText: '1일전',
    viewCount: 32,
    favoriteCount: 2,
    status: '판매중',
    condition: '미개봉',
    deliveryMethod: '택배거래',
    imageUrls: const [
      'https://images.unsplash.com/photo-1511512578047-dfb367046420?auto=format&fit=crop&w=1200&q=80',
    ],
    seller: _narutoSeller,
  ),
  UsedTradeItem(
    id: 3,
    title: '주술회전 만쥬겔',
    description: '주술회전 굿즈 일괄 판매합니다. 박스 포함으로 보내드려요.',
    price: 15000,
    createdAtText: '2일전',
    viewCount: 18,
    favoriteCount: 3,
    status: '판매중',
    condition: '개봉',
    deliveryMethod: '택배거래',
    imageUrls: const [
      'https://images.unsplash.com/photo-1608889825103-eb5ed706fc64?auto=format&fit=crop&w=1200&q=80',
    ],
    seller: _narutoSeller,
  ),
  UsedTradeItem(
    id: 4,
    title: '짱구 피규어 세트',
    description: '짱구 피규어 세트 팝니다. 책장 전시만 했고 하자 없습니다.',
    price: 5000,
    createdAtText: '2일전',
    viewCount: 12,
    favoriteCount: 1,
    status: '판매중',
    condition: '개봉',
    deliveryMethod: '직거래',
    imageUrls: const [
      'https://images.unsplash.com/photo-1523413651479-597eb2da0ad6?auto=format&fit=crop&w=1200&q=80',
    ],
    seller: _narutoSeller,
  ),
  UsedTradeItem(
    id: 5,
    title: '반프레스토 나루토 피규어',
    description: '*거래 후 환불 불가* 책상 위에 올려두면 귀여워요!! 미개봉이고 택배거래 선호합니다. 편하게 쪽지 주세요!',
    price: 10000,
    createdAtText: '1일전',
    viewCount: 45,
    favoriteCount: 5,
    status: '판매중',
    condition: '미개봉',
    deliveryMethod: '택배거래',
    imageUrls: const [
      'https://images.unsplash.com/photo-1578632767115-351597cf2477?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1608889825271-9696288f2fe0?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1511884642898-4c92249e20b6?auto=format&fit=crop&w=1200&q=80',
    ],
    seller: _narutoSeller,
  ),
  UsedTradeItem(
    id: 6,
    title: '나루토 콤비네이션 배틀',
    description: '나루토 콤비네이션 배틀 라인 판매합니다. 박스 상태도 좋습니다.',
    price: 10000,
    createdAtText: '3일전',
    viewCount: 20,
    favoriteCount: 4,
    status: '판매중',
    condition: '미개봉',
    deliveryMethod: '택배거래',
    imageUrls: const [
      'https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&w=1200&q=80',
    ],
    seller: _narutoSeller,
  ),
  UsedTradeItem(
    id: 7,
    title: '우즈마키 나루토 룩업',
    description: '귀여운 룩업 피규어 판매합니다. 디테일 예쁘고 보관 상태 깔끔해요.',
    price: 10000,
    createdAtText: '3일전',
    viewCount: 27,
    favoriteCount: 6,
    status: '판매중',
    condition: '미개봉',
    deliveryMethod: '택배거래',
    imageUrls: const [
      'https://images.unsplash.com/photo-1593305841991-05c297ba4575?auto=format&fit=crop&w=1200&q=80',
    ],
    seller: _narutoSeller,
  ),
  UsedTradeItem(
    id: 8,
    title: '우즈마키 나루토 스탠드',
    description: '한정 스탠드 굿즈입니다. 택배 안전포장 가능합니다.',
    price: 10000,
    createdAtText: '4일전',
    viewCount: 16,
    favoriteCount: 2,
    status: '판매중',
    condition: '미개봉',
    deliveryMethod: '택배거래',
    imageUrls: const [
      'https://images.unsplash.com/photo-1542751110-97427bbecf20?auto=format&fit=crop&w=1200&q=80',
    ],
    seller: _narutoSeller,
  ),
];
