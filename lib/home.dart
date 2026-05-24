import 'dart:html' as html;
import 'package:akiba/app_router.dart';
import 'package:akiba/Carousel/AutionCareven.dart';
import 'package:akiba/Carousel/careven.dart';
import 'package:akiba/Carousel/ItemCareven.dart';
import 'package:akiba/Cards/category.dart';
import 'package:akiba/limited/api/limited_api.dart';
import 'package:akiba/limited/limited_widgets.dart';
import 'package:akiba/limited/model/limited_models.dart';
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
  List<UsedTradeItem> _usedPopularItems = const [];
  List<LimitedItem> _limitedPopularItems = const [];
  bool _isUsedPopularLoading = true;
  bool _isLimitedPopularLoading = true;

  @override
  void initState() {
    super.initState();
    html.window.history.replaceState(null, '', '/main');
    _fetchPopularItems();
  }

  Future<void> _fetchPopularItems() async {
    _fetchUsedPopularItems();
    _fetchLimitedPopularItems();
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
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRouter.usedDetail,
            arguments: UsedTradeDetailRouteArgs(postId: item.id, item: item),
          );
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
        onTap: () => Navigator.of(context).pushNamed(AppRouter.limited),
      );
    }).toList();
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
              Careven(),
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
                onMoreTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.used),
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
              fontSize: Responsive.ref(context) * 0.04,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: Responsive.ref(context) * 0.03),
          child: GestureDetector(
            onTap: onMoreTap,
            child: Text(
              '더보기',
              style: TextStyle(
                color: Color(0xff838383),
                fontSize: Responsive.ref(context) * 0.035,
              ),
            ),
          ),
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
