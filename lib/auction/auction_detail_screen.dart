import 'package:akiba/auction/api/auction_api.dart';
import 'package:akiba/widgets/akiba_network_image.dart';
import 'package:akiba/widgets/image_preview_viewer.dart';
import 'package:akiba/widgets/report_dialog.dart';
import 'package:flutter/material.dart';

class AuctionDetailScreen extends StatefulWidget {
  const AuctionDetailScreen({super.key, required this.postId, this.initialItem});

  final int postId;
  final AuctionSummary? initialItem;

  @override
  State<AuctionDetailScreen> createState() => _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends State<AuctionDetailScreen> {
  AuctionSummary? _item;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _item = widget.initialItem;
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final item = await AuctionApi.getPostDetail(widget.postId);
      if (!mounted) return;
      setState(() {
        _item = item;
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('auction detail fetch error: $error');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitBid(int bidAmount) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await AuctionApi.bid(postId: widget.postId, bidAmount: bidAmount);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('입찰이 완료되었습니다.')),
      );
      await _fetchDetail();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('입찰 실패: $error')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _buyNow() async {
    final item = _item;
    if (item == null || item.buyNowPrice <= 0 || _isSubmitting) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff202020),
        title: const Text('즉시 구매', style: TextStyle(color: Colors.white)),
        content: Text(
          '${_formatPrice(item.buyNowPrice)}에 즉시 구매할까요?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('구매')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isSubmitting = true);
    try {
      await AuctionApi.buyNow(postId: widget.postId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('즉시 구매가 완료되었습니다.')),
      );
      await _fetchDetail();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('즉시 구매 실패: $error')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _deletePost() async {
    final item = _item;
    if (item == null || _isDeleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff202020),
        title: const Text('경매 글 삭제', style: TextStyle(color: Colors.white)),
        content: const Text(
          '이 경매 글을 삭제할까요?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제하기'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    try {
      await AuctionApi.deletePost(postId: item.postId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('경매 글이 삭제되었습니다.')));
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('삭제 실패: $error')));
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _reportPost() async {
    final item = _item;
    final targetUserId = item?.sellerUserId;
    if (item == null || targetUserId == null || targetUserId == 0) return;

    final submitted = await showReportDialog(
      context,
      targetUserId: targetUserId,
      targetPostId: item.postId,
    );
    if (!mounted || !submitted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('신고가 접수되었습니다.')));
  }

  void _openBidSheet() {
    final item = _item;
    if (item == null) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xff202020),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (_) => _BidSheet(item: item, onSubmit: _submitBid),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;

    return Scaffold(
      backgroundColor: const Color(0xff070707),
      appBar: AppBar(
        backgroundColor: const Color(0xff070707),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        actions: [
          if (item != null)
            PopupMenuButton<String>(
              color: const Color(0xff1b1b1b),
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'delete') {
                  _deletePost();
                }
                if (value == 'report') {
                  _reportPost();
                }
              },
              itemBuilder: (context) => item.myPost
                  ? [
                      PopupMenuItem(
                        value: 'delete',
                        enabled: !_isDeleting,
                        child: Text(
                          _isDeleting ? '삭제 중...' : '삭제하기',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ]
                  : const [
                      PopupMenuItem(
                        value: 'report',
                        child: Text(
                          '신고하기',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
            ),
          const SizedBox(width: 10),
        ],
      ),
      body: _isLoading && item == null
          ? const Center(child: CircularProgressIndicator())
          : item == null
          ? const Center(
              child: Text('경매 글을 불러오지 못했습니다.', style: TextStyle(color: Colors.white70)),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AuctionImages(item: item),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _Badge(text: '경매중', filled: true),
                                  const SizedBox(width: 10),
                                  _Badge(text: _specialLabel(item.specialType)),
                                  const SizedBox(width: 10),
                                  _Badge(text: item.productCondition.isEmpty ? '상태미상' : item.productCondition),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Text(
                                item.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _formatPrice(item.currentPrice),
                                style: const TextStyle(
                                  color: Color(0xffD0FF00),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              if (item.content.isNotEmpty) ...[
                                const SizedBox(height: 18),
                                Text(
                                  item.content,
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 14,
                                    height: 1.65,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 26),
                              const Divider(color: Color(0xff2A2A2A)),
                              const SizedBox(height: 22),
                              Center(child: _StartPriceChip(price: item.startPrice)),
                              const SizedBox(height: 22),
                              _PriceRow(label: '현재 입찰가', value: _formatPrice(item.currentPrice)),
                              const SizedBox(height: 14),
                              _PriceRow(label: '즉시 구매가', value: _formatPrice(item.buyNowPrice)),
                              const SizedBox(height: 22),
                              Center(
                                child: Text(
                                  '${_formatDateTime(item.endsAt)}까지',
                                  style: const TextStyle(color: Color(0xffB335FF), fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(height: 26),
                              const Text(
                                '판매자 정보',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 12),
                              _SellerCard(
                                nickname: item.sellerNickname,
                                profileImageUrl: item.sellerProfileImageUrl,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: item == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
                child: Row(
                  children: [
                    const Icon(Icons.favorite_border, color: Colors.white70, size: 32),
                    if (item.favoriteCount > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        item.favoriteCount.toString(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting || item.myPost
                            ? null
                            : _openBidSheet,
                        style: _ctaStyle(),
                        child: Text(item.myPost ? '내 경매' : '입찰하기'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ||
                                item.myPost ||
                                item.buyNowPrice <= 0
                            ? null
                            : _buyNow,
                        style: _ctaStyle(),
                        child: const Text('즉시 구매'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _BidSheet extends StatefulWidget {
  const _BidSheet({required this.item, required this.onSubmit});

  final AuctionSummary item;
  final ValueChanged<int> onSubmit;

  @override
  State<_BidSheet> createState() => _BidSheetState();
}

class _BidSheetState extends State<_BidSheet> {
  late int _bidAmount;

  @override
  void initState() {
    super.initState();
    _bidAmount = widget.item.currentPrice + _bidStep;
  }

  int get _bidStep => widget.item.bidStep > 0 ? widget.item.bidStep : 10000;

  void _add(int amount) {
    setState(() {
      _bidAmount += amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final startPrice = widget.item.startPrice;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('입찰하기', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(child: _StartPriceChip(price: startPrice)),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BidStepButton(label: '+ 5,000원', onTap: () => _add(5000)),
                const SizedBox(width: 10),
                _BidStepButton(label: '+ 10,000원', selected: true, onTap: () => _add(10000)),
                const SizedBox(width: 10),
                _BidStepButton(label: '+ 100,000원', onTap: () => _add(100000)),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              height: 56,
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() {
                      _bidAmount = (_bidAmount - _bidStep).clamp(widget.item.currentPrice + _bidStep, 1 << 31);
                    }),
                    icon: const Icon(Icons.remove, color: Colors.white),
                  ),
                  const Spacer(),
                  Text(
                    _formatNumber(_bidAmount),
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _add(_bidStep),
                    icon: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Divider(color: Color(0xff333333)),
            const SizedBox(height: 12),
            _PriceRow(label: '입찰 신청가', value: _formatPrice(_bidAmount)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onSubmit(_bidAmount);
                },
                style: _ctaStyle(),
                child: const Text('입찰하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuctionImages extends StatefulWidget {
  const _AuctionImages({required this.item});

  final AuctionSummary item;

  @override
  State<_AuctionImages> createState() => _AuctionImagesState();
}

class _AuctionImagesState extends State<_AuctionImages> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.item.imageUrls.isEmpty
        ? [widget.item.thumbnailUrl]
        : widget.item.imageUrls;
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => showImagePreviewViewer(
                  context,
                  imageUrls: images,
                  initialIndex: _currentIndex,
                ),
                child: PageView.builder(
                  controller: _controller,
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (_, index) => AkibaNetworkImage(
                    url: images[index],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                left: 18,
                bottom: 16,
                child: _RemainingBadge(endsAt: widget.item.endsAt),
              ),
              Positioned(
                right: 18,
                bottom: 16,
                child: Row(
                  children: [
                    const Icon(Icons.visibility, color: Colors.white, size: 17),
                    const SizedBox(width: 4),
                    Text(
                      widget.item.viewCount.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 58,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) => GestureDetector(
                onTap: () {
                  _controller.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _currentIndex == index
                          ? const Color(0xFFD0FF00)
                          : Colors.white12,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AkibaNetworkImage(
                    url: images[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _RemainingBadge extends StatelessWidget {
  const _RemainingBadge({required this.endsAt});

  final DateTime? endsAt;

  @override
  Widget build(BuildContext context) {
    final remaining = _remainingText(endsAt);
    final isEnded = remaining == '마감';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isEnded ? const Color(0xff242424) : const Color(0xffD0FF00),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        remaining,
        style: TextStyle(
          color: isEnded ? Colors.white70 : Colors.black,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, this.filled = false});

  final String text;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? const Color(0xffD0FF00) : Colors.transparent,
        border: Border.all(color: filled ? const Color(0xffD0FF00) : const Color(0xff5C2CA5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: filled ? Colors.black : Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StartPriceChip extends StatelessWidget {
  const _StartPriceChip({required this.price});

  final int price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(border: Border.all(color: const Color(0xffB335FF))),
      child: Text('시작가: ${_formatPrice(price)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16))),
        Text(value, style: const TextStyle(color: Color(0xffD0FF00), fontSize: 22, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _SellerCard extends StatelessWidget {
  const _SellerCard({required this.nickname, this.profileImageUrl});

  final String nickname;
  final String? profileImageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: const Color(0xffD0FF00)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: const Color(0xff242424),
            backgroundImage: profileImageUrl == null
                ? const AssetImage('assets/community/community_character.gif')
                : NetworkImage(profileImageUrl!) as ImageProvider,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(nickname, style: const TextStyle(color: Color(0xffD0FF00), fontSize: 17, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _BidStepButton extends StatelessWidget {
  const _BidStepButton({required this.label, required this.onTap, this.selected = false});

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: selected ? const Color(0xffD0FF00) : const Color(0xff3D3D3D)),
        shape: const RoundedRectangleBorder(),
      ),
      child: Text(label),
    );
  }
}

ButtonStyle _ctaStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: const Color(0xffD0FF00),
    foregroundColor: Colors.black,
    disabledBackgroundColor: const Color(0xff3A3A3A),
    disabledForegroundColor: Colors.white38,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
  );
}

String _specialLabel(String value) {
  return switch (value) {
    'LIMITED_EDITION' => '한정판',
    'SPECIAL_BENEFIT' => '특전',
    'BOTH' => '특전/한정',
    _ => '미개봉',
  };
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

String _formatDateTime(DateTime? value) {
  if (value == null) return '마감 시간 미정';
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}

String _formatPrice(int price) {
  if (price <= 0) return '없음';
  return '${_formatNumber(price)}원';
}

String _formatNumber(int value) {
  return value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
}
