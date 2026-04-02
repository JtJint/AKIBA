import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';
import 'package:akiba/Login/api/userApi.dart';
import 'package:akiba/Logo/nickName.dart';
import 'package:akiba/dummyPage.dart';
import 'package:akiba/Logo/onBoarding.dart';
import 'package:akiba/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String randomState([int len = 16]) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final r = Random.secure();
  return List.generate(len, (_) => chars[r.nextInt(chars.length)]).join();
}

void startNaverLogin() {
  final state = randomState();
  html.window.sessionStorage['naver_state'] = state;

  // const clientId = 'ZfdrzEhizfq8bi0KaKTQ';
  const clientId = 'quwp3RTYyaTzBPWUj59t';
  // const redirectUri = 'http://localhost:8000/oauth/callback';
  const redirectUri =
      'https://akiba-bay.vercel.app/oauth/callback'; //배포용 redirect URI

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
      try {
        final uri = Uri.base;
        // print(uri.toString());
        final code = uri.queryParameters['code'];
        final state = uri.queryParameters['state'];
        final error = uri.queryParameters['error'];

        print('code: $code');
        print('state: $state');
        print('error: $error');

        // if (error != null) {
        //   Navigator.of(context).pushReplacementNamed('/login');
        //   return;
        // }

        // if (code == null || state == null) {
        //   Navigator.of(context).pushReplacementNamed('/login');
        //   return;
        // }

        // final expected = html.window.sessionStorage['naver_state'];
        // if (expected == null || expected != state) {
        //   Navigator.of(context).pushReplacementNamed('/login');
        //   return;
        // }

        // html.window.sessionStorage.remove('naver_state');

        // final rt = await Loginapi.loginAct(code, state);
        // print('statusCode: ${rt.statusCode}');
        // print('body: ${rt.body}');

        // if (rt.statusCode != 200) {
        //   Navigator.of(context).pushReplacementNamed('/login');
        //   return;
        // }

        // final decodingRt = jsonDecode(rt.body);

        // final isNewUser = decodingRt['isNewUser'];

        // if (isNewUser == true) {
        //   html.window.history.replaceState(
        //     html.window.history.state,
        //     '',
        //     '/nickname',
        //   );
        //   Navigator.of(context).pushReplacementNamed('/nickname');
        // } else if (isNewUser == false) {
        //   html.window.history.replaceState(
        //     html.window.history.state,
        //     '',
        //     '/main',
        //   );
        //   Navigator.of(
        //     context,
        //   ).pushNamedAndRemoveUntil('/main', (route) => false);
        // } else {
        //   html.window.history.replaceState(null, '', '/login');
        //   Navigator.of(context).pushReplacementNamed('/login');
        // }
      } catch (e, st) {
        print('callback error: $e');
        print(st);
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('네이버 로그인 처리중...')));
  }
}
