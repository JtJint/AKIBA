import 'dart:async';

import 'package:akiba/auction/api/auction_api.dart';
import 'package:akiba/Cards/AuctionCard.careven.dart';
import 'package:akiba/utils/responsive.dart';
import 'package:flutter/material.dart';

/// 곧 입찰이 끝나는 순서대로 정렬된 경매 매물 캐러셀
class Autioncareven extends StatefulWidget {
  const Autioncareven({super.key});

  @override
  State<Autioncareven> createState() => _AutioncarevenState();
}

class _AutioncarevenState extends State<Autioncareven> {
  final PageController _pageController = PageController(viewportFraction: 0.28);
  List<AuctionSummary> _auctionItems = const [];
  bool _isLoading = true;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    _fetchEndingSoonAuctions();
  }

  Future<void> _fetchEndingSoonAuctions() async {
    try {
      final items = await AuctionApi.getEndingSoon(limit: 10);
      if (!mounted) return;
      setState(() {
        _auctionItems = items;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _auctionItems = const [];
        _isLoading = false;
      });
      debugPrint('ending soon auctions fetch error: $error');
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: Responsive.w(context) * 0.9,
        height: Responsive.ref(context) * 0.18,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_auctionItems.isEmpty) {
      return SizedBox(
        width: Responsive.w(context) * 0.9,
        height: Responsive.ref(context) * 0.18,
        child: const Center(
          child: Text(
            '마감 임박 경매를 불러오지 못했습니다.',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return SizedBox(
      width: Responsive.w(context) * 0.9,
      height: Responsive.ref(context) * 0.32,
      child: PageView.builder(
        controller: _pageController,
        padEnds: false,
        scrollDirection: Axis.horizontal,
        itemCount: _auctionItems.length,
        itemBuilder: (context, index) {
          final item = _auctionItems[index];
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.ref(context) * 0.01,
            ),
            child: Center(
              child: Auctioncardcareven(
                img: item.thumbnailUrl.isEmpty
                    ? 'https://picsum.photos/seed/auction-${item.postId}/400/400'
                    : item.thumbnailUrl,
                name: item.title,
                endTime: _formatRemainingTime(item.endsAt),
                price: _formatPrice(item.currentPrice),
                rateOfChange: item.bidCount.toDouble(),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatPrice(int price) {
    final formatted = price.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    return '$formatted원';
  }

  String _formatRemainingTime(DateTime? endsAt) {
    if (endsAt == null) return '마감 임박';
    final diff = endsAt.toLocal().difference(DateTime.now());
    if (diff.isNegative) return '마감';
    if (diff.inDays > 0) return '${diff.inDays}일 남음';
    if (diff.inHours > 0) return '${diff.inHours}시간 ${diff.inMinutes % 60}분';
    if (diff.inMinutes > 0) return '${diff.inMinutes}분 남음';
    return '곧 마감';
  }
}
