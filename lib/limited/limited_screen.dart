import 'package:akiba/app_router.dart';
import 'package:akiba/limited/api/limited_api.dart';
import 'package:akiba/limited/limited_widgets.dart';
import 'package:akiba/limited/model/limited_models.dart';
import 'package:akiba/utils/headerFiles.dart';
import 'package:akiba/widgets/akiba_shell.dart';
import 'package:flutter/material.dart';

class LimitedScreen extends StatefulWidget {
  const LimitedScreen({super.key});

  @override
  State<LimitedScreen> createState() => _LimitedScreenState();
}

class _LimitedScreenState extends State<LimitedScreen> {
  List<LimitedItem> _items = limitedDummyItems;
  bool _isLoading = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    try {
      final items = await LimitedApi.getItems();
      if (!mounted) return;
      setState(() {
        _items = items.isEmpty ? limitedDummyItems : items;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _items = limitedDummyItems;
        _isLoading = false;
        _errorText = '특전/한정판 글을 불러오지 못했습니다.';
      });
      debugPrint('limited fetch error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hotItems = _items.take(4).toList();
    final recommendItems = _items.skip(2).take(8).toList();
    final recentItems = _items.reversed.take(8).toList();

    return AkibaShell(
      selectedIndex: 0,
      showAppBar: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: TopBar(
              title: '특전/한정판',
              onBack: () => Navigator.of(context).pop(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(
                  AppRouter.search,
                  arguments: const SearchRouteArgs(initialType: '특전/한정판'),
                ),
                child: const LimitedSearchBar(
                  hintText: '특전/한정판 내에서 검색하세요',
                  readOnly: true,
                ),
              ),
            ),
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  _errorText!,
                  style: const TextStyle(color: Colors.white54),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 22)),
          SliverToBoxAdapter(
            child: _LargeLimitedSection(
              title: '지금 가장 핫한 매물 !',
              items: hotItems,
            ),
          ),
          SliverToBoxAdapter(
            child: _LimitedHorizontalSection(
              title: '좋아하실 것 같아요!',
              items: recommendItems,
            ),
          ),
          SliverToBoxAdapter(
            child: _LimitedHorizontalSection(
              title: '최근 본 상품',
              items: recentItems,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _LargeLimitedSection extends StatelessWidget {
  const _LargeLimitedSection({required this.title, required this.items});

  final String title;
  final List<LimitedItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(title: title, onMore: () {}),
        SizedBox(
          height: 270,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) => LimitedLargeCard(item: items[index]),
          ),
        ),
      ],
    );
  }
}

class _LimitedHorizontalSection extends StatelessWidget {
  const _LimitedHorizontalSection({required this.title, required this.items});

  final String title;
  final List<LimitedItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(title: title, onMore: () {}),
        SizedBox(
          height: 166,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) => LimitedThumbCard(item: items[index]),
          ),
        ),
      ],
    );
  }
}
