import 'package:akiba/app_router.dart';
import 'package:akiba/community/api/board_api.dart';
import 'package:akiba/widgets/community_app_bar.dart';
import 'package:flutter/material.dart';

class CommunityPopularPostsScreen extends StatefulWidget {
  const CommunityPopularPostsScreen({super.key});

  @override
  State<CommunityPopularPostsScreen> createState() =>
      _CommunityPopularPostsScreenState();
}

class _CommunityPopularPostsScreenState
    extends State<CommunityPopularPostsScreen> {
  late Future<List<BoardPostSummary>> _popularPosts;

  @override
  void initState() {
    super.initState();
    _popularPosts = BoardApi.getPopularPosts();
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
            showBack: true,
            centerTitle: true,
            title: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '이번 주 인기글 ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Best',
                  style: TextStyle(
                    color: Color(0xffD0FF00),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          body: FutureBuilder<List<BoardPostSummary>>(
            future: _popularPosts,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              final posts = snapshot.data ?? const <BoardPostSummary>[];
              if (posts.isEmpty) {
                return const Center(
                  child: Text(
                    '아직 작성된 인기글이 없습니다.',
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return _PopularPostListTile(
                    rank: index + 1,
                    post: post,
                    onDeleted: () {
                      setState(() {
                        _popularPosts = BoardApi.getPopularPosts();
                      });
                    },
                  );
                },
                separatorBuilder: (_, __) =>
                    const Divider(height: 30, color: Color(0xffD9D9D9)),
                itemCount: posts.length,
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.of(context).pushNamed(
              AppRouter.communityWrite,
              arguments: const CommunityWriteRouteArgs(boardCode: 'FREE'),
            ),
            backgroundColor: const Color(0xffD0FF00),
            foregroundColor: Colors.black,
            icon: const Icon(Icons.edit, size: 20),
            label: const Text(
              '글쓰기',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }
}

class _PopularPostListTile extends StatelessWidget {
  const _PopularPostListTile({
    required this.rank,
    required this.post,
    required this.onDeleted,
  });

  final int rank;
  final BoardPostSummary post;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final deleted = await Navigator.of(context).pushNamed(
          AppRouter.communityPostDetailPath(post.boardCode, post.postId),
          arguments: CommunityPostDetailRouteArgs(initialPost: post),
        );
        if (deleted == true) onDeleted();
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              rank.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
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
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  post.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xff8C8C8C)),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text(
                      _boardLabel(post.boardCode),
                      style: const TextStyle(
                        color: Color(0xffA434FE),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        '${post.author.isEmpty ? '익명' : post.author}   ${_dateText(post.createdAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xffB8B8B8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Icon(Icons.favorite_border, color: Colors.white, size: 17),
                    const SizedBox(width: 4),
                    Text(
                      post.likeCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      post.commentCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (post.imageUrls.isNotEmpty) ...[
            const SizedBox(width: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: _PostThumbnail(imageUrls: post.imageUrls),
            ),
          ],
        ],
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

String _boardLabel(String boardCode) {
  return switch (boardCode) {
    'AUTHENTICITY' => '정품 감정',
    'QNA_HELP' => 'Q&A',
    _ => '자유',
  };
}

String _dateText(DateTime? value) {
  if (value == null) return '';
  return '${value.month.toString().padLeft(2, '0')}.${value.day.toString().padLeft(2, '0')}';
}
