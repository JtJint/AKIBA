import 'package:akiba/app_router.dart';
import 'package:akiba/community/api/board_api.dart';
import 'package:akiba/widgets/akiba_shell.dart';
import 'package:flutter/material.dart';

class communityMain extends StatelessWidget {
  const communityMain({super.key});

  @override
  Widget build(BuildContext context) {
    return const AkibaShell(selectedIndex: 2, child: _CommunityHome());
  }
}

class _CommunityHome extends StatelessWidget {
  const _CommunityHome();

  static const _fallbackCategories = [
    _CommunityCategory(
      boardCode: 'FREE',
      title: '자유',
      imagePath: 'assets/community/community_pencil.png',
    ),
    _CommunityCategory(
      boardCode: 'AUTHENTICITY',
      title: '정품 감정',
      imagePath: 'assets/community/community_shield.png',
    ),
    _CommunityCategory(
      boardCode: 'QNA_HELP',
      title: 'Q&A',
      imagePath: 'assets/community/community_chat.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const _CommunityHomeBody();
  }
}

class _CommunityHomeBody extends StatefulWidget {
  const _CommunityHomeBody();

  @override
  State<_CommunityHomeBody> createState() => _CommunityHomeBodyState();
}

class _CommunityHomeBodyState extends State<_CommunityHomeBody> {
  List<BoardSummary> _boards = const [];
  List<BoardPostSummary> _popularPosts = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCommunityData();
  }

  Future<void> _fetchCommunityData() async {
    try {
      final results = await Future.wait([
        BoardApi.getBoards(),
        BoardApi.getPopularPosts(),
      ]);
      if (!mounted) return;
      setState(() {
        _boards = results[0] as List<BoardSummary>;
        _popularPosts = results[1] as List<BoardPostSummary>;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      debugPrint('community fetch error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width.clamp(360.0, 800.0);
    final horizontalPadding = width <= 440 ? 20.0 : 28.0;
    final categories = _boards.isEmpty
        ? _CommunityHome._fallbackCategories
        : _boards.map(_categoryFromBoard).take(3).toList();
    final popularPosts = _popularPosts.take(3).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        22,
        horizontalPadding,
        96,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CommunityHero(),
          const SizedBox(height: 30),
          const _SectionTitle(title: '카테고리'),
          const SizedBox(height: 18),
          Row(
            children: [
              for (var i = 0; i < categories.length; i++) ...[
                Expanded(child: _CategoryCard(category: categories[i])),
                if (i != categories.length - 1) const SizedBox(width: 12),
              ],
            ],
          ),
          const SizedBox(height: 34),
          _PopularHeader(isLoading: _isLoading),
          const SizedBox(height: 18),
          if (_isLoading)
            const _PopularPostsLoading()
          else if (popularPosts.isEmpty)
            const _PopularPostsEmpty()
          else
            for (final entry in popularPosts.indexed) ...[
              _PopularPostCard(
                rank: entry.$1 + 1,
                post: entry.$2,
                onDeleted: _fetchCommunityData,
              ),
              const SizedBox(height: 14),
            ],
        ],
      ),
    );
  }

  _CommunityCategory _categoryFromBoard(BoardSummary board) {
    return _CommunityCategory(
      boardCode: board.boardCode,
      title: _displayBoardName(board),
      imagePath: switch (board.boardCode) {
        'AUTHENTICITY' => 'assets/community/community_shield.png',
        'QNA_HELP' => 'assets/community/community_chat.png',
        _ => 'assets/community/community_pencil.png',
      },
    );
  }

  String _displayBoardName(BoardSummary board) {
    if (board.boardCode == 'FREE') return '자유';
    if (board.boardCode == 'AUTHENTICITY') return '정품 감정';
    if (board.boardCode == 'QNA_HELP') return 'Q&A';
    return board.boardName.isEmpty ? board.boardCode : board.boardName;
  }
}

class _CommunityHero extends StatelessWidget {
  const _CommunityHero();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width.clamp(360.0, 800.0);
    final heroHeight = width <= 440 ? 190.0 : 240.0;
    final characterSize = width <= 440 ? 200.0 : 280.0;

    return SizedBox(
      height: heroHeight + 28,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            top: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/community/community_banner_bg.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  Container(color: Colors.black.withValues(alpha: 0.12)),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.34),
                          Colors.black.withValues(alpha: 0.04),
                          Colors.black.withValues(alpha: 0.20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 28,
            bottom: 36,
            child: Text(
              '실시간으로 확인하는\n굿즈 시세와 희귀 매물',
              style: TextStyle(
                color: Colors.white,
                fontSize: width <= 440 ? 25 : 34,
                height: 1.32,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Positioned(
            right: width <= 440 ? 4 : 32,
            bottom: -12,
            child: Image.asset(
              'assets/community/community_character.gif',
              width: characterSize,
              height: characterSize,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final _CommunityCategory category;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final iconSize = width <= 440 ? 68.0 : 82.0;

    return InkWell(
      onTap: () => Navigator.of(
        context,
      ).pushNamed(AppRouter.communityBoardPath(category.boardCode)),
      child: Container(
        height: width <= 440 ? 122 : 150,
        decoration: BoxDecoration(
          color: const Color(0xff202020),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  category.title,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                category.imagePath,
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularHeader extends StatelessWidget {
  const _PopularHeader({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          '이번 주 인기글 ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Text(
          'TOP3',
          style: TextStyle(
            color: Color(0xffD0FF00),
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        if (isLoading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        if (isLoading) const SizedBox(width: 12),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRouter.communityPopular),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: EdgeInsets.zero,
            minimumSize: const Size(78, 36),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '더보기',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 24),
            ],
          ),
        ),
      ],
    );
  }
}

class _PopularPostCard extends StatelessWidget {
  const _PopularPostCard({
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
      child: Container(
        constraints: const BoxConstraints(minHeight: 94),
        decoration: BoxDecoration(
          color: const Color(0xff202020),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              child: Text(
                rank.toString(),
                style: const TextStyle(
                  color: Color(0xffD0FF00),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.content.isEmpty
                        ? '댓글 ${post.commentCount}개 · 좋아요 ${post.likeCount}개'
                        : post.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xff8C8C8C),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
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

class _PopularPostsLoading extends StatelessWidget {
  const _PopularPostsLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 94,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _PopularPostsEmpty extends StatelessWidget {
  const _PopularPostsEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 94),
      decoration: BoxDecoration(
        color: const Color(0xff202020),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: const Text(
        '아직 작성된 인기글이 없습니다.',
        style: TextStyle(
          color: Color(0xff8C8C8C),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CommunityCategory {
  const _CommunityCategory({
    required this.boardCode,
    required this.title,
    required this.imagePath,
  });

  final String boardCode;
  final String title;
  final String imagePath;
}
