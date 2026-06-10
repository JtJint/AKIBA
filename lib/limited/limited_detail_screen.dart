import 'dart:convert';
import 'dart:html' as html;

import 'package:akiba/app_router.dart';
import 'package:akiba/chat/api/chatApi.dart';
import 'package:akiba/limited/api/limited_api.dart';
import 'package:akiba/limited/limited_widgets.dart';
import 'package:akiba/used/model/used_trade_models.dart';
import 'package:akiba/used/widgets/used_trade_widgets.dart';
import 'package:akiba/widgets/report_dialog.dart';
import 'package:flutter/material.dart';

class LimitedDetailScreen extends StatefulWidget {
  const LimitedDetailScreen({super.key, required this.postId});

  final int postId;

  @override
  State<LimitedDetailScreen> createState() => _LimitedDetailScreenState();
}

class _LimitedDetailScreenState extends State<LimitedDetailScreen> {
  UsedTradeItem? _item;
  bool _isLoading = true;
  bool _isDeleting = false;

  bool get _canEdit {
    final myUserId = int.tryParse(html.window.localStorage['userId'] ?? '');
    final sellerUserId = _item?.seller.userId;
    return myUserId != null && sellerUserId != null && myUserId == sellerUserId;
  }

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final item = await LimitedApi.getPostDetail(widget.postId);
      if (!mounted) return;
      setState(() {
        _item = item;
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('limited detail fetch error: $error');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePost() async {
    final item = _item;
    if (item == null || _isDeleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff1b1b1b),
        title: const Text('특전/한정판 글 삭제', style: TextStyle(color: Colors.white)),
        content: const Text(
          '이 글을 삭제할까요?',
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
    final response = await LimitedApi.deletePost(item.id);
    if (!mounted) return;
    setState(() => _isDeleting = false);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('특전/한정판 글이 삭제되었습니다.')));
      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('삭제 실패 (${response.statusCode}): ${response.body}'),
      ),
    );
  }

  Future<void> _reportPost() async {
    final item = _item;
    final targetUserId = item?.seller.userId;
    if (item == null || targetUserId == null || targetUserId == 0) return;

    final submitted = await showReportDialog(
      context,
      targetUserId: targetUserId,
      targetPostId: item.id,
    );
    if (!mounted || !submitted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('신고가 접수되었습니다.')));
  }

  Future<void> _openChatRoom() async {
    final item = _item;
    if (item == null) return;

    final myUserId = int.tryParse(html.window.localStorage['userId'] ?? '');
    if (myUserId != null && myUserId == item.seller.userId) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('내 글에는 채팅을 시작할 수 없습니다.')));
      return;
    }

    final response = await Chatapi.postRoom(
      'MARKET',
      item.id,
      item.seller.userId,
    );
    if (!mounted) return;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('채팅방 생성 실패 (${response.statusCode})')),
      );
      return;
    }

    final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    final roomId = _extractRoomId(body);
    if (roomId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('채팅방 정보가 올바르지 않습니다.')));
      return;
    }

    Navigator.of(context).pushNamed(
      AppRouter.chatRoomPath(roomId),
      arguments: ChatRoomRouteArgs(
        userName: item.seller.nickname,
        itemTitle: item.title,
        itemImageUrl: item.imageUrls.isNotEmpty ? item.imageUrls.first : null,
        priceText: formatLimitedPrice(item.price),
      ),
    );
  }

  int? _extractRoomId(dynamic body) {
    if (body is Map<String, dynamic>) {
      final candidates = [
        body['roomId'],
        body['id'],
        body['data'] is Map ? body['data']['roomId'] : null,
        body['result'] is Map ? body['result']['roomId'] : null,
      ];
      for (final candidate in candidates) {
        final parsed = int.tryParse(candidate?.toString() ?? '');
        if (parsed != null) return parsed;
      }
    }
    return null;
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
                if (value == 'delete') _deletePost();
                if (value == 'report') _reportPost();
              },
              itemBuilder: (context) => _canEdit
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
              child: Text(
                '특전/한정판 글을 불러오지 못했습니다.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: UsedTradeImageCarousel(
                            imageUrls: item.imageUrls,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _Badge(text: _specialLabel(item.specialType)),
                                  const SizedBox(width: 8),
                                  _Badge(text: item.condition),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Text(
                                item.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w900,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                formatLimitedPrice(item.price),
                                style: const TextStyle(
                                  color: Color(0xffD0FF00),
                                  fontSize: 23,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.visibility_outlined,
                                    color: Colors.white54,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${item.viewCount}',
                                    style: const TextStyle(color: Colors.white54),
                                  ),
                                  const SizedBox(width: 14),
                                  const Icon(
                                    Icons.favorite_border,
                                    color: Colors.white54,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${item.favoriteCount}',
                                    style: const TextStyle(color: Colors.white54),
                                  ),
                                  const Spacer(),
                                  Text(
                                    item.createdAtText,
                                    style: const TextStyle(color: Colors.white38),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              Text(
                                item.description,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                  height: 1.65,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Divider(color: Color(0xff2A2A2A)),
                              const SizedBox(height: 18),
                              _InfoRow(label: '거래 방식', value: item.deliveryMethod),
                              const SizedBox(height: 10),
                              _InfoRow(label: '구매처', value: item.purchaseSource),
                              if (item.tags.isNotEmpty) ...[
                                const SizedBox(height: 18),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: item.tags
                                      .map((tag) => _TagChip(text: tag))
                                      .toList(),
                                ),
                              ],
                              const SizedBox(height: 26),
                              const Text(
                                '판매자 정보',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _SellerCard(seller: item.seller),
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
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _canEdit ? null : _openChatRoom,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffD0FF00),
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.white12,
                      disabledForegroundColor: Colors.white38,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      _canEdit ? '내 글' : '채팅하기',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffD0FF00)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text.isEmpty ? '특전/한정' : text,
        style: const TextStyle(
          color: Color(0xffD0FF00),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 82,
          child: Text(label, style: const TextStyle(color: Colors.white54)),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '#$text',
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }
}

class _SellerCard extends StatelessWidget {
  const _SellerCard({required this.seller});

  final UsedTradeSeller seller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffD0FF00)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(seller.profileImageUrl),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller.nickname,
                  style: const TextStyle(
                    color: Color(0xffD0FF00),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  seller.intro,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _specialLabel(String value) {
  return switch (value) {
    'LIMITED_EDITION' => '한정판',
    'SPECIAL_BENEFIT' => '특전',
    'BOTH' => '특전/한정',
    _ => '특전/한정',
  };
}
