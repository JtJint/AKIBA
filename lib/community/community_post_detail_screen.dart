import 'dart:html' as html;

import 'package:akiba/community/api/board_api.dart';
import 'package:akiba/widgets/community_app_bar.dart';
import 'package:akiba/widgets/report_dialog.dart';
import 'package:flutter/material.dart';

class CommunityPostDetailScreen extends StatefulWidget {
  const CommunityPostDetailScreen({
    super.key,
    required this.boardCode,
    required this.postId,
    this.initialPost,
  });

  final String boardCode;
  final int postId;
  final BoardPostSummary? initialPost;

  @override
  State<CommunityPostDetailScreen> createState() =>
      _CommunityPostDetailScreenState();
}

class _CommunityPostDetailScreenState extends State<CommunityPostDetailScreen> {
  late Future<BoardPostSummary> _postFuture;
  late Future<List<BoardComment>> _commentsFuture;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmittingComment = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _postFuture = BoardApi.getPostDetail(
      boardCode: widget.boardCode,
      postId: widget.postId,
    );
    _commentsFuture = BoardApi.getComments(
      boardCode: widget.boardCode,
      postId: widget.postId,
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_isSubmittingComment) return;
    final userId = int.tryParse(html.window.localStorage['userId'] ?? '');
    final content = _commentController.text.trim();
    if (userId == null) {
      _showSnack('로그인 후 댓글을 작성할 수 있습니다.');
      return;
    }
    if (content.isEmpty) return;

    setState(() {
      _isSubmittingComment = true;
    });

    try {
      await BoardApi.createComment(
        boardCode: widget.boardCode,
        postId: widget.postId,
        payload: BoardCommentCreatePayload(userId: userId, content: content),
      );
      if (!mounted) return;
      _commentController.clear();
      setState(() {
        _commentsFuture = BoardApi.getComments(
          boardCode: widget.boardCode,
          postId: widget.postId,
        );
        _postFuture = BoardApi.getPostDetail(
          boardCode: widget.boardCode,
          postId: widget.postId,
        );
      });
    } catch (error) {
      if (!mounted) return;
      _showSnack('댓글 등록 중 오류가 발생했습니다: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingComment = false;
        });
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _isMyPost(BoardPostSummary post) {
    final myUserId = int.tryParse(html.window.localStorage['userId'] ?? '');
    return myUserId != null && post.userId != 0 && myUserId == post.userId;
  }

  Future<void> _deletePost(BoardPostSummary post) async {
    if (_isDeleting) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff1b1b1b),
        title: const Text('게시글 삭제', style: TextStyle(color: Colors.white)),
        content: const Text(
          '이 게시글을 삭제할까요?',
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
      await BoardApi.deletePost(
        boardCode: post.boardCode.isEmpty ? widget.boardCode : post.boardCode,
        postId: post.postId,
      );
      if (!mounted) return;
      _showSnack('게시글이 삭제되었습니다.');
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      _showSnack('삭제 실패: $error');
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _reportPost(BoardPostSummary post) async {
    if (post.userId == 0) return;
    final submitted = await showReportDialog(
      context,
      targetUserId: post.userId,
      targetPostId: post.postId,
    );
    if (!mounted || !submitted) return;
    _showSnack('신고가 접수되었습니다.');
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
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.ios_share, color: Colors.white),
              ),
              FutureBuilder<BoardPostSummary>(
                future: _postFuture,
                initialData: widget.initialPost,
                builder: (context, snapshot) {
                  final post = snapshot.data;
                  if (post == null) {
                    return const SizedBox(width: 48);
                  }
                  final isMine = _isMyPost(post);
                  return PopupMenuButton<String>(
                    color: const Color(0xff1b1b1b),
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deletePost(post);
                      }
                      if (value == 'report') {
                        _reportPost(post);
                      }
                    },
                    itemBuilder: (context) => isMine
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
                  );
                },
              ),
              const SizedBox(width: 6),
            ],
          ),
          body: FutureBuilder<BoardPostSummary>(
            future: _postFuture,
            initialData: widget.initialPost,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final post = snapshot.data!;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BoardBadge(boardCode: post.boardCode),
                    const SizedBox(height: 12),
                    Text(
                      post.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _AuthorRow(post: post),
                    const SizedBox(height: 30),
                    Text(
                      post.content,
                      style: const TextStyle(
                        color: Color(0xffCFCFCF),
                        fontSize: 14,
                        height: 1.65,
                      ),
                    ),
                    if (post.imageUrls.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      _PostImages(imageUrls: post.imageUrls),
                    ],
                    if (post.hashtags.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: post.hashtags
                            .map((tag) => _HashTag(label: '#$tag'))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 34),
                    _ActionCounts(post: post),
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xff777777)),
                    const SizedBox(height: 24),
                    FutureBuilder<List<BoardComment>>(
                      future: _commentsFuture,
                      builder: (context, commentsSnapshot) {
                        final comments =
                            commentsSnapshot.data ?? const <BoardComment>[];
                        final count = commentsSnapshot.hasData
                            ? comments.length
                            : post.commentCount;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '댓글  $count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 18),
                            if (commentsSnapshot.connectionState !=
                                ConnectionState.done)
                              const Center(child: CircularProgressIndicator())
                            else if (comments.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  '아직 작성된 댓글이 없습니다.',
                                  style: TextStyle(color: Colors.white54),
                                ),
                              )
                            else
                              for (final comment in comments) ...[
                                _CommentTile(comment: comment),
                                const SizedBox(height: 24),
                              ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          bottomSheet: Container(
            color: const Color(0xff141414),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: const Color(0xffD0FF00),
                      decoration: InputDecoration(
                        hintText: '댓글을 입력해주세요.',
                        hintStyle: const TextStyle(color: Color(0xff777777)),
                        filled: true,
                        fillColor: const Color(0xff202020),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(2),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isSubmittingComment ? null : _submitComment,
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xffD0FF00),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    icon: _isSubmittingComment
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BoardBadge extends StatelessWidget {
  const _BoardBadge({required this.boardCode});

  final String boardCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xffA434FE),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        _boardLabel(boardCode),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _AuthorRow extends StatelessWidget {
  const _AuthorRow({required this.post});

  final BoardPostSummary post;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: Color(0xff2A2A2A),
          backgroundImage: AssetImage(
            'assets/community/community_character.gif',
          ),
        ),
        const SizedBox(width: 12),
        Text(
          post.author.isEmpty ? '익명' : post.author,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          _dateText(post.createdAt),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        const SizedBox(width: 14),
        Text(
          _timeText(post.createdAt),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}

class _PostImages extends StatelessWidget {
  const _PostImages({required this.imageUrls});

  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: imageUrls
          .map(
            (url) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  url,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220,
                    color: const Color(0xff242424),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _HashTag extends StatelessWidget {
  const _HashTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      color: const Color(0xff202020),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xffD0FF00),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ActionCounts extends StatelessWidget {
  const _ActionCounts({required this.post});

  final BoardPostSummary post;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.favorite_border, color: Colors.white, size: 27),
        const SizedBox(width: 8),
        Text(
          post.likeCount.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        const SizedBox(width: 18),
        const Icon(Icons.bookmark_border, color: Colors.white, size: 27),
        const SizedBox(width: 8),
        Text(
          post.bookmarkCount.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        const SizedBox(width: 18),
        const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 25),
        const SizedBox(width: 8),
        Text(
          post.commentCount.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final BoardComment comment;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 21,
          backgroundColor: Color(0xff2A2A2A),
          backgroundImage: AssetImage(
            'assets/community/community_character.gif',
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    comment.author.isEmpty ? '익명' : comment.author,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    _dateText(comment.createdAt),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                comment.content,
                style: const TextStyle(
                  color: Color(0xffCFCFCF),
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    '공감 ${comment.likeCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  const SizedBox(width: 18),
                  const Text(
                    '답글달기',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  const SizedBox(width: 18),
                  const Text(
                    '신고하기',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
            ],
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
  final year = value.year.toString().substring(2);
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year.$month.$day';
}

String _timeText(DateTime? value) {
  if (value == null) return '';
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
