import 'package:akiba/colors.dart';
import 'package:akiba/utils/responsive.dart';
import 'package:flutter/material.dart';

/// Figma AKIBA Design - 검색 화면
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  static const List<String> _recentSearches = [
    '아이폰 15',
    '맥북 에어',
    '에어팟',
    '닌텐도 스위치',
  ];

  /// 추천 검색어 태그
  static const List<String> _recommendedTags = ['중고거래', '경매', '한정판', '특전'];

  /// 인기 검색어 10위 (1위~10위)
  static const List<String> _popularSearchesTop10 = [
    '아이폰 15 Pro',
    '맥북 에어 M3',
    '에어팟 프로 2',
    '닌텐도 스위치',
    '소니 WH-1000XM5',
    '갤럭시 버즈2',
    '아이패드 미니',
    '애플워치 울트라',
    'PS5',
    'Xbox 시리즈 X',
  ];

  bool _isPopularBoxExpanded = false;

  void _onSearchChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
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
              _buildSearchBar(),
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
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () => _searchFocusNode.requestFocus(),
      child: Container(
        width: double.infinity,
        height: Responsive.ref(context) * 0.06,
        decoration: BoxDecoration(
          color: Color(0xff070707),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xff2A2A2A), width: 1),
        ),
        child: Row(
          children: [
            SizedBox(width: Responsive.ref(context) * 0.03),
            Icon(
              Icons.search,
              color: PointColor,
              size: Responsive.ref(context) * 0.04,
            ),
            SizedBox(width: Responsive.ref(context) * 0.02),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.ref(context) * 0.035,
                ),
                decoration: InputDecoration(
                  hintText: '검색어를 입력하세요',
                  hintStyle: TextStyle(
                    color: Color(0xff838383),
                    fontSize: Responsive.ref(context) * 0.035,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: Responsive.ref(context) * 0.015,
                  ),
                ),
                onSubmitted: (value) => _performSearch(value),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Color(0xff838383),
                  size: Responsive.ref(context) * 0.03,
                ),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              ),
            SizedBox(width: Responsive.ref(context) * 0.02),
          ],
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
    return Wrap(
      spacing: ref * 0.02,
      runSpacing: ref * 0.02,
      children: _recommendedTags.map((tag) {
        return GestureDetector(
          onTap: () => _performSearch(tag),
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
                '#$tag',
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
                  ...List.generate(_popularSearchesTop10.length, (index) {
                    final rank = index + 1;
                    final item = _popularSearchesTop10[index];
                    return GestureDetector(
                      onTap: () => _performSearch(item),
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
                                item,
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
    if (query.isEmpty) return;
    // TODO: 실제 검색 로직 구현
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => SearchResultScreen(query: query)),
    );
  }
}

/// 검색 결과 화면
class SearchResultScreen extends StatelessWidget {
  final String query;

  const SearchResultScreen({super.key, required this.query});

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
          '"$query" 검색 결과',
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.ref(context) * 0.035,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
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
      ),
    );
  }
}
