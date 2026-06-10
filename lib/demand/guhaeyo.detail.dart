import 'dart:convert';
import 'dart:html' as html;

import 'package:akiba/app_router.dart';
import 'package:akiba/chat/api/chatApi.dart';
import 'package:akiba/demand/api/wanted_api.dart';
import 'package:akiba/widgets/akiba_network_image.dart';
import 'package:akiba/widgets/image_preview_viewer.dart';
import 'package:akiba/widgets/report_dialog.dart';
import 'package:akiba/wirte/write_page.dart';
import 'package:flutter/material.dart';

class GDetailScreen extends StatefulWidget {
  const GDetailScreen({super.key, required this.postId});

  final int postId;

  @override
  State<GDetailScreen> createState() => _GDetailScreenState();
}

class _GDetailScreenState extends State<GDetailScreen> {
  final PageController _pageController = PageController();
  WantedPostDetail? _post;
  bool _isLoading = true;
  bool _isDeleting = false;
  int _currentImageIndex = 0;

  bool get _canEdit {
    final myUserId = int.tryParse(html.window.localStorage['userId'] ?? '');
    return _post != null &&
        myUserId != null &&
        _post!.author.userId == myUserId;
  }

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final detail = await WantedApi.getWantedPostDetail(widget.postId);
      if (!mounted) return;
      setState(() {
        _post = detail;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('상세 정보를 불러오지 못했습니다: $error')));
    }
  }

  Future<void> _deletePost() async {
    final post = _post;
    if (post == null || _isDeleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff1b1b1b),
        title: const Text('구해요 글 삭제', style: TextStyle(color: Colors.white)),
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
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
    });

    final response = await WantedApi.deleteWantedPost(post.postId);
    if (!mounted) return;

    setState(() {
      _isDeleting = false;
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('구해요 글이 삭제되었습니다.')));
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
    final post = _post;
    if (post == null || post.author.userId == 0) return;

    final submitted = await showReportDialog(
      context,
      targetUserId: post.author.userId,
      targetPostId: post.postId,
    );
    if (!mounted || !submitted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('신고가 접수되었습니다.')));
  }

  Future<void> _openChatRoom() async {
    final post = _post;
    if (post == null) return;

    final myUserId = int.tryParse(html.window.localStorage['userId'] ?? '');
    if (myUserId != null && myUserId == post.author.userId) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('내 글에는 채팅을 시작할 수 없습니다.')));
      return;
    }

    final response = await Chatapi.postRoom(
      'REQUEST',
      post.postId,
      post.author.userId,
    );

    if (!mounted) return;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('채팅방 생성 실패 (${response.statusCode})')),
      );
      return;
    }

    final decoded = response.body.isNotEmpty ? response.body : '{}';
    final dynamic body = decoded.isNotEmpty ? jsonDecode(decoded) : {};
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
        userName: post.author.nickname,
        itemTitle: post.title,
        itemImageUrl: post.images.isNotEmpty ? post.images.first.imageUrl : null,
        priceText: _formatPrice(post.price),
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
    final post = _post;

    return Scaffold(
      backgroundColor: const Color(0xff070707),
      appBar: AppBar(
        backgroundColor: const Color(0xff070707),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        actions: [
          if (post != null)
            PopupMenuButton<String>(
              color: const Color(0xff1b1b1b),
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) async {
                if (value == 'edit') {
                  await Navigator.of(context).pushNamed(
                    AppRouter.write,
                    arguments: WritePageRouteArgs(
                      initialMode: WriteMode.wanted,
                      wantedEditPost: post,
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
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : post == null
          ? const Center(
              child: Text(
                '상세 정보를 찾을 수 없습니다.',
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
                            ? _TwoColumnDetail(
                                post: post,
                                currentImageIndex: _currentImageIndex,
                                pageController: _pageController,
                                onPageChanged: (value) {
                                  setState(() {
                                    _currentImageIndex = value;
                                  });
                                },
                                onSimilarTap: (postId) {
                                  Navigator.of(context).pushNamed(
                                    AppRouter.wantedDetailPath(postId),
                                  );
                                },
                              )
                            : _OneColumnDetail(
                                post: post,
                                currentImageIndex: _currentImageIndex,
                                pageController: _pageController,
                                onPageChanged: (value) {
                                  setState(() {
                                    _currentImageIndex = value;
                                  });
                                },
                                onSimilarTap: (postId) {
                                  Navigator.of(context).pushNamed(
                                    AppRouter.wantedDetailPath(postId),
                                  );
                                },
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: post == null
          ? null
          : _BottomCTA(
              isFavorite: post.favorite,
              onChatTap: _openChatRoom,
              canChat: !_canEdit,
              isDeleting: _isDeleting,
            ),
    );
  }
}

class _OneColumnDetail extends StatelessWidget {
  const _OneColumnDetail({
    required this.post,
    required this.currentImageIndex,
    required this.pageController,
    required this.onPageChanged,
    required this.onSimilarTap,
  });

  final WantedPostDetail post;
  final int currentImageIndex;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onSimilarTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _HeroImageCarousel(
          images: post.images,
          pageController: pageController,
          currentImageIndex: currentImageIndex,
          onPageChanged: onPageChanged,
        ),
        const SizedBox(height: 14),
        _InfoBlock(post: post),
        const SizedBox(height: 18),
        _SellerBlock(post: post),
        const SizedBox(height: 22),
        _SimilarProductsBlock(
          posts: post.similarPosts,
          onTapPost: onSimilarTap,
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _TwoColumnDetail extends StatelessWidget {
  const _TwoColumnDetail({
    required this.post,
    required this.currentImageIndex,
    required this.pageController,
    required this.onPageChanged,
    required this.onSimilarTap,
  });

  final WantedPostDetail post;
  final int currentImageIndex;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onSimilarTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: _HeroImageCarousel(
              images: post.images,
              pageController: pageController,
              currentImageIndex: currentImageIndex,
              onPageChanged: onPageChanged,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoBlock(post: post),
                const SizedBox(height: 18),
                _SellerBlock(post: post),
                const SizedBox(height: 22),
                _SimilarProductsBlock(
                  posts: post.similarPosts,
                  onTapPost: onSimilarTap,
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroImageCarousel extends StatelessWidget {
  const _HeroImageCarousel({
    required this.images,
    required this.pageController,
    required this.currentImageIndex,
    required this.onPageChanged,
  });

  final List<WantedImage> images;
  final PageController pageController;
  final int currentImageIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final imageUrls = images.isNotEmpty
        ? images.map((image) => image.imageUrl).toList()
        : ['https://picsum.photos/seed/wanted-detail/900/900'];

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 1,
            child: GestureDetector(
              onTap: () => showImagePreviewViewer(
                context,
                imageUrls: imageUrls,
                initialIndex: currentImageIndex,
              ),
              child: PageView.builder(
                controller: pageController,
                itemCount: imageUrls.length,
                onPageChanged: onPageChanged,
                itemBuilder: (_, index) {
                  return AkibaNetworkImage(
                    url: imageUrls[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_) => Container(
                      color: Colors.white10,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.white54,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        if (imageUrls.length > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 58,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: imageUrls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) => GestureDetector(
                onTap: () {
                  pageController.animateToPage(
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
                      color: currentImageIndex == index
                          ? const Color(0xFFD0FF00)
                          : Colors.white12,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AkibaNetworkImage(
                    url: imageUrls[index],
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

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.post});

  final WantedPostDetail post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatDate(post.createdAt),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
              const Icon(
                Icons.remove_red_eye_outlined,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${post.viewCount}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(width: 14),
              const Icon(
                Icons.favorite_border,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${post.favoriteCount}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PillChip(text: '구해요', filled: true),
              _PillChip(text: post.deliveryMethod),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            post.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatPrice(post.price),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(0xffD1FF00),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '(가격 제안 가능)',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white12),
        ],
      ),
    );
  }
}

class _SellerBlock extends StatelessWidget {
  const _SellerBlock({required this.post});

  final WantedPostDetail post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffD1FF00).withOpacity(0.5)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white24,
              backgroundImage: post.author.profileImageUrl.isNotEmpty
                  ? NetworkImage(post.author.profileImageUrl)
                  : null,
              child: post.author.profileImageUrl.isEmpty
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.author.nickname,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xffD1FF00),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '작성자 ID ${post.author.userId}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white70),
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

class _SimilarProductsBlock extends StatelessWidget {
  const _SimilarProductsBlock({required this.posts, required this.onTapPost});

  final List<WantedSimilarPost> posts;
  final ValueChanged<int> onTapPost;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '보고 있는 상품과 비슷한 상품',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('더보기')),
            ],
          ),
          const SizedBox(height: 10),
          if (posts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                '비슷한 상품이 없습니다.',
                style: TextStyle(color: Colors.white54),
              ),
            )
          else
            Column(
              children: posts.map((post) {
                return InkWell(
                  onTap: () => onTapPost(post.postId),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                post.conditionTxt,
                                style: const TextStyle(
                                  color: Color(0xffD1FF00),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatDate(post.createdAt),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.image, color: Colors.white24),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  const _PillChip({required this.text, this.filled = false});

  final String text;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: filled ? const Color(0xffD1FF00) : const Color(0xff8522D5),
        ),
        color: filled ? const Color(0xffD1FF00) : Colors.black26,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: filled ? Colors.black : Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BottomCTA extends StatelessWidget {
  const _BottomCTA({
    required this.isFavorite,
    required this.onChatTap,
    required this.canChat,
    required this.isDeleting,
  });

  final bool isFavorite;
  final VoidCallback onChatTap;
  final bool canChat;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        color: const Color(0xff070707),
        child: Row(
          children: [
            Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white70,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canChat
                        ? const Color(0xffD1FF00)
                        : const Color(0xff444444),
                    foregroundColor: canChat ? Colors.black : Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: canChat && !isDeleting ? onChatTap : null,
                  child: Text(
                    canChat ? '채팅하기' : '내 글',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatPrice(int price) {
  final value = price.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  return '$value원';
}

String _formatDate(DateTime? dateTime) {
  if (dateTime == null) {
    return '';
  }

  final now = DateTime.now();
  final difference = now.difference(dateTime).inDays;
  if (difference <= 0) return '오늘';
  if (difference == 1) return '1일전';
  return '${difference}일전';
}
