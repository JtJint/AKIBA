// import 'package:akiba/Login/URL.dart';
// import 'package:akiba/dummyPage.dart';
// import 'package:akiba/onBoarding.dart'; // 파일명 확인 (onBoarding.dart vs onboarding.dart)
// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Scaffold 대신 MaterialApp을 최상위에 둡니다.
//     return MaterialApp(
//       routes: {
//         '/oauth/callback': (_) => const NaverCallbackPage(),
//         '/login': (_) => Dummypage(),
//         '/': (_) => Dummypage(),
//       },
//       themeMode: ThemeMode.dark,
//       debugShowCheckedModeBanner: false, // 오른쪽 위 'Debug' 띠 제거 (선택사항)
//       title: 'Akiba',
//       theme: ThemeData(
//         scaffoldBackgroundColor: Color(0xff141414),
//         primaryColor: Color(0xff141414),
//       ),
//       // home: const OnboardingPage(), // 여기에 OnboardingPage를 연결합니다.
//       // home: Dummypage(),
//       // home: HomeScreen(),
//     );
//   }
// }

import 'dart:ui';

import 'package:akiba/Login/URL.dart';
import 'package:akiba/Logo/nickName.dart';
import 'package:akiba/community/communityMain.dart';
import 'package:akiba/dummyPage.dart';
import 'package:akiba/home.dart';
import 'package:akiba/Logo/onBoarding.dart';
import 'package:akiba/myPage/myPage.dart';
import 'package:akiba/wirte/write_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xff000000),
        primaryColor: const Color(0xff141414),
        fontFamily: 'Pretendard-Light',
      ),
      scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '/');

        // ✅ 여기서 /oauth/callback 라우팅
        if (uri.path == '/oauth/callback') {
          return MaterialPageRoute(
            builder: (_) => const NaverCallbackPage(),
            settings: settings,
          );
        }

        if (uri.path == '/nickname') {
          return MaterialPageRoute(builder: (_) => inputNickNamePage());
        }
        if (uri.path == '/main') {
          return MaterialPageRoute(
            builder: (_) => HomeScreen(),
            settings: settings,
          );
        }
        if (uri.path == '/write') {
          return MaterialPageRoute(
            builder: (_) => WritePage(),
            settings: settings,
          );
        }
        if (uri.path == '/community') {
          return MaterialPageRoute(
            builder: (_) => communityMain(),
            settings: settings,
          );
        }
        if (uri.path == '/mypage') {
          return MaterialPageRoute(
            builder: (_) => Mypage(),
            settings: settings,
          );
        }
        // 기본
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      },
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}
