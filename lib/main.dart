import 'package:akiba/home.dart';
import 'package:akiba/onBoarding.dart'; // 파일명 확인 (onBoarding.dart vs onboarding.dart)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 상태바 투명하게
      statusBarIconBrightness: Brightness.light, // 상태바 아이콘 밝기 설정
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold 대신 MaterialApp을 최상위에 둡니다.
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 오른쪽 위 'Debug' 띠 제거 (선택사항)
      title: 'Akiba',
      theme: ThemeData(primaryColor: Color(0xff141414)),
      home: const OnboardingPage(), // 여기에 OnboardingPage를 연결합니다.
      // home: HomeScreen(),
    );
  }
}
