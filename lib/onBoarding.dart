import 'package:akiba/Logo/logo.dart';
import 'package:akiba/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  // 1. 처음에는 투명하게(0.0) 설정
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // 2. 화면이 시작되면 애니메이션과 페이지 이동 로직 실행
    _startAnimationAndNavigate();
  }

  Future<void> _startAnimationAndNavigate() async {
    // 약간의 딜레이를 주어 화면이 그려진 직후 애니메이션 시작 (선택 사항)
    await Future.delayed(const Duration(milliseconds: 100));

    // 3. 투명도를 1.0으로 변경 -> AnimatedOpacity가 이를 감지하고 페이드인 효과 발생
    setState(() {
      _opacity = 1.0;
    });

    // 4. 애니메이션 시간(1500ms) + 대기 시간(예: 1000ms) 만큼 기다림
    await Future.delayed(const Duration(milliseconds: 2500));

    // 5. 홈 화면으로 이동 (Mount check: 위젯이 여전히 화면에 있는지 확인)
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Color(0xff141414),
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark, // ios
          ),
        ),
        backgroundColor: const Color(0xff141414),
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.3, // 크기 조금 키움 (취향껏 조절)
            child: AnimatedOpacity(
              // 6. 상태 변수 _opacity에 따라 애니메이션 자동 적용
              opacity: _opacity,
              duration: const Duration(milliseconds: 1500), // 페이드인 되는 시간
              curve: Curves.easeIn, // 부드러운 가속도 곡선
              child: logo(width: 0.3, height: 0.1),
            ),
          ),
        ),
      ),
    );
  }
}
