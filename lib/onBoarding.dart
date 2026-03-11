import 'package:akiba/Logo/logo.dart';
import 'package:akiba/home.dart';
import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  double _logoOpacity = 0.0;
  double _logoTopFactor = 0.38; // 처음엔 중앙쯤
  double _loginOpacity = 0.0;
  double _loginOffsetY = 30.0; // 아래에서 올라오게

  @override
  void initState() {
    super.initState();
    _startSequence();
  }

  Future<void> _startSequence() async {
    // 1) 로고 페이드 인
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    setState(() {
      _logoOpacity = 1.0;
    });

    // 로고가 충분히 보일 때까지 대기
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    // 2) 로고를 위로 이동
    setState(() {
      _logoTopFactor = 0.20;
    });

    // 로고 이동 후
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    // 3) 로그인 영역 등장
    setState(() {
      _loginOpacity = 1.0;
      _loginOffsetY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xff141414),
      body: SafeArea(
        child: Stack(
          children: [
            // 로고
            AnimatedPositioned(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeInOut,
              top: size.height * _logoTopFactor,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _logoOpacity,
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeIn,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      logo(width: 0.35, height: 0.12),
                      const SizedBox(height: 12),
                      const Text(
                        '뭐시기 슬로건',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 로그인 영역
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 48,
                ),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: _loginOpacity,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    transform: Matrix4.translationValues(0, _loginOffsetY, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return HomeScreen();
                                  },
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff03C75A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              '네이버 계정으로 시작하기',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
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
