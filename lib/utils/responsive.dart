import 'package:flutter/material.dart';

/// 화면 비율에 따라 자동으로 기준점을 전환하는 반응형 유틸리티
///
/// - **가로가 넓을 때(랜드스케이프)**: 세로(height)를 기준으로 스케일링
/// - **세로가 길 때(포트레이트)**: 가로(width)를 기준으로 스케일링
///
/// 즉, 항상 **짧은 쪽**을 기준으로 사용하여 웹/다양한 화면에서 일관된 비율 유지
class Responsive {
  Responsive._();

  /// 최소 ref 값 (폰 등 작은 화면에서 글씨/요소가 너무 작아지는 것 방지)
  static const double refMin = 500;

  /// 화면의 기준 치수 (짧은 쪽)
  /// - 포트레이트: width
  /// - 랜드스케이프: height
  /// - refMin 미만일 경우 refMin 사용 (가독성 보장)
  static double ref(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final value = size.width < size.height ? size.width : size.height;
    return value < refMin ? refMin : value;
  }

  /// 화면 너비 (전체 너비가 필요한 경우)
  static double w(BuildContext context) => MediaQuery.of(context).size.width;

  /// 화면 높이 (전체 높이가 필요한 경우)
  static double h(BuildContext context) => MediaQuery.of(context).size.height;

  /// 캐러셀/리스트 아이템 간격 (반응형 + 최대값 제한)
  /// 큰 화면에서 과도하게 넓어지지 않도록 cap 적용
  static double carouselGap(BuildContext context) {
    final value = ref(context) * 0.021;
    return value.clamp(6.0, 14.0); // 최소 6px, 최대 14px
  }

  /// 캐러셀 높이 (모바일에서 세로로 과도하게 길어지는 것 방지)
  /// 화면 높이의 22%를 초과하지 않도록 제한
  static double carouselHeight(BuildContext context) {
    final desired = ref(context) * 0.35;
    final maxByScreen = h(context) * 0.22;
    return desired.clamp(120, maxByScreen); // 최소 120px로 카드가 잘리지 않도록
  }
}
