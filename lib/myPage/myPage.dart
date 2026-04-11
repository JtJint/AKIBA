import 'dart:convert';
import 'dart:ui' as html;

import 'package:akiba/models/sideBar.dart';
import 'package:akiba/myPage/mypage.api.dart';
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

  void _handleSidebarTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/main');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/write');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/community');
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/chat');
        break;
      case 4:
        Navigator.of(context).pushReplacementNamed('/mypage');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xff0b0b0d);
    const panelColor = Color(0xff17171b);
    const lime = Color(0xffd7ff00);
    const purple = Color(0xff8a2be2);
    const textPrimary = Colors.white;
    const dividerColor = Color(0xff3a3a3f);

    final isMobile = MediaQuery.of(context).size.width <= 440;
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(360.0, 800.0);
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: contentWidth,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMobile) ...[
                  LeftSidebar(
                    selectedIndex: getSelectedIndexFromRoute(context),
                    onTap: (index) => _handleSidebarTap(context, index),
                  ),
                  const SizedBox(width: 24),
                ],
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: lime, width: 1.2),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xff2a2a2f),
                                      Color(0xff1a1a1f),
                                    ],
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'akiba',
                                    style: TextStyle(
                                      color: Color(0xff6f6f76),
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      fontStyle: FontStyle.italic,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                body['nickname'],
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: purple,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '신뢰도 ${body["mannerScore"]}%',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

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
                                  title: '진행 중',
                                  value: "${body['ongoingDealCount']}건",
                                  showRightBorder: true,
                                ),
                              ),
                              Expanded(
                                child: _StatItem(
                                  title: '찜한 목록',
                                  value: '${body['followingCount']}건',
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
                        const _MenuItem(
                          title: '매칭된 제안',
                          trailing: _PurpleDot(),
                        ),

                        const SizedBox(height: 26),
                        Container(height: 1, color: dividerColor),
                        const SizedBox(height: 26),

                        const _SectionTitle(title: '경매', color: lime),
                        const SizedBox(height: 18),
                        _MenuItem(
                          title: '입찰 중',
                          trailing: _CountBadge(
                            count: '${body["ongoingDealCount"]}건',
                          ),
                        ),
                        const SizedBox(height: 28),
                        const _MenuItem(title: '낙찰 성공', trailing: _PurpleDot()),
                        const SizedBox(height: 28),
                        const _MenuItem(title: '내 경매 현황'),

                        const SizedBox(height: 40),
                      ],
                    ),
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

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w800),
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
