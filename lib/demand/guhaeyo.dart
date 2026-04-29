import 'package:akiba/Carousel/rankingListTile.dart';
import 'package:akiba/Carousel/recommendCaroulsel.dart';
import 'package:akiba/demand/api/wanted_api.dart';
import 'package:akiba/demand/guhaeyo.detail.dart';
import 'package:akiba/search/SearchWidget.dart';
import 'package:akiba/utils/headerFiles.dart';
import 'package:akiba/models/recommendItem.dart';
import 'package:akiba/utils/responsive.dart';
import 'package:flutter/material.dart';

class GuhaeyoScreen extends StatefulWidget {
  const GuhaeyoScreen({super.key});

  @override
  State<GuhaeyoScreen> createState() => _GuhaeyoScreenState();
}

class _GuhaeyoScreenState extends State<GuhaeyoScreen> {
  List<dynamic> _wantedPosts = [];
  bool _isLoading = true;
  String? _errorText;
  @override
  void initState() {
    super.initState();
    _fetchWantedPosts();
  }

  Future<void> _fetchWantedPosts() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final posts = await WantedApi.getWantedPosts();
      setState(() {
        _wantedPosts = posts;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorText = '구해요 글을 불러오지 못했습니다.';
        _isLoading = false;
      });
      debugPrint('wanted posts fetch error: $error');
    }
  }

  List<_WantedPostViewModel> get _postItems {
    return _wantedPosts
        .map((post) => _WantedPostViewModel.fromJson(post))
        .where((item) => item.title.isNotEmpty)
        .toList();
  }

  List<RecommendItem> get _recommendItems {
    return _postItems
        .take(5)
        .map(
          (item) => RecommendItem(
            img: item.thumbnailUrl,
            title: item.title,
            subtitle: item.writerName,
            price: item.priceText,
          ),
        )
        .toList();
  }

  List<_WantedPostViewModel> get _rankingItems => _postItems.take(5).toList();
  List<_WantedPostViewModel> get _hotItems => _postItems.take(10).toList();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(360.0, 800.0);
    return Center(
      child: Container(
        width: contentWidth,
        child: Scaffold(
          backgroundColor: const Color(0xff141414),
          appBar: AppBar(
            backgroundColor: Color(0xff141414),
            title: Text('구해요', style: TextStyle(color: Colors.white)),
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            actions: [
              const SearchWidget(type: '구해요'), // 이미 분리해둔 거
            ],
          ),
          body: SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorText != null
                ? Center(
                    child: Text(
                      _errorText!,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  )
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: SectionHeader(
                          title: "이런 굿즈는 어때요?",
                          onMore: () {},
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: RecommendCarousel(
                          items: _recommendItems,
                          onTapItem: (item) {
                            final match = _postItems.where(
                              (post) => post.title == item.title,
                            );
                            if (match.isEmpty) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    GDetailScreen(postId: match.first.id),
                              ),
                            );
                          },
                        ),
                      ),
                      SliverToBoxAdapter(child: const SizedBox(height: 28)),
                      SliverToBoxAdapter(
                        child: SectionHeader(
                          title: "지금 가장 많이 찾는 굿즈!",
                          onMore: () {},
                        ),
                      ),
                      SliverList.separated(
                        itemCount: _rankingItems.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final item = _rankingItems[i];
                          return RankingListTile(
                            rank: i + 1,
                            title: item.title,
                            subtitle: item.writerName,
                            thumbnailUrl: item.thumbnailUrl,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      GDetailScreen(postId: item.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      SliverToBoxAdapter(child: const SizedBox(height: 28)),
                      SliverToBoxAdapter(
                        child: SectionHeader(
                          title: "지금 가장 핫한 매물!",
                          onMore: () {},
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: Responsive.ref(context) * 0.36,
                          child: _WantedHotCarousel(items: _hotItems),
                        ),
                      ),
                      SliverToBoxAdapter(child: const SizedBox(height: 24)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _WantedHotCarousel extends StatefulWidget {
  const _WantedHotCarousel({required this.items});

  final List<_WantedPostViewModel> items;

  @override
  State<_WantedHotCarousel> createState() => _WantedHotCarouselState();
}

class _WantedHotCarouselState extends State<_WantedHotCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.28);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Center(
        child: Text(
          '표시할 구해요 글이 없습니다.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return SizedBox(
      height: Responsive.ref(context) * 0.36,
      child: PageView.builder(
        controller: _pageController,
        padEnds: false,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.ref(context) * 0.01,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GDetailScreen(postId: item.id),
                  ),
                );
              },
              child: _WantedHotCard(item: item),
            ),
          );
        },
      ),
    );
  }
}

class _WantedHotCard extends StatelessWidget {
  const _WantedHotCard({required this.item});

  final _WantedPostViewModel item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              item.thumbnailUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.white10,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.white54,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.priceText,
          style: const TextStyle(
            color: Color(0xffD0FF00),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _WantedPostViewModel {
  final int id;
  final String title;
  final String writerName;
  final String thumbnailUrl;
  final String priceText;

  const _WantedPostViewModel({
    required this.id,
    required this.title,
    required this.writerName,
    required this.thumbnailUrl,
    required this.priceText,
  });

  factory _WantedPostViewModel.fromJson(dynamic raw) {
    final map = raw is Map<String, dynamic>
        ? raw
        : raw is Map
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};

    return _WantedPostViewModel(
      id: (map['postId'] ?? map['id'] ?? 0) as int,
      title: (map['title'] ?? map['wantedTitle'] ?? '').toString(),
      writerName:
          (map['writerNickname'] ??
                  map['nickname'] ??
                  map['writerName'] ??
                  '작성자')
              .toString(),
      thumbnailUrl:
          (map['thumbnailUrl'] ??
                  map['imageUrl'] ??
                  map['thumbnailImageUrl'] ??
                  'https://picsum.photos/seed/wanted/400/400')
              .toString(),
      priceText: _formatPrice(
        map['price'] ?? map['wantedPrice'] ?? map['hopePrice'],
      ),
    );
  }

  static String _formatPrice(dynamic rawPrice) {
    if (rawPrice == null) {
      return '가격 미정';
    }

    final number = int.tryParse(rawPrice.toString());
    if (number == null) {
      return rawPrice.toString();
    }

    final price = number.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    return '$price원';
  }
}
