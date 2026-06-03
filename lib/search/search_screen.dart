import 'package:akiba/colors.dart';
import 'package:akiba/app_router.dart';
import 'package:akiba/search/api/market_search_api.dart';
import 'package:akiba/used/model/used_trade_models.dart';
import 'package:akiba/utils/responsive.dart';
import 'package:akiba/widgets/akiba_network_image.dart';
import 'package:flutter/material.dart';

/// Figma AKIBA Design - 검색 화면
class SearchScreen_ extends StatefulWidget {
  const SearchScreen_({super.key, required this.initialType});
  final String? initialType; // 'home' 또는 'guhaeyo'로 구분하여 초기 검색창 타입 설정
  @override
  State<SearchScreen_> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen_> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String? selectedType; // 'home' 또는 'guhaeyo' 중 선택된 타입
  static const List<String> _recentSearches = [
    '아이폰 15',
    '맥북 에어',
    '에어팟',
    '닌텐도 스위치',
  ];

  List<String> _recommendedTags = const [];
  List<PopularKeyword> _popularKeywords = const [];
  bool _isPopularBoxExpanded = false;
  bool _isKeywordLoading = true;

  void _onSearchChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    selectedType = widget.initialType == 'home'
        ? null
        : widget.initialType; // ✅ 여기서 미리 고정 칩 세팅
    _fetchSearchMeta();
  }

  Future<void> _fetchSearchMeta() async {
    try {
      final results = await Future.wait([
        MarketSearchApi.getRecommendedTags(type: _typeQueryValue, limit: 10),
        MarketSearchApi.getPopularKeywords(limit: 10),
      ]);
      if (!mounted) return;
      setState(() {
        final tags = results[0] as List<String>;
        final keywords = results[1] as List<PopularKeyword>;
        _recommendedTags = tags.take(10).toList();
        _popularKeywords = keywords;
        _isKeywordLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _recommendedTags = const [];
        _popularKeywords = const [];
        _isKeywordLoading = false;
      });
      debugPrint('search meta fetch error: $error');
    }
  }

  String? get _typeQueryValue {
    return switch (selectedType) {
      '중고거래' => 'USED',
      '특전/한정판' || '한정판' || '특전' => 'LIMITED',
      '경매' => 'AUCTION',
      _ => null,
    };
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(360.0, 800.0);
    return Center(
      child: Container(
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
              '검색',
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.ref(context) * 0.04,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.ref(context) * 0.04,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: Responsive.ref(context) * 0.02),
                  // 검색창
                  _SearchBar(
                    typeChip: selectedType,
                    controller: _searchController,
                    onRemoveType: () => setState(() => selectedType = null),
                    onChanged: (value) => setState(() {}),
                    onSubmitted: _performSearch,
                  ),
                  SizedBox(height: Responsive.ref(context) * 0.04),
                  // 최근 검색어
                  _buildSectionTitle('최근 검색어'),
                  SizedBox(height: Responsive.ref(context) * 0.015),
                  _buildSearchChips(_recentSearches),
                  SizedBox(height: Responsive.ref(context) * 0.04),
                  // 추천 검색어 태그
                  _buildSectionTitle('추천 검색어'),
                  SizedBox(height: Responsive.ref(context) * 0.015),
                  _buildRecommendedTags(),
                  SizedBox(height: Responsive.ref(context) * 0.04),
                  // 인기검색어 박스 (탭 시 확장)
                  _buildPopularSearchBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: Responsive.ref(context) * 0.035,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSearchChips(List<String> items) {
    return Wrap(
      spacing: Responsive.ref(context) * 0.02,
      runSpacing: Responsive.ref(context) * 0.02,
      children: items.map((item) {
        return GestureDetector(
          onTap: () => _performSearch(item),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.ref(context) * 0.03,
              vertical: Responsive.ref(context) * 0.015,
            ),
            decoration: BoxDecoration(
              color: Color(0xff1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color(0xff2A2A2A), width: 1),
            ),
            child: Text(
              item,
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.ref(context) * 0.03,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 추천 검색어 태그 (보라→초록 그라데이션 테두리)
  Widget _buildRecommendedTags() {
    final ref = Responsive.ref(context);
    final tags = _recommendedTags.isEmpty ? const ['-'] : _recommendedTags;
    return Wrap(
      spacing: ref * 0.02,
      runSpacing: ref * 0.02,
      children: tags.map((tag) {
        return GestureDetector(
          onTap: tag == '-' ? null : () => _performSearch(tag),
          child: Container(
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff8522D5),
                  Color(0xffA434FE),
                  Color(0xffD0FF00),
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(0xff8522D5).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ref * 0.03,
                vertical: ref * 0.015,
              ),
              decoration: BoxDecoration(
                color: Color(0xff1E1E1E),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                tag == '-' ? '-' : '#$tag',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ref * 0.03,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 인기검색어 박스 (탭 시 확장하여 10위권 표시)
  Widget _buildPopularSearchBox() {
    final ref = Responsive.ref(context);
    return GestureDetector(
      onTap: () =>
          setState(() => _isPopularBoxExpanded = !_isPopularBoxExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: EdgeInsets.all(ref * 0.03),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff1A1A2E), Color(0xff16213E), Color(0xff0F3460)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            width: 1.5,
            color: _isPopularBoxExpanded
                ? PointColor.withOpacity(0.5)
                : Color(0xff2A2A2A),
          ),
          boxShadow: [
            BoxShadow(
              color: _isPopularBoxExpanded
                  ? PointColor.withOpacity(0.15)
                  : Colors.black26,
              blurRadius: _isPopularBoxExpanded ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: PointColor,
                      size: ref * 0.04,
                    ),
                    SizedBox(width: ref * 0.015),
                    Text(
                      '인기검색어',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ref * 0.035,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                AnimatedRotation(
                  turns: _isPopularBoxExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white70,
                    size: ref * 0.05,
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: SizedBox(height: 0),
              secondChild: Column(
                children: [
                  SizedBox(height: ref * 0.02),
                  if (_isKeywordLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 18),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    ...List.generate(10, (index) {
                      final rank = index + 1;
                      final item = _popularKeywordAt(rank);
                      return GestureDetector(
                        onTap: item.keyword == '-'
                            ? null
                            : () => _performSearch(item.keyword),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: ref * 0.012),
                          child: Row(
                            children: [
                              Container(
                                width: ref * 0.06,
                                alignment: Alignment.center,
                                child: Text(
                                  '$rank',
                                  style: TextStyle(
                                    color: rank <= 3
                                        ? PointColor
                                        : Color(0xff838383),
                                    fontSize: ref * 0.028,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              SizedBox(width: ref * 0.02),
                              Expanded(
                                child: Text(
                                  item.keyword,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ref * 0.03,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
              crossFadeState: _isPopularBoxExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  void _performSearch(String query) {
    final normalized = query.trim();
    if (normalized.isEmpty) return;
    Navigator.of(context).pushNamed(
      AppRouter.searchResult,
      arguments: SearchResultRouteArgs(
        query: normalized,
        type: _typeQueryValue,
        onlyActive: true,
        unOpenedOnly: false,
        sort: 'latest',
      ),
    );
  }

  PopularKeyword _popularKeywordAt(int rank) {
    return _popularKeywords.firstWhere(
      (item) => item.rank == rank,
      orElse: () =>
          _popularKeywords.length >= rank
              ? _popularKeywords[rank - 1]
              : PopularKeyword(rank: rank, keyword: '-', trend: 'SAME'),
    );
  }
}

/// 검색 결과 화면
class SearchResultScreen extends StatefulWidget {
  final String query;
  final String? type;
  final bool? onlyActive;
  final bool? unOpenedOnly;
  final String? sort;

  const SearchResultScreen({
    super.key,
    required this.query,
    this.type,
    this.onlyActive,
    this.unOpenedOnly,
    this.sort,
  });

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
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
    return Scaffold(
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
                  Icon(Icons.search_off, size: 64, color: Color(0xff838383)),
                  SizedBox(height: Responsive.ref(context) * 0.02),
                  Text(
                    '검색 결과가 없습니다',
                    style: TextStyle(
                      color: Color(0xff838383),
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

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemBuilder: (context, index) {
              final item = items[index];
              return _SearchResultTile(item: item);
            },
            separatorBuilder: (_, __) => const Divider(color: Colors.white12),
            itemCount: items.length,
          );
        },
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.item});

  final MarketSearchPost item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openDetail(context),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: 64,
            height: 64,
            child: item.thumbnailUrl.isEmpty
                ? Container(color: const Color(0xff202020))
                : AkibaNetworkImage(
                    url: item.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_) =>
                        Container(color: const Color(0xff202020)),
                  ),
          ),
        ),
        title: Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          [
            _formatPrice(item.price),
            if (item.createdAtText.isNotEmpty) item.createdAtText,
          ].join(' · '),
          style: TextStyle(color: PointColor, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    final type = item.type.toUpperCase();
    if (type.contains('USED') || type.contains('LIMITED')) {
      Navigator.of(context).pushNamed(
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
      return;
    }

    if (type.contains('AUCTION')) {
      Navigator.of(context).pushNamed(AppRouter.auctionDetailPath(item.postId));
    }
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

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.typeChip,
    required this.controller,
    required this.onRemoveType,
    required this.onChanged,
    required this.onSubmitted,
  });

  final String? typeChip;
  final TextEditingController controller;
  final VoidCallback onRemoveType;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white70),
          const SizedBox(width: 8),

          if (typeChip != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xffD1FF00)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    typeChip!,
                    style: const TextStyle(
                      color: Color(0xffD1FF00),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onRemoveType,
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Color(0xffD1FF00),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
          ],

          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "검색어를 입력하세요",
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
            ),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.photo_camera_outlined,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
