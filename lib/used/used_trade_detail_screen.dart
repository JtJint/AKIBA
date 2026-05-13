import 'package:akiba/app_router.dart';
import 'package:akiba/used/model/used_trade_models.dart';
import 'package:akiba/used/used_trade_screen.dart';
import 'package:akiba/used/widgets/used_trade_widgets.dart';
import 'package:akiba/utils/headerFiles.dart';
import 'package:flutter/material.dart';

class UsedTradeDetailScreen extends StatelessWidget {
  const UsedTradeDetailScreen({super.key, required this.item});

  final UsedTradeItem item;

  @override
  Widget build(BuildContext context) {
    final similarItems = usedTradeDummyItems
        .where((element) => element.id != item.id)
        .take(6)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xff070707),
      appBar: AppBar(
        backgroundColor: const Color(0xff070707),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        actions: const [
          Icon(Icons.ios_share_outlined, color: Colors.white),
          SizedBox(width: 20),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxContentWidth = constraints.maxWidth >= 900
                ? 1100.0
                : 520.0;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: constraints.maxWidth >= 900
                      ? _DesktopDetailLayout(
                          item: item,
                          similarItems: similarItems,
                        )
                      : _MobileDetailLayout(
                          item: item,
                          similarItems: similarItems,
                        ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: UsedTradeBottomCta(
        onChatTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('채팅 연결은 추후 API와 함께 붙일 예정입니다.')),
          );
        },
      ),
    );
  }
}

class _MobileDetailLayout extends StatelessWidget {
  const _MobileDetailLayout({required this.item, required this.similarItems});

  final UsedTradeItem item;
  final List<UsedTradeItem> similarItems;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UsedTradeImageCarousel(imageUrls: item.imageUrls),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: UsedTradeDetailHeader(item: item),
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '판매자 정보',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: UsedTradeSellerCard(seller: item.seller),
        ),
        const SizedBox(height: 26),
        UsedTradeHorizontalSection(
          title: '보고 있는 상품과 비슷한 상품',
          items: similarItems,
          onTapItem: (next) {
            Navigator.of(context).pushNamed(
              AppRouter.usedDetail,
              arguments: UsedTradeDetailRouteArgs(item: next),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _DesktopDetailLayout extends StatelessWidget {
  const _DesktopDetailLayout({required this.item, required this.similarItems});

  final UsedTradeItem item;
  final List<UsedTradeItem> similarItems;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: UsedTradeImageCarousel(imageUrls: item.imageUrls),
          ),
          const SizedBox(width: 18),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UsedTradeDetailHeader(item: item),
                const SizedBox(height: 28),
                Text(
                  '판매자 정보',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                UsedTradeSellerCard(seller: item.seller),
                const SizedBox(height: 26),
                SectionHeader(title: '보고 있는 상품과 비슷한 상품', onMore: () {}),
                SizedBox(
                  height: 192,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: similarItems.length,
                    itemBuilder: (_, index) => UsedTradeThumbCard(
                      item: similarItems[index],
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRouter.usedDetail,
                          arguments: UsedTradeDetailRouteArgs(
                            item: similarItems[index],
                          ),
                        );
                      },
                    ),
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
