import 'dart:html' as html;
import 'dart:math';
import 'package:akiba/dummyPage.dart';
import 'package:akiba/onBoarding.dart';
import 'package:flutter/material.dart';

String randomState([int len = 16]) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final r = Random.secure();
  return List.generate(len, (_) => chars[r.nextInt(chars.length)]).join();
}

void startNaverLogin() {
  final state = randomState();
  html.window.sessionStorage['naver_state'] = state;

  const clientId = 'ZfdrzEhizfq8bi0KaKTQ';
  const redirectUri = 'http://localhost:3000/oauth/callback';

  final authUrl = Uri.https('nid.naver.com', '/oauth2.0/authorize', {
    'response_type': 'code',
    'client_id': clientId,
    'redirect_uri': redirectUri,
    'state': state,
  }).toString();

  // 같은 탭 이동(리다이렉트)
  html.window.location.href = authUrl;
}

class NaverCallbackPage extends StatefulWidget {
  const NaverCallbackPage({super.key});

  @override
  State<NaverCallbackPage> createState() => _NaverCallbackPageState();
}

class _NaverCallbackPageState extends State<NaverCallbackPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final uri = Uri.base;
      final code = uri.queryParameters['code'];
      final state = uri.queryParameters['state'];
      final error = uri.queryParameters['error'];

      if (error != null) {
        // 실패 처리
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      if (code == null || state == null) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      // CSRF 방지 state 검증 (웹은 sessionStorage가 편함)
      final expected = html.window.sessionStorage['naver_state'];
      if (expected == null || expected != state) {
        // state mismatch
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      // TODO: code를 백엔드로 보내서 토큰 교환 (client_secret은 백엔드!)
      print('NAVER code=$code state=$state');
      // await api.loginWithNaver(code: code, state: state);

      // 임시: 성공 처리로 홈 이동
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => OnboardingPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('네이버 로그인 처리중...')));
  }
}

// http://localhost:3000/oauth/callback?code=yWjLsd9HeCKJtnlQx4&state=kdss2r7rmkiqa2rd
