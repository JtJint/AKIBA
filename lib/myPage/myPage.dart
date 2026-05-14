import 'dart:convert';
import 'dart:html' as html;

import 'package:akiba/Login/api/userApi.dart';
import 'package:akiba/myPage/mypage.api.dart';
import 'package:akiba/widgets/akiba_shell.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  Response rt = Response('', 200);
  dynamic body = {
    "userId": 0,
    "nickname": "사용자",
    "bio": null,
    "profileImageUrl": null,
    "mannerScore": 0,
    "ongoingDealCount": 0,
    "followerCount": 0,
    "followingCount": 0,
    "isFollowing": false,
  };
  @override
  initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final response = await myPageAPI.getProfile();
      setState(() {
        rt = response;
        body = jsonDecode(rt.body);
      });
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  Future<void> _logout() async {
    await Loginapi.logout();

    if (!mounted) return;

    html.window.history.replaceState(null, '', '/login');
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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
    final profileImageUrl = body['profileImageUrl']?.toString();

    return AkibaShell(
      selectedIndex: getSelectedIndexFromRoute(context),
      backgroundColor: bgColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileStage(
              nickname: nickname,
              trustText: '신뢰도 ${body["mannerScore"]}%',
              characterImageUrl:
                  profileImageUrl != null && profileImageUrl.isNotEmpty
                  ? profileImageUrl
                  : null,
            ),

            const SizedBox(height: 18),

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
            const SizedBox(height: 16),
          ],
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
  const _ProfileStage({
    required this.nickname,
    required this.trustText,
    this.characterImageUrl,
  });

  final String nickname;
  final String trustText;
  final String? characterImageUrl;

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xff8a2be2);

    return SizedBox(
      height: 405,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 66,
            child: Container(
              width: 455,
              height: 320,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.86,
                  colors: [
                    Color(0xff242426),
                    Color(0xff171719),
                    Color(0xff0b0b0d),
                  ],
                  stops: [0.0, 0.58, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 26,
            child: Container(
              width: 300,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(120),
                gradient: const RadialGradient(
                  colors: [
                    Color(0xffd7ff00),
                    Color(0xff6f8d00),
                    Color(0x000b0b0d),
                  ],
                  stops: [0.0, 0.36, 1.0],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x77d7ff00),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 78,
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
            top: 176,
            child: SizedBox(
              width: 220,
              height: 172,
              child: characterImageUrl == null
                  ? const _CharacterPlaceholder()
                  : Image.network(
                      characterImageUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const _CharacterPlaceholder(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterPlaceholder extends StatelessWidget {
  const _CharacterPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Image.asset('assets/myPageChar.png', fit: BoxFit.fitHeight),
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
