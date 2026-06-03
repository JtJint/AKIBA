import 'package:akiba/app_router.dart';
import 'package:akiba/auction/api/auction_api.dart';
import 'package:akiba/utils/headerFiles.dart';
import 'package:akiba/widgets/akiba_network_image.dart';
import 'package:akiba/widgets/akiba_shell.dart';
import 'package:flutter/material.dart';

enum AuctionListType { endingSoon, popular }

class AuctionListScreen extends StatefulWidget {
  const AuctionListScreen({super.key, required this.type});

  final AuctionListType type;

  @override
  State<AuctionListScreen> createState() => _AuctionListScreenState();
}

class _AuctionListScreenState extends State<AuctionListScreen> {
  late Future<List<AuctionSummary>> _items;

  @override
  void initState() {
    super.initState();
    _items = _fetchItems();
  }

  Future<List<AuctionSummary>> _fetchItems() {
    return switch (widget.type) {
      AuctionListType.endingSoon => AuctionApi.getEndingSoon(limit: 40),
      AuctionListType.popular => AuctionApi.getPosts(sort: 'popular', size: 40),
    };
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == AuctionListType.endingSoon
        ? '마감 임박 경매'
        : '인기 경매';

    return AkibaShell(
      selectedIndex: 0,
      showAppBar: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: TopBar(
              title: title,
              onBack: () => Navigator.of(context).pop(),
            ),
          ),
          FutureBuilder<List<AuctionSummary>>(
            future: _items,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final items = snapshot.data ?? const <AuctionSummary>[];
              if (items.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      '표시할 경매가 없습니다.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                sliver: SliverList.separated(
                  itemBuilder: (_, index) =>
                      _AuctionListItem(item: items[index]),
                  separatorBuilder: (_, __) =>
                      const Divider(color: Color(0xff242424)),
                  itemCount: items.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AuctionListItem extends StatelessWidget {
  const _AuctionListItem({required this.item});

  final AuctionSummary item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
        AppRouter.auctionDetailPath(item.postId),
        arguments: AuctionDetailRouteArgs(initialItem: item),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 92,
                height: 92,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AkibaNetworkImage(
                        url: item.thumbnailUrl,
                        width: 92,
                        height: 92,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: _CountdownBadge(endsAt: item.endsAt),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '현재 입찰가 ${_formatPrice(item.currentPrice)}',
                    style: const TextStyle(
                      color: Color(0xffD0FF00),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '즉시 구매가 ${_formatPrice(item.buyNowPrice)} · 입찰 ${item.bidCount}회',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  const _CountdownBadge({required this.endsAt});

  final DateTime? endsAt;

  @override
  Widget build(BuildContext context) {
    final remaining = _remainingText(endsAt);
    final isEnded = remaining == '마감';

    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints(maxWidth: 78),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: isEnded ? const Color(0xff242424) : const Color(0xffD0FF00),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        remaining,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isEnded ? Colors.white70 : Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String _remainingText(DateTime? endsAt) {
  if (endsAt == null) return '마감 임박';
  final diff = endsAt.toLocal().difference(DateTime.now());
  if (diff.isNegative) return '마감';
  final hours = diff.inHours.toString().padLeft(2, '0');
  final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

String _formatPrice(int price) {
  if (price <= 0) return '없음';
  return '${price.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}원';
}
