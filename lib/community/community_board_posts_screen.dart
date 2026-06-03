import 'package:akiba/app_router.dart';
import 'package:akiba/community/api/board_api.dart';
import 'package:akiba/search/SearchWidget.dart';
import 'package:akiba/widgets/community_app_bar.dart';
import 'package:flutter/material.dart';

class CommunityBoardPostsScreen extends StatefulWidget {
  const CommunityBoardPostsScreen({super.key, required this.boardCode});

  final String boardCode;

  @override
  State<CommunityBoardPostsScreen> createState() =>
      _CommunityBoardPostsScreenState();
}

class _CommunityBoardPostsScreenState extends State<CommunityBoardPostsScreen> {
  late Future<List<BoardPostSummary>> _posts;
  String _sort = 'latest';

  @override
  void initState() {
    super.initState();
    _posts = _fetchPosts();
  }

  Future<List<BoardPostSummary>> _fetchPosts() {
    return BoardApi.getPosts(boardCode: widget.boardCode, sort: _sort);
  }

  void _changeSort(String sort) {
    if (_sort == sort) return;
    setState(() {
      _sort = sort;
      _posts = _fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width.clamp(360.0, 800.0);

    return Center(
      child: SizedBox(
        width: width,
        child: Scaffold(
          backgroundColor: const Color(0xff141414),
          appBar: CommunityAppBar(
            actions: [
              const SearchWidget(type: 'community'),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                  size: 29,
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: RefreshIndicator(
            color: const Color(0xffD0FF00),
            backgroundColor: const Color(0xff202020),
            onRefresh: () async {
              setState(() {
                _posts = _fetchPosts();
              });
              await _posts;
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                    child: Column(
                      children: [
                        const _BoardTabs(),
                        const SizedBox(height: 22),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _SortButton(
                            sort: _sort,
                            onChanged: _changeSort,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                FutureBuilder<List<BoardPostSummary>>(
                  future: _posts,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final posts = snapshot.data ?? const <BoardPostSummary>[];
                    if (posts.isEmpty) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            '아직 작성된 글이 없습니다.',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      sliver: SliverList.separated(
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return _CommunityPostTile(post: post);
                        },
                        separatorBuilder: (_, __) =>
                            const Divider(height: 28, color: Color(0xff777777)),
                        itemCount: posts.length,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          floatingActionButton: SizedBox(
            width: 126,
            height: 54,
            child: FloatingActionButton.extended(
              onPressed: () async {
                final created = await Navigator.of(context).pushNamed(
                  AppRouter.communityWrite,
                  arguments: CommunityWriteRouteArgs(
                    boardCode: widget.boardCode,
                  ),
                );
                if (!mounted || created != true) return;
                setState(() {
                  _posts = _fetchPosts();
                });
              },
              backgroundColor: const Color(0xffD0FF00),
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
              icon: const Icon(Icons.edit, size: 24),
              label: const Text(
                '글쓰기',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }
}

class _BoardTabs extends StatelessWidget {
  const _BoardTabs();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _BoardChip(
          boardCode: 'FREE',
          label: '자유',
          iconPath: 'assets/community/community_pencil.png',
        ),
        SizedBox(width: 8),
        _BoardChip(
          boardCode: 'AUTHENTICITY',
          label: '정품 감정',
          iconPath: 'assets/community/community_shield.png',
        ),
        SizedBox(width: 8),
        _BoardChip(
          boardCode: 'QNA_HELP',
          label: 'Q&A',
          iconPath: 'assets/community/community_chat.png',
        ),
      ],
    );
  }
}

class _BoardChip extends StatelessWidget {
  const _BoardChip({
    required this.boardCode,
    required this.label,
    required this.iconPath,
  });

  final String boardCode;
  final String label;
  final String iconPath;

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? '';
    final selected = route.contains('/community/$boardCode');

    return Expanded(
      child: InkWell(
        onTap: () => Navigator.of(
          context,
        ).pushReplacementNamed(AppRouter.communityBoardPath(boardCode)),
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: selected ? const Color(0xff2A2A2A) : const Color(0xff202020),
            borderRadius: BorderRadius.circular(2),
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  iconPath,
                  width: 23,
                  height: 23,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({required this.sort, required this.onChanged});

  final String sort;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: const Color(0xff202020),
      initialValue: sort,
      onSelected: onChanged,
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'latest', child: Text('최신순')),
        PopupMenuItem(value: 'popular', child: Text('인기순')),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            sort == 'popular' ? '인기순' : '최신순',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
        ],
      ),
    );
  }
}

class _CommunityPostTile extends StatelessWidget {
  const _CommunityPostTile({required this.post});

  final BoardPostSummary post;

  @override
  Widget build(BuildContext context) {
    final tileHeight = post.imageUrls.isNotEmpty ? 124.0 : 110.0;

    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
        AppRouter.communityPostDetailPath(post.boardCode, post.postId),
        arguments: CommunityPostDetailRouteArgs(initialPost: post),
      ),
      child: SizedBox(
        height: tileHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.35,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    post.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xff8B8B8B),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        post.author.isEmpty ? '익명' : post.author,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _timeText(post.createdAt),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 68,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (post.imageUrls.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: _PostThumbnail(imageUrls: post.imageUrls),
                    )
                  else
                    const SizedBox(height: 68),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        post.likeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white,
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        post.commentCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
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

class _PostThumbnail extends StatelessWidget {
  const _PostThumbnail({required this.imageUrls});

  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Image.network(
          imageUrls.first,
          width: 68,
          height: 68,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 68,
            height: 68,
            color: const Color(0xff242424),
          ),
        ),
        if (imageUrls.length > 1)
          Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              imageUrls.length.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

String _timeText(DateTime? value) {
  if (value == null) return '';
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
