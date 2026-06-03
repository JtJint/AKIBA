import 'dart:convert';

import 'package:akiba/Login/api/userApi.dart';
import 'package:akiba/myPage/mypage.api.dart';
import 'package:akiba/widgets/akiba_shell.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key, this.targetUserId});

  final int? targetUserId;

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  static const Map<String, dynamic> _defaultProfile = {
    "userId": 0,
    "nickname": "사용자",
    "bio": null,
    "profileImageUrl": null,
    "mannerScore": 0,
    "completedDealCount": 0,
    "ongoingDealCount": 0,
    "followerCount": 0,
    "followingCount": 0,
    "isFollowing": false,
  };

  Response rt = Response('', 200);
  Map<String, dynamic> body = Map<String, dynamic>.from(_defaultProfile);
  bool _isFollowSubmitting = false;

  bool get _isMyProfile => widget.targetUserId == null;

  @override
  initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final response = await myPageAPI.getProfile(
        targetUserId: widget.targetUserId,
      );
      final decoded = jsonDecode(response.body);
      final profile = _extractProfile(decoded);
      setState(() {
        rt = response;
        body = {..._defaultProfile, ...profile};
      });
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  Map<String, dynamic> _extractProfile(dynamic decoded) {
    if (decoded is! Map) return <String, dynamic>{};

    for (final key in ['data', 'result', 'profile', 'user']) {
      final value = decoded[key];
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    }

    return Map<String, dynamic>.from(decoded);
  }

  Future<void> _logout() async {
    await Loginapi.logout();

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  Future<void> _toggleFollow() async {
    final targetUserId = widget.targetUserId;
    if (targetUserId == null || _isFollowSubmitting) return;

    final isFollowing = body['isFollowing'] == true;
    setState(() {
      _isFollowSubmitting = true;
    });

    try {
      final response = isFollowing
          ? await myPageAPI.unfollow(targetUserId)
          : await myPageAPI.follow(targetUserId);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFollowing ? '팔로우 취소에 실패했어요.' : '팔로우에 실패했어요.',
            ),
          ),
        );
        return;
      }

      await fetchProfile();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('팔로우 상태 변경 중 오류가 발생했어요. $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isFollowSubmitting = false;
        });
      }
    }
  }

  //   {
  int getSelectedIndexFromRoute(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;

    switch (routeName) {
      case '/main':
        return 0;
      case '/write':
        return 1;
      case '/community':
        return 2;
      case '/chat':
        return 3;
      case '/mypage':
        return 4;
      default:
        return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xff0b0b0d);
    const panelColor = Color(0xff17171b);
    const lime = Color(0xffd7ff00);
    const dividerColor = Color(0xff3a3a3f);
    final nickname = body['nickname']?.toString() ?? '아키바님';
    final isFollowing = body['isFollowing'] == true;

    return AkibaShell(
      selectedIndex: _isMyProfile ? getSelectedIndexFromRoute(context) : 0,
      backgroundColor: bgColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileStage(
              nickname: nickname,
              trustText: '신뢰도 ${body["mannerScore"]}%',
            ),

            const SizedBox(height: 18),

            if (!_isMyProfile) ...[
              _FollowButton(
                isFollowing: isFollowing,
                isLoading: _isFollowSubmitting,
                onPressed: _toggleFollow,
              ),
              const SizedBox(height: 18),
            ],

            Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: panelColor,
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      title: '거래완료',
                      value: "${body['completedDealCount'] ?? 0}건",
                      showRightBorder: true,
                    ),
                  ),
                  Expanded(
                    child: _StatItem(
                      title: '진행 중',
                      value: '${body['ongoingDealCount']}건',
                      showRightBorder: true,
                    ),
                  ),
                  Expanded(
                    child: _StatItem(
                      title: '팔로워',
                      value: '${body['followerCount']}명',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            const _SectionTitle(title: '판매', color: lime),
            const SizedBox(height: 18),
            const _MenuItem(title: '등록한 상품'),
            const SizedBox(height: 28),
            const _MenuItem(title: '판매 완료'),

            const SizedBox(height: 26),
            Container(height: 1, color: dividerColor),
            const SizedBox(height: 26),

            const _SectionTitle(title: '구해요', color: lime),
            const SizedBox(height: 18),
            const _MenuItem(title: '내가 올린 구해요'),
            const SizedBox(height: 28),
            const _MenuItem(title: '매칭된 제안', trailing: _PurpleDot()),

            const SizedBox(height: 26),
            Container(height: 1, color: dividerColor),
            const SizedBox(height: 26),

            const _SectionTitle(title: '경매', color: lime),
            const SizedBox(height: 18),
            _MenuItem(
              title: '입찰 중',
              trailing: _CountBadge(count: '${body["ongoingDealCount"]}건'),
            ),
            const SizedBox(height: 28),
            const _MenuItem(title: '낙찰 성공', trailing: _PurpleDot()),
            const SizedBox(height: 28),
            const _MenuItem(title: '내 경매 현황'),

            if (_isMyProfile) ...[
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _logout,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xff3a3a3f)),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '로그아웃',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({
    required this.isFollowing,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isFollowing;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowing
              ? const Color(0xff242428)
              : const Color(0xffd7ff00),
          disabledBackgroundColor: const Color(0xff242428),
          foregroundColor: isFollowing ? Colors.white : Colors.black,
          disabledForegroundColor: const Color(0xff8d8d94),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xffd7ff00),
                ),
              )
            : Text(
                isFollowing ? '팔로우취소' : '팔로우',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final bool showRightBorder;

  const _StatItem({
    required this.title,
    required this.value,
    this.showRightBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    const textPrimary = Colors.white;
    const dividerColor = Color(0xff3a3a3f);

    return Container(
      decoration: BoxDecoration(
        border: showRightBorder
            ? const Border(right: BorderSide(color: dividerColor, width: 1))
            : null,
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            value,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStage extends StatelessWidget {
  const _ProfileStage({required this.nickname, required this.trustText});

  final String nickname;
  final String trustText;

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xff8a2be2);

    return LayoutBuilder(
      builder: (context, constraints) {
        final stageWidth = constraints.maxWidth.clamp(320.0, 664.0).toDouble();
        final stageHeight = (stageWidth * 0.84).clamp(330.0, 500.0);
        final ellipseWidth = stageWidth;
        final ellipseHeight = ellipseWidth * 55 / 664;
        final characterSize = (stageWidth * 0.62).clamp(210.0, 360.0);
        final ellipseBottom = stageHeight * 0.12;
        final characterBottom = ellipseBottom + ellipseHeight * 0.1;

        return SizedBox(
          height: stageHeight,
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 0,
                child: Container(
                  width: stageWidth,
                  height: stageHeight,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xff202020),
                        Color(0xff171719),
                        Color(0xff0b0b0d),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 24,
                child: Column(
                  children: [
                    Text(
                      nickname,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: purple,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        trustText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: ellipseBottom,
                child: Transform.rotate(
                  angle: -0.018,
                  child: Container(
                    width: ellipseWidth,
                    height: ellipseHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xffd7ff00), Color(0xff94c400)],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xaad7ff00),
                          blurRadius: 14,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: characterBottom,
                child: _ProfileCharacter(size: characterSize),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileCharacter extends StatelessWidget {
  const _ProfileCharacter({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/myPageCharacter.gif',
      width: size,
      height: size,
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _MenuItem({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}

class _PurpleDot extends StatelessWidget {
  const _PurpleDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xff8a2be2),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final String count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xff2a2a2f),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        count,
        style: const TextStyle(
          color: Color(0xffb0b0b7),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
