import 'package:akiba/Login/URL.dart';
import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        print('Login button pressed');
        try {
          final r = startNaverLogin();
          // ✅ 여기서 code/state를 백엔드로 보내서 토큰 교환해야 함(Secret은 백엔드!)
          // debugPrint('NAVER code=${r.code} state=${r.state}');
        } catch (e) {
          debugPrint('Login failed: $e');
        }
      },
      child: const Text('네이버로 로그인'),
    );
  }
}
