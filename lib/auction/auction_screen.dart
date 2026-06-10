import 'dart:async';

import 'package:akiba/app_router.dart';
import 'package:akiba/auction/api/auction_api.dart';
import 'package:akiba/utils/headerFiles.dart';
import 'package:akiba/widgets/akiba_network_image.dart';
import 'package:akiba/widgets/akiba_shell.dart';
import 'package:flutter/material.dart';

class AuctionScreen extends StatefulWidget {
  const AuctionScreen({super.key});

  @override
  State<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends State<AuctionScreen> {
  List<AuctionSummary> _endingSoonItems = const [];
  List<AuctionSummary> _popularItems = const [];
  List<AuctionSummary> _recentItems = const [];
  bool _isLoading = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _fetchAuctions();
  }

  Future<void> _fetchAuctions() async {
    try {
      final results = await Future.wait([
        AuctionApi.getEndingSoon(limit: 10),
        AuctionApi.getPosts(sort: 'popular', size: 10),
        AuctionApi.getPosts(sort: 'latest', size: 20),
      ]);
      if (!mounted) return;
      setState(() {
        _endingSoonItems = results[0];
        _popularItems = results[1];
        _recentItems = results[2];
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = '경매 목록을 불러오지 못했습니다.';
      });
      debugPrint('auction fetch error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final featuredItems = _endingSoonItems.isEmpty
        ? _recentItems.take(6).toList()
        : _endingSoonItems;

    return AkibaShell(
      selectedIndex: 0,
      showAppBar: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: TopBar(
              title: '경매',
              onBack: () => Navigator.of(context).pop(),
            ),
          ),
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          if (_errorText != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(
                  _errorText!,
                  style: const TextStyle(color: Colors.white54),
                ),
              ),
            ),
          if (!_isLoading) ...[
            if (featuredItems.isNotEmpty)
              SliverToBoxAdapter(
                child: _AuctionHorizontalSection(
                  title: '곧 입찰이 끝나요!',
                  items: featuredItems,
                  onMore: () => _openList(AppRouter.auctionEndingSoon),
                  onDeleted: _removeItem,
                ),
              ),
            if (_popularItems.isNotEmpty)
              SliverToBoxAdapter(
                child: _AuctionHorizontalSection(
                  title: '인기 경매',
                  items: _popularItems,
                  onMore: () => _openList(AppRouter.auctionPopular),
                  onDeleted: _removeItem,
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Text(
                  '전체 경매',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: _recentItems.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Text(
                            '등록된 경매가 없습니다.',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ),
                    )
                  : SliverList.separated(
                      itemBuilder: (_, index) => _AuctionListTile(
                        item: _recentItems[index],
                        onDeleted: _removeItem,
                      ),
                      separatorBuilder: (_, __) =>
                          const Divider(color: Color(0xff242424)),
                      itemCount: _recentItems.length,
                    ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Future<void> _openList(String routeName) async {
    final changed = await Navigator.of(context).pushNamed(routeName);
    if (changed == true && mounted) {
      _fetchAuctions();
    }
  }

  void _removeItem(int postId) {
    setState(() {
      _endingSoonItems = _endingSoonItems
          .where((item) => item.postId != postId)
          .toList();
      _popularItems = _popularItems
          .where((item) => item.postId != postId)
          .toList();
      _recentItems = _recentItems
          .where((item) => item.postId != postId)
          .toList();
    });
  }
}

class _AuctionHorizontalSection extends StatelessWidget {
  const _AuctionHorizontalSection({
    required this.title,
    required this.items,
    required this.onMore,
    required this.onDeleted,
  });

  final String title;
  final List<AuctionSummary> items;
  final VoidCallback onMore;
  final ValueChanged<int> onDeleted;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SectionHeader(title: title, onMore: onMore),
        SizedBox(
          height: 240,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) =>
                _AuctionCard(item: items[index], onDeleted: onDeleted),
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemCount: items.length,
          ),
        ),
      ],
    );
  }
}

class _AuctionCard extends StatelessWidget {
  const _AuctionCard({required this.item, required this.onDeleted});

  final AuctionSummary item;
  final ValueChanged<int> onDeleted;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final deleted = await Navigator.of(context).pushNamed(
          AppRouter.auctionDetailPath(item.postId),
          arguments: AuctionDetailRouteArgs(initialItem: item),
        );
        if (deleted == true) onDeleted(item.postId);
      },
      child: SizedBox(
        width: 156,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 1,
                child: _AuctionImageWithCountdown(item: item),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatPrice(item.currentPrice),
              style: const TextStyle(
                color: Color(0xffD1FF00),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuctionListTile extends StatelessWidget {
  const _AuctionListTile({required this.item, required this.onDeleted});

  final AuctionSummary item;
  final ValueChanged<int> onDeleted;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final deleted = await Navigator.of(context).pushNamed(
          AppRouter.auctionDetailPath(item.postId),
          arguments: AuctionDetailRouteArgs(initialItem: item),
        );
        if (deleted == true) onDeleted(item.postId);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 92,
                height: 92,
                child: _AuctionImageWithCountdown(item: item),
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
                  const SizedBox(height: 6),
                  Text(
                    '현재가 ${_formatPrice(item.currentPrice)} · 입찰 ${item.bidCount}회',
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
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

class _CountdownBadge extends StatefulWidget {
  const _CountdownBadge({required this.endsAt});

  final DateTime? endsAt;

  @override
  State<_CountdownBadge> createState() => _CountdownBadgeState();
}

class _CountdownBadgeState extends State<_CountdownBadge> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _remainingText(widget.endsAt);
    final isEnded = remaining == '마감';

    return Container(
      constraints: const BoxConstraints(maxWidth: 128),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _AuctionImageWithCountdown extends StatelessWidget {
  const _AuctionImageWithCountdown({required this.item});

  final AuctionSummary item;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: _AuctionImage(item: item)),
        Positioned(
          left: 8,
          top: 8,
          child: _CountdownBadge(endsAt: item.endsAt),
        ),
      ],
    );
  }
}

class _AuctionImage extends StatelessWidget {
  const _AuctionImage({required this.item});

  final AuctionSummary item;

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.thumbnailUrl.isEmpty
        ? 'https://picsum.photos/seed/auction-${item.postId}/500/500'
        : item.thumbnailUrl;

    return AkibaNetworkImage(
      url: imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_) => Container(
        color: const Color(0xff202020),
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported, color: Colors.white38),
      ),
    );
  }
}

String _remainingText(DateTime? endsAt) {
  if (endsAt == null) return '마감 임박';

  final diff = endsAt.toLocal().difference(DateTime.now());
  if (diff.isNegative) return '마감';

  final days = diff.inDays;
  final hours = diff.inHours % 24;
  final minutes = diff.inMinutes % 60;
  final seconds = diff.inSeconds % 60;

  if (days > 0) {
    return '$days일 ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

String _formatPrice(int price) {
  if (price <= 0) return '가격문의';
  final formatted = price.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  return '$formatted원';
}
