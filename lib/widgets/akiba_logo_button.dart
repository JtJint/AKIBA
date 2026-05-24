import 'package:akiba/Logo/logo.dart';
import 'package:akiba/app_router.dart';
import 'package:flutter/material.dart';

/// AKIBA 로고 — 탭 시 홈(/main)으로 이동
class AkibaLogoButton extends StatelessWidget {
  const AkibaLogoButton({
    super.key,
    this.width = 0.18,
    this.height = 0.05,
  });

  final double width;
  final double height;

  void _goHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRouter.main);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _goHome(context),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: logo(width: width, height: height),
      ),
    );
  }
}
