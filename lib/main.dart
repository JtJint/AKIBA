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
import 'dart:html' as html;

import 'package:akiba/app_router.dart';
import 'package:akiba/chat/api/chatApi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  usePathUrlStrategy();
  ChatService.instance.registerLifecycleHandlers();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ChatService.instance.disconnect();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      ChatService.instance.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAccessToken =
        (html.window.localStorage['accessToken'] ?? '').isNotEmpty;
    final initialPath = hasAccessToken ? AppRouter.main : AppRouter.onboarding;

    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xff000000),
        primaryColor: const Color(0xff141414),
        fontFamily: 'Pretendard-Light',
      ),
      scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      initialRoute: initialPath,
      onGenerateRoute: AppRouter.onGenerateRoute,
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
