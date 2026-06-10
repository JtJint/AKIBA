import 'dart:convert';
import 'dart:html' as html;

import 'package:akiba/app_router.dart';
import 'package:akiba/chat/api/chatApi.dart';
import 'package:akiba/used/api/used_trade_api.dart';
import 'package:akiba/used/model/used_trade_models.dart';
import 'package:akiba/used/widgets/used_trade_widgets.dart';
import 'package:akiba/utils/headerFiles.dart';
import 'package:akiba/widgets/report_dialog.dart';
import 'package:akiba/wirte/write_page.dart';
import 'package:flutter/material.dart';

class UsedTradeDetailScreen extends StatefulWidget {
  const UsedTradeDetailScreen({super.key, this.postId, this.initialItem});

  final int? postId;
  final UsedTradeItem? initialItem;

  @override
  State<UsedTradeDetailScreen> createState() => _UsedTradeDetailScreenState();
}

class _UsedTradeDetailScreenState extends State<UsedTradeDetailScreen> {
  UsedTradeItem? _item;
  List<UsedTradeItem> _similarItems = const [];
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
    _item = widget.initialItem;
    _fetchDetail();
    _fetchSimilarItems();
  }

  Future<void> _fetchDetail() async {
    final postId = widget.postId ?? widget.initialItem?.id;
    if (postId == null || postId == 0) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final item = await UsedTradeApi.getPostDetail(postId);
      if (!mounted) return;
      setState(() {
        _item = item;
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('used detail fetch error: $error');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchSimilarItems() async {
    final currentId = widget.postId ?? widget.initialItem?.id;
    if (currentId == null || currentId == 0) return;

    try {
      final items = await UsedTradeApi.getSimilarPosts(
        postId: currentId,
        limit: 8,
      );
      if (!mounted) return;
      setState(() {
        _similarItems = items.where((item) => item.id != currentId).toList();
      });
    } catch (error) {
      debugPrint('used similar fetch error: $error');
    }
  }

  Future<void> _deletePost() async {
    final item = _item;
    if (item == null || _isDeleting) return;

    setState(() {
      _isDeleting = true;
    });

    final response = await UsedTradeApi.deletePost(item.id);
    if (!mounted) return;

    setState(() {
      _isDeleting = false;
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('중고거래 글이 삭제되었습니다.')));
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
      'USED',
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

    final dynamic body = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
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
        priceText: formatUsedTradePrice(item.price),
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
          const Icon(Icons.ios_share_outlined, color: Colors.white),
          const SizedBox(width: 10),
          if (item != null)
            PopupMenuButton<String>(
              color: const Color(0xff1b1b1b),
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) async {
                if (value == 'edit') {
                  await Navigator.of(context).pushNamed(
                    AppRouter.write,
                    arguments: WritePageRouteArgs(
                      initialMode: WriteMode.used,
                      usedEditPost: item,
                    ),
                  );
                  _fetchDetail();
                }
                if (value == 'delete') {
                  _deletePost();
                }
                if (value == 'report') {
                  _reportPost();
                }
              },
              itemBuilder: (context) => _canEdit
                  ? [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text(
                          '수정',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
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
                '중고거래 글을 불러오지 못했습니다.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : SafeArea(
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
                                similarItems: _similarItems,
                              )
                            : _MobileDetailLayout(
                                item: item,
                                similarItems: _similarItems,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: item == null
          ? null
          : UsedTradeBottomCta(onChatTap: _openChatRoom),
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
