import 'package:flutter/material.dart';

class Responsive {
  Responsive._();

  static const double refMin = 360; // 모바일 폭 기준
  static const double refMax = 900; // 웹에서 과대 확대 방지

  static double ref(BuildContext context) {
    final shortSide = MediaQuery.of(context).size.shortestSide;
    return shortSide.clamp(refMin, refMax);
  }

  static double w(BuildContext context) => MediaQuery.of(context).size.width;
  static double h(BuildContext context) => MediaQuery.of(context).size.height;

  static double carouselGap(BuildContext context) {
    final value = ref(context) * 0.021;
    return value.clamp(6.0, 14.0);
  }

  static double carouselHeight(BuildContext context) {
    final desired = ref(context) * 0.30;
    final maxByScreen = (h(context) * 0.28).clamp(180.0, 320.0);
    return desired.clamp(160.0, maxByScreen);
  }
}
